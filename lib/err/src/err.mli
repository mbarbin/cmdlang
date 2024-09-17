(** Err is an abstraction to report located errors and warnings to the user.

    The canonical syntax for an error produced by this lib is:

    {[
      File "my-file", line 42, character 6-11:
      42 | Hello World
                 ^^^^^
      Error: Some message that gives a general explanation of the issue.
      Followed by more details.
    ]}

    It is heavily inspired by dune's user_messages and uses dune's error message
    rendering under the hood. *)

(** A value of type [t] is an immutable piece of information that the programmer
    intends to report to the user, in a way that breaks flow. To give some
    concrete examples:

    - A message (or several) reporting an error condition in a program
    - A request to exit the program with an exit code. *)
type t

(** The exception that is raised to break the control flow of programs using
    [Err].

    Examples:

    {ul
     {- When reporting an error:
       {[
         if had_error then Err.raise [ Pp.text "An error occurred" ]
       ]}
    }
    }

    {ul
     {- When requesting an exit code:
       {[
         if shall_exit_42 then Err.exit 42
       ]}
    }
    }

    The standard usage for this library is to wrap entire sections in a
    {!val:protect}, which takes care of catching [E] and handling it
    accordingly. You may also catch this exception manually if you need, for
    more advanced uses (in which case you'll take care of recording and
    re-raising backtraces, etc). *)
exception E of t

(** Return a [Sexp] to inspect what inside [t]. Note the sexp is incomplete and
    it is not meant for supporting any kind of round trip serialization (there
    is no [t_of_sexp]). Rather, this is for quick inspection of what's inside
    [t]. We think exposing this can help accommodating some use cases, making
    it easier to write expect tests involving [Err], etc. *)
val sexp_of_t : t -> Sexplib0.Sexp.t

(** {1 Exit codes}

    This part allows breaking the control flow with an exception indicating a
    request to end the program with a given exit code. *)

module Exit_code : sig
  (** The handling of exit code is based on [Cmdliner] conventions. *)

  type t = int

  val ok : int
  val some_error : int
  val cli_error : int
  val internal_error : int
end

(** Request the termination of the program with the provided exit code. Make
    sure you have documented that particular exit code in the man page of your
    CLI. We recommend to stick to the error codes exposed by
    {!module:Exit_code}, which are documented by default and pervasively used
    by existing CLIs built with cmdliner. Raises {!exception:E}. *)
val exit : Exit_code.t -> _

(** {1 Raising errors} *)

module Style : sig
  (** You may decorate the messages built with this library with styles that
      will make them look awesome in a console. Enhance your users experience
      today! *)

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

(** Raise a user error. You may override [exit_code] with the requested exit
    code to end the program with. It defaults to {!val:Exit_code.some_error}.

    Example:
    {[
      let unknown_var var =
        Err.raise
          ~loc
          [ Pp.textf "Unknown variable '%s'" var ]
          ~hints:(Err.did_you_mean var ~candidates:[ "foo"; "bar"; "baz" ])
      ;;
    ]} *)
val raise
  :  ?loc:Loc.t
  -> ?hints:Style.t Pp.t list
  -> ?exit_code:Exit_code.t
  -> Style.t Pp.t list
  -> _

(** Reraise with added context. Usage:

    {[
      match do_x (Y.to_x y) with
      | exception Err.E e ->
        let bt = Printexc.get_raw_backtrace () in
        Err.reraise bt e [ Pp.text "Trying to do x with y"; Y.pp y ]
    ]} *)
val reraise
  :  Printexc.raw_backtrace
  -> t
  -> ?loc:Loc.t
  -> ?hints:Style.t Pp.t list
  -> ?exit_code:Exit_code.t
  -> Style.t Pp.t list
  -> _

(** Create a err and return it, instead of raising it right away. *)
val create
  :  ?loc:Loc.t
  -> ?hints:Style.t Pp.t list
  -> ?exit_code:Exit_code.t
  -> Style.t Pp.t list
  -> t

(** [append ?exit_code t1 t2] creates a new err that contains all messages of t1
    and t2. The exit_code of this new [t] may be specified, otherwise it will
    be that of [t2]. *)
val append : ?exit_code:Exit_code.t -> t -> t -> t

(** This is exposed to help with libraries compatibility if needed. *)
val of_stdune_user_message : ?exit_code:Exit_code.t -> Stdune.User_message.t -> t

(** {1 Result} *)

(** Helper to raise a user error from a result type.
    - [ok_exn (Ok x)] is [x]
    - [ok_exn (Error msg)] is [Stdlib.raise (E msg)] *)
