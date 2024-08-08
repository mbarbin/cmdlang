module Param = struct
  let project : type a. a Ast.Param.t -> a Cmdliner.Arg.conv = function
    | Conv { docv; parse; print } -> Cmdliner.Arg.conv ~docv (parse, print)
    | String -> Cmdliner.Arg.string
    | Int -> Cmdliner.Arg.int
    | Float -> Cmdliner.Arg.float
    | Bool -> Cmdliner.Arg.bool
    | File -> Cmdliner.Arg.file
    | Enum { docv = _; choices = hd :: tl } -> Cmdliner.Arg.enum (hd :: tl)
  ;;
end

module Arg = struct
  let rec project : type a. a Ast.Arg.t -> a Cmdliner.Term.t = function
    | Return x -> Cmdliner.Term.const x
    | Map { x; f } -> Cmdliner.Term.map f (project x)
    | Both (a, b) -> Cmdliner.Term.product (project a) (project b)
    | Apply { f; x } -> Cmdliner.Term.app (project f) (project x)
    | Flag { names = hd :: tl; doc } ->
      Cmdliner.Arg.value (Cmdliner.Arg.flag (Cmdliner.Arg.info ~doc (hd :: tl)))
    | Named_opt { names = hd :: tl; doc; docv; param } ->
      Cmdliner.Arg.value
        (Cmdliner.Arg.opt
           (Cmdliner.Arg.some' (Param.project param))
           None
           (Cmdliner.Arg.info ?docv ~doc (hd :: tl)))
    | Named_with_default { names = hd :: tl; doc; docv; param; default } ->
      Cmdliner.Arg.value
        (Cmdliner.Arg.opt
           (Param.project param)
           default
           (Cmdliner.Arg.info ?docv ~doc (hd :: tl)))
    | Named_req { names = hd :: tl; doc; docv; param } ->
      Cmdliner.Arg.required
        (Cmdliner.Arg.opt
           (Cmdliner.Arg.some' (Param.project param))
           None
           (Cmdliner.Arg.info ?docv ~doc (hd :: tl)))
  ;;
end

module Command = struct
  let rec project : type a. a Ast.Command.t -> name:string -> a Cmdliner.Cmd.t =
    fun command ~name ->
    match command with
    | Make { arg; doc } ->
      let info = Cmdliner.Cmd.info name ~doc in
      Cmdliner.Cmd.v info (Arg.project arg)
    | Group { default; doc; subcommands } ->
      let cmds = subcommands |> List.map (fun (name, arg) -> project arg ~name) in
      let info = Cmdliner.Cmd.info name ~doc in
      Cmdliner.Cmd.group ?default:(default |> Option.map Arg.project) info cmds
  ;;
end

module To_ast = Commandlang.Command.Private.To_ast

let _param p = p |> To_ast.param |> Param.project
let _arg a = a |> To_ast.arg |> Arg.project
let command a ~name = a |> To_ast.command |> Command.project ~name
