(*********************************************************************************)
(*  cmdlang - Declarative command-line parsing for OCaml                         *)
(*  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*  SPDX-License-Identifier: MIT                                                 *)
(*********************************************************************************)

module Param = struct
  let rec translate : type a. a Ast.Param.t -> a Climate.Arg_parser.conv = function
    | Conv { docv; parse; print } ->
      { Climate.Arg_parser.parse
      ; print
      ; default_value_name = docv |> Option.value ~default:"VAL"
      ; completion = None
      }
    | String -> Climate.Arg_parser.string
    | Int -> Climate.Arg_parser.int
    | Float -> Climate.Arg_parser.float
    | Bool -> Climate.Arg_parser.bool
    | File -> Climate.Arg_parser.file
    | Enum { docv; choices = hd :: tl; to_string } ->
      let choices = hd :: tl in
      let str x =
        match List.find_opt (fun (_, y) -> y == x) choices with
        | Some (a, _) -> a
        | None -> to_string x
      in
      let eq a b = a == b || String.equal (str a) (str b) in
      Climate.Arg_parser.enum ?default_value_name:docv choices ~eq
    | Comma_separated t ->
      let { Climate.Arg_parser.parse; print; default_value_name; completion = _ } =
        translate t
      in
      let parse str =
        let ok, msgs =
          str
          |> String.split_on_char ','
          |> List.partition_map (fun arg ->
            match parse arg with
            | Ok x -> Left x
            | Error (`Msg e) -> Right e)
        in
        match msgs with
        | [] -> Ok ok
        | _ :: _ -> Error (`Msg (String.concat ", " msgs))
      in
      let print fmt = function
        | [] -> ()
        | [ e ] -> print fmt e
        | hd :: (_ :: _ as tl) ->
          Format.fprintf fmt "%a," print hd;
          tl |> List.iter (fun i -> Format.fprintf fmt ",%a" print i)
      in
      { Climate.Arg_parser.parse; print; default_value_name; completion = None }
  ;;
end

module Arg = struct
  let fmt_doc ~doc = doc

  let make_doc : type a. doc:string -> param:a Ast.Param.t -> string =
    fun ~doc ~param ->
    match (param : _ Ast.Param.t) with
    | Conv _ | String | Int | Float | Bool | File
    | Enum { docv = _; choices = _; to_string = _ }
    | Comma_separated _ -> fmt_doc ~doc
  ;;

  let rec translate : type a. a Ast.Arg.t -> a Climate.Arg_parser.t = function
    | Return x -> Climate.Arg_parser.const x
    | Map { x; f } -> Climate.Arg_parser.map (translate x) ~f
    | Both (a, b) -> Climate.Arg_parser.both (translate a) (translate b)
    | Apply { f; x } -> Climate.Arg_parser.apply (translate f) (translate x)
    | Flag { names = hd :: tl; doc } ->
      let doc = fmt_doc ~doc in
      Climate.Arg_parser.flag ~doc (hd :: tl)
    | Flag_count { names = hd :: tl; doc } ->
      let doc = fmt_doc ~doc in
      Climate.Arg_parser.flag_count ~doc (hd :: tl)
    | Named { names = hd :: tl; param; docv; doc } ->
      let doc = make_doc ~doc ~param in
      Climate.Arg_parser.named_req
        ~doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.translate)
    | Named_multi { names = hd :: tl; param; docv; doc } ->
      let doc = make_doc ~doc ~param in
      Climate.Arg_parser.named_multi
        ~doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.translate)
    | Named_opt { names = hd :: tl; param; docv; doc } ->
      let doc = make_doc ~doc ~param in
      Climate.Arg_parser.named_opt
        ~doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.translate)
    | Named_with_default { names = hd :: tl; param; default; docv; doc } ->
      let doc = make_doc ~doc ~param in
      Climate.Arg_parser.named_with_default
        ~doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.translate)
        ~default
    | Pos { pos; param; docv; doc } ->
      let doc = make_doc ~doc ~param in
      Climate.Arg_parser.pos_req ~doc ?value_name:docv pos (param |> Param.translate)
    | Pos_opt { pos; param; docv; doc } ->
      let doc = make_doc ~doc ~param in
      Climate.Arg_parser.pos_opt ~doc ?value_name:docv pos (param |> Param.translate)
    | Pos_with_default { pos; param; default; docv; doc } ->
      let doc = make_doc ~doc ~param in
      Climate.Arg_parser.pos_with_default
        ~doc
        ?value_name:docv
        pos
        (param |> Param.translate)
        ~default
    | Pos_all { param; docv; doc } ->
      let doc = make_doc ~doc ~param in
      Climate.Arg_parser.pos_all ~doc ?value_name:docv (param |> Param.translate)
  ;;
end

module Command = struct
  let doc ~summary ~readme =
    match readme with
    | None -> summary
    | Some readme -> summary ^ "\n" ^ readme ()
  ;;

  let rec to_command : type a. a Ast.Command.t -> a Climate.Command.t =
    fun command ->
    match command with
    | Make { arg; summary; readme } ->
      Climate.Command.singleton ~doc:(doc ~summary ~readme) (arg |> Arg.translate)
    | Group { default; summary; readme; subcommands } ->
      let cmds = subcommands |> List.map (fun (name, arg) -> to_subcommand arg ~name) in
      Climate.Command.group
        ?default_arg_parser:(default |> Option.map Arg.translate)
        ~doc:(doc ~summary ~readme)
        cmds

  and to_subcommand
    : type a. a Ast.Command.t -> name:string -> a Climate.Command.subcommand
    =
    fun command ~name -> Climate.Command.subcommand name (to_command command)
  ;;
end

module To_ast = Cmdlang.Command.Private.To_ast

let param p = p |> To_ast.param |> Param.translate
let arg a = a |> To_ast.arg |> Arg.translate
let command a = a |> To_ast.command |> Command.to_command

module Private = struct end
