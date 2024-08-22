module Exit_code = struct
  type t =
    | Ok
    | Some_error
    | Cli_error
    | Internal_error
    | Custom of int

  let ok = 0
  let some_error = 123
  let cli_error = 124
  let internal_error = 125

  let code = function
    | Ok -> ok
    | Some_error -> some_error
    | Cli_error -> cli_error
    | Internal_error -> internal_error
    | Custom i -> i
  ;;
end

type t =
  { msgs : Stdune.User_message.t list
  ; exit_code : Exit_code.t
  }

exception E of t

let () =
  Printexc.register_printer (function
    | E { msgs; exit_code } ->
      let sexp =
        Sexp.List
          ((Sexp.Atom "Err.E"
            :: List.map (fun msg -> Sexp.Atom (Stdune.User_message.to_string msg)) msgs)
           @ [ Sexp.List [ Atom "Exit"; Atom (Int.to_string (Exit_code.code exit_code)) ]
             ])
      in
      Some (Sexp.to_string_hum sexp)
    | _ -> None)
;;

module Style = struct
  type t = Stdune.User_message.Style.t =
    | Loc
    | Error
    | Warning
    | Kwd
    | Id
    | Prompt
    | Hint
    | Details
    | Ok
    | Debug
    | Success
    | Ansi_styles of Stdune.Ansi_color.Style.t list
end

module Config = struct
  module Mode = struct
    type t =
      | Default
      | Verbose
      | Debug

    let sexp_of_t = function
      | Default -> Sexp.Atom "Default"
      | Verbose -> Sexp.Atom "Verbose"
      | Debug -> Sexp.Atom "Debug"
    ;;

    let compare = compare
    let equal = ( = )
  end

  module Warn_error = struct
    type t = bool

    let switch = "warn-error"
  end

  type t =
    { mode : Mode.t
    ; warn_error : Warn_error.t
    }

  let create ?(mode = Mode.Default) ?(warn_error = false) () = { mode; warn_error }
  let default = create ()

  let arg =
    let open Command.Std in
    let+ warn_error = Arg.flag [ Warn_error.switch ] ~doc:"treat warnings as errors"
    and+ mode =
      let+ verbose = Arg.flag [ "verbose"; "v" ] ~doc:"print more messages"
      and+ debug =
        Arg.flag [ "debug"; "d" ] ~doc:"enable all messages including debug output"
      in
      if debug then Mode.Debug else if verbose then Mode.Verbose else Mode.Default
    in
    { mode; warn_error }
  ;;

  let to_args { mode; warn_error } =
    List.concat
      [ (match mode with
         | Default -> []
         | Verbose -> [ "--verbose" ]
         | Debug -> [ "--debug" ])
      ; (if warn_error then [ "--" ^ Warn_error.switch ] else [])
      ]
  ;;
end

module State = struct
  type t =
    { mutable config : Config.t
    ; mutable had_errors : bool
    ; mutable had_warnings : bool
    }

  let create () = { config = Config.default; had_errors = false; had_warnings = false }
  let mode t = t.config.mode
  let is_debug_mode t = Config.Mode.equal (mode t) Debug
  let set_config t config = t.config <- config
  let had_errors t = t.had_errors || (t.config.warn_error && t.had_warnings)

  let reset t =
    t.had_errors <- false;
    t.had_warnings <- false
  ;;
end

let the_state : State.t = State.create ()

let set_config ?(state = the_state) () =
  let open Command.Std in
  let+ config = Config.arg in
  State.set_config state config
;;

module Message_kind = struct
  type t =
    | Error
    | Warning
    | Info
    | Debug

  let is_enabled t ~(state : State.t) =
    let config = state.config in
    match (t : t) with
    | Error -> true
    | Warning -> config.warn_error || Config.Mode.compare config.mode Default >= 0
    | Info -> Config.Mode.compare config.mode Verbose >= 0
    | Debug -> Config.Mode.compare config.mode Debug >= 0
  ;;
end

let of_stdune_user_message ?(exit_code = Exit_code.Some_error) t =
  { msgs = [ t ]; exit_code }
;;

let make ?loc ?hints ?exit_code paragraphs =
  Stdune.User_error.make ?loc ?hints paragraphs |> of_stdune_user_message ?exit_code
;;

let raise ?(state = the_state) ?loc ?hints ?(exit_code = Exit_code.Some_error) paragraphs =
  state.had_errors <- true;
  let msg = Stdune.User_error.make ?loc ?hints paragraphs in
  raise (E { msgs = [ msg ]; exit_code })
;;

let reraise
  bt
  e
  ?(state = the_state)
  ?loc
  ?hints
  ?(exit_code = Exit_code.Some_error)
  paragraphs
  =
  state.had_errors <- true;
  let msg = Stdune.User_error.make ?loc ?hints paragraphs in
  Printexc.raise_with_backtrace (E { msgs = msg :: e.msgs; exit_code }) bt
;;

let exit exit_code = Stdlib.raise (E { msgs = []; exit_code })

let ok_exn = function
  | Ok x -> x
  | Error e -> Stdlib.raise (E e)
;;

let did_you_mean = Stdune.User_message.did_you_mean

