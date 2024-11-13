module Config = struct
  type t =
    { auto_add_short_aliases : bool
    ; auto_add_one_dash_aliases : bool
    ; full_flags_required : bool
    }

  let create
    ?(auto_add_short_aliases = false)
    ?(auto_add_one_dash_aliases = false)
    ?(full_flags_required = true)
    ()
    =
    { auto_add_short_aliases; auto_add_one_dash_aliases; full_flags_required }
  ;;
end

module Nonempty_list = struct
  type 'a t = 'a Cmdlang.Command.Nonempty_list.t = ( :: ) : 'a * 'a list -> 'a t
end

module Param = struct
  type 'a t = { arg_type : 'a Command.Arg_type.t }

  let translate : type a. a Ast.Param.t -> config:Config.t -> a t =
    fun ast ~config:(_ : Config.t) ->
    let rec translate : type a. a Ast.Param.t -> a t = function
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
      | Comma_separated t ->
        { arg_type = Command.Arg_type.comma_separated (t |> translate).arg_type }
    in
    translate ast
  ;;

  let rec docv : type a. a Ast.Param.t -> string option = function
    | Conv { docv; parse = _; print = _ } -> docv
    | String -> Some "STRING"
    | Int -> Some "INT"
    | Float -> Some "FLOAT"
    | Bool -> Some "BOOL"
    | File -> Some "FILE"
    | Enum { docv; choices = _; to_string = _ } -> docv
    | Comma_separated param ->
      docv param |> Option.map ~f:(fun docv -> Printf.sprintf "[%s,..]" docv)
  ;;
end

module Arg = struct
  type 'a t = { param : 'a Command.Param.t }

  let docv_of_param ~docv ~param =
    match docv with
    | Some docv -> docv
    | None -> Param.docv param |> Option.value ~default:"VAL"
  ;;

  let doc_of_param ~docv ~doc ~param = docv_of_param ~docv ~param ^ " " ^ doc

  let translate_flag_names (hd :: tl : _ Nonempty_list.t) ~(config : Config.t) =
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

  let check_positional_index ~last_positional_index ~next_positional_index =
    let expected = !last_positional_index + 1 in
    if next_positional_index = expected
    then last_positional_index := next_positional_index
    else
      Error.raise_s
        [%sexp
          "Positional arguments must be supplied in consecutive order"
          , { expected : int; got = (next_positional_index : int) }]
  ;;

  let translate : type a. a Ast.Arg.t -> config:Config.t -> a t =
    fun ast ~(config : Config.t) ->
    let last_positional_index = ref (-1) in
    let rec translate : type a. a Ast.Arg.t -> a t = function
      | Return x -> { param = Command.Param.return x }
      | Map { x; f } ->
        let { param = x } = translate x in
        { param = Command.Param.map x ~f }
      | Both (a, b) ->
        let { param = a } = translate a in
        let { param = b } = translate b in
        { param = Command.Param.both a b }
      | Apply { f; x } ->
        let { param = f } = translate f in
        let { param = x } = translate x in
        { param = Command.Param.apply f x }
      | Flag { names; doc } ->
        let (name :: aliases) = translate_flag_names names ~config in
        let flag = Command.Flag.no_arg in
        { param = Command.Param.flag ~aliases name flag ~doc }
      | Flag_count { names = hd :: tl; doc } ->
        raise_s
          [%sexp
            "Flag_count not supported by core.command"
            , { names = (hd :: tl : string list); doc : string }]
      | Named { names; param; docv; doc } ->
        let (name :: aliases) = translate_flag_names names ~config in
        let { Param.arg_type } = Param.translate param ~config in
        { param =
            Command.Param.flag
              ~aliases
              ?full_flag_required:(Option.some_if config.full_flags_required ())
              name
              (Command.Flag.required arg_type)
              ~doc:(doc_of_param ~docv ~doc ~param)
        }
      | Named_multi { names; param; docv; doc } ->
        let (name :: aliases) = translate_flag_names names ~config in
        let { Param.arg_type } = Param.translate param ~config in
        { param =
            Command.Param.flag
              ~aliases
              ?full_flag_required:(Option.some_if config.full_flags_required ())
              name
              (Command.Flag.listed arg_type)
              ~doc:(doc_of_param ~docv ~doc ~param)
        }
      | Named_opt { names; param; docv; doc } ->
        let (name :: aliases) = translate_flag_names names ~config in
        let { Param.arg_type } = Param.translate param ~config in
        { param =
            Command.Param.flag
              ~aliases
              ?full_flag_required:(Option.some_if config.full_flags_required ())
              name
              (Command.Flag.optional arg_type)
              ~doc:(doc_of_param ~docv ~doc ~param)
        }
      | Named_with_default { names; param; default; docv; doc } ->
        let (name :: aliases) = translate_flag_names names ~config in
        let { Param.arg_type } = Param.translate param ~config in
        { param =
            Command.Param.flag
              ~aliases
              ?full_flag_required:(Option.some_if config.full_flags_required ())
              name
              (Command.Flag.optional_with_default default arg_type)
              ~doc:(doc_of_param ~docv ~doc ~param)
        }
      | Pos { pos; param; docv; doc = _ } ->
        check_positional_index ~last_positional_index ~next_positional_index:pos;
        let { Param.arg_type } = Param.translate param ~config in
        let anon = Command.Anons.(docv_of_param ~docv ~param %: arg_type) in
        { param = Command.Param.anon anon }
      | Pos_opt { pos; param; docv; doc = _ } ->
        check_positional_index ~last_positional_index ~next_positional_index:pos;
        let { Param.arg_type } = Param.translate param ~config in
        let anon = Command.Anons.(docv_of_param ~docv ~param %: arg_type) in
        { param = Command.Param.anon (Command.Anons.maybe anon) }
      | Pos_with_default { pos; param; default; docv; doc = _ } ->
        check_positional_index ~last_positional_index ~next_positional_index:pos;
        let { Param.arg_type } = Param.translate param ~config in
        let anon = Command.Anons.(docv_of_param ~docv ~param %: arg_type) in
        { param = Command.Param.anon (Command.Anons.maybe_with_default default anon) }
      | Pos_all { param; docv; doc = _ } ->
        let { Param.arg_type } = Param.translate param ~config in
        let anon = Command.Anons.(docv_of_param ~docv ~param %: arg_type) in
        { param = Command.Param.anon (Command.Anons.sequence anon) }
    in
    translate ast
  ;;
