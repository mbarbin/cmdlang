module Config = struct
  type t =
    { auto_add_one_dash_aliases : bool
    ; full_flags_required : bool
    }

  let create ?(auto_add_one_dash_aliases = false) ?(full_flags_required = true) () =
    { auto_add_one_dash_aliases; full_flags_required }
  ;;
end

module Nonempty_list = struct
  type 'a t = 'a Cmdlang.Command.Nonempty_list.t = ( :: ) : 'a * 'a list -> 'a t
end

module Param = struct
  type 'a t = 'a Command.Arg_type.t

  let translate : type a. a Ast.Param.t -> config:Config.t -> a t =
    fun ast ~config:(_ : Config.t) ->
    let rec aux : type a. a Ast.Param.t -> a t = function
      | Conv { docv = _; parse; print = _ } ->
        let parse s =
          match parse s with
          | Ok ok -> ok
          | Error (`Msg str) -> Error.raise_s [%sexp Msg (str : string)]
        in
        Command.Arg_type.create parse
      | String -> Command.Arg_type.Export.string
      | Int -> Command.Arg_type.Export.int
      | Float -> Command.Arg_type.Export.float
      | Bool -> Command.Arg_type.Export.bool
      | File -> Command.Arg_type.Export.string
      | Enum { docv; choices = hd :: tl; to_string = _ } ->
        Command.Arg_type.of_alist_exn ~list_values_in_help:(Option.is_none docv) (hd :: tl)
      | Comma_separated t -> Command.Arg_type.comma_separated (aux t)
    in
    aux ast
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
  type 'a t = 'a Command.Param.t

  let docv_of_param ~docv ~param =
    match docv with
    | Some docv -> docv
    | None -> Param.docv param |> Option.value ~default:"VAL"
  ;;

  let fmt_doc ~doc = doc
  let doc_of_param ~docv ~doc ~param = docv_of_param ~docv ~param ^ " " ^ fmt_doc ~doc

  let translate_flag_names (hd :: tl : _ Nonempty_list.t) ~(config : Config.t) =
    let map_flag name = if String.length name = 1 then name else "--" ^ name in
    let tl =
      List.concat
        [ (if String.length hd > 1 && config.auto_add_one_dash_aliases then [ hd ] else [])
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
    let rec aux : type a. a Ast.Arg.t -> a t = function
      | Return x -> Command.Param.return x
      | Map { x; f } ->
        let x = aux x in
        Command.Param.map x ~f
      | Both (a, b) ->
        let a = aux a in
        let b = aux b in
        Command.Param.both a b
      | Apply { f; x } ->
        let f = aux f in
        let x = aux x in
        Command.Param.apply f x
      | Flag { names; doc } ->
        let doc = fmt_doc ~doc in
        let (name :: aliases) = translate_flag_names names ~config in
        let flag = Command.Flag.no_arg in
        Command.Param.flag ~aliases name flag ~doc
      | Flag_count { names = hd :: tl; doc } ->
        raise_s
          [%sexp
            "Flag_count not supported by core.command"
          , { names = (hd :: tl : string list); doc : string }]
      | Named { names; param; docv; doc } ->
        let (name :: aliases) = translate_flag_names names ~config in
        let arg_type = Param.translate param ~config in
        Command.Param.flag
          ~aliases
          ?full_flag_required:(Option.some_if config.full_flags_required ())
          name
          (Command.Flag.required arg_type)
          ~doc:(doc_of_param ~docv ~doc ~param)
      | Named_multi { names; param; docv; doc } ->
        let (name :: aliases) = translate_flag_names names ~config in
        let arg_type = Param.translate param ~config in
        Command.Param.flag
          ~aliases
          ?full_flag_required:(Option.some_if config.full_flags_required ())
          name
          (Command.Flag.listed arg_type)
          ~doc:(doc_of_param ~docv ~doc ~param)
      | Named_opt { names; param; docv; doc } ->
        let (name :: aliases) = translate_flag_names names ~config in
        let arg_type = Param.translate param ~config in
        Command.Param.flag
          ~aliases
          ?full_flag_required:(Option.some_if config.full_flags_required ())
          name
          (Command.Flag.optional arg_type)
          ~doc:(doc_of_param ~docv ~doc ~param)
      | Named_with_default { names; param; default; docv; doc } ->
        let (name :: aliases) = translate_flag_names names ~config in
        let arg_type = Param.translate param ~config in
        Command.Param.flag
          ~aliases
          ?full_flag_required:(Option.some_if config.full_flags_required ())
          name
          (Command.Flag.optional_with_default default arg_type)
          ~doc:(doc_of_param ~docv ~doc ~param)
      | Pos { pos; param; docv; doc = _ } ->
        check_positional_index ~last_positional_index ~next_positional_index:pos;
        let arg_type = Param.translate param ~config in
        let anon = Command.Anons.(docv_of_param ~docv ~param %: arg_type) in
        Command.Param.anon anon
      | Pos_opt { pos; param; docv; doc = _ } ->
        check_positional_index ~last_positional_index ~next_positional_index:pos;
        let arg_type = Param.translate param ~config in
        let anon = Command.Anons.(docv_of_param ~docv ~param %: arg_type) in
        Command.Param.anon (Command.Anons.maybe anon)
      | Pos_with_default { pos; param; default; docv; doc = _ } ->
        check_positional_index ~last_positional_index ~next_positional_index:pos;
        let arg_type = Param.translate param ~config in
        let anon = Command.Anons.(docv_of_param ~docv ~param %: arg_type) in
        Command.Param.anon (Command.Anons.maybe_with_default default anon)
      | Pos_all { param; docv; doc = _ } ->
        let arg_type = Param.translate param ~config in
        let anon = Command.Anons.(docv_of_param ~docv ~param %: arg_type) in
        Command.Param.anon (Command.Anons.sequence anon)
    in
    aux ast
  ;;
end

module Command = struct
  let config_or_default ~config =
    match config with
    | Some config -> config
    | None -> Config.create ()
  ;;

  let unit ?config command =
    let config = config_or_default ~config in
    let rec aux : unit Ast.Command.t -> Command.t =
      fun command ->
      match command with
      | Make { arg; summary; readme } ->
        let param = arg |> Arg.translate ~config in
        Command.basic
          ~summary
          ?readme
          (let%map_open.Command () = param in
           fun () -> ())
      | Group { default = _; readme; summary; subcommands } ->
        Command.group
          ~summary
          ?readme
          (List.map subcommands ~f:(fun (name, arg) -> name, arg |> aux))
    in
    aux command
  ;;

  let basic ?config command =
    let config = config_or_default ~config in
    let rec aux : (unit -> unit) Ast.Command.t -> Command.t =
      fun command ->
      match command with
      | Make { arg; summary; readme } ->
        let param = arg |> Arg.translate ~config in
        Command.basic ~summary ?readme param
      | Group { default = _; summary; readme; subcommands } ->
        Command.group
          ~summary
          ?readme
          (List.map subcommands ~f:(fun (name, arg) -> name, arg |> aux))
    in
    aux command
  ;;

  let or_error ?config command =
    let config = config_or_default ~config in
    let rec aux : (unit -> unit Or_error.t) Ast.Command.t -> Command.t =
      fun command ->
      match command with
      | Make { arg; summary; readme } ->
        let param = arg |> Arg.translate ~config in
        Command.basic_or_error ~summary ?readme param
      | Group { default = _; summary; readme; subcommands } ->
        Command.group
          ~summary
          ?readme
          (List.map subcommands ~f:(fun (name, arg) -> name, arg |> aux))
    in
    aux command
  ;;
end

module To_ast = Cmdlang.Command.Private.To_ast

let param p ~config = p |> To_ast.param |> Param.translate ~config
let arg a ~config = a |> To_ast.arg |> Arg.translate ~config
let command_unit ?config a = a |> To_ast.command |> Command.unit ?config
let command_basic ?config a = a |> To_ast.command |> Command.basic ?config
let command_or_error ?config a = a |> To_ast.command |> Command.or_error ?config

module Utils = struct
  let or_error_handler ~f =
    match f () with
    | Ok () -> ()
    | Error err ->
      Stdlib.prerr_endline (Error.to_string_hum err);
      Stdlib.exit 1
  ;;

  let command_unit_of_basic t = Cmdlang.Command.Utils.map t ~f:(fun f -> f ())

  let command_unit_of_or_error t =
    Cmdlang.Command.Utils.map t ~f:(fun f -> or_error_handler ~f)
  ;;
end

module Private = struct
  module Arg = Arg
end
