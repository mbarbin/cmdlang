module Command = Cmdlang.Command

let return =
  Command.make
    ~summary:"return"
    (let open Command.Std in
     let+ () = Arg.return () in
     ())
;;

let group = Command.group ~summary:"group" [ "name_with_underscore", return ]

let%expect_test "base" =
  (* core.command rejects subcommand names containing an underscore. *)
  require_does_raise [%here] (fun () ->
    Command_unix.run (Cmdlang_to_base.Translate.command_unit group));
  [%expect
    {|
    (Failure
     "subcommand name_with_underscore contains an underscore. Use a dash instead.")
    |}];
  ()
;;

let%expect_test "climate" =
  (* In climate, subcommand names containing an underscore are valid. *)
  Climate.Command.eval
    (Cmdlang_to_climate.Translate.command group)
    { program = "./main.exe"; args = [ "name_with_underscore" ] };
  [%expect {||}];
  ()
;;

let%expect_test "cmdliner" =
  (* In cmdliner, subcommand names containing an underscore are valid. *)
  Cmdliner.Cmd.eval
    (Cmdlang_to_cmdliner.Translate.command group ~name:"./main.exe")
    ~argv:[| "./main.exe"; "name_with_underscore" |]
  |> Stdlib.print_int;
  [%expect {| 0 |}];
  ()
;;
