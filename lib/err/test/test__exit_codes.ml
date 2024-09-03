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
  let test exit_code = print_endline (Int.to_string exit_code) in
  test Err.Exit_code.ok;
  [%expect {| 0 |}];
  test Err.Exit_code.some_error;
  [%expect {| 123 |}];
  test Err.Exit_code.cli_error;
  [%expect {| 124 |}];
  test Err.Exit_code.internal_error;
  [%expect {| 125 |}];
  test 42;
  [%expect {| 42 |}];
  ()
;;

let%expect_test "exit" =
  let test f = Err.For_test.protect f in
  test ignore;
  [%expect {| |}];
  test (fun () -> Err.exit Err.Exit_code.ok);
  [%expect {| [0] |}];
  test (fun () -> Err.exit Err.Exit_code.some_error);
  [%expect {| [123] |}];
  test (fun () -> Err.exit Err.Exit_code.cli_error);
  [%expect {| [124] |}];
  test (fun () -> Err.exit Err.Exit_code.internal_error);
  [%expect {|
    Backtrace: <backtrace disabled in tests>
    [125]
    |}];
  test (fun () -> Err.exit 42);
  [%expect {| [42] |}];
  ()
;;

let%expect_test "exit without handler" =
  require_does_raise [%here] (fun () -> Err.exit Err.Exit_code.ok);
  [%expect {| ((Exit 0)) |}];
  require_does_raise [%here] (fun () -> Err.exit Err.Exit_code.some_error);
  [%expect {| ((Exit 123)) |}];
  ()
;;
