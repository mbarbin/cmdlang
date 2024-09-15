val command : 'a Cmdlang.Command.t -> 'a Climate.Command.t

module Private : sig
  (** This module is exported for testing purposes only. Its signature may
      change in breaking ways without any notice. Do not use. *)

  module Arg : sig
    val project : 'a Cmdlang_ast.Ast.Arg.t -> 'a Climate.Arg_parser.t
  end
end
