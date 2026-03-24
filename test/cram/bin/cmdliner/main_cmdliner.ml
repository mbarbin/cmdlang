(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let version =
  match Build_info.V1.version () with
  | None -> "n/a"
  | Some v -> Build_info.V1.Version.to_string v
;;

let () =
  let code =
    Cmdliner.Cmd.eval
      (Cmdlang_to_cmdliner.Translate.command
         Cram_command_test.Cmd.main
         ~name:Sys.argv.(0)
         ~version)
  in
  (* We disable coverage here because [bisect_ppx] instruments the out-edge of
     calls to [exit], which never returns. This creates false negatives in test
     coverage. We may revisit this decision in the future if the context
     changes. *)
  (exit code [@coverage off])
;;
