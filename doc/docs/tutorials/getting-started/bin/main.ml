let () =
  Cmdliner.Cmd.eval
    (Cmdlang_to_cmdliner.Translate.command
       Getting_started.cmd
       ~name:"my-calculator"
       ~version:"%%VERSION%%")
  |> Stdlib.exit
;;
