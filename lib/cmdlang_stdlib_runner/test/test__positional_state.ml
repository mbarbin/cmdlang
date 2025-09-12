(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Positional_state = Cmdlang_stdlib_runner.Positional_state

let%expect_test "anon_fun" =
  let no_pos =
    match Positional_state.make ~pos:[] ~pos_all:None with
    | Ok t -> t
    | Error _ -> assert false
  in
  require_does_raise [%here] (fun () ->
    (ignore (Positional_state.anon_fun no_pos "Hey" : unit) [@coverage off]));
  [%expect {| (Arg.Bad "Unexpected positional argument \"Hey\"") |}];
  ()
;;

let%expect_test "pos_all" =
  let pos =
    match
      Positional_state.make
        ~pos:[]
        ~pos_all:
          (Some
             (Positional_state.Pos_all.T
                { param = Cmdlang_ast.Ast.Param.Int
                ; docv = None
                ; doc = ""
                ; rev_var = ref []
                }))
    with
    | Ok t -> t
    | Error _ -> assert false
  in
  require_does_raise [%here] (fun () ->
    (ignore (Positional_state.anon_fun pos "Hey" : unit) [@coverage off]));
  [%expect
    {| (Arg.Bad "Positional argument 0 \"Hey\": invalid value \"Hey\" (not an int)") |}];
  ()
;;

let%expect_test "usage_msg" =
  let pos =
    match
      Positional_state.make
        ~pos:
          [ T
              { pos = 0
              ; param = Cmdlang_ast.Ast.Param.Int
              ; docv = Some "Hello-INT"
              ; doc = "doc for pos0"
              ; var = ref None
              }
          ; T
              { pos = 1
              ; param = Cmdlang_ast.Ast.Param.Bool
              ; docv = None
              ; doc = "doc for pos1"
              ; var = ref None
              }
          ]
        ~pos_all:
          (Some
             (Positional_state.Pos_all.T
                { param = Cmdlang_ast.Ast.Param.Int
                ; docv = Some "INT"
                ; doc = "a sequence of integers"
                ; rev_var = ref []
                }))
    with
    | Ok t -> t
    | Error _ -> assert false
  in
  print_endline (Positional_state.usage_msg pos |> Option.value_exn);
  [%expect
    {|
    Arguments:
      <Hello-INT>  doc for pos0
      <BOOL>  doc for pos1
    |}];
  ()
;;
