(*_********************************************************************************)
(*_  cmdlang - Declarative command-line parsing for OCaml                         *)
(*_  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** A mutable state that will collect parsing information for positional
    arguments.

    This state is compiled from the AST representation of the command line and
    is used to collect and store the values of positional arguments during the
    calls to [Arg.anon_fun]. *)

module One_pos : sig
  type 'a t =
    { pos : int
    ; param : 'a Ast.Param.t
    ; docv : string option
    ; doc : string
    ; var : 'a option ref
    }

  type packed = T : 'a t -> packed [@@unboxed]
end

module Pos_all : sig
  type 'a t =
    { param : 'a Ast.Param.t
    ; docv : string option
    ; doc : string
    ; rev_var : 'a list ref
    }

  type packed = T : 'a t -> packed [@@unboxed]
end

type t =
  { pos : One_pos.packed array
  ; pos_all : Pos_all.packed option
  ; mutable current_pos : int
  }

val make : pos:One_pos.packed list -> pos_all:Pos_all.packed option -> t Ast.or_error_msg

(** Update the positional state based on the parsing of the next positional
    argument in the command line.*)
val anon_fun : t -> Arg.anon_fun

(** {1 Usage and help documentation}

    This section is dedicated to create contents to display for [--help]
    messages, such as in:

    {[
      Usage: my_command [OPTIONS] [ARGUMENTS]

      ARGUMENTS:
        <arg>  description of arg1
        <arg>  description of arg2
    ]} *)

(** Return [None] if no positional arguments are expected. *)
val usage_msg : t -> string option
