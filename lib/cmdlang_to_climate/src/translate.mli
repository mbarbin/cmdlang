(*_********************************************************************************)
(*_  cmdlang - Declarative command-line parsing for OCaml                         *)
(*_  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Translate cmdlang parsers to climate.

    The translation to climate is experimental, not well tested or documented,
    and doesn't support all features of climate. In particular there's currently
    no support to target the auto-completion features offered by climate. This
    is an area left for future work. More info
    {{:https://mbarbin.github.io/cmdlang/docs/explanation/future_plans/} here}. *)

(** {1 Param} *)

val param : 'a Cmdlang.Command.Param.t -> 'a Climate.Arg_parser.conv

(** {1 Arg} *)

val arg : 'a Cmdlang.Command.Arg.t -> 'a Climate.Arg_parser.t

(** {1 Command} *)

val command : 'a Cmdlang.Command.t -> 'a Climate.Command.t

module Private : sig
  (** This module is exported for testing purposes only. Its signature may
      change in breaking ways without any notice. Do not use. *)
end
