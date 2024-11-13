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

let rec eval : type a. a t -> a =
  fun (type a) (t : a t) : a ->
  match t with
  | Value a -> a
  | Map { x; f } -> f (eval x)
  | Both (a, b) ->
    let a = eval a in
    let b = eval b in
    a, b
  | Apply { f; x } ->
    let f = eval f in
    let x = eval x in
    f x
;;
