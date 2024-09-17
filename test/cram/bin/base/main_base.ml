let () =
  Command_unix.run (Cmdlang_to_base.Translate.command_unit Cram_test_command.Cmd.main)
;;
