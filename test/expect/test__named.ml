module Command = Cmdlang.Command

let%expect_test "named" =
  let test =
    Arg_test.create
      (let%map_open.Command who =
         Arg.named [ "who" ] Param.string ~docv:"WHO" ~doc:"hello who?"
       in
       print_endline ("Hello " ^ who))
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E "Missing required named argument: --who"))
    ----------------------------- Cmdliner
    test: required option --who is missing
    Usage: test [--who=WHO] [OPTION]…
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" "missing required flag: --who")
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "--who"; "World" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello World
    ----------------------------- Cmdliner
    Hello World
    ----------------------------- Core_command
    Hello World
    |}];
  (* [climate] and [cmdliner] support the [--arg=VALUE] syntax. [core.command] does not. *)
  Arg_test.eval_all test { prog = "test"; args = [ "--who=You" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello You
    ----------------------------- Cmdliner
    Hello You
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"unknown flag --who=You\")"))
    |}];
  ()
;;

let%expect_test "1-letter-named" =
  let test =
    Arg_test.create
      (let%map_open.Command who =
         Arg.named [ "w" ] Param.string ~docv:"WHO" ~doc:"hello who?"
       in
       print_endline ("Hello " ^ who))
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E "Missing required named argument: -w"))
    ----------------------------- Cmdliner
    test: required option -w is missing
    Usage: test [-w WHO] [OPTION]…
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" "missing required flag: -w")
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "-w"; "World" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello World
    ----------------------------- Cmdliner
    Hello World
    ----------------------------- Core_command
    Hello World
    |}];
  (* [climate] and [cmdliner] support the [-wVALUE] syntax. [core.command] does not. *)
  Arg_test.eval_all test { prog = "test"; args = [ "-wYou" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello You
    ----------------------------- Cmdliner
    Hello You
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"unknown flag -wYou\")"))
    |}];
  ()
;;

let%expect_test "named_multi" =
  let test =
    Arg_test.create
      (let%map_open.Command who =
         Arg.named_multi [ "who" ] Param.string ~docv:"WHO" ~doc:"hello who?"
       in
       List.iter who ~f:(fun who -> print_endline ("Hello " ^ who)))
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------- Climate
    ----------------------------- Cmdliner
    ----------------------------- Core_command
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "--who"; "World" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello World
    ----------------------------- Cmdliner
    Hello World
    ----------------------------- Core_command
    Hello World
    |}];
  Arg_test.eval_all
    test
    { prog = "test"
    ; args = List.concat [ [ "--who"; "World" ]; [ "--who"; "You" ]; [ "--who"; "Me" ] ]
    };
  [%expect
    {|
    ----------------------------- Climate
    Hello World
    Hello You
    Hello Me
    ----------------------------- Cmdliner
    Hello World
    Hello You
    Hello Me
    ----------------------------- Core_command
    Hello World
    Hello You
    Hello Me
    |}];
  ()
;;

let%expect_test "named_opt" =
  let test =
    Arg_test.create
      (let%map_open.Command who =
         Arg.named_opt [ "who" ] Param.string ~docv:"WHO" ~doc:"hello who?"
       in
       Option.iter who ~f:(fun who -> print_endline ("Hello " ^ who)))
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------- Climate
    ----------------------------- Cmdliner
    ----------------------------- Core_command
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "--who"; "World" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello World
    ----------------------------- Cmdliner
    Hello World
    ----------------------------- Core_command
    Hello World
    |}];
  ()
;;

let%expect_test "named_with_default" =
  let test =
    Arg_test.create
      (let%map_open.Command who =
         Arg.named_with_default
           [ "who" ]
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
    ----------------------------- Climate
    Hello World
    ----------------------------- Cmdliner
    Hello World
    ----------------------------- Core_command
    Hello World
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "--who"; "You" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello You
    ----------------------------- Cmdliner
    Hello You
    ----------------------------- Core_command
    Hello You
    |}];
  ()
;;

let%expect_test "named_with_default__comma_separated" =
  let test ?(default = [ "You"; "Me"; "World" ]) () =
    Arg_test.create
      (let%map_open.Command who =
         Arg.named_with_default
           [ "who" ]
           (Param.comma_separated Param.string)
           ~docv:"WHO"
           ~default
           ~doc:"hello who?"
       in
       List.iter who ~f:(fun who -> print_endline ("Hello " ^ who)))
  in
  Arg_test.eval_all (test ()) { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------- Climate
    Hello You
    Hello Me
    Hello World
    ----------------------------- Cmdliner
    Hello You
    Hello Me
    Hello World
    ----------------------------- Core_command
    Hello You
    Hello Me
    Hello World
    |}];
  Arg_test.eval_all (test ~default:[] ()) { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------- Climate
    ----------------------------- Cmdliner
    ----------------------------- Core_command
    |}];
  (* Empty values are currently treated inconsistently by the three
     translation+backend. In climate, you get a singleton made of the empty
     string, in cmdliner you get the empty list, and in core.command you get an
     error. *)
  Arg_test.eval_all (test ()) { prog = "test"; args = [ "--who"; "" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello
    ----------------------------- Cmdliner
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"failed to parse --who value \\\"\\\".\\n(Failure \\\"Command.Spec.Arg_type.comma_separated: empty list not allowed\\\")\")"))
    |}];
  Arg_test.eval_all (test ()) { prog = "test"; args = [ "--who"; "Universe,Them Too" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello Universe
    Hello Them Too
    ----------------------------- Cmdliner
    Hello Universe
    Hello Them Too
    ----------------------------- Core_command
    Hello Universe
    Hello Them Too
    |}];
  ()
;;
