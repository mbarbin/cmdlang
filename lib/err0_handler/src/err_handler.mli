(** Err_handler contains functions to work with Err on the side of end programs
    (such as a command line tool, as opposed to libraries).

    If you are implementing a library and all you care about is to raise some
    Err errors, you don't need to worry about how the exceptions are printed,
    and how the exit code of the program is affected. This would be done for you
    by an application that *uses* your library.

    Thus, we packaged the handling part as a separate library, and this is what
    [Err_handler] is. *)

(** {1 Configuration} *)

module Config : sig
  type t = Err.Config.t

  val arg : t Command.Arg.t
  val to_args : t -> string list
end

(** Adding this argument to your command line will make it support [Err]
    configuration and takes care of setting the config.

    {[
      let open Command.Std
      let+ () = Err_handler.set_config () in
      ...
    ]} *)
val set_config : ?state:Err.State.t -> unit -> unit Command.Arg.t

(** {1 Printing messages} *)

(** Print to [stderr] (not thread safe). The state is used to lookup the config,
    whether we should print colors, if we are in test mode, etc. [state]
    defaults to [Err.the_state]. *)
val prerr : ?state:Err.State.t -> Err.t -> unit

(** {1 Handler}

    To be used by command line handlers, as well as tests. *)

(** [handler f] will take care of running [f], and catch any user error. If the
    exit code must be affected it is returned as an [Error]. This also takes
    care of catching uncaught exceptions and printing them to the screen. You
    may provide [exn_handler] to match on custom exceptions and turn them into
    [Err] for display and exit code. Any uncaught exception will be reported as
    an internal errors with a backtrace. *)
val protect
  :  ?state:Err.State.t
  -> ?exn_handler:(exn -> Err.t option)
  -> (unit -> 'a)
  -> ('a, int) Result.t

module For_test : sig
  (** Same as [handler], but won't return the exit code, rather print the code
      at the end in case of a non zero code, like in cram tests. *)
  val protect
    :  ?state:Err.State.t
    -> ?exn_handler:(exn -> Err.t option)
    -> (unit -> unit)
    -> unit

  (** Wrap the execution of a function under an environment proper for test
      execution. For example, it will turn down the colors in user messages.
      {!val:For_test.protect} already does a [wrap] - this is exposed if you'd
      like to run some test outside of a [protect] handler. *)
  val wrap : ?state:Err.State.t -> (unit -> 'a) -> 'a

  val am_running_test : ?state:Err.State.t -> unit -> bool
end
