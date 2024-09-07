module Param = struct
  let rec project : type a. a Ast.Param.t -> a Cmdliner.Arg.conv = function
    | Conv { docv; parse; print } -> Cmdliner.Arg.conv ?docv (parse, print)
    | String -> Cmdliner.Arg.string
    | Int -> Cmdliner.Arg.int
    | Float -> Cmdliner.Arg.float
    | Bool -> Cmdliner.Arg.bool
    | File -> Cmdliner.Arg.file
    | Enum { docv = _; choices = hd :: tl } -> Cmdliner.Arg.enum (hd :: tl)
    | Comma_separated param -> Cmdliner.Arg.list ~sep:',' (project param)
  ;;

  let rec docv : type a. a Ast.Param.t -> string option = function
    | Conv { docv; parse = _; print = _ } -> docv
    | String -> Some "STRING"
    | Int -> Some "INT"
    | Float -> Some "FLOAT"
    | Bool -> Some "BOOL"
    | File -> Some "FILE"
    | Enum { docv; choices = _ } -> docv
    | Comma_separated param ->
      docv param |> Option.map (fun docv -> Printf.sprintf "[%s,..]" docv)
  ;;
end

module Arg = struct
  let docv_of_param ~docv ~param =
    match docv with
    | Some _ -> docv
    | None -> Param.docv param
  ;;

  let with_dot_suffix ~doc =
    let needs_dot =
      let trim = String.trim doc in
      String.length trim > 0 && trim.[String.length trim - 1] <> '.'
    in
    if needs_dot then doc ^ "." else doc
  ;;

  let rec doc_of_param : type a. doc:string -> param:a Ast.Param.t -> string =
    fun ~doc ~param ->
    match (param : _ Ast.Param.t) with
    | Conv _ | String | Int | Float | Bool | File -> with_dot_suffix ~doc
    | Enum { docv = _; choices = hd :: tl } ->
      Printf.sprintf
        "%s. $(docv) must be %s."
        doc
        (Cmdliner.Arg.doc_alts_enum ~quoted:true (hd :: tl))
    | Comma_separated param -> doc_of_param ~doc:(doc ^ " (comma-separated)") ~param
  ;;

  let rec project : type a. a Ast.Arg.t -> a Cmdliner.Term.t = function
    | Return x -> Cmdliner.Term.const x
    | Map { x; f } -> Cmdliner.Term.map f (project x)
    | Both (a, b) -> Cmdliner.Term.product (project a) (project b)
    | Apply { f; x } -> Cmdliner.Term.app (project f) (project x)
    | Flag { names = hd :: tl; doc } ->
      let doc = with_dot_suffix ~doc in
      Cmdliner.Arg.value (Cmdliner.Arg.flag (Cmdliner.Arg.info ~doc (hd :: tl)))
    | Flag_count { names = hd :: tl; doc } ->
      let doc = with_dot_suffix ~doc in
      Cmdliner.Arg.value (Cmdliner.Arg.flag_all (Cmdliner.Arg.info ~doc (hd :: tl)))
      |> Cmdliner.Term.map List.length
    | Named { names = hd :: tl; param; docv; doc } ->
      let doc = doc_of_param ~doc ~param in
      let docv = docv_of_param ~docv ~param in
      Cmdliner.Arg.required
        (Cmdliner.Arg.opt
           (Cmdliner.Arg.some (Param.project param))
           None
           (Cmdliner.Arg.info ?docv ~doc (hd :: tl)))
    | Named_multi { names = hd :: tl; param; docv; doc } ->
      let doc = doc_of_param ~doc ~param in
      let docv = docv_of_param ~docv ~param in
      Cmdliner.Arg.value
        (Cmdliner.Arg.opt_all
           (Param.project param)
           []
           (Cmdliner.Arg.info ?docv ~doc (hd :: tl)))
    | Named_opt { names = hd :: tl; param; docv; doc } ->
      let doc = doc_of_param ~doc ~param in
      let docv = docv_of_param ~docv ~param in
      Cmdliner.Arg.value
        (Cmdliner.Arg.opt
           (Cmdliner.Arg.some (Param.project param))
           None
           (Cmdliner.Arg.info ?docv ~doc (hd :: tl)))
    | Named_with_default { names = hd :: tl; param; default; docv; doc } ->
      let doc = doc_of_param ~doc ~param in
      let docv = docv_of_param ~docv ~param in
      Cmdliner.Arg.value
        (Cmdliner.Arg.opt
           (Param.project param)
           default
           (Cmdliner.Arg.info ?docv ~doc (hd :: tl)))
    | Pos { pos; param; docv; doc } ->
      let doc = doc_of_param ~doc ~param in
      let docv = docv_of_param ~docv ~param in
      Cmdliner.Arg.required
        (Cmdliner.Arg.pos
           pos
           (Cmdliner.Arg.some (Param.project param))
           None
           (Cmdliner.Arg.info ?docv ~doc []))
    | Pos_opt { pos; param; docv; doc } ->
      let doc = doc_of_param ~doc ~param in
      let docv = docv_of_param ~docv ~param in
      Cmdliner.Arg.value
        (Cmdliner.Arg.pos
           pos
           (Cmdliner.Arg.some (Param.project param))
           None
           (Cmdliner.Arg.info ?docv ~doc []))
    | Pos_with_default { pos; param; default; docv; doc } ->
      let doc = doc_of_param ~doc ~param in
      let docv = docv_of_param ~docv ~param in
      Cmdliner.Arg.value
        (Cmdliner.Arg.pos
           pos
           (Param.project param)
           default
           (Cmdliner.Arg.info ?docv ~doc []))
    | Pos_all { param; docv; doc } ->
      let doc = doc_of_param ~doc ~param in
      let docv = docv_of_param ~docv ~param in
      Cmdliner.Arg.value
        (Cmdliner.Arg.pos_all (Param.project param) [] (Cmdliner.Arg.info ?docv ~doc []))
  ;;
