(*_********************************************************************************)
(*_  cmdlang - Declarative command-line parsing for OCaml                         *)
(*_  SPDX-FileCopyrightText: 2024-2025 Mathieu Barbin <mathieu.barbin@gmail.com>  *)
(*_  SPDX-License-Identifier: MIT                                                 *)
(*_********************************************************************************)

module Array : sig
  include module type of Array

  val find_mapi : (int -> 'a -> 'b option) -> 'a array -> 'b option
end
