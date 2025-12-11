(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Empty = struct
  type t = |

  let all = []

  let to_string t =
    match[@coverage off] t with
    | (_ : t) -> .
  ;;
end

let%expect_test "Param.enumerated" =
  let open Command.Std in
  require_does_raise [%here] (fun () -> Param.enumerated (module Empty));
  [%expect {| (Invalid_argument Command.Param.enumerated) |}];
  ()
;;
