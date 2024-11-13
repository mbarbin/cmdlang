type 'a t =
  | Return : 'a -> 'a t
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
  | Flag :
      { names : string Ast.Nonempty_list.t
      ; doc : string
      ; var : bool ref
      }
      -> bool t
  | Flag_count :
      { names : string Ast.Nonempty_list.t
      ; doc : string
      ; var : int ref
      }
      -> int t
  | Named :
      { names : string Ast.Nonempty_list.t
      ; param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a t
  | Named_multi :
      { names : string Ast.Nonempty_list.t
      ; param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; rev_var : 'a list ref
      }
      -> 'a list t
  | Named_opt :
      { names : string Ast.Nonempty_list.t
      ; param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a option t
  | Named_with_default :
      { names : string Ast.Nonempty_list.t
      ; param : 'a Ast.Param.t
      ; default : 'a
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a t
  | Pos :
      { pos : int
      ; param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a t
  | Pos_opt :
      { pos : int
      ; param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a option t
  | Pos_with_default :
      { pos : int
      ; param : 'a Ast.Param.t
      ; default : 'a
      ; docv : string option
      ; doc : string
      ; var : 'a option ref
      }
      -> 'a t
  | Pos_all :
      { param : 'a Ast.Param.t
      ; docv : string option
      ; doc : string
      ; rev_var : 'a list ref
      }
      -> 'a list t

let rec create : type a. a Ast.Arg.t -> a t =
  fun (type a) (arg : a Ast.Arg.t) ->
  match arg with
  | Return a -> Return a
  | Map { x; f } ->
    let x = create x in
    Map { x; f }
  | Both (x, y) ->
    let x = create x in
    let y = create y in
    Both (x, y)
  | Apply { f; x } ->
    let f = create f in
    let x = create x in
    Apply { f; x }
  | Flag { names; doc } -> Flag { names; doc; var = ref false }
  | Flag_count { names; doc } -> Flag_count { names; doc; var = ref 0 }
  | Named { names; param; docv; doc } -> Named { names; param; docv; doc; var = ref None }
  | Named_multi { names; param; docv; doc } ->
    Named_multi { names; param; docv; doc; rev_var = ref [] }
  | Named_opt { names; param; docv; doc } ->
    Named_opt { names; param; docv; doc; var = ref None }
  | Named_with_default { names; param; default; docv; doc } ->
    Named_with_default { names; param; default; docv; doc; var = ref None }
  | Pos { pos; param; docv; doc } -> Pos { pos; param; docv; doc; var = ref None }
  | Pos_opt { pos; param; docv; doc } -> Pos_opt { pos; param; docv; doc; var = ref None }
  | Pos_with_default { pos; param; default; docv; doc } ->
    Pos_with_default { pos; param; default; docv; doc; var = ref None }
  | Pos_all { param; docv; doc } -> Pos_all { param; docv; doc; rev_var = ref [] }
;;

module Parse_error = struct
  type t =
    | Missing_argument :
        { names : string Ast.Nonempty_list.t
        ; param : 'a Ast.Param.t
        ; docv : string option
        ; doc : string
        }
        -> t
    | Missing_positional_argument :
        { pos : int
        ; param : 'a Ast.Param.t
        ; docv : string option
        ; doc : string
        }
        -> t
end

let finalize (type a) (t : a t) =
  let ( let* ) = Result.bind in
  let rec eval : type a. a t -> (a Arg_runner.t, Parse_error.t) Result.t =
    fun (type a) (arg : a t) : (a Arg_runner.t, Parse_error.t) Result.t ->
    match arg with
    | Return a -> Ok (Arg_runner.Value a)
    | Map { x; f } ->
      let* x = eval x in
      Ok (Arg_runner.Map { x; f })
    | Both (a, b) ->
      let* a = eval a in
      let* b = eval b in
      Ok (Arg_runner.Both (a, b))
    | Apply { f; x } ->
      let* f = eval f in
      let* x = eval x in
      Ok (Arg_runner.Apply { f; x })
    | Flag { names = _; doc = _; var } -> Ok (Arg_runner.Value var.contents)
    | Flag_count { names = _; doc = _; var } -> Ok (Arg_runner.Value var.contents)
    | Named { names; param; docv; doc; var } ->
      (match var.contents with
       | Some value -> Ok (Arg_runner.Value value)
       | None -> Error (Parse_error.Missing_argument { names; param; docv; doc }))
    | Named_multi { names = _; param = _; docv = _; doc = _; rev_var } ->
      Ok (Arg_runner.Value (List.rev rev_var.contents))
    | Named_opt { names = _; param = _; docv = _; doc = _; var } ->
      Ok (Arg_runner.Value var.contents)
    | Named_with_default { names = _; param = _; default; docv = _; doc = _; var } ->
      Ok
        (Arg_runner.Value
           (match var.contents with
            | Some value -> value
            | None -> default))
    | Pos { pos; param; docv; doc; var } ->
      (match var.contents with
       | Some value -> Ok (Arg_runner.Value value)
       | None -> Error (Parse_error.Missing_positional_argument { pos; param; docv; doc }))
    | Pos_opt { pos = _; param = _; docv = _; doc = _; var } ->
      Ok (Arg_runner.Value var.contents)
    | Pos_with_default { pos = _; param = _; default; docv = _; doc = _; var } ->
      Ok
        (Arg_runner.Value
           (match var.contents with
            | Some value -> value
            | None -> default))
    | Pos_all { param = _; docv = _; doc = _; rev_var } ->
      Ok (Arg_runner.Value (List.rev rev_var.contents))
  in
  eval t
;;
