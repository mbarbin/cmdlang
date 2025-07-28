let return =
  Command.make
    ~summary:"An empty command."
    (let open Command.Std in
     let+ () = Arg.return () in
     print_endline "()")
;;

module Flags = struct
  let names =
    Command.make
      ~summary:"Various flags."
      (let open Command.Std in
       let+ _ = Arg.flag [ "a" ] ~doc:"A short flag."
       and+ _ = Arg.flag [ "long" ] ~doc:"A long flag." in
       ())
  ;;

  let main = Command.group ~summary:"Flags." [ "names", names ]
end

module Basic = struct
  let string =
    Command.make
      ~summary:"Print string."
      (let open Command.Std in
       let+ v = Arg.pos ~pos:0 Param.string ~doc:"A param with a value." in
       print_endline v)
  ;;

  let int =
    Command.make
      ~summary:"Print int."
      (let open Command.Std in
       let+ v = Arg.pos ~pos:0 Param.int ~doc:"A param with a value." in
       print_endline (Int.to_string v))
  ;;

  let float =
    Command.make
      ~summary:"Print float."
      (let open Command.Std in
       let+ v = Arg.pos ~pos:0 Param.float ~doc:"A param with a value." in
       print_endline (Float.to_string v))
  ;;

  let bool =
    Command.make
      ~summary:"Print bool."
      (let open Command.Std in
       let+ v = Arg.pos ~pos:0 Param.bool ~doc:"A param with a value." in
       print_endline (Bool.to_string v))
  ;;

  let file =
    Command.make
      ~summary:"Print file."
      (let open Command.Std in
       let+ v = Arg.pos ~pos:0 Param.file ~doc:"A param with a value." in
       print_endline v)
  ;;

  let main =
    Command.group
      ~summary:"Basic types."
      [ "string", string; "int", int; "float", float; "bool", bool; "file", file ]
  ;;
end

module Enum = struct
  module Color = struct
    type t =
      | Red
      | Green
      | Blue

    let all = [ Red; Green; Blue ]

    let to_string = function
      | Red -> "red"
      | Green -> "green"
      | Blue -> "blue"
    ;;
  end

  let color_param = Command.Param.enumerated ~docv:"COLOR" (module Color)

  let pos =
    Command.make
      ~summary:"Print color."
      (let open Command.Std in
       let+ color = Arg.pos ~pos:0 color_param ~doc:"A color." in
       print_endline (Color.to_string color))
  ;;

  let named =
    Command.make
      ~summary:"Print color."
      (let open Command.Std in
       let+ color = Arg.named [ "color" ] color_param ~doc:"A color." in
       print_endline (Color.to_string color))
  ;;

  let main = Command.group ~summary:"Enum types." [ "named", named; "pos", pos ]
end

module Doc = struct
  let singleton_with_readme =
    Command.make
      ~summary:"Singleton command with a readme."
      ~readme:(fun () -> "This is a readme.\nIt can be written on multiple lines.")
      (let open Command.Std in
       let+ () = Arg.return () in
       (() [@coverage off]))
  ;;

  let args_doc_end_with_dots =
    Command.make
      ~summary:"Args doc end with dots."
      (let open Command.Std in
       let+ _ =
         Arg.pos ~pos:0 Param.string ~doc:"The doc for [a] in the code ends with a dot."
       and+ _ = Arg.pos ~pos:1 Param.string ~doc:"The doc for [b] doesn't" in
       (() [@coverage off]))
  ;;

  let main =
    Command.group
      ~summary:"Testing documentation features."
      ~readme:(fun () -> "This group is dedicated to testing documentation features.")
      [ "args-doc-end-with-dots", args_doc_end_with_dots
      ; "singleton-with-readme", singleton_with_readme
      ]
  ;;
end

module Named = struct
  module Opt = struct
    let string_with_docv =
      Command.make
        ~summary:"Named_opt__string_with_docv"
        (let open Command.Std in
         let+ who = Arg.named_opt [ "who" ] Param.string ~docv:"WHO" ~doc:"Hello WHO?" in
         Option.iter who ~f:(fun who -> print_endline ("Hello " ^ who)))
    ;;

    let string_without_docv =
      Command.make
        ~summary:"Named_opt__string_without_docv"
        (let open Command.Std in
         let+ who = Arg.named_opt [ "who" ] Param.string ~doc:"Hello WHO?" in
         (ignore (who : string option) [@coverage off]))
    ;;

    let main =
      Command.group
        ~summary:"Testing named-opt"
        [ "string-with-docv", string_with_docv
        ; "string-without-docv", string_without_docv
        ]
    ;;
  end

  module With_default = struct
    let int =
      Command.make
        ~summary:"Named_with_default__int"
        (let open Command.Std in
         let+ x =
           Arg.named_with_default
             [ "x" ]
             Param.int
             ~docv:"X"
             ~default:42
             ~doc:"Print Hello X."
         in
         print_endline ("Hello " ^ Int.to_string x))
    ;;

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

    let float =
      Command.make
        ~summary:"Named_with_default__float"
        (let open Command.Std in
         let+ x =
           Arg.named_with_default
             [ "x" ]
             Param.float
             ~docv:"X"
             ~default:42.
             ~doc:"Print Hello X."
         in
         print_endline ("Hello " ^ Float.to_string x))
    ;;

    let bool =
      Command.make
        ~summary:"Named_with_default__bool"
        (let open Command.Std in
         let+ x =
           Arg.named_with_default
             [ "x" ]
             Param.bool
             ~docv:"X"
             ~default:true
             ~doc:"Print Hello X."
         in
         print_endline ("Hello " ^ Bool.to_string x))
    ;;

    let file =
      Command.make
        ~summary:"Named_with_default__file"
        (let open Command.Std in
         let+ x =
           Arg.named_with_default
             [ "x" ]
             Param.file
             ~docv:"X"
             ~default:"path/to/file"
             ~doc:"Print Hello X."
         in
         print_endline ("Hello " ^ x))
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
        ; "int", int
        ; "string", string
        ; "float", float
        ; "bool", bool
        ; "file", file
        ; "stringable", stringable
        ; "validated", validated
        ; "comma-separated", comma_separated
        ]
    ;;
  end

  let main =
    Command.group
      ~summary:"Named arguments"
      [ "opt", Opt.main; "with-default", With_default.main ]
  ;;
end

module Group = struct
  (* We express the handler for this group as delayed function. This is not
     required to test default command, rather this is used in order to test the
     mapping of command handlers. *)

  let a =
    Command.make
      ~summary:"Do nothing."
      (let open Command.Std in
       let+ () = Arg.return () in
       fun () -> ())
  ;;

  let default =
    let open Command.Std in
    let+ name = Arg.pos ~pos:0 Param.string ~doc:"A name to greet." in
    fun () -> print_endline ("Hello " ^ name)
  ;;

  let main =
    Command.group ~summary:"A group command with a default." ~default [ "a", a ]
    |> Command.Utils.map ~f:(fun f -> f ())
  ;;
end

let main =
  Command.group
    ~summary:"Cram Test Commands."
    [ "basic", Basic.main
    ; "doc", Doc.main
    ; "enum", Enum.main
    ; "flags", Flags.main
    ; "group", Group.main
    ; "named", Named.main
    ; "return", return
    ]
;;
