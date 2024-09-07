module Translate = Translate

(** This is the standard way that is designed with cmdlang, assuming you are
    using [Err] etc. *)
val run
  :  ?exn_handler:(exn -> Err.t option)
  -> unit Cmdlang.Command.t
  -> name:string
  -> version:string
  -> unit
