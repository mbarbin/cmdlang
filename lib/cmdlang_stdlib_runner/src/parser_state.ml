let make_arg_spec
  : type a. name:string -> a Ast.Param.t -> with_var:(a -> unit) -> Arg.spec
  =
  fun ~name param ~with_var ->
  let unspecialized : type a. a Ast.Param.t -> with_var:(a -> unit) -> Arg.spec =
    fun param ~with_var ->
    Arg.String
      (fun s ->
        match Param_parser.eval param s with
        | Ok v -> with_var v
        | Error (`Msg m) ->
          raise
            (Arg.Bad (Printf.sprintf "Failed to parse the named argument %S: %s" name m)))
  in
  match param with
  | String -> Arg.String with_var
  | Int -> Arg.Int with_var
  | Float -> Arg.Float with_var
  | Bool -> Arg.Bool with_var
  | File -> Arg.String with_var
  | Enum { docv = _; choices = hd :: tl; to_string = _ } ->
    let choices = hd :: tl in
    let symbols = List.map fst choices in
    Arg.Symbol
      ( symbols
      , fun symbol ->
          choices
          |> List.find (fun (choice, _) -> String.equal choice symbol)
          |> snd
          |> with_var )
  | Conv _ as param -> unspecialized param ~with_var
  | Comma_separated _ as param -> unspecialized param ~with_var
;;

let make_key ~name =
  let length = String.length name in
  if length > 0 && name.[0] = '-'
  then name
  else if length = 1
  then "-" ^ name
  else "--" ^ name
;;

module Arg_presence = struct
  type 'a t =
    | Required
    | Optional
    | Repeated
    | With_default of
        { param : 'a Ast.Param.t
        ; default : 'a
        }
end

let ( let* ) = Result.bind

let make_docv param ~docv =
  let docv = Param_parser.docv param ~docv in
  Printf.sprintf "<%s>" docv
;;

let make_doc (type a) ~doc ~arg_presence =
  Printf.sprintf
    "%s (%s)"
    doc
    (match (arg_presence : a Arg_presence.t) with
     | Required -> "required"
     | Optional -> "optional"
     | Repeated -> "repeated"
     | With_default { param; default } ->
       Printf.sprintf "default %s" (Param_parser.print param default))
;;

let compile
  : type a.
    a Arg_state.t
    -> ((Arg.key * Arg.spec * Arg.doc) list * Positional_state.t) Ast.or_error_msg
  =
  fun t ->
  let r = ref [] in
  let pos_state = ref [] in
  let pos_all_state = ref None in
  let emit_named s = r := s :: !r in
  let emit_pos pos = pos_state := Positional_state.One_pos.T pos :: !pos_state in
  let rec aux : type a. a Arg_state.t -> unit =
    fun t ->
    match t with
    | Return (_ : a) -> ()
    | Map { x; f = _ } -> aux x
    | Both (a, b) ->
      aux a;
      aux b
    | Apply { f; x } ->
      aux f;
      aux x
    | Flag { names = hd :: tl; doc; var } ->
      let doc = make_doc ~doc ~arg_presence:Optional in
      hd :: tl
      |> List.iter (fun name -> emit_named (make_key ~name, Arg.Set var, " " ^ doc))
    | Flag_count { names = hd :: tl; doc; var } ->
      let doc = make_doc ~doc ~arg_presence:Repeated in
      hd :: tl
      |> List.iter (fun name ->
        emit_named (make_key ~name, Arg.Unit (fun () -> incr var), " " ^ doc))
    | Named { names = hd :: tl; param; docv; doc; var } ->
      let doc = make_doc ~doc ~arg_presence:Required in
      let docv = make_docv param ~docv in
      hd :: tl
      |> List.iter (fun name ->
        emit_named
          ( make_key ~name
          , make_arg_spec ~name param ~with_var:(fun s -> var := Some s)
          , docv ^ " " ^ doc ))
    | Named_multi { names = hd :: tl; param; docv; doc; rev_var } ->
      let doc = make_doc ~doc ~arg_presence:Repeated in
      let docv = make_docv param ~docv in
      hd :: tl
      |> List.iter (fun name ->
        emit_named
          ( make_key ~name
          , make_arg_spec ~name param ~with_var:(fun s -> rev_var := s :: !rev_var)
          , docv ^ " " ^ doc ))
    | Named_opt { names = hd :: tl; param; docv; doc; var } ->
      let doc = make_doc ~doc ~arg_presence:Optional in
      let docv = make_docv param ~docv in
      hd :: tl
      |> List.iter (fun name ->
        emit_named
          ( make_key ~name
          , make_arg_spec ~name param ~with_var:(fun s -> var := Some s)
          , docv ^ " " ^ doc ))
    | Named_with_default { names = hd :: tl; param; default; docv; doc; var } ->
      let doc = make_doc ~doc ~arg_presence:(With_default { param; default }) in
      let docv = make_docv param ~docv in
      hd :: tl
      |> List.iter (fun name ->
        emit_named
          ( make_key ~name
          , make_arg_spec ~name param ~with_var:(fun s -> var := Some s)
          , docv ^ " " ^ doc ))
    | Pos { pos; param; docv; doc; var } ->
      let doc = make_doc ~doc ~arg_presence:Required in
      emit_pos { pos; param; docv; doc; var }
    | Pos_opt { pos; param; docv; doc; var } ->
      let doc = make_doc ~doc ~arg_presence:Optional in
      emit_pos { pos; param; docv; doc; var }
    | Pos_with_default { pos; param; default; docv; doc; var } ->
      let doc = make_doc ~doc ~arg_presence:(With_default { param; default }) in
      emit_pos { pos; param; docv; doc; var }
    | Pos_all { param; docv; doc; rev_var } ->
      let doc = make_doc ~doc ~arg_presence:Repeated in
      pos_all_state := Some (Positional_state.Pos_all.T { param; docv; doc; rev_var })
  in
  aux t;
  let spec_list = !r in
  let* positional_state = Positional_state.make ~pos:!pos_state ~pos_all:!pos_all_state in
  Ok (spec_list, positional_state)
;;

type 'a t =
  { arg_state : 'a Arg_state.t
  ; spec : (Arg.key * Arg.spec * Arg.doc) list
  ; positional_state : Positional_state.t
  }

let create arg =
  let arg_state = Arg_state.create arg in
  let* spec, positional_state = compile arg_state in
  Ok { arg_state; spec; positional_state }
;;

let spec t = t.spec
let positional_state t = t.positional_state
let finalize t = Arg_state.finalize t.arg_state
