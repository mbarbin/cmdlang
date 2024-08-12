let cmd =
  Command.make
    ~summary:"Hello command"
    (let open Command.Std in
     let+ () = Arg.return () in
     print_endline "Hello Wold";
     ())
;;

let cmd2 =
  Command.make
    ~summary:"Hello let%bind command"
    (let%map_open.Command verbose = Arg.flag [ "verbose"; "v" ] ~doc:"be more verbose" in
     print_endline (Printf.sprintf "verbose = %b" verbose);
     ())
;;

let cmd3 =
  Command.make
    ~summary:"Hello cmd3"
    (let open Command.Std in
     let+ verbose = Arg.flag [ "verbose"; "v" ] ~doc:"be more verbose"
     and+ result =
       Arg.named_opt ~docv:"MYBOOL" [ "bool"; "b" ] Param.bool ~doc:"Specify a value"
     and+ int =
       Arg.named_with_default [ "int"; "i" ] Param.int ~default:42 ~doc:"Specify an int"
     in
     let open Base in
     print_s [%sexp { verbose : bool }];
     print_s [%sexp (result : bool option)];
     print_s [%sexp (int : int)];
     ())
;;

let cmd4 =
  Command.make
    ~summary:"Hello let%bind command"
    (let%map_open.Command f = Arg.named [ "n" ] Param.float ~doc:"a float to print" in
     print_endline (Float.to_string f);
     ())
;;

let cmd5 =
  Command.make
    ~summary:"Hello positional"
    (let%map_open.Command a = Arg.pos 0 ~docv:"A" Param.float
     and b = Arg.pos 1 ~docv:"B" Param.float
     and c = Arg.pos_with_default 2 ~docv:"C" Param.float ~default:3.14 in
     print_s [%sexp { a : float; b : float; c : float }];
     ())
;;

let cmd =
  Command.group
    ~summary:"Hello"
    [ "cmd1", cmd; "cmd2", cmd2; "cmd3", cmd3; "cmd4", cmd4; "cmd5", cmd5 ]
;;
