module Array : sig
  include module type of Array

  val find_mapi : (int -> 'a -> 'b option) -> 'a array -> 'b option
end
