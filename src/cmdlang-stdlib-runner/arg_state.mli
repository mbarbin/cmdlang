(*_********************************************************************************)
(*_  cmdlang - Declarative command-line parsing for OCaml                         *)
(*_  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Internal representation for cmdlang arg expressions used during parsing.

    This is a projection of [Cmdlang.Ast.Arg.t] where we added mutable variables
    to collect and store the intermediate results of parsing the command line
    arguments during the parsing phase of the execution.

    To give a concrete example, let's look at the [Flag] construct. In the ast,
    the type is:

    {[
      | Flag :
           { names : string Ast.Nonempty_list.t
           ; doc : string
           }
           -> bool t
    ]}

    Note how, in this intermediate representation we added a new mutable field
    as a place to collect and store the value for that flag: [var : bool ref]:

    {[
      | Flag :
           { names : string Ast.Nonempty_list.t
           ; doc : string
           ; var : bool ref (* <== Added mutable field *)
           }
           -> bool t
    ]}

    This [var] is where the parsing engine will store the value read from the
    command line. Then the rest of the execution chain will be able to read the
    value from there while going through this runtime ast for evaluation, after
    the parsing is complete. *)

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
      { names : string Ast.Nonempty_list.t
      ; doc : string
      ; var : bool ref
      }
      -> bool t
  | Flag_count :
      { names : string Ast.Nonempty_list.t
      ; doc : string
      ; var : int ref
      }
      -> int t
  | Named :
      { names : string Ast.Nonempty_list.t
      ; param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a t
  | Named_multi :
      { names : string Ast.Nonempty_list.t
      ; param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; rev_var : 'a list ref
      }
      -> 'a list t
  | Named_opt :
      { names : string Ast.Nonempty_list.t
      ; param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a option t
  | Named_with_default :
      { names : string Ast.Nonempty_list.t
      ; param : 'a Ast.Param.t
      ; default : 'a
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a t
  | Pos :
      { pos : int
      ; param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a t
  | Pos_opt :
      { pos : int
      ; param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a option t
  | Pos_with_default :
      { pos : int
      ; param : 'a Ast.Param.t
      ; default : 'a
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a t
  | Pos_all :
      { param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; rev_var : 'a list ref
      }
      -> 'a list t

(** Recursively allocate an arg state for all arguments contained in a parser. *)
val create : 'a Ast.Arg.t -> 'a t

(** {1 Finalization}

    This part of the interface deals with finalizing the state and returning an
    expression suitable for execution.

    It must be called last, once all the parsing and mutating is done. *)

module Parse_error : sig
  type t =
    | Missing_argument :
        { names : string Ast.Nonempty_list.t
        ; param : 'a Ast.Param.t
        ; docv : string option
        ; doc : string
        }
        -> t
    | Missing_positional_argument :
        { pos : int
        ; param : 'a Ast.Param.t
        ; docv : string option
        ; doc : string
        }
        -> t
end

(** The idea with [finalize] is to split the execution into 2 isolated parts :
    the part where the command line is parsed, and the part where user code is
    actually ran. *)
val finalize : 'a t -> ('a Arg_runner.t, Parse_error.t) Result.t
