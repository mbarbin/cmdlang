module Param = struct
  let rec project : type a. a Ast.Param.t -> a Climate.Arg_parser.conv = function
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
    | Enum { docv; choices = hd :: tl } ->
      let choices = hd :: tl in
      let eq a b =
        (* We are basing this function on the fact that climate cannot produce
           values of type ['a] out of thin air, rather the values that are going
           to be supplied to [eq] necessarily come from [choices]. Thus we can
           base the equality function from that of the attached string
           mnemonics (alternatively, this could also be done in climate). *)
        if a == b
        then true
        else (
          match
            ( List.find_opt (fun (_, x) -> x == a) choices
            , List.find_opt (fun (_, x) -> x == b) choices )
          with
          | Some (a, _), Some (b, _) -> String.equal a b
          | Some _, None | None, Some _ | None, None -> false)
      in
      Climate.Arg_parser.enum ?default_value_name:docv choices ~eq
    | Comma_separated t ->
      let { Climate.Arg_parser.parse; print; default_value_name; completion = _ } =
        project t
      in
      let parse str =
        match String.split_on_char ',' str |> List.map parse with
        | exception e -> Error (`Msg (Printexc.to_string e))
        | r ->
          let ok, msgs =
            r
            |> List.partition_map (function
              | Ok x -> Left x
              | Error (`Msg e) -> Right e)
          in
          (match msgs with
           | [] -> Ok ok
           | _ :: _ -> Error (`Msg (String.concat ", " msgs)))
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
  let rec project : type a. a Ast.Arg.t -> a Climate.Arg_parser.t = function
    | Return x -> Climate.Arg_parser.const x
    | Map { x; f } -> Climate.Arg_parser.map (project x) ~f
    | Both (a, b) -> Climate.Arg_parser.both (project a) (project b)
    | Apply { f; x } -> Climate.Arg_parser.apply (project f) (project x)
    | Flag { names = hd :: tl; doc } -> Climate.Arg_parser.flag ~desc:doc (hd :: tl)
    | Flag_count { names = hd :: tl; doc } ->
      Climate.Arg_parser.flag_count ~desc:doc (hd :: tl)
    | Named { names = hd :: tl; param; docv; doc } ->
      Climate.Arg_parser.named_req
        ~desc:doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.project)
    | Named_multi { names = hd :: tl; param; docv; doc } ->
      Climate.Arg_parser.named_multi
        ~desc:doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.project)
    | Named_opt { names = hd :: tl; param; docv; doc } ->
      Climate.Arg_parser.named_opt
        ~desc:doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.project)
    | Named_with_default { names = hd :: tl; param; default; docv; doc } ->
      Climate.Arg_parser.named_with_default
        ~desc:doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.project)
        ~default
    | Pos { pos; param; docv; doc = _ } ->
      Climate.Arg_parser.pos_req ?value_name:docv pos (param |> Param.project)
    | Pos_opt { pos; param; docv; doc = _ } ->
      Climate.Arg_parser.pos_opt ?value_name:docv pos (param |> Param.project)
    | Pos_with_default { pos; param; default; docv; doc = _ } ->
      Climate.Arg_parser.pos_with_default
        ?value_name:docv
        pos
        (param |> Param.project)
        ~default
    | Pos_all { param; docv; doc = _ } ->
      Climate.Arg_parser.pos_all ?value_name:docv (param |> Param.project)
  ;;
end

module Command = struct
  let desc ~summary ~readme =
    match readme with
    | None -> summary
    | Some readme -> summary ^ "\n" ^ readme ()
  ;;

  let rec to_command : type a. a Ast.Command.t -> a Climate.Command.t =
    fun command ->
    match command with
    | Make { arg; summary; readme } ->
      Climate.Command.singleton ~desc:(desc ~summary ~readme) (arg |> Arg.project)
    | Group { default; summary; readme; subcommands } ->
      let cmds = subcommands |> List.map (fun (name, arg) -> to_subcommand arg ~name) in
      Climate.Command.group
        ?default_arg_parser:(default |> Option.map Arg.project)
        ~desc:(desc ~summary ~readme)
        cmds

  and to_subcommand
    : type a. a Ast.Command.t -> name:string -> a Climate.Command.subcommand
    =
    fun command ~name -> Climate.Command.subcommand name (to_command command)
  ;;
end

module To_ast = Cmdlang.Command.Private.To_ast

let _param p = p |> To_ast.param |> Param.project
let _arg a = a |> To_ast.arg |> Arg.project
let command a = a |> To_ast.command |> Command.to_command

module Private = struct
  module Arg = Arg
end
