module Command = Cmdlang.Command

let%expect_test "const" =
  let test =
    Arg_test.create
      (let open Command.Std in
       let+ string = Arg.return "hello" in
       print_endline string)
  in
  Arg_test.eval_all test { prog = "test"; args = [] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    hello
    ----------------------------------------------------- Cmdliner
    hello
    ----------------------------------------------------- Core_command
    hello
    ----------------------------------------------------- Stdlib_runner
    hello
    |}];
  ()
;;

let%expect_test "map" =
  let test =
    Arg_test.create
      (let open Command.Std in
       let+ v =
         Arg.pos ~pos:0 Param.string ~doc:"An integer." |> Arg.map ~f:Int.of_string_opt
       in
       print_s [%sexp (v : int option)])
  in
  Arg_test.eval_all test { prog = "test"; args = [ "0" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    (0)
    ----------------------------------------------------- Cmdliner
    (0)
    ----------------------------------------------------- Core_command
    (0)
    ----------------------------------------------------- Stdlib_runner
    (0)
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "not-an-int" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    ()
    ----------------------------------------------------- Cmdliner
    ()
    ----------------------------------------------------- Core_command
    ()
    ----------------------------------------------------- Stdlib_runner
    ()
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "42" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    (42)
    ----------------------------------------------------- Cmdliner
    (42)
    ----------------------------------------------------- Core_command
    (42)
    ----------------------------------------------------- Stdlib_runner
    (42)
    |}];
  ()
;;

let%expect_test "apply" =
  let module Operator = struct
    type t =
      | Succ
      | Pred
    [@@deriving enumerate]

    let to_string = function
      | Succ -> "succ"
      | Pred -> "pred"
    ;;

    let apply t i =
      match t with
      | Succ -> i + 1
      | Pred -> i - 1
    ;;
  end
  in
  let test =
    let open Command.Std in
    Arg_test.create
      (let op =
         Arg.pos ~pos:0 (Param.enumerated (module Operator)) ~doc:"An operator."
         |> Arg.map ~f:Operator.apply
       and v = Arg.pos_with_default ~pos:1 Param.int ~default:0 ~doc:"An integer." in
       Arg.map (Arg.apply op v) ~f:(fun v -> print_s [%sexp (v : int)]))
  in
  Arg_test.eval_all test { prog = "test"; args = [ "succ"; "0" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    1
    ----------------------------------------------------- Cmdliner
    1
    ----------------------------------------------------- Core_command
    1
    ----------------------------------------------------- Stdlib_runner
    1
    |}];
  Arg_test.eval_all test { prog = "test"; args = [ "pred"; "42" ] };
  [%expect
    {|
    ----------------------------------------------------- Climate
    41
    ----------------------------------------------------- Cmdliner
    41
    ----------------------------------------------------- Core_command
    41
    ----------------------------------------------------- Stdlib_runner
    41
    |}];
  ()
;;
