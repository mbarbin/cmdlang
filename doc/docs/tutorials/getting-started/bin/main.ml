let () =
  match
    Cmdliner.Cmd.eval_value'
      (Commandlang_to_cmdliner.Translate.command
         Getting_started.cmd
         ~name:"my-calculator")
  with
  | `Ok () -> ()
  | `Exit code -> exit code
;;
