module Command = Cmdlang.Command

let return =
  let open Command.Std in
  let+ () = Arg.return () in
  ()
;;
