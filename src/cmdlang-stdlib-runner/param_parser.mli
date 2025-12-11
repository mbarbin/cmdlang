(*_********************************************************************************)
(*_  cmdlang - Declarative command-line parsing for OCaml                         *)
(*_  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Parsing parameters according to their specification.

    This is a util module to convert string based parameters coming from the
    command line into their typed representation.

    For example, if a param is expected to be an integer, this module will
    convert the string representation of the integer into an actual integer.

    {[
      ./my_command.exe --int-param 42
    ]}

    The string ["42"] will be converted into the integer [42], given the
    parameter [Ast.Param.Int] for the arg [--int-param]. *)

val eval : 'a Ast.Param.t -> string -> 'a Ast.or_error_msg

(** Choose a docv for the help. *)
val docv : _ Ast.Param.t -> docv:string option -> string

(** Print a param for the help (e.g. document a default value). *)
val print : 'a Ast.Param.t -> 'a -> string
