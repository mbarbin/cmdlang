(*_********************************************************************************)
(*_  cmdlang - Declarative command-line parsing for OCaml                         *)
(*_  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

(** Selecting a command within a group hierarchy.

    Cmdlang supports grouping subcommands into a nested tree, whereas
    [stdlib.arg] works at the level of a command leaves. This module is used to
    navigate the command tree to select the one based on the prefix of the
    command line.

    For example, given the following command invocation:

    {[
      ./my_command group1 subcommand --flag value
    ]}

    this module will select from the command tree the subcommand named
    [subcommand] from the group [group1]. It will also return the index at which
    the parsing should resume, in this case [3] (the index of [--flag] in
    [Sys.argv]). *)

module Selected : sig
  type 'a t =
    { command : 'a Ast.Command.t
    ; resume_parsing_from_index : int
    }
end

val select : 'a Ast.Command.t -> argv:string array -> 'a Selected.t
