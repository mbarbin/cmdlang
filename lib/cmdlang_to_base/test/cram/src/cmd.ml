let original_basic_print =
  Command.basic
    ~summary:"A basic print command"
    (let%map_open.Command arg = flag "arg" (required string) ~doc:"ARG my long arg" in
     fun () -> print_endline arg)
;;

let original_basic_return =
  Command.basic
    ~summary:"A basic return command"
    (let%map_open.Command () = return () in
     fun () -> ())
;;

let original_basic =
  Command.group
    ~summary:"A group of basic commands"
    [ "print", original_basic_print; "return", original_basic_return ]
;;

let original_or_error_print =
  Command.basic_or_error
    ~summary:"An or-error print command"
    (let%map_open.Command arg = flag "arg" (optional string) ~doc:"ARG my long arg" in
     fun () ->
       match arg with
       | None ->
         Or_error.error_string
           "This command fails during execution when the argument is missing."
       | Some arg ->
         print_endline arg;
         Or_error.return ())
;;

let original_or_error_return =
  Command.basic_or_error
    ~summary:"An or-error return command"
    (let%map_open.Command () = return () in
     fun () -> Or_error.return ())
;;

let original_or_error =
  Command.group
    ~summary:"A group of or-error commands"
    [ "print", original_or_error_print; "return", original_or_error_return ]
;;

let original =
  Command.group
    ~summary:"A group of commands"
    [ "basic", original_basic; "or-error", original_or_error ]
;;

let migrated_basic_print =
  let module Command = Cmdlang.Command in
  Command.make
    ~summary:"A basic command"
    (let%map_open.Command arg =
       Arg.named [ "arg" ] Param.string ~docv:"ARG" ~doc:"my long arg"
     in
     fun () -> print_endline arg)
;;

let migrated_basic_return =
  let module Command = Cmdlang.Command in
  Command.make
    ~summary:"A basic command"
    (let%map_open.Command () = Arg.return () in
     fun () -> ())
;;

let migrated_basic =
  let module Command = Cmdlang.Command in
  Command.group
    ~summary:"A group of basic commands"
    [ "print", migrated_basic_print; "return", migrated_basic_return ]
;;

let migrated_or_error_print =
  let module Command = Cmdlang.Command in
  Command.make
    ~summary:"An or-error print command"
    (let%map_open.Command arg =
       Arg.named_opt [ "arg" ] Param.string ~docv:"ARG" ~doc:"my long arg"
     in
     fun () ->
       match arg with
       | None ->
         Or_error.error_string
           "This command fails during execution when the argument is missing"
       | Some arg ->
         print_endline arg;
         Or_error.return ())
;;

let migrated_or_error_return =
  let module Command = Cmdlang.Command in
  Command.make
    ~summary:"An or-error return command"
    (let%map_open.Command () = Arg.return () in
     fun () -> Or_error.return ())
;;

let migrated_or_error =
  let module Command = Cmdlang.Command in
  Command.group
    ~summary:"A group of or-error commands"
    [ "print", migrated_or_error_print; "return", migrated_or_error_return ]
;;

let migration_step1 =
  let config =
    Cmdlang_to_base.Translate.Config.create ~auto_add_one_dash_aliases:true ()
  in
  let basic = Cmdlang_to_base.Translate.command_basic migrated_basic ~config in
  Command.group
    ~summary:"A group of commands partially migrated"
    [ "basic", basic; "or-error", original_or_error ]
;;

let migration_step2 =
  let config =
    Cmdlang_to_base.Translate.Config.create ~auto_add_one_dash_aliases:true ()
  in
  let basic = Cmdlang_to_base.Translate.command_basic migrated_basic ~config in
  let or_error = Cmdlang_to_base.Translate.command_or_error migrated_or_error ~config in
  Command.group
    ~summary:"A group of commands fully migrated"
    [ "basic", basic; "or-error", or_error ]
;;

let migration_step3 =
  (* At this point, the default config may be used for the migration. *)
  let basic = Cmdlang_to_base.Translate.command_basic migrated_basic in
  let or_error = Cmdlang_to_base.Translate.command_or_error migrated_or_error in
  Command.group
    ~summary:"A group of commands fully and strictly migrated"
    [ "basic", basic; "or-error", or_error ]
;;

let main =
  Command.group
    ~summary:"Multiple steps of migration"
    [ "original", original
    ; "migration-step1", migration_step1
    ; "migration-step2", migration_step2
    ; "migration-step3", migration_step3
    ]
;;

let migrated =
  Cmdlang.Command.group
    ~summary:"Migrated command"
    [ "basic", Cmdlang_to_base.Translate.Utils.command_unit_of_basic migrated_basic
    ; ( "or-error"
      , Cmdlang_to_base.Translate.Utils.command_unit_of_or_error migrated_or_error )
    ]
;;
