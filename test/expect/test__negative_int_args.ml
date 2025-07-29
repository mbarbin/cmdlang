module Command = Cmdlang.Command

let%expect_test "negative positional" =
  let test =
    Arg_test.create
      (let open Command.Std in
       let+ string =
         Arg.pos ~pos:0 Param.int ~doc:"An integer."
         |> Arg.map ~f:(fun i ->
           match Ordering.of_int i with
           | Less -> ("negative" [@coverage off])
           | Equal -> "zero"
           | Greater -> "positive")
       in
       print_endline string)
  in
  Arg_test.eval_all test { prog = "test"; args = [ "0" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    zero
    ----------------------------------------------------- Cmdliner
    zero
    ----------------------------------------------------- Core_command
    zero
    ----------------------------------------------------- Stdlib_runner
    zero
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "+1" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    positive
    ----------------------------------------------------- Cmdliner
    positive
    ----------------------------------------------------- Core_command
    positive
    ----------------------------------------------------- Stdlib_runner
    positive
    |}];
  (* All backends agree, negative numbers are not supported as positional
     arguments, because they look like flags. *)
  Arg_test.eval_all test { prog = "test"; args = [ "-1" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    Evaluation Failed: Unknown argument name: -1
    ----------------------------------------------------- Cmdliner
    test: unknown option '-1'.
    Usage: test [OPTION]… INT
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"unknown flag -1\")"))
    ----------------------------------------------------- Stdlib_runner
    test: unknown option '-1'.
    Usage: test [OPTIONS] [ARGUMENTS]

    eval-stdlib-runner

    Arguments:
      <INT>  An integer. (required)

    Options:
      -help   Display this list of options
      --help  Display this list of options
    ("Evaluation Failed" ((exit_code 2)))
    |}];
  ()
;;

let%expect_test "negative named" =
  let test =
    Arg_test.create
      (let open Command.Std in
       let+ string =
         Arg.named [ "n" ] Param.int ~doc:"An integer."
         |> Arg.map ~f:(fun i ->
           match Ordering.of_int i with
           | Less -> "negative"
           | Equal -> "zero"
           | Greater -> "positive")
       in
       print_endline string)
  in
  Arg_test.eval_all test { prog = "test"; args = [ "-n"; "0" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    zero
    ----------------------------------------------------- Cmdliner
    zero
    ----------------------------------------------------- Core_command
    zero
    ----------------------------------------------------- Stdlib_runner
    zero
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "-n"; "+1" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    positive
    ----------------------------------------------------- Cmdliner
    positive
    ----------------------------------------------------- Core_command
    positive
    ----------------------------------------------------- Stdlib_runner
    positive
    |}];
  (* When the arg is named, cmdliner does not support negative values. *)
  Arg_test.eval_all test { prog = "test"; args = [ "-n"; "-1" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    negative
    ----------------------------------------------------- Cmdliner
    test: unknown option '-1'.
    Usage: test [-n INT] [OPTION]…
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------------------------------- Core_command
    negative
    ----------------------------------------------------- Stdlib_runner
    negative
    |}];
  ()
;;
