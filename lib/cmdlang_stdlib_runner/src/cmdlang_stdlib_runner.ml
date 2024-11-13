module Arg_state = Arg_state
module Command_selector = Command_selector
module Param_parser = Param_parser
module Parser_state = Parser_state

let usage_msg
  ~argv
  ~resume_parsing_from_index
  ~summary
  ~readme
  ~subcommands
  ~positional_state
  =
  let usage_prefix =
    Array.sub argv 0 resume_parsing_from_index |> Array.to_list |> String.concat " "
  in
  let subcommands =
    match subcommands with
    | [] -> ""
    | _ :: _ as subcommands ->
      let subcommands =
        subcommands
        |> List.map (fun (name, command) ->
          let summary = Ast.Command.summary command in
          name, summary)
      in
      let padding =
        List.fold_left (fun acc (name, _) -> max acc (String.length name)) 0 subcommands
        + 2
      in
      let items =
        subcommands
        |> List.map (fun (name, summary) ->
          Printf.sprintf "  %-*s   %s" padding name summary)
        |> String.concat "\n"
      in
      "Subcommands:\n" ^ items ^ "\n\n"
  in
  let positional_suffix, positional_state =
    match
      match positional_state with
      | None -> None
      | Some positional_state -> Positional_state.usage_msg positional_state
    with
    | None -> "", ""
    | Some msg -> " [ARGUMENTS]", msg ^ "\n\n"
  in
  Printf.sprintf
    "Usage: %s [OPTIONS]%s\n\n%s\n\n%s%s%sOptions:"
    usage_prefix
    positional_suffix
    summary
    (match readme with
     | None -> ""
     | Some m -> m () ^ "\n\n")
    subcommands
    positional_state
;;

let eval_arg
  (type a)
  ~(arg : a Ast.Arg.t)
  ~summary
  ~readme
  ~subcommands
  ~argv
  ~resume_parsing_from_index
  =
  let state =
    match Parser_state.create arg with
    | Ok state -> state
    | Error (`Msg msg) ->
      let message = "Invalid command specification (programming error):\n\n" ^ msg in
      raise (Arg.Bad message)
  in
  let spec = Parser_state.spec state |> Arg.align in
  let positional_state = Parser_state.positional_state state in
  let anon_fun = Positional_state.anon_fun positional_state in
  let usage_msg ~readme =
    usage_msg
      ~argv
      ~resume_parsing_from_index
      ~summary
      ~readme
      ~subcommands
      ~positional_state:(Some positional_state)
  in
  let () =
    let current = ref (resume_parsing_from_index - 1) in
    try Arg.parse_argv ~current argv spec anon_fun (usage_msg ~readme:None) with
    | Arg.Help _ ->
      (* We rewrite the help in order to add the [readme] section. We do not
         want to add it by default in the [Arg.Bad] case. *)
      let message = Arg.usage_string spec (usage_msg ~readme) in
      raise (Arg.Help message)
  in
  match Parser_state.finalize state with
  | Ok runner -> Arg_runner.eval runner
  | Error parse_error ->
    (match parse_error with
     | Arg_state.Parse_error.Missing_argument
         { names = name :: _; param = _; docv = _; doc = _ } ->
       raise (Arg.Bad (Printf.sprintf "Missing required named argument: %S.\n" name))
     | Arg_state.Parse_error.Missing_positional_argument
         { pos; param = _; docv = _; doc = _ } ->
       raise
         (Arg.Bad
            (Printf.sprintf "Missing required positional argument at position %d.\n" pos)))
;;

let eval_internal (type a) (command : a Ast.Command.t) ~argv =
  let { Command_selector.Selected.command; resume_parsing_from_index } =
    Command_selector.select command ~argv
  in
  match command with
  | Make { arg; summary; readme } ->
    eval_arg ~arg ~summary ~readme ~subcommands:[] ~argv ~resume_parsing_from_index
  | Group { default; summary; readme; subcommands } ->
    (match default with
     | Some arg ->
       eval_arg ~arg ~summary ~readme ~subcommands ~argv ~resume_parsing_from_index
     | None ->
       let message =
         usage_msg
           ~argv
           ~resume_parsing_from_index
           ~summary
           ~readme
           ~subcommands
           ~positional_state:None
       in
       let arg =
         let message = Arg.usage_string [] message in
         Ast.Arg.(Map { x = Return (); f = (fun () -> raise (Arg.Bad message)) })
       in
       eval_arg ~arg ~summary ~readme ~subcommands ~argv ~resume_parsing_from_index)
;;

module To_ast = Cmdlang.Command.Private.To_ast

let eval a ~argv =
  let command = a |> To_ast.command in
  try Ok (eval_internal command ~argv) with
  | Arg.Help msg -> Error (`Help msg)
  | Arg.Bad msg -> Error (`Bad msg)
;;

let eval_exit_code a ~argv =
  match eval a ~argv with
  | Ok () -> 0
  | Error (`Bad msg) ->
    Printf.printf "%s" msg;
    2
  | Error (`Help msg) ->
    Printf.printf "%s" msg;
    0
;;

let run a =
  match eval a ~argv:Sys.argv with
  | Ok a -> a
  | Error (`Bad msg) ->
    Printf.printf "%s" msg;
    exit 2
  | Error (`Help msg) ->
    Printf.printf "%s" msg;
    exit 0
;;
