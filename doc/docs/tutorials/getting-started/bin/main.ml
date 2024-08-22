let () =
  Commandlang_to_cmdliner.run
    Getting_started.cmd
    ~name:"my-calculator"
    ~version:"%%VERSION%%"
;;
