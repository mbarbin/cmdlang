(*_********************************************************************************)
(*_  cmdlang - Declarative command-line parsing for OCaml                         *)
(*_  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** This module allows to stage the translation of a cmdlang argument into
    different backends for testing. *)

type 'a t

val create : 'a Cmdlang.Command.Arg.t -> 'a t

(** {1 Evaluation} *)

module Command_line : sig
  type t =
    { prog : string
    ; args : string list
    }
end

(** Evaluate all backends and print a full trace on standard channels for use in
    expect tests. *)
val eval_all : unit t -> Command_line.t -> unit
