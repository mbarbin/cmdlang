let%expect_test "exit codes" =
  print_s [%sexp (Err.Exit_code.ok : int)];
  require [%here] (Cmdliner.Cmd.Exit.ok = Err.Exit_code.ok);
  [%expect {| 0 |}];
  print_s [%sexp (Err.Exit_code.some_error : int)];
  require [%here] (Cmdliner.Cmd.Exit.some_error = Err.Exit_code.some_error);
  [%expect {| 123 |}];
  print_s [%sexp (Err.Exit_code.cli_error : int)];
  require [%here] (Cmdliner.Cmd.Exit.cli_error = Err.Exit_code.cli_error);
  [%expect {| 124 |}];
  print_s [%sexp (Err.Exit_code.internal_error : int)];
  require [%here] (Cmdliner.Cmd.Exit.internal_error = Err.Exit_code.internal_error);
  [%expect {| 125 |}];
  ()
;;

let%expect_test "code" =
  let test exit_code = print_endline (Int.to_string (Err.Exit_code.code exit_code)) in
  test Ok;
  [%expect {| 0 |}];
  test Some_error;
  [%expect {| 123 |}];
  test Cli_error;
  [%expect {| 124 |}];
  test Internal_error;
  [%expect {| 125 |}];
  test (Custom 42);
  [%expect {| 42 |}];
  ()
;;

let%expect_test "exit" =
  let test f = Err_handler.For_test.protect f in
  test ignore;
  [%expect {| |}];
  test (fun () -> Err.exit Ok);
  [%expect {| [0] |}];
  test (fun () -> Err.exit Some_error);
  [%expect {| [123] |}];
  test (fun () -> Err.exit Cli_error);
  [%expect {| [124] |}];
  test (fun () -> Err.exit Internal_error);
  [%expect {|
    Backtrace: <backtrace disabled in tests>
    [125]
    |}];
  test (fun () -> Err.exit (Custom 42));
  [%expect {| [42] |}];
  ()
;;

let%expect_test "exit without handler" =
  require_does_raise [%here] (fun () -> Err.exit Ok);
  [%expect {| ("(Err.E (Exit 0))") |}];
  require_does_raise [%here] (fun () -> Err.exit Some_error);
  [%expect {| ("(Err.E (Exit 123))") |}];
  ()
;;
