(** Declarative Command-line Parsing for OCaml. *)

(** {1 Utils} *)

module Nonempty_list : sig
  type 'a t = 'a Commandlang_ast.Ast.Nonempty_list.t = ( :: ) : 'a * 'a list -> 'a t
end

module type Enumerated_stringable = sig
  type t

  val all : t list
  val to_string : t -> string
end

module type Stringable = sig
  (** An interface for types that can be parsed from strings, when parsing never
      results in failures. *)

  type t

  (** This function is not expected to to raise. If you need to validate the
      input string, see {!val:validated_string}. *)
  val of_string : string -> t

  val to_string : t -> string
end

module type Validated_string = sig
  (** An interface for types that can be parsed from strings, with the possibility
      of parsing failures. This is useful for types that require validation
      during conversion from string representations.

      The names [v] and [to_string] were chosen to match the conventions used by
      some existing libraries, such as [Fpath]. *)

  type t

  (** Parses a string into the type [t], potentially raising an exception if the
      string is invalid. The exception is turned into a user facing message,
      so the actual exception is expected to be registered with [Printexc]. *)
  val v : string -> t

  val to_string : t -> string
end

(** {1 Parameters} *)

module Param : sig
  type 'a t
  type 'a parse := string -> ('a, [ `Msg of string ]) result
  type 'a print := Format.formatter -> 'a -> unit

  val create : docv:string -> parse:'a parse -> print:'a print -> 'a t

  (** {1 Basic types} *)

  val string : string t
  val int : int t
  val float : float t
  val bool : bool t
  val file : string t

  (** {1 Helpers} *)

  val assoc : ?docv:string -> (string * 'a) list -> 'a t
  val enumerated : ?docv:string -> (module Enumerated_stringable with type t = 'a) -> 'a t
  val stringable : ?docv:string -> (module Stringable with type t = 'a) -> 'a t

  val validated_string
    :  ?docv:string
    -> (module Validated_string with type t = 'a)
    -> 'a t

  val comma_separated : 'a t -> 'a list t
end

(** {1 Arguments} *)

module Arg : sig
  type 'a t

  val return : 'a -> 'a t

  (** {1 Named arguments} *)

  val flag : string Nonempty_list.t -> doc:string -> bool t
  val named : ?docv:string -> string Nonempty_list.t -> 'a Param.t -> doc:string -> 'a t

  val named_multi
    :  ?docv:string
    -> string Nonempty_list.t
    -> 'a Param.t
    -> doc:string
    -> 'a list t

  val named_opt
    :  ?docv:string
    -> string Nonempty_list.t
    -> 'a Param.t
    -> doc:string
    -> 'a option t

  val named_with_default
    :  ?docv:string
    -> string Nonempty_list.t
    -> 'a Param.t
    -> default:'a
    -> doc:string
    -> 'a t

  (** {1 Positional arguments} *)

  (** Positional argument start at index 0. *)

  val pos : ?docv:string -> pos:int -> 'a Param.t -> doc:string -> 'a t
  val pos_opt : ?docv:string -> pos:int -> 'a Param.t -> doc:string -> 'a option t

  val pos_with_default
    :  ?docv:string
    -> pos:int
    -> 'a Param.t
    -> default:'a
    -> doc:string
    -> 'a t

  val pos_all : ?docv:string -> 'a Param.t -> doc:string -> 'a list t
end

(** {1 Commands} *)

type 'a t

val make : ?readme:(unit -> string) -> 'a Arg.t -> summary:string -> 'a t

val group
  :  ?default:'a Arg.t
  -> ?readme:(unit -> string)
  -> summary:string
  -> (string * 'a t) list
  -> 'a t

(** For use with the [( let+ )] style. *)

module type Applicative_syntax = sig
  type 'a t

  val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
  val ( and+ ) : 'a t -> 'b t -> ('a * 'b) t
end

(** {1 Let operators}

    For use with the [( let+ )] style. *)

module Std : sig
  include Applicative_syntax with type 'a t := 'a Arg.t
  module Arg = Arg
  module Param = Param
end

(** {1 Ppx_let}

    For use with the [( let%map_open.Command )] style. *)

module type Applicative_infix = sig
  type 'a t

  val ( <*> ) : ('a -> 'b) t -> 'a t -> 'b t
  val ( <* ) : 'a t -> unit t -> 'a t
  val ( *> ) : unit t -> 'a t -> 'a t
  val ( >>| ) : 'a t -> ('a -> 'b) -> 'b t
end

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
    [commandlang]. Its signature may change in breaking ways at any time without
    prior notice. *)

module Private : sig
  module To_ast : sig
    val arg : 'a Arg.t -> 'a Ast.Arg.t
    val param : 'a Param.t -> 'a Ast.Param.t
    val command : 'a t -> 'a Ast.Command.t
  end
end
