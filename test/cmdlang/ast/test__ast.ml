(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

(* This is to silence `dune build @unused-libs` and keeping intended deps. *)
open! Cmdlang_ast.Ast

let%expect_test "empty" =
  ();
  [%expect {||}];
  ()
;;
