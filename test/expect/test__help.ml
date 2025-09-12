(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Command = Cmdlang.Command

let%expect_test "flag" =
  let test =
    Arg_test.create
      (let open Command.Std in
       let+ hello = Arg.flag [ "print-hello" ] ~doc:"Print Hello." in
       (ignore (hello : bool) [@coverage off]))
  in
  Arg_test.eval_all test { prog = "test"; args = [ "--help" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    Evaluation Failed: (Help (
      (command_doc_spec _)
      (error            false)
      (message ())))
    Usage: test [OPTION]…

    Options:
          --print-hello  Print Hello.
      -h, --help         Show this help message.
    ----------------------------------------------------- Cmdliner
    NAME
           test

    SYNOPSIS
           test [--print-hello] [OPTION]…

    OPTIONS
           --print-hello
               Print Hello.

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
      --print-hello  Print Hello. (optional)
      -help          Display this list of options
      --help         Display this list of options


           125 on unexpected internal errors (bugs).
    |}];
  ()
;;
