(** {1 Param} *)

val param : 'a Cmdlang.Command.Param.t -> 'a Climate.Arg_parser.conv

(** {1 Arg} *)

val arg : 'a Cmdlang.Command.Arg.t -> 'a Climate.Arg_parser.t

(** {1 Command} *)

val command : 'a Cmdlang.Command.t -> 'a Climate.Command.t

module Private : sig
  (** This module is exported for testing purposes only. Its signature may
      change in breaking ways without any notice. Do not use. *)
end
