(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

type 'a or_error_msg = ('a, [ `Msg of string ]) result
type 'a of_string = string -> 'a or_error_msg
type 'a to_string = 'a -> string

module Nonempty_list = struct
  type 'a t = ( :: ) : 'a * 'a list -> 'a t
end

module Param = struct
  type 'a t =
    | Conv :
        { docv : string option
        ; of_string : 'a of_string
        ; to_string : 'a to_string
        }
        -> 'a t
    | String : string t
    | Int : int t
    | Float : float t
    | Bool : bool t
    | File : string t
    | Enum :
        { docv : string option
        ; choices : (string * 'a) Nonempty_list.t
        ; to_string : 'a -> string
        }
        -> 'a t
    | Comma_separated : 'a t -> 'a list t
end

module Arg = struct
  type 'a t =
    | Return : 'a -> 'a t
    | Map :
        { x : 'a t
        ; f : 'a -> 'b
        }
        -> 'b t
    | Both : 'a t * 'b t -> ('a * 'b) t
    | Apply :
        { f : ('a -> 'b) t
        ; x : 'a t
        }
        -> 'b t
    | Flag :
        { names : string Nonempty_list.t
        ; doc : string
        }
        -> bool t
    | Flag_count :
        { names : string Nonempty_list.t
        ; doc : string
        }
        -> int t
    | Named :
        { names : string Nonempty_list.t
        ; param : 'a Param.t
        ; docv : string option
        ; doc : string
        }
        -> 'a t
    | Named_multi :
        { names : string Nonempty_list.t
        ; param : 'a Param.t
        ; docv : string option
        ; doc : string
        }
        -> 'a list t
    | Named_opt :
        { names : string Nonempty_list.t
        ; param : 'a Param.t
        ; docv : string option
        ; doc : string
        }
        -> 'a option t
    | Named_with_default :
        { names : string Nonempty_list.t
        ; param : 'a Param.t
        ; default : 'a
        ; docv : string option
        ; doc : string
        }
        -> 'a t
    | Pos :
        { pos : int
        ; param : 'a Param.t
        ; docv : string option
        ; doc : string
        }
        -> 'a t
    | Pos_opt :
        { pos : int
        ; param : 'a Param.t
        ; docv : string option
        ; doc : string
        }
        -> 'a option t
    | Pos_with_default :
        { pos : int
        ; param : 'a Param.t
        ; default : 'a
        ; docv : string option
        ; doc : string
        }
        -> 'a t
    | Pos_all :
        { param : 'a Param.t
        ; docv : string option
        ; doc : string
        }
        -> 'a list t
end

module Command = struct
  type 'a t =
    | Make :
        { arg : 'a Arg.t
        ; summary : string
        ; readme : (unit -> string) option
        }
        -> 'a t
    | Group :
        { default : 'a Arg.t option
        ; summary : string
        ; readme : (unit -> string) option
        ; subcommands : (string * 'a t) list
        }
        -> 'a t

  let summary = function
    | Make { summary; _ } -> summary
    | Group { summary; _ } -> summary
  ;;

  let rec map : type a b. a t -> f:(a -> b) -> b t =
    fun a ~f ->
    match a with
    | Make { arg; summary; readme } ->
      Make { arg = Arg.Map { x = arg; f }; summary; readme }
    | Group { default; summary; readme; subcommands } ->
      Group
        { default = default |> Option.map (fun arg -> Arg.Map { x = arg; f })
        ; summary
        ; readme
        ; subcommands = subcommands |> List.map (fun (name, arg) -> name, map arg ~f)
        }
  ;;
end
