(* In this test we characterize what happens when more positional argument
   follow an optional positional argument. *)

module Command = Cmdlang.Command

let test =
  let%map_open.Command a = Arg.pos_opt ~pos:0 Param.string ~doc:"value for a"
  and b = Arg.pos ~pos:1 Param.string ~doc:"value for b" in
  print_s [%sexp { a : string option; b : string }]
;;

let%expect_test "invalid_pos_sequence" =
  let test = Arg_test.create test in
  Arg_test.eval_all test { prog = "test"; args = [ "A"; "B" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    ((a (A)) (b B))
    ----------------------------------------------------- Cmdliner
    ((a (A)) (b B))
    ----------------------------------------------------- Core_command
    ((a (A)) (b B))
    ----------------------------------------------------- Stdlib_runner
    ((a (A)) (b B))
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "B" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    Evaluation Failed: Missing required positional argument at position 1.
    ----------------------------------------------------- Cmdliner
    test: required argument STRING is missing
    Usage: test [OPTION]… [STRING] STRING
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------------------------------- Core_command
    ("Evaluation Failed" "missing anonymous argument: STRING")
    ----------------------------------------------------- Stdlib_runner
    Missing required positional argument at position 1.
    ("Evaluation Failed" ((exit_code 2)))
    |}];
  ()
;;

(* When converting the spec to a command, core.command rejects it. In climate
   and cmdliner, the spec is successfully translated, however it will fail when
   the optional positional argument isn't supplied. *)

let cmd = Command.make ~summary:"test" test

let%expect_test "base" =
  require_does_raise [%here] (fun () -> Cmdlang_to_base.Translate.command_unit cmd);
  [%expect
    {|
    (Failure
     "the grammar [STRING] STRING for anonymous arguments is not supported because there is the possibility for arguments (STRING) following a variable number of arguments ([STRING]).  Supporting such grammars would complicate the implementation significantly.")
    |}];
  ()
;;

let%expect_test "climate" =
  let cmd = Cmdlang_to_climate.Translate.command cmd in
  let run args =
    match Climate.For_test.eval_result ~program_name:"./main.exe" cmd args with
    | Ok () -> ()
    | Error e ->
      print_string "Evaluation Failed: ";
      Climate_non_ret.print e
    | exception e -> print_s [%sexp "Evaluation Raised", (e : Exn.t)] [@coverage off]
  in
  run [ "A"; "B" ];
  [%expect {| ((a (A)) (b B)) |}];
  run [ "B" ];
  [%expect {| Evaluation Failed: Missing required positional argument at position 1. |}];
  ()
;;

let%expect_test "cmdliner" =
  let cmd = Cmdlang_to_cmdliner.Translate.command cmd ~name:"./main.exe" in
  let run args =
    Cmdliner.Cmd.eval cmd ~argv:(Array.concat [ [| "./main.exe" |]; Array.of_list args ])
    |> Stdlib.print_int
  in
  run [ "A"; "B" ];
  [%expect
    {|
    ((a (A)) (b B))
    0
    |}];
  run [ "B" ];
  [%expect
    {|
    ./main.exe: required argument STRING is missing
    Usage: ./main.exe [OPTION]… [STRING] STRING
    Try './main.exe --help' for more information.
    124
    |}];
  ()
;;

let%expect_test "stdlib-runner" =
  let run args =
    Cmdlang_stdlib_runner.eval_exit_code
      cmd
      ~argv:(Array.concat [ [| "./main.exe" |]; Array.of_list args ])
    |> Stdlib.print_int
  in
  run [ "A"; "B" ];
  [%expect
    {|
    ((a (A)) (b B))
    0
    |}];
  run [ "B" ];
  [%expect
    {|
    Missing required positional argument at position 1.
    2
    |}];
  ()
;;
