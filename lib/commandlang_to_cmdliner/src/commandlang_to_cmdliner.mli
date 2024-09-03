module Translate = Translate

(** This is the standard way that is designed with commandlang, assuming you are
    using [Err] etc. *)
val run
  :  ?exn_handler:(exn -> Err.t option)
  -> unit Commandlang.Command.t
  -> name:string
  -> version:string
  -> unit
