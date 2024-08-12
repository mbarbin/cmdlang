let () =
  Cmdliner.Cmd.eval
    (Commandlang_to_cmdliner.Translate.command
       Test_command.cmd
       ~name:Sys.argv.(0)
       ~version:"%%VERSION%%")
  |> Stdlib.exit
;;
