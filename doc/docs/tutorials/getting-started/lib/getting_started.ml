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

(* $MDX part-begin=final *)
let cmd =
  Command.make
    ~summary:"A simple calculator"
    (let open Command.Std in
     let+ op =
       Arg.named
         [ "op" ]
         (Param.enumerated (module Operator))
         ~docv:"OP"
         ~doc:"operation to perform"
     and+ a = Arg.pos ~pos:0 Param.float ~docv:"a" ~doc:"first operand"
     and+ b = Arg.pos ~pos:1 Param.float ~docv:"b" ~doc:"second operand"
     and+ verbose = Arg.flag [ "verbose" ] ~doc:"print debug information" in
     if verbose then Printf.printf "op: %s, a: %f, b: %f\n" (Operator.to_string op) a b;
     print_endline (Operator.eval op a b |> string_of_float))
;;
(* $MDX part-end *)
