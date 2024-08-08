let cmd =
  Command.make
    ~doc:"Hello command"
    (let open Command.Std in
     let+ () = Arg.return () in
     print_endline "Hello Wold";
     ())
;;

let cmd2 =
  Command.make
    ~doc:"Hello let%bind command"
    (let%map_open.Command verbose = Arg.flag [ "verbose"; "v" ] ~doc:"be more verbose" in
     print_endline (Printf.sprintf "verbose = %b" verbose);
     ())
;;

let cmd3 =
  Command.make
    ~doc:"Hello cmd3"
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
    ~doc:"Hello let%bind command"
    (let%map_open.Command f = Arg.named_req [ "n" ] Param.float ~doc:"a float to print" in
     print_endline (Float.to_string f);
     ())
;;

let cmd =
  Command.group ~doc:"Hello" [ "cmd1", cmd; "cmd2", cmd2; "cmd3", cmd3; "cmd4", cmd4 ]
;;
