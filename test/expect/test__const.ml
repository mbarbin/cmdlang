module Command = Cmdlang.Command

let%expect_test "const" =
  let test =
    Arg_test.create
      (let%map_open.Command string = Arg.return "hello" in
       print_endline string)
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect {|
    ----------------------------- Climate
    hello
    ----------------------------- Cmdliner
    hello
    ----------------------------- Core_command
    hello
    |}];
  ()
;;
