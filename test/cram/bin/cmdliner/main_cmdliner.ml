let () =
  Cmdlang_to_cmdliner.run
    Cram_test_command.Cmd.main
    ~name:Sys.argv.(0)
    ~version:"%%VERSION%%"
;;
