module Config : sig
  type t

  val create
    :  ?auto_add_short_aliases:bool (** default to [true]. *)
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

val basic : ?config:Config.t -> unit Commandlang.Command.t -> Command.t