end

module Command = struct
  let unit ?config command =
    let config =
      match config with
      | Some config -> config
      | None -> Config.create ()
    in
    let rec unit : unit Ast.Command.t -> Command.t =
      fun command ->
      match command with
      | Make { arg; summary; readme } ->
        let { Arg.param } = arg |> Arg.translate ~config in
        Command.basic
          ~summary
          ?readme
          (let%map_open.Command () = param in
           fun () -> ())
      | Group { default = _; readme; summary; subcommands } ->
        Command.group
          ~summary
          ?readme
          (List.map subcommands ~f:(fun (name, arg) -> name, arg |> unit))
    in
    unit command
  ;;

  let basic ?config command =
    let config =
      match config with
      | Some config -> config
      | None -> Config.create ()
    in
    let rec basic : (unit -> unit) Ast.Command.t -> Command.t =
      fun command ->
      match command with
      | Make { arg; summary; readme } ->
        let { Arg.param } = arg |> Arg.translate ~config in
        Command.basic ~summary ?readme param
      | Group { default = _; summary; readme; subcommands } ->
        Command.group
          ~summary
          ?readme
          (List.map subcommands ~f:(fun (name, arg) -> name, arg |> basic))
    in
    basic command
  ;;

  let or_error ?config command =
    let config =
      match config with
      | Some config -> config
      | None -> Config.create ()
    in
    let rec or_error : (unit -> unit Or_error.t) Ast.Command.t -> Command.t =
      fun command ->
      match command with
      | Make { arg; summary; readme } ->
        let { Arg.param } = arg |> Arg.translate ~config in
        Command.basic_or_error ~summary ?readme param
      | Group { default = _; summary; readme; subcommands } ->
        Command.group
          ~summary
          ?readme
          (List.map subcommands ~f:(fun (name, arg) -> name, arg |> or_error))
    in
    or_error command
  ;;
end

module To_ast = Cmdlang.Command.Private.To_ast

let param p ~config = (p |> To_ast.param |> Param.translate ~config).arg_type
let arg a ~config = (a |> To_ast.arg |> Arg.translate ~config).param
let command_unit ?config a = a |> To_ast.command |> Command.unit ?config
let command_basic ?config a = a |> To_ast.command |> Command.basic ?config
let command_or_error ?config a = a |> To_ast.command |> Command.or_error ?config

module Private = struct
  module Arg = Arg
end
