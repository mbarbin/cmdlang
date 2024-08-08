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
    ~doc:"A simple calculator"
    (let open Command.Std in
     let+ () = Arg.return () in
     ())
;;

(* $MDX part-end *)
let _ = cmd

(* $MDX part-begin=final *)
let cmd =
  Command.make
    ~doc:"A simple calculator"
    (let open Command.Std in
     let+ op =
       Arg.named_req
         [ "op" ]
         ~doc:"operation to perform"
         (Param.enum (Operator.all |> List.map (fun op -> Operator.to_string op, op)))
     and+ a = Arg.named_req [ "a" ] ~doc:"first operand" Param.float
     and+ b = Arg.named_req [ "b" ] ~doc:"second operand" Param.float
     and+ verbose = Arg.flag [ "verbose" ] ~doc:"print debug information" in
     if verbose then Printf.printf "op: %s, a: %f, b: %f\n" (Operator.to_string op) a b;
     print_endline (Operator.eval op a b |> string_of_float))
;;
(* $MDX part-end *)
