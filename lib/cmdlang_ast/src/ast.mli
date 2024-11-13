(** The internal representation for the EDSL used by the cmdlang library.

    Cmdlang doesn't include an execution engine. Instead, Cmdlang parsers are
    automatically translated to `cmdliner`, `core.command`, or `climate`
    commands for execution.

    When you use the cmdlang library to define a command-line interface, you are
    effectively building a value of type [Cmdlang_ast.Ast.Command.t]. It is then
    converted internally to the targeted backend.

    This module is not meant to be used directly by users of the library.
    Rather, users use the [Cmdlang.Command] interface which provides a
    high-level API meant to be ergonomic and user-friendly.

    [Cmdlang_ast] is exposed to allow extending the library with new backends or
    to write analysis tools, etc. *)

type 'a or_error_msg = ('a, [ `Msg of string ]) result
type 'a parse := string -> 'a or_error_msg
type 'a print := Format.formatter -> 'a -> unit

module Nonempty_list : sig
  type 'a t = ( :: ) : 'a * 'a list -> 'a t
end

module Param : sig
  type 'a t =
    | Conv :
        { docv : string option
        ; parse : 'a parse
        ; print : 'a print
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

module Arg : sig
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

module Command : sig
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

  val summary : _ t -> string
end
