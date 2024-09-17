let return =
  Command.make
    ~summary:"An empty command"
    (let open Command.Std in
     let+ () = Arg.return () in
     print_endline "()")
;;

module Doc = struct
  let singleton_with_readme =
    Command.make
      ~summary:"Singleton command with a readme"
      ~readme:(fun () -> {|
This is a readme.
It can be written on multiple lines.
|})
      (let open Command.Std in
       let+ () = Arg.return () in
       ())
  ;;

  let args_doc_end_with_dots =
    Command.make
      ~summary:"Args doc end with dots"
      (let open Command.Std in
       let+ a = Arg.pos ~pos:0 Param.string ~doc:"The doc for a ends with a dot."
       and+ b = Arg.pos ~pos:1 Param.string ~doc:"The doc for b doesn't" in
       List.iter [ a; b ] ~f:print_endline)
  ;;

  let main =
    Command.group
      ~summary:"Testing documentation features"
      ~readme:(fun () ->
        {|
This group is dedicated to testing documentation features.
    |})
      [ "args-doc-end-with-dots", args_doc_end_with_dots
      ; "singleton-with-readme", singleton_with_readme
      ]
  ;;
end

module Named = struct
  module With_default = struct
    let string =
      Command.make
        ~summary:"Named_with_default__string"
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
        ~summary:"Named_with_default__create"
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
        ~summary:"Named_with_default__stringable"
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

    let validated =
      Command.make
        ~summary:"Named_with_default__validated"
        (let module Id4 : sig
           type t

           val of_string : string -> (t, [ `Msg of string ]) Result.t
           val to_string : t -> string
           val default : t
         end = struct
           type t = string

           let invariant t =
             String.length t = 4
             && String.for_all ~f:(fun c -> Char.is_alpha c || Char.is_digit c) t
           ;;

           let to_string t = t

           let of_string t =
             if invariant t
             then Ok t
             else
               Error
                 (`Msg
                   (Printf.sprintf "%S: invalid 4 letters alphanumerical identifier" t))
           ;;

           let default =
             let t = "0000" in
             assert (invariant t);
             t
           ;;
         end
         in
        let open Command.Std in
        let+ e =
          Arg.named_with_default
            [ "who" ]
            (Param.validated_string (module Id4))
            ~default:Id4.default
            ~doc:"4 letters alphanumerical identifier"
        in
        print_endline ("Hello " ^ Id4.to_string e))
    ;;

    let comma_separated =
      Command.make
        ~summary:"Named_with_default__comma_separated"
        (let open Command.Std in
         let+ who =
           Arg.named_with_default
             [ "who" ]
             (Param.comma_separated Param.string)
             ~default:[ "World" ]
             ~doc:"Hello WHO?"
         in
         List.iter who ~f:(fun who -> print_endline ("Hello " ^ who)))
    ;;

    let main =
      Command.group
        ~summary:"Testing named-with-default"
        [ "create", create
        ; "string", string
        ; "stringable", stringable
        ; "validated", validated
        ; "comma-separated", comma_separated
        ]
    ;;
  end

  let main =
    Command.group ~summary:"Named arguments" [ "with-default", With_default.main ]
  ;;
end

let main =
  Command.group
    ~summary:"Cram Test Command"
    [ "doc", Doc.main; "named", Named.main; "return", return ]
;;
