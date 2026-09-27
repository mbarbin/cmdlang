(*_********************************************************************************)
(*_  cmdlang - Declarative command-line parsing for OCaml                         *)
(*_  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Translate cmdlang parsers to cmdliner.

    This library aims to remain as compatible as possible with older
    versions of [cmdliner], down to [1.3]. However, it is only actively
    tested against the version of [cmdliner] used by this project's own test
    suite (currently [>= 2.1.1]), so older versions are no longer verified
    by CI. *)

(** {1 Param} *)

val param : 'a Cmdlang.Command.Param.t -> 'a Cmdliner.Arg.conv

(** {1 Arg} *)

val arg : 'a Cmdlang.Command.Arg.t -> 'a Cmdliner.Term.t

(** {1 Command} *)

val command : ?version:string -> 'a Cmdlang.Command.t -> name:string -> 'a Cmdliner.Cmd.t

(** {1 Private} *)

module Private : sig
  (** This module is exported for testing purposes only. Its signature may
      change in breaking ways without any notice. Do not use. *)

  module Arg : sig
    val doc_of_param : doc:string -> param:'a Ast.Param.t -> string
  end

  module Command : sig
    val manpage_of_readme : readme:(unit -> string) -> [ `P of string ] list
  end
end
