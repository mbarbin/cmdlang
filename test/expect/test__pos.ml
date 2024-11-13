module Command = Cmdlang.Command

let%expect_test "pos" =
  let test =
    Arg_test.create
      (let%map_open.Command who =
         Arg.pos ~pos:0 Param.string ~docv:"WHO" ~doc:"hello who?"
       in
       print_endline ("Hello " ^ who))
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E "Missing required positional argument at position 0."))
    ----------------------------------------------------- Cmdliner
    test: required argument WHO is missing
    Usage: test [OPTION]… WHO
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------------------------------- Core_command
    ("Evaluation Failed" "missing anonymous argument: WHO")
    ----------------------------------------------------- Stdlib_runner
    Missing required positional argument at position 0.
    ("Evaluation Failed" ((exit_code 2)))
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "World" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    Hello World
    ----------------------------------------------------- Cmdliner
    Hello World
    ----------------------------------------------------- Core_command
    Hello World
    ----------------------------------------------------- Stdlib_runner
    Hello World
    |}];
  ()
;;

let%expect_test "skipping-pos" =
  let test =
    Arg_test.create
      (let%map_open.Command who =
         Arg.pos ~pos:1 Param.string ~docv:"WHO" ~doc:"hello who?"
       in
       print_endline ("Hello " ^ who))
  in
  (* As of now, the handling of positional argument with gaps isn't consistent
     between the backends. In [climate] and [core.command], the spec is rejected
     upfront. In [cmdliner], this creates runtime errors. *)
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    ("Evaluation Raised" (
      Climate.Spec_error.E
      "Attempted to declare a parser with a gap in its positional arguments. No parser would interpret the argument at position 0 but there is a parser for at least one argument at a higher position."))
    Attempted to declare a parser with a gap in its positional arguments. No parser would interpret the argument at position 0 but there is a parser for at least one argument at a higher position.----------------------------------------------------- Cmdliner
    test: required argument WHO is missing
    Usage: test [OPTION]… WHO
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------------------------------- Core_command
    ("Translation Raised" (
      "Positional arguments must be supplied in consecutive order"
      ((expected 0)
       (got      1))))
    ----------------------------------------------------- Stdlib_runner
    Invalid command specification (programming error):

    Attempted to declare a parser with a gap in its positional arguments.
    Positional argument 0 is missing.
    ("Evaluation Failed" ((exit_code 2)))
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "World" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    ("Evaluation Raised" (
      Climate.Spec_error.E
      "Attempted to declare a parser with a gap in its positional arguments. No parser would interpret the argument at position 0 but there is a parser for at least one argument at a higher position."))
    Attempted to declare a parser with a gap in its positional arguments. No parser would interpret the argument at position 0 but there is a parser for at least one argument at a higher position.----------------------------------------------------- Cmdliner
    test: required argument WHO is missing
    Usage: test [OPTION]… WHO
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------------------------------- Core_command
    ("Translation Raised" (
      "Positional arguments must be supplied in consecutive order"
      ((expected 0)
       (got      1))))
    ----------------------------------------------------- Stdlib_runner
    Invalid command specification (programming error):

    Attempted to declare a parser with a gap in its positional arguments.
    Positional argument 0 is missing.
    ("Evaluation Failed" ((exit_code 2)))
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "Big"; "World" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    ("Evaluation Raised" (
      Climate.Spec_error.E
      "Attempted to declare a parser with a gap in its positional arguments. No parser would interpret the argument at position 0 but there is a parser for at least one argument at a higher position."))
    Attempted to declare a parser with a gap in its positional arguments. No parser would interpret the argument at position 0 but there is a parser for at least one argument at a higher position.----------------------------------------------------- Cmdliner
    Hello World
    ----------------------------------------------------- Core_command
    ("Translation Raised" (
      "Positional arguments must be supplied in consecutive order"
      ((expected 0)
       (got      1))))
    ----------------------------------------------------- Stdlib_runner
    Invalid command specification (programming error):

    Attempted to declare a parser with a gap in its positional arguments.
    Positional argument 0 is missing.
    ("Evaluation Failed" ((exit_code 2)))
    |}];
  ()
;;

let%expect_test "pos_opt" =
  let test =
    Arg_test.create
      (let%map_open.Command who =
         Arg.pos_opt ~pos:0 Param.string ~docv:"WHO" ~doc:"hello who?"
       in
       Option.iter who ~f:(fun who -> print_endline ("Hello " ^ who)))
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    ----------------------------------------------------- Cmdliner
    ----------------------------------------------------- Core_command
    ----------------------------------------------------- Stdlib_runner
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "World" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    Hello World
    ----------------------------------------------------- Cmdliner
    Hello World
    ----------------------------------------------------- Core_command
    Hello World
    ----------------------------------------------------- Stdlib_runner
    Hello World
    |}];
  ()
;;

let%expect_test "pos_with_default" =
  let test =
    Arg_test.create
      (let%map_open.Command who =
         Arg.pos_with_default
           ~pos:0
           Param.string
           ~docv:"WHO"
           ~default:"World"
           ~doc:"hello who?"
       in
       print_endline ("Hello " ^ who))
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    Hello World
    ----------------------------------------------------- Cmdliner
    Hello World
    ----------------------------------------------------- Core_command
    Hello World
    ----------------------------------------------------- Stdlib_runner
    Hello World
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "You" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    Hello You
    ----------------------------------------------------- Cmdliner
    Hello You
    ----------------------------------------------------- Core_command
    Hello You
    ----------------------------------------------------- Stdlib_runner
    Hello You
    |}];
  ()
;;

let%expect_test "pos_all" =
  let test =
    Arg_test.create
      (let%map_open.Command who =
         Arg.pos_all Param.string ~docv:"WHO" ~doc:"hello who?"
       in
       List.iter who ~f:(fun who -> print_endline ("Hello " ^ who)))
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    ----------------------------------------------------- Cmdliner
    ----------------------------------------------------- Core_command
    ----------------------------------------------------- Stdlib_runner
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "World" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    Hello World
    ----------------------------------------------------- Cmdliner
    Hello World
    ----------------------------------------------------- Core_command
    Hello World
    ----------------------------------------------------- Stdlib_runner
    Hello World
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "World"; "You"; "Me" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    Hello World
    Hello You
    Hello Me
    ----------------------------------------------------- Cmdliner
    Hello World
    Hello You
    Hello Me
    ----------------------------------------------------- Core_command
    Hello World
    Hello You
    Hello Me
    ----------------------------------------------------- Stdlib_runner
    Hello World
    Hello You
    Hello Me
    |}];
  ()
;;
