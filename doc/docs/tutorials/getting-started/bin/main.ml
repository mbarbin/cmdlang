let () =
  Cmdliner.Cmd.eval
    (Commandlang_to_cmdliner.Translate.command
       Getting_started.cmd
       ~name:"my-calculator"
       ~version:"%%VERSION%%")
  |> Stdlib.exit
;;
