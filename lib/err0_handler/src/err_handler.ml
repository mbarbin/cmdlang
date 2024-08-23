module Config = struct
  module Mode = struct
    type t = Err.Config.Mode.t =
      | Default
      | Verbose
      | Debug
  end

  module Warn_error = struct
    type t = bool

    let switch = "warn-error"
  end

  type t = Err.Config.t =
    { mode : Mode.t
    ; warn_error : Warn_error.t
    }

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

let set_config ?(state = Err.the_state) () =
  let open Command.Std in
  let+ config = Config.arg in
  Err.State.set_config state config
;;

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
let test_printer pp = Stdlib.prerr_string (Format.asprintf "%a" Pp.to_fmt pp)
let include_separator = ref false

let prerr_message_internal (t : Stdune.User_message.t) ~state =
  let use_test_printer = Err.State.am_running_test state in
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

let prerr_internal (t : Err.t) ~state =
  List.iter
    (fun message -> prerr_message_internal message ~state)
    (Err.Private.messages t)
;;

(* Linking with this library affects the reporting of upstream libraries as it
   relate to printing user errors. *)

let () =
  Stdune.User_warning.set_reporter (fun message ->
    prerr_message_internal message ~state:Err.the_state)
;;

let () = Err.set_reporter prerr_internal

let pp_backtrace backtrace ~state =
  if Err.State.am_running_test state
  then [ "<backtrace disabled in tests>" ]
  else
    String.split_on_char '\n' (Printexc.raw_backtrace_to_string backtrace)
    |> List.filter (fun s -> not (String.length s = 0))
;;

let handle_messages_and_exit ~messages ~exit_code ~state ~backtrace =
  List.iter (fun message -> prerr_message_internal message ~state) messages;
  let code = Err.Exit_code.code exit_code in
  if Int.equal code Err.Exit_code.internal_error
  then (
    let message =
      let prefix =
        Pp.seq (Pp.tag Err.Style.Error (Pp.verbatim "Backtrace")) (Pp.char ':')
      in
      let backtrace = pp_backtrace backtrace ~state in
      Stdune.User_message.make
        ~prefix
        [ Pp.concat_map ~sep:(Pp.break ~nspaces:1 ~shift:0) backtrace ~f:Pp.verbatim ]
    in
    prerr_message_internal message ~state);
  Error code
;;

let protect_internal
  ~am_running_test
  ?(state = Err.the_state)
  ?(exn_handler = Fun.const None)
  f
  =
  Err.State.reset state ~am_running_test;
  match f () with
  | ok ->
    if Err.State.had_errors state then Error (Err.Exit_code.code Some_error) else Ok ok
  | exception Err.E err ->
    let backtrace = Printexc.get_raw_backtrace () in
    let messages = Err.Private.messages err in
    let exit_code = Err.Private.exit_code err in
    handle_messages_and_exit ~messages ~exit_code ~state ~backtrace
  | exception exn ->
    let backtrace = Printexc.get_raw_backtrace () in
    (match exn_handler exn with
     | Some err ->
       let messages = Err.Private.messages err in
       let exit_code = Err.Private.exit_code err in
       handle_messages_and_exit ~messages ~exit_code ~state ~backtrace
     | None ->
       let message =
         let prefix =
           Pp.seq (Pp.tag Err.Style.Error (Pp.verbatim "Internal Error")) (Pp.char ':')
         in
         let backtrace = pp_backtrace backtrace ~state in
         Stdune.User_message.make
           ~prefix
           [ Pp.concat_map
               ~sep:(Pp.break ~nspaces:1 ~shift:0)
               (Printexc.to_string exn :: backtrace)
               ~f:Pp.verbatim
           ]
       in
       prerr_message_internal message ~state;
       Error Err.Exit_code.internal_error)
;;

module For_test = struct
  let wrap ?(state = Err.the_state) f =
    let init = Err.State.am_running_test state in
    Err.State.set_am_running_test state true;
    Fun.protect ~finally:(fun () -> Err.State.set_am_running_test state init) f
  ;;

  let protect ?state ?exn_handler f =
    match
      wrap ?state (fun () -> protect_internal ~am_running_test:true f ?state ?exn_handler)
    with
    | Ok () -> ()
    | Error code -> Stdlib.prerr_endline (Printf.sprintf "[%d]" code)
  ;;

  let am_running_test ?(state = Err.the_state) () = Err.State.am_running_test state
end

let protect ?state ?exn_handler f =
  protect_internal ~am_running_test:false ?state ?exn_handler f
;;

let prerr ?(state = Err.the_state) t = prerr_internal t ~state
