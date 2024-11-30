(** Translate cmdlang parsers to core.command. *)

(** {1 Configuration}

    The translation implemented in this module allows some configuration
    regarding the resulting command that you want to build. The goal of this
    configuration is to furnish assistance for complex multi-stages migrations from
    a backend to another.

    It is currently experimental, not well tested or documented, and expected to
    change in the future. *)

module Config : sig
  type t

  val create
    :  ?auto_add_one_dash_aliases:bool
         (** default to [false]. We recommend enabling one dash aliases to be
             used for migration path only. *)
    -> ?full_flags_required:bool
         (** default to [true]. Accepting flags unique prefixes makes the
             resulting behavior quite different from the other backends - we
             recommend [false] to be used for migration path only. *)
    -> unit
    -> t
end

(** {1 Param} *)

val param : 'a Cmdlang.Command.Param.t -> config:Config.t -> 'a Command.Arg_type.t

(** {1 Arg} *)

val arg : 'a Cmdlang.Command.Arg.t -> config:Config.t -> 'a Command.Param.t

(** {1 Command} *)

val command_basic : ?config:Config.t -> (unit -> unit) Cmdlang.Command.t -> Command.t

val command_or_error
  :  ?config:Config.t
  -> (unit -> unit Or_error.t) Cmdlang.Command.t
  -> Command.t

(** [unit] can be a convenient helper during a migration, however note that it
    is probably not quite right, due to the body of the command being evaluated
    as an argument. *)
val command_unit : ?config:Config.t -> unit Cmdlang.Command.t -> Command.t

module Utils : sig
  (** {1 Migration helpers} *)

  (** Print error and exit on error. Mimic [Core.Command.basic_or_error]. *)
  val or_error_handler : f:(unit -> unit Or_error.t) -> unit

  val command_unit_of_basic : (unit -> unit) Cmdlang.Command.t -> unit Cmdlang.Command.t

  val command_unit_of_or_error
    :  (unit -> unit Or_error.t) Cmdlang.Command.t
    -> unit Cmdlang.Command.t
end

(** {1 Private} *)

module Private : sig
  (** This module is exported for testing purposes only. Its signature may
      change in breaking ways without any notice. Do not use. *)

  module Arg : sig
    type 'a t = 'a Command.Param.t

    val translate : 'a Cmdlang_ast.Ast.Arg.t -> config:Config.t -> 'a t
  end
end
