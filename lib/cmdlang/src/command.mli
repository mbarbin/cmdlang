(** Declarative Command-line Parsing for OCaml.

    Cmdlang is a library for creating command-line parsers in OCaml. Implemented
    as an OCaml EDSL, its declarative specification language lives at the
    intersection of other well-established similar libraries.

    Cmdlang exposes a single module named [Command], which contains the entire
    API to declare command line parsers.

    Assuming [Cmdlang.Command] to be available in your scope as [Command], the
    following is a minimalist command that does nothing:

    {[
      let cmd : unit Command.t =
        Command.make
          ~summary:"A command that does nothing"
          (let open Command.Std in
           let+ () = Arg.return () in
           ())
      ;;
    ]}

    To get started with this API refers to this
    {{:https://mbarbin.github.io/cmdlang/docs/tutorials/getting-started/} tutorial}
    from cmdlang's documentation. *)

(** {1 Terminology}

    The terminology used by cmdlang is inspired by
    {{:https://github.com/gridbugs/climate/} climate}.

    {2:arguments Arguments}

    An {e Argument} is a distinct piece of information passed to the program on
    the command line. For example, in the command [make -td --jobs 4 all], there
    are 4 arguments: [-t], [-d], [--jobs 4], and [all]. Arguments are declared
    using the module {!module:Arg}.

    Arguments can be either {e positional} or {e named}:

    {3:positional_arguments Positional arguments}

    {e Positional} arguments are identified by their position (0-based) in the
    argument list rather than by name.

    {3:named_arguments Named arguments}

    {e Named} arguments can be either {e short} or {e long}:
    - {e Short} named arguments begin with a single [-] followed by a single
      non [-] character, such as [-l].
    - {e Long} named arguments begin with [--] followed by several non [-]
      characters, such as [--jobs].

    {3:parameters Parameters}

    A {e Parameter} is a single value that is attached to a named argument on
    the command line. For example, in [make --jobs 4], ["jobs"] is the argument
    name and [4] is its parameter. Parameters are declared using the module
    {!module:Param}.

    {2:docv docv}

    The term {e docv} is a convention in the API to denote the string that will
    be printed in the help messages in place of the value that is actually
    expected. This applies to both positional arguments and parameters of named
    arguments. For example, in the help message for a named argument, you might
    see [--flag VALUE], where "VALUE" is the {e docv} representing the expected
    parameter. Similarly, for positional arguments, you might see usage like
    [./main.exe VAL VAL], where "VAL" is the {e docv} representing the expected
    positional argument. The name {e docv} stands for "documentation value" and
    was inspired by {i cmdliner}.

    {2 Supported Command Line Syntax}

    Not all syntaxes are supported by all backends, so you should check the
    documentation of the targeted backend for more information, and choose your
    execution engine according to your preferences.

    For example, some backends may support combining a collection of short named
    arguments together with a single leading [-] followed by each short argument
    name (in which case [ls -la] is an alternative way of writing [ls -l -a]).

    As another example, we list here the different ways supported by climate of
    passing a parameter to a named argument on the command line:

    {v
      make --jobs=4   (* long name with equals sign *)
      make --jobs 4   (* long name space delimited *)
      make -j 4       (* short name space delimited *)
      make -j4        (* short name without space *)
    v} *)

(** {1 Utils} *)

module Nonempty_list : sig
  (** A type to represent lists that are statically known to be non-empty. *)

  (** The way this constructor is defined allows one to use the regular list
      literal syntax in a context where a non-empty list is expected. For
      example, the function {!val:Arg.flag} expects a first argument of type
      [string Nonempty_list.t] and may be used that way:

      {[
        Arg.flag [ "verbose" ] ~doc:"enable more output"
      ]}

      The point being that the following would be a type error:

      {[
        Arg.flag [] ~doc:"enable more output"
      ]} *)
  type 'a t = 'a Cmdlang_ast.Ast.Nonempty_list.t = ( :: ) : 'a * 'a list -> 'a t
end

(** {1 Interfaces}

    These interfaces are convenient to use with the {!module:Param} module, so
    you can apply its helpers to custom modules. For example, if your module
    [My_enum] implements the {!Enumerated_stringable} interface, then you can
    build a parser for it with:

    {[
      Param.enumerated (module My_enum)
    ]} *)

module type Enumerated_stringable = sig
  (** An interface for types that have a finite number of inhabitants that all
      have a canonical string representation. *)

  type t

  val all : t list

  (** Due to the canonical string representation contract, cmdlang will assume
      to be able to define an equality function between [t]s defined as such:

      {[
        let equal a b = phys_equal a b || String.equal (to_string a) (to_string b)
      ]} *)
  val to_string : t -> string
end

module type Stringable = sig
  (** An interface for types that can be parsed from strings, when parsing never
      results in failures. *)

  type t

  (** This function is not expected to to raise. If you need to validate the
      input string, see {!val:Param.validated_string}. *)
  val of_string : string -> t

  val to_string : t -> string
end

module type Validated_string = sig
  (** An interface for types that can be parsed from strings, with the
      possibility of parsing failures.

      This is useful for types that require validation during conversion from
      string representations. The names and types for the functions [of_string]
      and [to_string] were chosen to match the conventions used by some existing
      libraries, such as [Fpath]. *)

  type t

  (** Parses a string into the type [t], potentially returning an error if the
      string is invalid. *)
  val of_string : string -> (t, [ `Msg of string ]) Result.t

  val to_string : t -> string
end

(** {1 Building Parameters} *)

module Param : sig
  (** Refer to the {{!parameters} Parameters} terminology. *)

  (** Parsing parameters of type ['a] from the command line. *)
  type 'a parse := string -> ('a, [ `Msg of string ]) result

  (** Printing parameters of type ['a] back to their expected command line
      syntax. Printing parameter is used for example when documenting default
      values in the help messages. *)
  type 'a print := Format.formatter -> 'a -> unit

  (** A type to hold the capability of parsing and printing a parameter of
      type ['a]. *)
  type 'a t

  val create : docv:string -> parse:'a parse -> print:'a print -> 'a t

  (** {1 Basic types} *)

  (** The API supports basic types with default {!docv} values. These defaults
      can be overridden for each argument. The default {e docv} is used only
      if none is specified at the argument level. The actual syntax used by
      default depend on the targeted backend. *)

  val string : string t
  val int : int t
  val float : float t
  val bool : bool t
  val file : string t

  (** {1 Helpers} *)

  (** Helpers for creating parameters for custom types. These helpers also come
      with default {e docv} values, which can be overridden as needed. *)

  (** Create a parameter for an enumerated type. The module must implement the
      [Enumerated_stringable] interface.

      Example:
      {[
        module Color = struct
          type t =
            | Red
            | Green
            | Blue

          let all = [ Red; Green; Blue ]

          let to_string = function
            | Red -> "red"
            | Green -> "green"
            | Blue -> "blue"
          ;;
        end

        let color_param = Param.enumerated ~docv:"COLOR" (module Color)
      ]}

      The usage message will show the supported values for [COLOR]. *)
  val enumerated : ?docv:string -> (module Enumerated_stringable with type t = 'a) -> 'a t

  val stringable : ?docv:string -> (module Stringable with type t = 'a) -> 'a t

  (** To be used with custom types when the parsing may fail. *)
  val validated_string
    :  ?docv:string
    -> (module Validated_string with type t = 'a)
    -> 'a t

  (** Parser for a list of values separated by commas. *)
  val comma_separated : 'a t -> 'a list t
end

(** {1 Building Arguments} *)

module Arg : sig
  (** Refer to the {{!arguments} Arguments} terminology. *)

  type 'a t

  (** {1 Applicative operations} *)

  val return : 'a -> 'a t
  val apply : ('a -> 'b) t -> 'a t -> 'b t
  val map : 'a t -> f:('a -> 'b) -> 'b t
  val both : 'a t -> 'b t -> ('a * 'b) t

  (** {1 Named arguments} *)

  (** A flag that may appear at most once on the command line. *)
  val flag : string Nonempty_list.t -> doc:string -> bool t

  (** A flag that may appear multiple times on the command line. Evaluates to
      the number of times the flag appeared. *)
  val flag_count : string Nonempty_list.t -> doc:string -> int t

  (** A required named argument (must appear exactly once on the command line). *)
  val named : ?docv:string -> string Nonempty_list.t -> 'a Param.t -> doc:string -> 'a t

  (** A named argument that may appear multiple times on the command line. *)
  val named_multi
    :  ?docv:string
    -> string Nonempty_list.t
    -> 'a Param.t
    -> doc:string
    -> 'a list t

  (** An optional named argument (may appear at most once). *)
  val named_opt
    :  ?docv:string
    -> string Nonempty_list.t
    -> 'a Param.t
    -> doc:string
    -> 'a option t

  (** An optional named argument with a default value. *)
  val named_with_default
    :  ?docv:string
    -> string Nonempty_list.t
    -> 'a Param.t
    -> default:'a
    -> doc:string
    -> 'a t

  (** {1 Positional arguments} *)

  (** Positional argument start at index 0. *)

  (** A required positional argument. It must appear exactly once at position
      [i] on the command line. *)
  val pos : ?docv:string -> pos:int -> 'a Param.t -> doc:string -> 'a t

  (** An optional positional argument at position [i]. Optional positional
      argument must not be followed by more positional argument as this
      creates ambiguous specifications. *)
  val pos_opt : ?docv:string -> pos:int -> 'a Param.t -> doc:string -> 'a option t

  (** A optional positional argument with a default value. *)
  val pos_with_default
    :  ?docv:string
    -> pos:int
    -> 'a Param.t
    -> default:'a
    -> doc:string
    -> 'a t

  (** Return the list of all remaining positional arguments. *)
  val pos_all : ?docv:string -> 'a Param.t -> doc:string -> 'a list t
end

(** {1 Building Commands} *)

type 'a t

(** Create a command with the given argument specification and summary.

    - [readme] is an optional function that returns a detailed description of
      the command.
    - [summary] is a short description of what the command does.
    - The argument specification is provided by an ['a Arg.t].

    Example:
    {[
      let hello_cmd =
        Command.make
          ~summary:"Prints 'Hello, world!'"
          ~readme:(fun () ->
            {|
      This would usually be a longer description of the command.
      It can be written on multiple lines.
      |})
          (let open Command.Std in
           let+ () = Arg.return () in
           print_endline "Hello, world!")
      ;;
    ]} *)
val make : ?readme:(unit -> string) -> 'a Arg.t -> summary:string -> 'a t

(** Create a group of subcommands with a common summary.

    - [default] is an optional default command to run if no subcommand is
      specified.
    - [readme] is an optional function that returns a detailed description of
      the command group.
    - [summary] is a short description of what the command group does.
    - The subcommands are provided as a list of (name, command) pairs.

    Example of a group with no default command:
    {[
      let cmd_group =
        Command.group
          ~summary:"A group of related commands"
          [ "hello", hello_cmd; "goodbye", goodbye_cmd ]
      ;;
    ]}

    Each command in the group may itself be a group, allowing for hierarchical
    trees of commands. *)
val group
  :  ?default:'a Arg.t
  -> ?readme:(unit -> string)
  -> summary:string
  -> (string * 'a t) list
  -> 'a t

module Utils : sig
  (** Utilities for handling commands. *)

  (** Return the summary of a command. *)
  val summary : _ t -> string

  (** Map a function over a command. *)
  val map : 'a t -> f:('a -> 'b) -> 'b t
end

(** {1 Applicative operations}

    These operations are used to build command-line parsers in a declarative
    style. *)

module type Applicative_infix = sig
  type 'a t

  val ( >>| ) : 'a t -> ('a -> 'b) -> 'b t
end

(** For use with the [( let+ )] style. *)

module type Applicative_syntax = sig
  type 'a t

  val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
  val ( and+ ) : 'a t -> 'b t -> ('a * 'b) t
end

(** {1 Let operators}

    For use with the [( let+ )] style:

    {[
      let cmd : unit Command.t =
        Command.make
          ~summary:"A command that does nothing"
          (let open Command.Std in
           let+ () = Arg.return () in
           ())
      ;;
    ]} *)

module Std : sig
  include Applicative_syntax with type 'a t := 'a Arg.t
  include Applicative_infix with type 'a t := 'a Arg.t
  module Arg = Arg
  module Param = Param
end

(** {1 Ppx_let}

    For use with the [( let%map_open.Command )] style:

    {[
      let cmd : unit Command.t =
        Command.make
          ~summary:"A command that does nothing"
          (let%map_open.Command () = Arg.return () in
           ())
      ;;
    ]} *)

module Let_syntax : sig
    (** Substituted below. *)
    type 'a t

    val return : 'a -> 'a t

    include Applicative_infix with type 'a t := 'a t

    module Let_syntax : sig
        (** Substituted below. *)
        type 'a t

        val return : 'a -> 'a t
        val map : 'a t -> f:('a -> 'b) -> 'b t
        val both : 'a t -> 'b t -> ('a * 'b) t

        module Open_on_rhs : sig
          module Arg = Arg
          module Param = Param
          include Applicative_infix with type 'a t := 'a t
        end
      end
      with type 'a t := 'a t
  end
  with type 'a t := 'a Arg.t

(** {1 Private}

    This module is exported to be used by libraries with strong ties to
    [cmdlang]. Its signature may change in breaking ways at any time without
    prior notice, and outside of the guidelines set by semver. *)

module Private : sig
  module To_ast : sig
    val arg : 'a Arg.t -> 'a Ast.Arg.t
    val param : 'a Param.t -> 'a Ast.Param.t
    val command : 'a t -> 'a Ast.Command.t
  end
end
