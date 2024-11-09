let () =
  Cmdliner.Cmd.eval
    (Cmdlang_to_cmdliner.Translate.command
       Cram_test_command.Cmd.main
       ~name:Sys.argv.(0)
       ~version:"%%VERSION%%")
  |> Stdlib.exit
;;
