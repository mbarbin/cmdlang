module Param = struct
  let project : type a. a Ast.Param.t -> a Climate.Arg_parser.conv = function
    | Conv { docv; parse; print } ->
      { Climate.Arg_parser.parse; print; default_value_name = docv; completion = None }
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
  ;;
end

module Arg = struct
  let rec project : type a. a Ast.Arg.t -> a Climate.Arg_parser.t = function
    | Return x -> Climate.Arg_parser.const x
    | Map { x; f } -> Climate.Arg_parser.map (project x) ~f
    | Both (a, b) -> Climate.Arg_parser.both (project a) (project b)
    | Apply { f; x } -> Climate.Arg_parser.apply (project f) (project x)
    | Flag { names = hd :: tl; doc } -> Climate.Arg_parser.flag ~desc:doc (hd :: tl)
    | Named_opt { names = hd :: tl; doc; docv; param } ->
      Climate.Arg_parser.named_opt
        ~desc:doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.project)
    | Named_with_default { names = hd :: tl; doc; docv; param; default } ->
      Climate.Arg_parser.named_with_default
        ~desc:doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.project)
        ~default
    | Named { names = hd :: tl; doc; docv; param } ->
      Climate.Arg_parser.named_req
        ~desc:doc
        ?value_name:docv
        (hd :: tl)
        (param |> Param.project)
    | Pos { doc = _; docv; index; param } ->
      Climate.Arg_parser.pos_req ?value_name:docv index (param |> Param.project)
    | Pos_opt { doc = _; docv; index; param } ->
      Climate.Arg_parser.pos_opt ?value_name:docv index (param |> Param.project)
    | Pos_with_default { doc = _; docv; index; param; default } ->
      Climate.Arg_parser.pos_with_default
        ?value_name:docv
        index
        (param |> Param.project)
        ~default
    | Pos_all { doc = _; docv; param } ->
      Climate.Arg_parser.pos_all ?value_name:docv (param |> Param.project)
  ;;
end

module Command = struct
  let rec to_command : type a. a Ast.Command.t -> a Climate.Command.t =
    fun command ->
    match command with
    | Make { arg; summary } -> Climate.Command.singleton ~desc:summary (arg |> Arg.project)
    | Group { default; summary; subcommands } ->
      let cmds = subcommands |> List.map (fun (name, arg) -> to_subcommand arg ~name) in
      Climate.Command.group
        ?default_arg_parser:(default |> Option.map Arg.project)
        ~desc:summary
        cmds

  and to_subcommand
    : type a. a Ast.Command.t -> name:string -> a Climate.Command.subcommand
    =
    fun command ~name -> Climate.Command.subcommand name (to_command command)
  ;;
end

module To_ast = Commandlang.Command.Private.To_ast

let _param p = p |> To_ast.param |> Param.project
let _arg a = a |> To_ast.arg |> Arg.project
let command a = a |> To_ast.command |> Command.to_command
