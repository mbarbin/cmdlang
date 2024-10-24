(** An opinionated runner for cmdlang parsers using cmdliner as a backend.

    This module provides a default runner that wraps [cmdlang-to-cmdliner] and
    runs the command under a [Err.protect] block.

    This furnishes a standard way to run cmdlang commands, assuming you are
    using [Err].

    It is opinionated and adds a few dependencies to your project, such as
    [Logs] and [Fmt]. *)
val run
  :  ?exn_handler:(exn -> Err.t option)
  -> unit Cmdlang.Command.t
  -> name:string
  -> version:string
  -> unit
