(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Selected = struct
  type 'a t =
    { command : 'a Ast.Command.t
    ; resume_parsing_from_index : int
    }
end

let select (type a) command ~argv =
  let rec aux index command =
    match (command : a Ast.Command.t) with
    | Make _ -> { Selected.command; resume_parsing_from_index = index }
    | Group { default = _; summary = _; readme = _; subcommands } ->
      if index >= Array.length argv
      then { Selected.command; resume_parsing_from_index = index }
      else (
        let arg = argv.(index) in
        match subcommands |> List.find_opt (fun (name, _) -> String.equal arg name) with
        | Some (_, subcommand) -> aux (index + 1) subcommand
        | None -> { Selected.command; resume_parsing_from_index = index })
  in
  aux 1 command
;;
