(* $MDX part-begin=let_plus_std *)
let _ : unit Command.t =
  Command.make
    ~summary:"A command skeleton"
    (let open Command.Std in
     let+ (_ : int) = Arg.named [ "n" ] Param.int ~doc:"A value for n"
     and+ () = Arg.return () in
     ())
;;

(* $MDX part-end *)

(* $MDX part-begin=let_plus_std_no_indent *)
let _ : unit Command.t =
  Command.make ~summary:"A command skeleton"
  @@
  let open Command.Std in
  let+ (_ : int) = Arg.named [ "n" ] Param.int ~doc:"A value for n"
  and+ () = Arg.return () in
  ()
;;

(* $MDX part-end *)

(* $MDX part-begin=let_map_open *)
let _ : unit Command.t =
  Command.make
    ~summary:"A command skeleton"
    (let%map_open.Command () = Arg.return ()
     and () = Arg.return () in
     ())
;;
(* $MDX part-end *)
