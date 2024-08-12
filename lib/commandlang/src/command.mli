(** {1 Utils} *)

module Nonempty_list : sig
  type 'a t = 'a Commandlang_ast.Ast.Nonempty_list.t = ( :: ) : 'a * 'a list -> 'a t
end

module type Enumerated_stringable = sig
  type t

  val all : t list
  val to_string : t -> string
end

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
end

module Arg : sig
  type 'a t

  val return : 'a -> 'a t

  (** {1 Named arguments} *)

  val flag : string Nonempty_list.t -> doc:string -> bool t
  val named : ?docv:string -> string Nonempty_list.t -> 'a Param.t -> doc:string -> 'a t

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

  (** starting at 0. *)

  val pos : ?docv:string -> ?doc:string -> int -> 'a Param.t -> 'a t
  val pos_opt : ?docv:string -> ?doc:string -> int -> 'a Param.t -> 'a option t

  val pos_with_default
    :  ?docv:string
    -> ?doc:string
    -> int
    -> 'a Param.t
    -> default:'a
    -> 'a t

  val pos_all : ?docv:string -> ?doc:string -> 'a Param.t -> 'a list t
end

(** {1 Command} *)

type 'a t

val make : 'a Arg.t -> summary:string -> 'a t
val group : ?default:'a Arg.t -> summary:string -> (string * 'a t) list -> 'a t

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
