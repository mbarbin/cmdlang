(** A mutable state that will collect parsing information.

    The strategy implemented by the cmdlang runner is to create such parser
    state, enrich it during a parsing phases using [stdlib.arg], and once this
    is done, return an expression suitable for evaluation. *)

type 'a t

(** {1 Initialization}

    In this part we allocate a parser state for a given parser. Once this is
    done, the parser must be enriched with information coming from the command
    line. *)

val create : 'a Ast.Arg.t -> 'a t Ast.or_error_msg

(** {1 Parsing}

    This part is what allows [stdlib.arg] to performs the expected side-effects
    within the state. *)

val spec : _ t -> (Arg.key * Arg.spec * Arg.doc) list
val positional_state : _ t -> Positional_state.t

(** {1 Finalization}

    Once the parsing has been done, we can finalize the state and return an
    evaluation suitable for execution. *)

val finalize : 'a t -> ('a Arg_runner.t, Arg_state.Parse_error.t) Result.t
