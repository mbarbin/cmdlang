module Message_kind = struct
  type t =
    | Error
    | Warning
    | Info
    | Debug
  [@@deriving enumerate, sexp_of]

  let to_string t =
    match sexp_of_t t with
    | Atom s -> String.uncapitalize s
    | _ -> assert false
  ;;
end

let write_cmd =
  Command.make
    ~summary:"write to an error-log"
    (let%map_open.Command () = Err.set_config ()
     and file = Arg.named [ "file" ] Param.string ~docv:"FILE" ~doc:"file"
     and line = Arg.named [ "line" ] Param.int ~docv:"N" ~doc:"line number"
     and pos_cnum = Arg.named [ "pos-cnum" ] Param.int ~docv:"N" ~doc:"character position"
     and pos_bol = Arg.named [ "pos-bol" ] Param.int ~docv:"N" ~doc:"beginning of line"
     and length = Arg.named [ "length" ] Param.int ~docv:"N" ~doc:"length of range"
     and message_kind =
       Arg.named_with_default
         [ "message-kind" ]
         (Param.enumerated (module Message_kind))
         ~default:Error
         ~docv:"KIND"
         ~doc:"message kind"
     and raise = Arg.flag [ "raise" ] ~doc:"raise an exception" in
     let loc =
       let p = { Lexing.pos_fname = file; pos_lnum = line; pos_cnum; pos_bol } in
       Loc.create (p, { p with pos_cnum = pos_cnum + length })
     in
     if raise then failwith "Raising an exception!";
     match message_kind with
     | Error -> Err.error ~loc [ Pp.text "error message" ]
     | Warning -> Err.warning ~loc [ Pp.text "warning message" ]
     | Info -> Err.info ~loc [ Pp.text "info message" ]
     | Debug -> Err.debug ~loc [ Pp.text "debug message" ])
;;

let main = Command.group ~summary:"test err from the command line" [ "write", write_cmd ]
let () = Commandlang_to_cmdliner.run main ~name:"main" ~version:"%%VERSION%%"
