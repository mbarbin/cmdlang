(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

let%expect_test "param" =
  let config = Cmdlang_to_base.Translate.Config.create () in
  let conv (type a) (param : a Cmdlang.Command.Param.t) (sexp_of_a : a -> Sexp.t) params =
    let conv = Cmdlang_to_base.Translate.param param ~config in
    List.iter params ~f:(fun str ->
      print_s [%sexp (str : string), (Command.Arg_type.parse conv str : a Or_error.t)])
  in
  conv Cmdlang.Command.Param.int [%sexp_of: int] [ ""; "a"; "0"; "42"; "-17" ];
  [%expect
    {|
    ("" (Error (Failure "Int.of_string: \"\"")))
    (a (Error (Failure "Int.of_string: \"a\"")))
    (0 (Ok 0))
    (42 (Ok 42))
    (-17 (Ok -17))
    |}];
  ()
;;
