let () =
  match
    Cmdliner.Cmd.eval_value'
      (Commandlang_to_cmdliner.Translate.command Test_command.cmd ~name:Sys.argv.(0))
  with
  | `Ok () -> ()
  | `Exit code -> exit code
;;
