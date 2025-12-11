(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Array = struct
  include Array

  (* [Array.find_mapi] available only since 5.1 *)
  let find_mapi f a =
    let n = length a in
    let rec loop i =
      if i = n
      then None
      else (
        match f i (unsafe_get a i) with
        | None -> loop (succ i)
        | Some _ as r -> r)
    in
    loop 0
  ;;
end
