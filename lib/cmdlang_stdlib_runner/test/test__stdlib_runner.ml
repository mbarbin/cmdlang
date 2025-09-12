(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Command = Cmdlang.Command

let%expect_test "eval_exit_code" =
  let arg =
    let open Command.Std in
    let+ arg = Arg.flag [ "flag" ] ~doc:"A flag." in
    print_s [%sexp (arg : bool)]
  in
  let cmd = Command.make ~summary:"A cmd." arg in
  let test argv =
    let code =
      Cmdlang_stdlib_runner.eval_exit_code
        cmd
        ~argv:(Array.of_list ("./main.exe" :: argv))
    in
    print_endline (Printf.sprintf "[%d]" code)
  in
  test [];
  [%expect
    {|
    false
    [0]
    |}];
  test [ "--help" ];
  [%expect
    {|
    Usage: ./main.exe [OPTIONS]

    A cmd.

    Options:
      --flag  A flag. (optional)
      -help   Display this list of options
      --help  Display this list of options
    [0]
    |}];
  ()
;;
