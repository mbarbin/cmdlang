(** An execution engine for [cmdlang] based on [stdlib.arg]. *)

val run : 'a Cmdlang.Command.t -> 'a

val eval
  :  'a Cmdlang.Command.t
  -> argv:string array
  -> ('a, [ `Help of string | `Bad of string ]) Result.t

val eval_exit_code : unit Cmdlang.Command.t -> argv:string array -> int

(** {1 Low level implementation}

    This modules should not be used directly by the users of the runner, but
    only through the {!run} and {!eval} functions. They are exposed if you want
    to re-use some existing code to build your own runner. *)

module Arg_runner = Arg_runner
module Arg_state = Arg_state
module Command_selector = Command_selector
module Param_parser = Param_parser
module Parser_state = Parser_state
module Positional_state = Positional_state
