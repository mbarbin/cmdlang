module Config = struct
  type t =
    { auto_add_short_aliases : bool
    ; auto_add_one_dash_aliases : bool
    ; full_flags_required : bool
    }

  let create
    ?(auto_add_short_aliases = true)
    ?(auto_add_one_dash_aliases = false)
    ?(full_flags_required = true)
    ()
    =
    { auto_add_short_aliases; auto_add_one_dash_aliases; full_flags_required }
  ;;
end

module Nonempty_list = struct
  type 'a t = 'a Commandlang.Command.Nonempty_list.t = ( :: ) : 'a * 'a list -> 'a t
end

module Param = struct
  type 'a t = { arg_type : 'a Command.Arg_type.t }

  let project : type a. a Ast.Param.t -> a t = function
    | Conv { docv = _; parse; print = _ } ->
      let parse s =
        match parse s with
        | Ok ok -> ok
        | Error (`Msg str) -> Error.raise_s [%sexp Msg (str : string)]
      in
      { arg_type = Command.Arg_type.create parse }
    | String -> { arg_type = Command.Arg_type.Export.string }
    | Int -> { arg_type = Command.Arg_type.Export.int }
    | Float -> { arg_type = Command.Arg_type.Export.float }
    | Bool -> { arg_type = Command.Arg_type.Export.bool }
    | File -> { arg_type = Command.Arg_type.Export.string }
    | Enum { docv; choices = hd :: tl } ->
      { arg_type =
          Command.Arg_type.of_alist_exn
            ~list_values_in_help:(Option.is_none docv)
            (hd :: tl)
      }
  ;;
end

let project_flag_names (hd :: tl : _ Nonempty_list.t) ~(config : Config.t) =
  let map_flag name = if String.length name = 1 then name else "--" ^ name in
  let present = Set.of_list (module String) (hd :: tl) in
  let tl =
    List.concat
      [ (if String.length hd > 1 && config.auto_add_short_aliases
         then (
           let short_alias = String.sub hd ~pos:0 ~len:1 in
           if Set.mem present short_alias then [] else [ short_alias ])
         else [])
      ; (if String.length hd > 1 && config.auto_add_one_dash_aliases then [ hd ] else [])
      ; List.map tl ~f:map_flag
      ]
  in
  Nonempty_list.(map_flag hd :: tl)
;;

module Arg = struct
  type 'a t = { param : 'a Command.Param.t }

  let project : type a. a Ast.Arg.t -> config:Config.t -> a t =
    fun ast ~(config : Config.t) ->
    let rec project : type a. a Ast.Arg.t -> a t = function
      | Return x -> { param = Command.Param.return x }
      | Map { x; f } ->
        let { param = x } = project x in
        { param = Command.Param.map x ~f }
      | Both (a, b) ->
        let { param = a } = project a in
        let { param = b } = project b in
        { param = Command.Param.both a b }
      | Apply { f; x } ->
        let { param = f } = project f in
        let { param = x } = project x in
        { param = Command.Param.apply f x }
      | Flag { names; doc } ->
        let (name :: aliases) = project_flag_names names ~config in
        let flag = Command.Flag.no_arg in
        { param = Command.Param.flag ~aliases name flag ~doc }
      | Named_opt { names; doc; docv; param } ->
        let (name :: aliases) = project_flag_names names ~config in
        let { Param.arg_type } = param |> Param.project in
        { param =
            Command.Param.flag
              ~aliases
              ?full_flag_required:(Option.some_if config.full_flags_required ())
              name
              (Command.Flag.optional arg_type)
              ~doc:
                (match docv with
                 | None -> doc
                 | Some docv -> docv ^ " " ^ doc)
        }
      | Named_with_default { names; doc; docv; param; default } ->
        let (name :: aliases) = project_flag_names names ~config in
        let { Param.arg_type } = param |> Param.project in
        { param =
            Command.Param.flag
              ~aliases
              ?full_flag_required:(Option.some_if config.full_flags_required ())
              name
              (Command.Flag.optional_with_default default arg_type)
              ~doc:
                (match docv with
                 | None -> doc
                 | Some docv -> docv ^ " " ^ doc)
        }
      | Named_req { names; doc; docv; param } ->
        let (name :: aliases) = project_flag_names names ~config in
        let { Param.arg_type } = param |> Param.project in
        { param =
            Command.Param.flag
              ~aliases
              ?full_flag_required:(Option.some_if config.full_flags_required ())
              name
              (Command.Flag.required arg_type)
              ~doc:
                (match docv with
                 | None -> doc
                 | Some docv -> docv ^ " " ^ doc)
        }
    in
    project ast
  ;;
end

module Command = struct
  let basic ?config command =
    let config =
      match config with
      | Some config -> config
      | None -> Config.create ()
    in
    let rec basic : unit Ast.Command.t -> Command.t =
      fun command ->
      match command with
      | Make { arg; doc } ->
        let { Arg.param } = arg |> Arg.project ~config in
        Command.basic
          ~summary:doc
          ?readme:None
          (let%map.Command param = param in
           fun () -> param)
      | Group { default = _; doc; subcommands } ->
        Command.group
          ~summary:doc
          (List.map subcommands ~f:(fun (name, arg) -> name, arg |> basic))
    in
    basic command
  ;;
end

module To_ast = Commandlang.Command.Private.To_ast

let _param p = p |> To_ast.param |> Param.project
let _arg a = a |> To_ast.arg |> Arg.project
let basic ?config a = a |> To_ast.command |> Command.basic ?config
