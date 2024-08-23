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

(** The exception that is raised to break the control flow of program using [Err].

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
         if shall_exit_42 then Err.exit (Custom 42)
       ]}
    }
    }

    The standard usage for this library is to wrap entire sections in a
    [Err_handler.protect], which takes care of catching [E] and handling it
    accordingly. You may also catch this exception manually if you need, for
    more advanced uses (in which case you'll take care of recording and
    re-raising backtraces, etc). *)
exception E of t

(** {1 Exit codes}

    This part allows breaking the control flow with an exception indicating a
    request to end the program with a given exit code. *)

module Exit_code : sig
  (** The handling of exit code is based on [Cmdliner] conventions. *)

  type t =
    | Ok
    | Some_error
    | Cli_error
    | Internal_error
    | Custom of int

  val code : t -> int

  (** Codes as int for direct use. *)

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

(** {1 Config} *)

module Config : sig
  (** The config allows to impact the behavior of certain functionalities.

      Two examples:
      - Treat warnings as fatal errors ("--warn-error")
      - Decide of the log level - whether to enable debug messages, etc. *)

  module Mode : sig
    type t =
      | Default
      | Verbose
      | Debug

    val sexp_of_t : t -> Sexp.t
  end

  type t =
    { mode : Mode.t
    ; warn_error : bool
    }

  val default : t
  val create : ?mode:Mode.t -> ?warn_error:bool -> unit -> t
end

(** {1 State} *)

