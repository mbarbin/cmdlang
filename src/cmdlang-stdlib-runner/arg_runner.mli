(*_********************************************************************************)
(*_  cmdlang - Declarative command-line parsing for OCaml                         *)
(*_  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

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
