let () =
  Commandlang_to_cmdliner.run Test_command.cmd ~name:Sys.argv.(0) ~version:"%%VERSION%%"
;;