module State : sig
  (** Some functions from this interface are stateful. When so, they take an
      optional [?state : State.t] argument. For example, they register whether
      errors were emitted. It is possible to provide a state explicitly if you want. By
      default the function will operate on a global state that is exposed as
      {!val:the_state}. *)

  type t

  val create : unit -> t

  (** {1 Getters} *)

  (** A convenient wrapper to access the mode currently configured. *)
  val mode : t -> Config.Mode.t

  (** A convenient wrapper to say whether the configured mode has debug messages enabled. *)
  val is_debug_mode : t -> bool

  (** [had_errors t] returns [true] if this state has seen errors previously
      (warnings don't count, unless in warn-error mode). This is meant to
      prevent other parts of the program from running.

      This is useful if you are trying not to stop at the first error encountered,
      but still want to stop the execution at a specific breakpoint after some
      numbers of errors. To be used in places where you want to stop the flow at a
      given point rather than returning meaningless data.

      [had_errors] is used by [Err_handler] to determine whether to exit with
      an error code. *)
  val had_errors : t -> bool

  (** {1 Setters} *)

  (** Set the configuration for this state. This will affect future calls to
      function accessing the state. For example, if you changed the log level
      to include Debug message, the next call to [debug ~state] will be
      printed. The intended usage is to do it early from the command line
      handler. See [Err_handler.set_config]. *)
  val set_config : t -> Config.t -> unit

  (** Reset the error and warning counts to zero. [reset] is done by each call
      to [Err_handler.protect] as an initialization step, so unless you are
      manipulating states directly you shouldn't need to use this function.
      [am_running_test] defaults to [false]. *)
  val reset : ?am_running_test:bool -> t -> unit

  (** Returns [true] if [set_am_running_test] was last called with [true]. *)
  val am_running_test : t -> bool

  val set_am_running_test : t -> bool -> unit
end

(** {2 Default shared state} *)

(** The default global state used by this library. You may provide your own if
    needed by supplying the [~state] parameter to functions that support it. For
    example:

    {[
      let my_state = Err.State.create ()
      let my_error () = Err.raise ~state [ Pp.text "An error occurred" ]
    ]} *)
val the_state : State.t

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
  :  ?state:State.t
  -> ?loc:Stdune.Loc.t
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
  -> ?state:State.t
  -> ?loc:Stdune.Loc.t
  -> ?hints:Style.t Pp.t list
  -> ?exit_code:Exit_code.t
  -> Style.t Pp.t list
  -> _

(** Create a err and return it, instead of raising it right away. *)
val make
  :  ?loc:Stdune.Loc.t
  -> ?hints:Style.t Pp.t list
  -> ?exit_code:Exit_code.t
  -> Style.t Pp.t list
  -> t

(** This is exposed to help with libraries compatibility if needed. *)
val of_stdune_user_message : ?exit_code:Exit_code.t -> Stdune.User_message.t -> t

(** {1 Result} *)

(** Helper to raise a user error from a result type.
    - [ok_exn (Ok x)] is [x]
    - [ok_exn (Error msg)] is [Stdlib.raise (E msg)] *)
val ok_exn : ('a, t) result -> 'a

(** {1 Hints} *)

(** Produces a "Did you mean ...?" hint *)
val did_you_mean : string -> candidates:string list -> Style.t Pp.t list

(** {1 Printing messages}

    When you only link with the [Err] library, the default printer for [t] is
    pretty basic. The hope is to accommodate more use cases, and not require
    linking with too many libraries. However, if you are writing a command
    line, chances are that you are already using [Err_handler] ([Commandlang]
    does this for you as well), in which case a better printer is setup, the one
    with colors from [dune]. *)

val set_reporter : (t -> state:State.t -> unit) -> unit

(** Call the function registered by [set_reporter]. [state] defaults to
    {!val:the_state}. *)
val report : ?state:State.t -> t -> unit

(** {1 Non-raising user errors}

    This part of the library allows the production of messages that do not raise.

    For example:
    - Report multiple errors before terminating
    - Non fatal Warnings
    - Debug and Info messages *)

(** Print a message with the prefix: "Error:". The presence of errors will cause
    the final exit code to be non-zero. Note that this function returns
    [unit], so you may report multiple errors instead of stopping at the first
    one. If you want to stop the flow of execution see {!val:raise}. *)
val error
  :  ?state:State.t
  -> ?loc:Stdune.Loc.t
  -> ?hints:Style.t Pp.t list
  -> Style.t Pp.t list
  -> unit

(** Print a message with the prefix: "Warning:". Warning do not affect the exit
    code of the application (it will be 0 if there are no other errors). *)
val warning
  :  ?state:State.t
  -> ?loc:Stdune.Loc.t
  -> ?hints:Style.t Pp.t list
  -> Style.t Pp.t list
  -> unit

(** Print a message with the prefix: "Info:". This is only printed when in mode
    verbose (or debug). *)
val info
  :  ?state:State.t
  -> ?loc:Stdune.Loc.t
  -> ?hints:Style.t Pp.t list
  -> Style.t Pp.t list
  -> unit

(** Print a message with the prefix: "Debug:". This is only printed when in mode
    debug. *)
val debug
  :  ?state:State.t
  -> ?loc:Stdune.Loc.t
  -> ?hints:Style.t Pp.t list
  -> Style.t Pp.t list
  -> unit

(** {1 Other styles}

    Whether that is during a migration, or to keep experimenting, we
    are currently exploring other ways to build and raise errors, using
    things like sexp, json or dyn. *)

val raise_s
  :  ?state:State.t
  -> ?loc:Stdune.Loc.t
  -> ?hints:Style.t Pp.t list
  -> ?exit_code:Exit_code.t
  -> string
  -> Sexp.t
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
  -> ?state:State.t
  -> ?loc:Stdune.Loc.t
  -> ?hints:Style.t Pp.t list
  -> ?exit_code:Exit_code.t
  -> string
  -> Sexp.t
  -> _

(** When you need to render a [Sexp.t] into a [_ Pp.t] paragraph, things may
    become tricky - newlines inserted in surprising places, etc. This
    functions attempts to do an OK job at it. *)
val pp_of_sexp : Sexp.t -> _ Pp.t

module Private : sig
  (** [Private] is used by the [Err_handler]. We mean both libraries to work as
      companion libs. Note any of this can change without notice and without
      requiring a semver bump, so use at your own risk (or don't). *)

  val messages : t -> Stdune.User_message.t list
  val exit_code : t -> Exit_code.t
end
