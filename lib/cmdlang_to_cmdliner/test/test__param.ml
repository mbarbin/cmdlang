module Command = Cmdlang.Command

let%expect_test "param" =
  let conv (type a) param sexp_of_a params =
    let conv = Cmdlang_to_cmdliner.Translate.param param in
    List.iter params ~f:(fun str ->
      print_s
        [%sexp
          (str : string)
          , (Cmdliner.Arg.conv_parser conv str : (a, [ `Msg of string ]) Result.t)])
  in
  conv Command.Param.int [%sexp_of: int] [ ""; "a"; "0"; "42"; "-17" ];
  [%expect
    {|
    ("" (Error (Msg "invalid value '', expected an integer")))
    (a (Error (Msg "invalid value 'a', expected an integer")))
    (0 (Ok 0))
    (42 (Ok 42))
    (-17 (Ok -17))
    |}];
  ()
;;
