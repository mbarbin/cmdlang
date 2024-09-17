(** Err_cli contains functions to work with Err on the side of end programs
    (such as a command line tool, as opposed to libraries).

    It defines a command line parser to configure the [Err] library, while
    taking take of setting the [Logs] and [Fmt] style rendering. *)

(** {1 Configuration} *)

module Config : sig
  type t

  val create
    :  ?logs_level:Logs.level option
    -> ?fmt_style_renderer:Fmt.style_renderer option
    -> ?warn_error:bool
    -> unit
    -> t

  (** {1 Getters} *)

  val logs_level : t -> Logs.level option
  val fmt_style_renderer : t -> Fmt.style_renderer option
  val warn_error : t -> bool

  (** {1 Arg builders} *)

  val logs_level_arg : Logs.level option Command.Arg.t
  val fmt_style_renderer_arg : Fmt.style_renderer option Command.Arg.t
  val arg : t Command.Arg.t
  val to_args : t -> string list
end

(** Perform global side effects to modules such as [Err], [Logs] & [Fmt] to
    configure how to do error rendering in the terminal, set log levels, etc. If
    you wish to do this automatically from the arguments parsed in a command
    line, see also {!val:set_config}. *)
val setup_config : config:Config.t -> unit

(** Adding this argument to your command line will make it support [Err]
    configuration and takes care of setting the global configuration with
    specification coming from the command line. This is designed to work well
    with project using [Err], [Logs] and [Fmt].

    {[
      let open Command.Std in
      let+ () = Err_cli.set_config () in ...
    ]} *)
val set_config : unit -> unit Command.Arg.t
