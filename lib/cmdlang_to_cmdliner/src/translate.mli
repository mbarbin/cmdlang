(** Translate cmdlang parsers to cmdliner. *)

(** {1 Param} *)

val param : 'a Cmdlang.Command.Param.t -> 'a Cmdliner.Arg.conv

(** {1 Arg} *)

val arg : 'a Cmdlang.Command.Arg.t -> 'a Cmdliner.Term.t

(** {1 Command} *)

val command : ?version:string -> 'a Cmdlang.Command.t -> name:string -> 'a Cmdliner.Cmd.t

(** {1 Private} *)

module Private : sig
  (** This module is exported for testing purposes only. Its signature may
      change in breaking ways without any notice. Do not use. *)

  module Arg : sig
    val doc_of_param : doc:string -> param:'a Ast.Param.t -> string
  end

  module Command : sig
    val manpage_of_readme : readme:(unit -> string) -> [ `P of string ] list
  end
end
