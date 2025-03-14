(** This is a helper that allows printing climate errors in the expect tests. *)

type t = Climate.For_test.Non_ret.t

val print : t -> unit
