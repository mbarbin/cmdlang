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

(* The messages are added to the head of the [messages] list - [reraise] is the
   operation that allows to chain multiple messages. As for the order in which
   the handler prints the messages, both approaches make sense. We had a slight
   preference for showing the errors in the order they were initially raised, so
   we reversed [messages] before printing them. *)
type t =
  { messages : Stdune.User_message.t list
  ; exit_code : Exit_code.t
  }

let sexp_of_t { messages; exit_code } =
  Sexp.List
    ((Sexp.Atom "Err.E"
      :: List.map
           (fun message -> Sexp.Atom (Stdune.User_message.to_string message))
           messages)
     @ [ Sexp.List [ Atom "Exit"; Atom (Int.to_string (Exit_code.code exit_code)) ] ])
;;

exception E of t

let () =
  Printexc.register_printer (function
    | E t -> Some (Sexp.to_string_hum (sexp_of_t t))
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

  type t =
    { mode : Mode.t
    ; warn_error : bool
    }

  let create ?(mode = Mode.Default) ?(warn_error = false) () = { mode; warn_error }
  let default = create ()
end

module State = struct
  type t =
    { mutable config : Config.t
    ; mutable had_errors : bool
    ; mutable had_warnings : bool
    ; mutable am_running_test : bool
    }

  let create () =
    { config = Config.default
    ; had_errors = false
    ; had_warnings = false
    ; am_running_test = false
    }
  ;;

  let mode t = t.config.mode
  let is_debug_mode t = Config.Mode.equal (mode t) Debug
  let set_config t config = t.config <- config
  let had_errors t = t.had_errors || (t.config.warn_error && t.had_warnings)

  let reset ?(am_running_test = false) t =
    t.had_errors <- false;
    t.had_warnings <- false;
    t.am_running_test <- am_running_test
  ;;

  let am_running_test t = t.am_running_test
  let set_am_running_test t value = t.am_running_test <- value
end

let the_state : State.t = State.create ()

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
  { messages = [ t ]; exit_code }
;;

let make ?loc ?hints ?exit_code paragraphs =
  Stdune.User_error.make ?loc ?hints paragraphs |> of_stdune_user_message ?exit_code
;;

let raise ?(state = the_state) ?loc ?hints ?(exit_code = Exit_code.Some_error) paragraphs =
  state.had_errors <- true;
  let message = Stdune.User_error.make ?loc ?hints paragraphs in
  raise (E { messages = [ message ]; exit_code })
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
  let message = Stdune.User_error.make ?loc ?hints paragraphs in
  Printexc.raise_with_backtrace (E { messages = message :: e.messages; exit_code }) bt
;;

let exit exit_code = Stdlib.raise (E { messages = []; exit_code })

let ok_exn = function
  | Ok x -> x
  | Error e -> Stdlib.raise (E e)
;;

let did_you_mean = Stdune.User_message.did_you_mean
let default_reporter t ~state:_ = Stdlib.prerr_endline (Sexp.to_string_hum (sexp_of_t t))
let reporter = ref default_reporter
let set_reporter f = reporter := f
let report_internal t ~state = !reporter t ~state

let error ?(state = the_state) ?loc ?hints paragraphs =
  if Message_kind.is_enabled Error ~state
  then (
    state.had_errors <- true;
    let message = Stdune.User_error.make ?loc ?hints paragraphs in
    report_internal { messages = [ message ]; exit_code = Some_error } ~state)
;;

let warning ?(state = the_state) ?loc ?hints paragraphs =
  if Message_kind.is_enabled Warning ~state
  then (
    state.had_warnings <- true;
    let message =
      Stdune.User_message.make
        ?loc
        ?hints
        ~prefix:
          (Pp.seq
             (Pp.tag Stdune.User_message.Style.Warning (Pp.verbatim "Warning"))
             (Pp.char ':'))
        paragraphs
    in
    report_internal { messages = [ message ]; exit_code = Ok } ~state)
;;

let info ?(state = the_state) ?loc ?hints paragraphs =
  if Message_kind.is_enabled Info ~state
  then (
    let message =
      Stdune.User_message.make
        ?loc
        ?hints
        ~prefix:
          (Pp.seq
             (Pp.tag Stdune.User_message.Style.Kwd (Pp.verbatim "Info"))
             (Pp.char ':'))
        paragraphs
    in
    report_internal { messages = [ message ]; exit_code = Ok } ~state)
;;

let debug ?(state = the_state) ?loc ?hints paragraphs =
  if Message_kind.is_enabled Debug ~state
  then (
    let message =
      Stdune.User_message.make
        ?loc
        ?hints
        ~prefix:
          (Pp.seq
             (Pp.tag Stdune.User_message.Style.Kwd (Pp.verbatim "Debug"))
             (Pp.char ':'))
        paragraphs
    in
    report_internal { messages = [ message ]; exit_code = Ok } ~state)
;;

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

let raise_s ?state ?loc ?hints ?exit_code desc sexp =
  raise ?state ?loc ?hints ?exit_code [ Pp.text desc; pp_of_sexp sexp ]
;;

let reraise_s bt e ?state ?loc ?hints ?exit_code desc sexp =
  reraise bt e ?state ?loc ?hints ?exit_code [ Pp.text desc; pp_of_sexp sexp ]
;;

module Private = struct
  let messages t = List.rev t.messages
  let exit_code t = t.exit_code
end

let report ?(state = the_state) t = report_internal t ~state
