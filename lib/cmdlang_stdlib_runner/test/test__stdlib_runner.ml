module Command = Cmdlang.Command

let%expect_test "eval_exit_code" =
  let arg =
    let open Command.Std in
    let+ arg = Arg.flag [ "flag" ] ~doc:"flag" in
    print_s [%sexp (arg : bool)]
  in
  let cmd = Command.make ~summary:"cmd" arg in
  let test argv =
    let code =
      Cmdlang_stdlib_runner.eval_exit_code
        cmd
        ~argv:(Array.of_list ("./main.exe" :: argv))
    in
    print_endline (Printf.sprintf "[%d]" code)
  in
  test [];
  [%expect {|
    false
    [0]
    |}];
  test [ "--help" ];
  [%expect {|
    Usage: ./main.exe [OPTIONS]

    cmd

    Options:
      --flag  flag (optional)
      -help   Display this list of options
      --help  Display this list of options
    [0]
    |}];
  ()
;;
