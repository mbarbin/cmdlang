let () =
  Cmdlang_cmdliner_runner.run
    Getting_started.cmd
    ~name:"my-calculator"
    ~version:"%%VERSION%%"
;;
