open! Import

module Presence = struct
  type 'a t =
    | Required
    | Optional
    | With_default of 'a
end

module One_pos = struct
  type 'a t =
    { pos : int
    ; param : 'a Ast.Param.t
    ; docv : string option
    ; doc : string
    ; presence : 'a Presence.t
    ; var : 'a option ref
    }

  type packed = T : 'a t -> packed [@@unboxed]
end

module Pos_all = struct
  type 'a t =
    { param : 'a Ast.Param.t
    ; docv : string option
    ; doc : string
    ; rev_var : 'a list ref
    }

  type packed = T : 'a t -> packed [@@unboxed]
end

type t =
  { pos : One_pos.packed array
  ; pos_all : Pos_all.packed option
  ; mutable current_pos : int
  }

let make_pos : One_pos.packed list -> One_pos.packed array Ast.or_error_msg =
  fun l ->
  let a = Array.of_list l in
  Array.sort (fun (One_pos.T { pos = a; _ }) (T { pos = b; _ }) -> compare a b) a;
  let skipped =
    Array.find_mapi (fun i (One_pos.T { pos; _ }) -> if i <> pos then Some i else None) a
  in
  match skipped with
  | None -> Ok a
  | Some i ->
    let message =
      Printf.sprintf
        "Attempted to declare a parser with a gap in its positional arguments.\n\
         Positional argument %d is missing.\n"
        i
    in
    Error (`Msg message)
;;

let ( let* ) = Result.bind

let make ~pos ~pos_all =
  let* pos = make_pos pos in
  Ok { pos; pos_all; current_pos = 0 }
;;

let anon_fun t anon =
  let current_pos = t.current_pos in
  t.current_pos <- succ current_pos;
  if current_pos < Array.length t.pos
  then (
    let (One_pos.T { pos; param; docv = _; doc = _; presence = _; var }) =
      t.pos.(current_pos)
    in
    assert (pos = current_pos);
    match Param_parser.eval param anon with
    | Ok a -> var := Some a
    | Error (`Msg error) ->
      raise
        (Arg.Bad
           (Printf.sprintf "Failed to parse the argument at position %d: %s" pos error)))
  else (
    match t.pos_all with
    | None -> raise (Arg.Bad (Printf.sprintf "Unexpected positional argument %S" anon))
    | Some (Pos_all.T { param; docv = _; doc = _; rev_var }) ->
      (match Param_parser.eval param anon with
       | Ok a -> rev_var := a :: !rev_var
       | Error (`Msg error) ->
         raise
           (Arg.Bad
              (Printf.sprintf "Positional argument %d %S: %s" current_pos anon error))))
;;

let usage_msg { pos; pos_all; current_pos = _ } =
  let pos =
    Array.to_list pos
    |> List.map (fun (One_pos.T { pos = _; param; docv; doc; presence; var = _ }) ->
      let docv = Param_parser.docv param ~docv in
      let doc =
        if String.ends_with ~suffix:"." doc
        then String.sub doc 0 (String.length doc - 1)
        else doc
      in
      Printf.sprintf
        "  <%s>  %s (%s)"
        docv
        doc
        (match presence with
         | Required -> "required"
         | Optional -> "optional"
         | With_default def -> Printf.sprintf "default %s" (Param_parser.print param def)))
  in
  let pos_all =
    match pos_all with
    | None -> []
    | Some (Pos_all.T { param; docv; doc; rev_var = _ }) ->
      let docv = Param_parser.docv param ~docv in
      let doc =
        if String.ends_with ~suffix:"." doc
        then String.sub doc 0 (String.length doc - 1)
        else doc
      in
      [ Printf.sprintf "  <%s>*  %s (listed)" docv doc ]
  in
  match pos @ pos_all with
  | [] -> None
  | _ -> Some ("Arguments:\n" ^ String.concat "\n" pos)
;;
