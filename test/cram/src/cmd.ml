let return =
  Command.make
    ~summary:"return"
    (let open Command.Std in
     let+ () = Arg.return () in
     print_endline "()")
;;

module Named = struct
  module With_default = struct
    let string =
      Command.make
        ~summary:"named_with_default__string"
        (let open Command.Std in
         let+ who =
           Arg.named_with_default
             [ "who" ]
             Param.string
             ~docv:"WHO"
             ~default:"World"
             ~doc:"Hello WHO?"
         in
         print_endline ("Hello " ^ who))
    ;;

    let create =
      Command.make
        ~summary:"named_with_default__create"
        (let module E = struct
           type t =
             | A
             | B

           let to_string = function
             | A -> "A"
             | B -> "B"
           ;;

           let print fmt t = Stdlib.Format.pp_print_string fmt (to_string t)

           let parse = function
             | "A" -> Ok A
             | "B" -> Ok B
             | str -> Error (`Msg (Printf.sprintf "%S: invalid E.t" str))
           ;;
         end
         in
        let open Command.Std in
        let+ e =
          Arg.named_with_default
            [ "who" ]
            (Param.create ~docv:"(A|B)" ~parse:E.parse ~print:E.print)
            ~default:A
            ~doc:"Greet A or B?"
        in
        print_endline ("Hello " ^ E.to_string e))
    ;;

    let stringable =
      Command.make
        ~summary:"named_with_default__stringable"
        (let module Id : sig
           type t

           val of_string : string -> t
           val to_string : t -> string
         end = struct
           type t = string

           let to_string t = t
           let of_string t = t
         end
         in
        let open Command.Std in
        let+ e =
          Arg.named_with_default
            [ "who" ]
            (Param.stringable (module Id))
            ~default:(Id.of_string "my-id")
            ~doc:"identifier"
        in
        print_endline ("Hello " ^ Id.to_string e))
    ;;

    let main =
      Command.group
        ~summary:"named-with-default"
        [ "create", create; "string", string; "stringable", stringable ]
    ;;
  end

  let main =
    Command.group ~summary:"named arguments" [ "with-default", With_default.main ]
  ;;
end

let main =
  Command.group ~summary:"Cram Test Command" [ "return", return; "named", Named.main ]
;;
