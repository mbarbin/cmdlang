(** Internal representation used to run a parser.

    This is the final representation returned after all of the parsing phases
    have completed, and is ready to run user code. *)

type 'a t =
  | Value : 'a -> 'a t
  | Map :
      { x : 'a t
      ; f : 'a -> 'b
      }
      -> 'b t
  | Both : 'a t * 'b t -> ('a * 'b) t
  | Apply :
      { f : ('a -> 'b) t
      ; x : 'a t
      }
      -> 'b t

val eval : 'a t -> 'a
