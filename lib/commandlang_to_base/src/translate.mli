module Config : sig
  type t

  val create
    :  ?auto_add_short_aliases:bool (** default to [false]. *)
    -> ?auto_add_one_dash_aliases:bool
         (** default to [false]. We recommend enabling one dash aliases to be
             used for migration path only. *)
    -> ?full_flags_required:bool
         (** default to [true]. Accepting flags unique prefixes makes the
             resulting behavior quite different from the other backends - we
             recommend [false] to be used for migration path only. *)
    -> unit
    -> t
end

val basic : ?config:Config.t -> (unit -> unit) Commandlang.Command.t -> Command.t

val or_error
  :  ?config:Config.t
  -> (unit -> unit Or_error.t) Commandlang.Command.t
  -> Command.t

(** [unit] can be a convenient helper during a migration, however note that it
    is probably not quite right, due to the body of the command being evaluated
    as an argument. *)
val unit : ?config:Config.t -> unit Commandlang.Command.t -> Command.t

module Private : sig
  (** This module is exported for testing purposes only. Its signature may
      change in breaking ways without any notice. Do not use. *)

  module Arg : sig
    type 'a t = { param : 'a Command.Param.t }

    val project : 'a Commandlang_ast.Ast.Arg.t -> config:Config.t -> 'a t
  end
end
