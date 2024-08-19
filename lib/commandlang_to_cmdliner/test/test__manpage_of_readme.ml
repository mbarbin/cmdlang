module Manpage_block = struct
  type t = [ `P of string ] [@@deriving sexp_of]
end

let manpage_of_readme : readme:(unit -> string) -> Manpage_block.t list =
  Commandlang_to_cmdliner.Translate.Private.Command.manpage_of_readme
;;

let test str =
  let manpage = manpage_of_readme ~readme:(fun () -> str) in
  print_s [%sexp (manpage : Manpage_block.t list)]
;;

let%expect_test "empty" =
  test "";
  [%expect {| ((P "\n")) |}]
;;

let%expect_test "white space" =
  test " ";
  [%expect {| ((P " ")) |}];
  test " \n ";
  [%expect {| ((P "   ")) |}];
  test " \n \n ";
  [%expect {| ((P "     ")) |}]
;;
