(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Nonempty_list = struct
  type 'a t = 'a Cmdlang_ast.Ast.Nonempty_list.t = ( :: ) : 'a * 'a list -> 'a t
end

module type Enumerated_stringable = sig
  type t

  val all : t list
  val to_string : t -> string
end

module type Stringable = sig
  type t

  val of_string : string -> t
  val to_string : t -> string
end

module type Validated_string = sig
  type t

  val of_string : string -> (t, [ `Msg of string ]) Result.t
  val to_string : t -> string
end

module Param = struct
  type 'a t = 'a Ast.Param.t

  let create' ~docv ~of_string ~to_string () =
    Ast.Param.Conv { docv = Some docv; of_string; to_string }
  ;;

  let create_with_pp ~docv ~parse ~pp () =
    let to_string a = Format.asprintf "%a" pp a in
    Ast.Param.Conv { docv = Some docv; of_string = parse; to_string }
  ;;

  let create ~docv ~parse ~print =
    create_with_pp ~docv ~parse ~pp:print () [@coverage off]
  ;;

  let string = Ast.Param.String
  let int = Ast.Param.Int
  let float = Ast.Param.Float
  let bool = Ast.Param.Bool
  let file = Ast.Param.File

  let enumerated (type a) ?docv (module M : Enumerated_stringable with type t = a) =
    match M.all |> List.map (fun m -> M.to_string m, m) with
    | [] -> invalid_arg "Command.Param.enumerated"
    | hd :: tl -> Ast.Param.Enum { docv; choices = hd :: tl; to_string = M.to_string }
  ;;

  let stringable (type a) ?docv (module M : Stringable with type t = a) =
    let of_string s = Ok (M.of_string s) in
    Ast.Param.Conv { docv; of_string; to_string = M.to_string }
  ;;

  let validated_string (type a) ?docv (module M : Validated_string with type t = a) =
    Ast.Param.Conv { docv; of_string = M.of_string; to_string = M.to_string }
  ;;

  let comma_separated t = Ast.Param.Comma_separated t
end

module Arg = struct
  type 'a t = 'a Ast.Arg.t

  let return x = Ast.Arg.Return x
  let map x ~f = Ast.Arg.Map { x; f }
  let both a b = Ast.Arg.Both (a, b)
  let ( >>| ) x f = map x ~f
  let apply f x = Ast.Arg.Apply { f; x }
  let ( let+ ) = ( >>| )
  let ( and+ ) = both
  let flag names ~doc = Ast.Arg.Flag { names; doc }
  let flag_count names ~doc = Ast.Arg.Flag_count { names; doc }
  let named ?docv names param ~doc = Ast.Arg.Named { names; param; docv; doc }
  let named_multi ?docv names param ~doc = Ast.Arg.Named_multi { names; param; docv; doc }
  let named_opt ?docv names param ~doc = Ast.Arg.Named_opt { names; param; docv; doc }

  let named_with_default ?docv names param ~default ~doc =
    Ast.Arg.Named_with_default { names; param; default; docv; doc }
  ;;

  let pos ?docv ~pos param ~doc = Ast.Arg.Pos { pos; param; docv; doc }
  let pos_opt ?docv ~pos param ~doc = Ast.Arg.Pos_opt { pos; param; docv; doc }

  let pos_with_default ?docv ~pos param ~default ~doc =
    Ast.Arg.Pos_with_default { pos; param; default; docv; doc }
  ;;

  let pos_all ?docv param ~doc = Ast.Arg.Pos_all { param; docv; doc }
end

type 'a t = 'a Ast.Command.t

let make ?readme arg ~summary = Ast.Command.Make { arg; summary; readme }

let group ?default ?readme ~summary subcommands =
  Ast.Command.Group { default; summary; readme; subcommands }
;;

module Utils = struct
  let summary = Ast.Command.summary
  let map = Ast.Command.map
end

module type Applicative_infix = sig
  type 'a t

  val ( >>| ) : 'a t -> ('a -> 'b) -> 'b t
end

module Applicative_infix : Applicative_infix with type 'a t := 'a Arg.t = struct
  open Arg

  let ( >>| ) = ( >>| )
end

module type Applicative_syntax = sig
  type 'a t

  val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
  val ( and+ ) : 'a t -> 'b t -> ('a * 'b) t
end

module Applicative_syntax : Applicative_syntax with type 'a t := 'a Arg.t = struct
  open Arg

  let ( let+ ) = ( let+ )
  let ( and+ ) = ( and+ )
end

module Std = struct
  module Arg = Arg
  module Param = Param
  include Applicative_syntax
  include Applicative_infix
end

module Let_syntax = struct
  open Arg

  let return = return

  include Applicative_infix

  module Let_syntax = struct
    let return = return
    let map = map
    let both = both

    module Open_on_rhs = struct
      module Arg = Arg
      module Param = Param
      include Applicative_infix
    end
  end
end

module Private = struct
  module To_ast = struct
    let arg : 'a Arg.t -> 'a Ast.Arg.t = Fun.id
    let param : 'a Param.t -> 'a Ast.Param.t = Fun.id
    let command : 'a t -> 'a Ast.Command.t = Fun.id
  end
end