val ok_exn : ('a, t) result -> 'a

(** {1 Other styles}

    Whether that is during a migration, or to keep experimenting, we
    are currently exploring other ways to build and raise errors, using
    things like sexp, json or dyn. *)

val create_s
  :  ?loc:Loc.t
  -> ?hints:Style.t Pp.t list
  -> ?exit_code:Exit_code.t
  -> string
  -> Sexplib0.Sexp.t
  -> t

val raise_s
  :  ?loc:Loc.t
  -> ?hints:Style.t Pp.t list
  -> ?exit_code:Exit_code.t
  -> string
  -> Sexplib0.Sexp.t
  -> _

(** Reraise with added context. Usage:

    {[
      match do_x x with
      | exception Err.E e ->
        let bt = Printexc.get_raw_backtrace () in
        Err.reraise_s bt e "Trying to do x with y" [%sexp { y : Y.t }]
    ]} *)
val reraise_s
  :  Printexc.raw_backtrace
  -> t
  -> ?loc:Loc.t
  -> ?hints:Style.t Pp.t list
  -> ?exit_code:Exit_code.t
  -> string
  -> Sexplib0.Sexp.t
  -> _

(** When you need to render a [Sexp.t] into a [_ Pp.t] paragraph, things may
    become tricky - newlines inserted in surprising places, etc. This
    functions attempts to do an OK job at it. *)
val pp_of_sexp : Sexplib0.Sexp.t -> _ Pp.t

(** {1 Hints} *)

(** Produces a "Did you mean ...?" hint *)
val did_you_mean : string -> candidates:string list -> Style.t Pp.t list

(** Set by the {!val:For_test.wrap} when wrapping sections for tests, accessed
    by libraries if needed. *)
val am_running_test : unit -> bool

(** This return the number of errors that have been emitted via [Err.error]
    since the last [reset_counts]. Beware, note that errors raised as
    exceptions via functions such as [Err.raise] do not affect the error
    count. The motivation is to allow exceptions to be caught without
    impacting the overall exit code. *)
val error_count : unit -> int

(** A convenient wrapper for [Err.error_count () > 0].

    This is useful if you are trying not to stop at the first error encountered,
    but still want to stop the execution at a specific breakpoint after some
    numbers of errors. To be used in places where you want to stop the flow at a
    given point rather than returning meaningless data. *)
val had_errors : unit -> bool

(** Return the number of warnings that have been emitted via [Err.warning] since
    the last [reset_counts]. *)
val warning_count : unit -> int

(** {1 Printing messages} *)

(** Print to [stderr] (not thread safe). By default, [prerr] will start by
    writing a blank line on [stderr] if [Err] messages have already been
    emitted during the lifetime of the program. That is a reasonable default
    to ensure that err messages are always nicely separated by an empty line,
    to make them more readable. However, if you structure your output
    manually, perhaps you do not want this. If [reset_separator=true], this
    behavior is turned off, and the first message of this batch will be
    printed directly without a leading blank line. *)
val prerr : ?reset_separator:bool -> t -> unit

(** {1 Non-raising user errors}

    This part of the library allows the production of messages that do not
    raise.

    For example: - Emitting multiple errors before terminating - Non fatal
    Warnings - Debug and Info messages

    Errors and warnings are going to affect [error_count] (and resp.
    [warning_count]), which is going to be used by {!val:protect} to impact the
    exit code of the application. Use with care. *)

(** Emit an error on stderr and increase the global error count. *)
val error : ?loc:Loc.t -> ?hints:Style.t Pp.t list -> Style.t Pp.t list -> unit

(** Emit a warning on stderr and increase the global warning count. *)
val warning : ?loc:Loc.t -> ?hints:Style.t Pp.t list -> Style.t Pp.t list -> unit

(** Emit a information message on stderr. Required verbosity level of [Info] or
    more, disabled by default. *)
val info : ?loc:Loc.t -> ?hints:Style.t Pp.t list -> Style.t Pp.t list -> unit

(** The last argument to [debug] is lazy in order to avoid the allocation when
    debug messages are disabled. This isn't done with the other functions,
    because we don't expect other logging functions to be used in a way that
    impacts the program's performance, and using lazy causes added programming
    friction. *)
val debug : ?loc:Loc.t -> ?hints:Style.t Pp.t list -> Style.t Pp.t list Lazy.t -> unit

(** {1 Handler}

    To be used by command line handlers, as well as tests. *)

(** [protect f] will take care of running [f], and catch any user error. If the
    exit code must be affected it is returned as an [Error]. This also takes
    care of catching uncaught exceptions and printing them to the screen. You
    may provide [exn_handler] to match on custom exceptions and turn them into
    [Err] for display and exit code. Any uncaught exception will be reported
    as an internal errors with a backtrace. When [Err.am_running_test ()] is
    true the backtrace is redacted to avoid making expect test traces too
    brittle. [protect] starts by performing a reset of the error and warning
    counts with a call to [reset_counts]. *)
val protect : ?exn_handler:(exn -> t option) -> (unit -> 'a) -> ('a, int) Result.t

module For_test : sig
  (** Same as [protect], but won't return the exit code, rather print the code
      at the end in case of a non zero code, like in cram tests. *)
  val protect : ?exn_handler:(exn -> t option) -> (unit -> unit) -> unit

  (** Wrap the execution of a function under an environment proper for test
      execution. For example, it will turn down the colors in user messages.
      {!val:For_test.protect} already does a [wrap] - this is exposed if you'd
      like to run some test outside of a [protect] handler. *)
  val wrap : (unit -> 'a) -> 'a
end

(** {1 Private} *)

module Private : sig
  (** [Private] is used by [Err_config]. We mean both libraries to work as
      companion libs. Note any of this can change without notice and without
      requiring a semver bump, so use at your own risk (or don't). *)

  val am_running_test : bool ref
  val reset_counts : unit -> unit
  val reset_separator : unit -> unit

  module Style_renderer : sig
    (** Compatibility with [Fmt]. *)

    type t =
      [ `Auto
      | `None
      ]
  end

  val style_renderer : Style_renderer.t ref

  module Logs_level : sig
    (** Compatibility with [Logs]. *)

    type t =
      | Quiet
      | Error
      | Warning
      | Info
      | Debug
  end

  (** Since [Err] does not depend on [Logs], the [Err] and [Logs] levels must be
      set independently. However, this is done for you consistently if you are
      using [Err_cli]. *)
  val set_logs_level : get:(unit -> Logs_level.t) -> set:(Logs_level.t -> unit) -> unit

  val warn_error : bool ref

  (** To avoid making this library depend on [Logs] we inject the dependency
      into the functions we need instead. To be called with [Logs.err_count]
      and [Logs.warn_count]. *)
  val set_logs_counts : err_count:(unit -> int) -> warn_count:(unit -> int) -> unit
end
