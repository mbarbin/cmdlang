let () =
  Cmdlang_cmdliner_runner.run
    Cram_test_command.Cmd.main
    ~name:Sys.argv.(0)
    ~version:"%%VERSION%%"
;;