end

module Command = struct
  type block = [ `P of string ]

  let manpage_of_readme ~readme : block list =
    let readme = readme () in
    let lines = String.split_on_char '\n' readme in
    let paragraphs = Queue.create () in
    let buffer = Buffer.create 256 in
    let flush_line () =
      let line = Buffer.contents buffer in
      if not (String.length line = 0)
      then (
        Queue.push (`P line) paragraphs;
        Buffer.clear buffer)
    in
    let add_separator () = if Buffer.length buffer > 0 then Buffer.add_char buffer ' ' in
    let rec loop lines =
      match lines with
      | [] -> flush_line ()
      | "" :: lines ->
        flush_line ();
        Queue.push (`P "\n") paragraphs;
        loop lines
      | line :: lines ->
        add_separator ();
        Buffer.add_string buffer line;
        loop lines
    in
    loop lines;
    Queue.fold (fun tl hd -> hd :: tl) [] paragraphs |> List.rev
  ;;

  let rec project
    : type a. ?version:string -> a Ast.Command.t -> name:string -> a Cmdliner.Cmd.t
    =
    fun ?version command ~name ->
    match (command : _ Ast.Command.t) with
    | Make { arg; summary; readme } ->
      let info =
        Cmdliner.Cmd.info
          ?man:
            (readme
             |> Option.map (fun readme ->
               (manpage_of_readme ~readme :> Cmdliner.Manpage.block list)))
          ~doc:summary
          ?version
          name
      in
      Cmdliner.Cmd.v info (Arg.project arg)
    | Group { default; summary; readme; subcommands } ->
      let commands = subcommands |> List.map (fun (name, arg) -> project arg ~name) in
      let info =
        Cmdliner.Cmd.info
          ?man:
            (readme
             |> Option.map (fun readme ->
               (manpage_of_readme ~readme :> Cmdliner.Manpage.block list)))
          ~doc:summary
          ?version
          name
      in
      Cmdliner.Cmd.group ?default:(default |> Option.map Arg.project) info commands
  ;;
end

module To_ast = Cmdlang.Command.Private.To_ast

let _param p = p |> To_ast.param |> Param.project
let _arg a = a |> To_ast.arg |> Arg.project
let command ?version a ~name = a |> To_ast.command |> Command.project ?version ~name

module Private = struct
  module Arg = Arg
  module Command = Command
end
