module Command = Cmdlang.Command

let%expect_test "flag" =
  let test =
    Arg_test.create
      (let%map_open.Command hello = Arg.flag [ "print-hello" ] ~doc:"print Hello" in
       (ignore (hello : bool) [@coverage off]))
  in
  Arg_test.eval_all test { prog = "test"; args = [ "--help" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    [34;1mUsage: [0mtest [OPTIONS]

    [34;1mOptions:[0m
      [35;1m-h, --help[0m         Show this help message.
      [35;1m    --print-hello[0m  print Hello
    ("Evaluation Raised" (Climate.Usage))
    ----------------------------------------------------- Cmdliner
    NAME
           test

    SYNOPSIS
           test [--print-hello] [OPTION]…

    OPTIONS
           --print-hello
               print Hello.

    COMMON OPTIONS
           --help[=FMT] (default=auto)
               Show this help in format FMT. The value FMT must be one of auto,
               pager, groff or plain. With auto, the format is pager or plain
               whenever the TERM env var is dumb or undefined.

    EXIT STATUS
           test exits with:

           0   on success.

           123 on indiscriminate errors reported on standard error.

           124 on command line parsing errors.
    ----------------------------------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"unknown flag --help\")"))
    ----------------------------------------------------- Stdlib_runner
    Usage: test [OPTIONS]

    eval-stdlib-runner

    Options:
      --print-hello  print Hello (optional)
      -help          Display this list of options
      --help         Display this list of options


           125 on unexpected internal errors (bugs).
    |}];
  ()
;;