(* I've tried testing the following, which doesn't work as expected:

   {v
   let%expect_test "am_running_test" =
     print_s [%sexp { am_running_inline_test : bool; am_running_test : bool }];
     [%expect {| ((am_running_inline_test false) (am_running_test false)) |}];
     ()
   ;;
   v}

   Thus been using this variable to avoid the printer to produce styles in expect
   tests when running in the GitHub Actions environment.
*)
let am_running_test = ref false
let test_printer pp = Stdlib.prerr_string (Format.asprintf "%a" Pp.to_fmt pp)
let include_separator = ref false

let prerr_msg (t : Stdune.User_message.t) =
  let use_test_printer = !am_running_test in
  let () =
    if !include_separator then Stdlib.prerr_newline () else include_separator := true
  in
  t.loc
  |> Option.iter (fun loc ->
    (if use_test_printer then test_printer else Stdune.Ansi_color.prerr)
      (Stdune.Loc.pp loc
       |> Pp.map_tags ~f:(fun (Loc : Stdune.Loc.tag) ->
         Stdune.User_message.Print_config.default Loc)));
  let message = { t with loc = None } in
  if use_test_printer
  then test_printer (Stdune.User_message.pp message)
  else Stdune.User_message.prerr message
;;

let () = Stdune.User_warning.set_reporter prerr_msg
let prerr (t : t) = List.iter prerr_msg t.msgs

let error ?(state = the_state) ?loc ?hints paragraphs =
  if Message_kind.is_enabled Error ~state
  then (
    state.had_errors <- true;
    let t = Stdune.User_error.make ?loc ?hints paragraphs in
    prerr_msg t)
;;

let warning ?(state = the_state) ?loc ?hints paragraphs =
  if Message_kind.is_enabled Warning ~state
  then (
    state.had_warnings <- true;
    Stdune.User_warning.emit ?loc ?hints paragraphs)
;;

let info ?(state = the_state) ?loc ?hints paragraphs =
  if Message_kind.is_enabled Info ~state
  then (
    let t =
      Stdune.User_message.make
        ?loc
        ?hints
        ~prefix:
          (Pp.seq
             (Pp.tag Stdune.User_message.Style.Kwd (Pp.verbatim "Info"))
             (Pp.char ':'))
        paragraphs
    in
    prerr_msg t)
;;

let debug ?(state = the_state) ?loc ?hints paragraphs =
  if Message_kind.is_enabled Debug ~state
  then (
    let t =
      Stdune.User_message.make
        ?loc
        ?hints
        ~prefix:
          (Pp.seq
             (Pp.tag Stdune.User_message.Style.Kwd (Pp.verbatim "Debug"))
             (Pp.char ':'))
        paragraphs
    in
    prerr_msg t)
;;

let handler ?(state = the_state) ?(exn_handler = Fun.const None) f =
  State.reset state;
  match f () with
  | ok -> if State.had_errors state then Error (Exit_code.code Some_error) else Ok ok
  | exception E { msgs; exit_code } ->
    List.iter prerr_msg msgs;
    Error (Exit_code.code exit_code)
  | exception exn ->
    let backtrace = Printexc.get_raw_backtrace () in
    (match exn_handler exn with
     | Some { msgs; exit_code } ->
       List.iter prerr_msg msgs;
       Error (Exit_code.code exit_code)
     | None ->
       let msg =
         let prefix =
           Pp.seq (Pp.tag Style.Error (Pp.verbatim "Internal Error")) (Pp.char ':')
         in
         let backtrace =
           if !am_running_test
           then [ "<backtrace disabled in tests>" ]
           else
             String.split_on_char '\n' (Printexc.raw_backtrace_to_string backtrace)
             |> List.filter (fun s -> not (String.length s = 0))
         in
         Stdune.User_message.make
           ~prefix
           [ Pp.concat_map
               ~sep:(Pp.break ~nspaces:1 ~shift:0)
               (Printexc.to_string exn :: backtrace)
               ~f:Pp.verbatim
           ]
       in
       prerr_msg msg;
       Error Exit_code.internal_error)
;;

module For_test = struct
  let wrap f =
    let init = !am_running_test in
    am_running_test := true;
    Fun.protect ~finally:(fun () -> am_running_test := init) f
  ;;

  let handler ?state ?exn_handler f =
    match wrap (fun () -> handler f ?state ?exn_handler) with
    | Ok () -> ()
    | Error code -> Stdlib.prerr_endline (Printf.sprintf "[%d]" code)
  ;;
end

let pp_of_sexp sexp =
  let rec aux sexp =
    match (sexp : Sexp.t) with
    | Atom s -> Pp.verbatim s
    | List [ sexp ] -> aux sexp
    | List _ -> Pp.verbatim (Sexp.to_string_hum sexp)
  in
  match (sexp : Sexp.t) with
  | List (Atom atom :: sexps) ->
    Pp.O.(Pp.verbatim atom ++ Pp.space ++ Pp.concat_map sexps ~f:aux)
  | sexp -> aux sexp
;;

let raise_s ?state ?loc ?hints ?exit_code msg sexp =
  raise ?state ?loc ?hints ?exit_code [ Pp.text msg; pp_of_sexp sexp ]
;;

let reraise_s bt e ?state ?loc ?hints ?exit_code msg sexp =
  reraise bt e ?state ?loc ?hints ?exit_code [ Pp.text msg; pp_of_sexp sexp ]
;;
