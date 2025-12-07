let () =
  Climate.Command.run
    (Cmdlang_to_climate.Translate.command Base_cram_test_command.Cmd.migrated)
;;
