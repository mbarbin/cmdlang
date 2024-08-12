(* $MDX part-begin=start *)
module Operator = struct
  type t =
    | Add
    | Mul

  let all = [ Add; Mul ]

  let to_string = function
    | Add -> "add"
    | Mul -> "mul"
  ;;

  let eval op a b =
    match op with
    | Add -> a +. b
    | Mul -> a *. b
  ;;
end
(* $MDX part-end *)

(* $MDX part-begin=void *)
let cmd =
  Command.make
    ~summary:"A simple calculator"
    (let open Command.Std in
     let+ () = Arg.return () in
     ())
;;

(* $MDX part-end *)
let _ = cmd

(* $MDX part-begin=final *)
let cmd =
  Command.make
    ~summary:"A simple calculator"
    (let open Command.Std in
     let+ op =
       Arg.named [ "op" ] (Param.enumerated (module Operator)) ~doc:"operation to perform"
     and+ a = Arg.pos 0 ~docv:"a" Param.float ~doc:"first operand"
     and+ b = Arg.pos 1 ~docv:"b" Param.float ~doc:"second operand"
     and+ verbose = Arg.flag [ "verbose" ] ~doc:"print debug information" in
     if verbose then Printf.printf "op: %s, a: %f, b: %f\n" (Operator.to_string op) a b;
     print_endline (Operator.eval op a b |> string_of_float))
;;
(* $MDX part-end *)
