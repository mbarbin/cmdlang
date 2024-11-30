module Ast = Cmdlang_ast.Ast
module Param_parser = Cmdlang_stdlib_runner.Param_parser

module Enum = struct
  type t =
    | A
    | B

  let to_string = function
    | A -> "a"
    | B -> "b"
  ;;
end

let%expect_test "print" =
  let test param a = print_endline (Param_parser.print param a) in
  test Ast.Param.String "Hello";
  [%expect {| Hello |}];
  test Ast.Param.Float 3.14;
  [%expect {| 3.14 |}];
  test Ast.Param.Bool true;
  [%expect {| true |}];
  test Ast.Param.File "path/to/file";
  [%expect {| path/to/file |}];
  let enum choices =
    Ast.Param.Enum { docv = None; choices; to_string = Enum.to_string }
  in
  test (enum [ "A", A ]) A;
  [%expect {| A |}];
  test (enum [ "B", B ]) A;
  [%expect {| a |}];
  test (enum [ "A", A ]) B;
  [%expect {| b |}];
  ()
;;
