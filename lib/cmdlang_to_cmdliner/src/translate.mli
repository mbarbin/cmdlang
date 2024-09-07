val command : ?version:string -> 'a Cmdlang.Command.t -> name:string -> 'a Cmdliner.Cmd.t

module Private : sig
  (** This module is exported for testing purposes only. Its signature may
      change in breaking ways without any notice. Do not use. *)

  module Arg : sig
    val with_dot_suffix : doc:string -> string
    val doc_of_param : doc:string -> param:'a Ast.Param.t -> string
  end

  module Command : sig
    val manpage_of_readme : readme:(unit -> string) -> [ `P of string ] list
  end
end
