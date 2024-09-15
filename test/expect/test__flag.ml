module Command = Cmdlang.Command

let%expect_test "flag" =
  let test =
    Arg_test.create
      (let%map_open.Command hello = Arg.flag [ "print-hello" ] ~doc:"print Hello" in
       if hello then print_endline "Hello")
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------- Climate
    ----------------------------- Cmdliner
    ----------------------------- Core_command
    |}];
  (* When full flags are provided, all backend agree and things work as expected. *)
  Arg_test.eval_all test { prog = "test"; args = [ "--print-hello" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello
    ----------------------------- Cmdliner
    Hello
    ----------------------------- Core_command
    Hello
    |}];
  (* When the specification does not include an explicit one letter alias, none
     is provided. We say more about this in a dedicated section below. *)
  Arg_test.eval_all test { prog = "test"; args = [ "-p" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (Climate.Parse_error.E "Unknown argument name: -p"))
    ----------------------------- Cmdliner
    test: unknown option '-p'.
    Usage: test [--print-hello] [OPTION]…
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"unknown flag -p\")"))
    |}];
  (* The default translation configured in [cmdlang] doesn't enable special
     support for long flag names with a single dash. That is reserved to special
     migration plans for [core.command], and is only enabled under a dedicated
     configuration. *)
  Arg_test.eval_all test { prog = "test"; args = [ "-print-hello" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (Climate.Parse_error.E "Unknown argument name: -p"))
    ----------------------------- Cmdliner
    test: unknown option '-p', did you mean '--print-hello'?
    Usage: test [--print-hello] [OPTION]…
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"unknown flag -print-hello\")"))
    |}];
  (* Partial flags are handled differently by the backend. In [climate], they
     are rejected. In [cmdliner] and [core.command], prefixes are interpreted as
     full flags. We say more about this in a dedicated section below. *)
  Arg_test.eval_all test { prog = "test"; args = [ "--print" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (Climate.Parse_error.E "Unknown argument name: --print"))
    ----------------------------- Cmdliner
    Hello
    ----------------------------- Core_command
    Hello
    |}];
  ()
;;

let%expect_test "1-letter-flag" =
  (* We revisit the initial example but this time the flag name has only 1 letter. *)
  let test =
    Arg_test.create
      (let%map_open.Command hello = Arg.flag [ "p" ] ~doc:"print Hello" in
       if hello then print_endline "Hello")
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------- Climate
    ----------------------------- Cmdliner
    ----------------------------- Core_command
    |}];
  (* One letter flags are expected to be supplied with a single dash. *)
  Arg_test.eval_all test { prog = "test"; args = [ "-p" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello
    ----------------------------- Cmdliner
    Hello
    ----------------------------- Core_command
    Hello
    |}];
  (* One letter flags are not recognized with called with two dashes. All backend agree on that. *)
  Arg_test.eval_all test { prog = "test"; args = [ "--p" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E
      "Single-character names must only be specified with a single dash. \"--p\" is not allowed as it has two dashes but only one character."))
    ----------------------------- Cmdliner
    test: unknown option '--p', did you mean '-p'?
    Usage: test [-p] [OPTION]…
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"unknown flag --p\")"))
    |}];
  ()
;;

let%expect_test "1-letter-alias" =
  (* We revisit the initial example and add a 1-letter alias to it. One letter
     flags needs to be called with a single dash. *)
  let test =
    Arg_test.create
      (let%map_open.Command hello = Arg.flag [ "print-hello"; "p" ] ~doc:"print Hello" in
       if hello then print_endline "Hello")
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------- Climate
    ----------------------------- Cmdliner
    ----------------------------- Core_command
    |}];
  (* When full flags are provided, all backend agree and things work as expected. *)
  Arg_test.eval_all test { prog = "test"; args = [ "--print-hello" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello
    ----------------------------- Cmdliner
    Hello
    ----------------------------- Core_command
    Hello
    |}];
  (* The specification now includes an explicit one letter alias. *)
  Arg_test.eval_all test { prog = "test"; args = [ "-p" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello
    ----------------------------- Cmdliner
    Hello
    ----------------------------- Core_command
    Hello
    |}];
  (* One letter flags may not be called with 2 dashes. However, since [cmdliner]
     and [core.command] allow partial flags, if the one letter is actually the
     prefix of a long flag name, the two dashes form will be accepted by these
     two backend. Beware, this may be confusing. *)
  Arg_test.eval_all test { prog = "test"; args = [ "--p" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E
      "Single-character names must only be specified with a single dash. \"--p\" is not allowed as it has two dashes but only one character."))
    ----------------------------- Cmdliner
    Hello
    ----------------------------- Core_command
    Hello
    |}];
  ()
;;

let%expect_test "ambiguous prefixes" =
  (* In this example, we characterize the behavior of backends that allow flag prefixes. *)
  let test =
    Arg_test.create
      (let%map_open.Command hello_you =
         Arg.flag [ "print-hello-you" ] ~doc:"print Hello You"
       and hello_world = Arg.flag [ "print-hello-world" ] ~doc:"print Hello World" in
       if hello_you then print_endline "Hello You";
       if hello_world then print_endline "Hello World")
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------- Climate
    ----------------------------- Cmdliner
    ----------------------------- Core_command
    |}];
  (* When full flags are provided, all backend agree and things work as expected. *)
  Arg_test.eval_all test { prog = "test"; args = [ "--print-hello-you" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello You
    ----------------------------- Cmdliner
    Hello You
    ----------------------------- Core_command
    Hello You
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "--print-hello-world" ] };
  [%expect
    {|
    ----------------------------- Climate
    Hello World
    ----------------------------- Cmdliner
    Hello World
    ----------------------------- Core_command
    Hello World
    |}];
  (* When the flags are supplied partially, the backend diverge. If the
     prefix is non-ambiguous, [cmdliner] and [core.command] accept it. *)
  Arg_test.eval_all test { prog = "test"; args = [ "--print-hello-w" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E "Unknown argument name: --print-hello-w"))
    ----------------------------- Cmdliner
    Hello World
    ----------------------------- Core_command
    Hello World
    |}];
  (* When the prefix is ambiguous, it is rejected. *)
  Arg_test.eval_all test { prog = "test"; args = [ "--print-hello" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E "Unknown argument name: --print-hello"))
    ----------------------------- Cmdliner
    test: option '--print-hello' ambiguous and could be either '--print-hello-world' or '--print-hello-you'
    Usage: test [--print-hello-world] [--print-hello-you] [OPTION]…
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"flag --print-hello is an ambiguous prefix: --print-hello-world, --print-hello-you\")"))
    |}];
  ()
;;
