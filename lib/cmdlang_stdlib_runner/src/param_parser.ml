let rec eval : type a. a Ast.Param.t -> string -> a Ast.or_error_msg =
  fun (type a) (param : a Ast.Param.t) (str : string) : a Ast.or_error_msg ->
  let err msg = Error (`Msg msg) in
  match param with
  | Conv { docv = _; parse; print = _ } -> parse str
  | String -> Ok str
  | Int ->
    (match int_of_string_opt str with
     | Some a -> Ok a
     | None -> err (Printf.sprintf "invalid value %S (not an int)" str))
  | Float ->
    (match float_of_string_opt str with
     | Some a -> Ok a
     | None -> err (Printf.sprintf "invalid value %S (not a float)" str))
  | Bool ->
    (match bool_of_string_opt str with
     | Some a -> Ok a
     | None -> err (Printf.sprintf "invalid value %S (not a bool)" str))
  | File -> Ok str
  | Enum { docv = _; choices = hd :: tl; to_string = _ } ->
    (match hd :: tl |> List.find_opt (fun (choice, _) -> String.equal choice str) with
     | Some (_, a) -> Ok a
     | None -> err (Printf.sprintf "invalid value %S (not a valid choice)" str))
  | Comma_separated param ->
    let params = String.split_on_char ',' str in
    let oks, errors =
      params
      |> List.partition_map (fun str ->
        match eval param str with
        | Ok a -> Either.Left a
        | Error (`Msg m) -> Either.Right m)
    in
    (match errors with
     | [] -> Ok oks
     | _ :: _ as msgs -> err (String.concat ", " msgs))
;;

let docv : type a. a Ast.Param.t -> docv:string option -> string =
  fun param ~docv ->
  let rec aux : type a. a Ast.Param.t -> docv:string option -> string =
    fun (type a) (param : a Ast.Param.t) ~docv ->
    match docv with
    | Some v -> v
    | None ->
      let or_val = function
        | Some v -> v
        | None -> "VAL"
      in
      (match param with
       | Conv { docv; parse = _; print = _ } -> or_val docv
       | String -> "STRING"
       | Int -> "INT"
       | Float -> "FLOAT"
       | Bool -> "BOOL"
       | File -> "FILE"
       | Enum { docv; choices = _; to_string = _ } -> or_val docv
       | Comma_separated param -> aux param ~docv:None)
  in
  aux param ~docv
;;

let rec print : type a. a Ast.Param.t -> a -> string =
  fun (type a) (param : a Ast.Param.t) (a : a) : string ->
  match param with
  | Conv { docv = _; parse = _; print } -> Format.asprintf "%a" print a
  | String -> a
  | Int -> string_of_int a
  | Float -> string_of_float a
  | Bool -> string_of_bool a
  | File -> a
  | Enum { docv = _; choices = hd :: tl; to_string } ->
    (match hd :: tl |> List.find_opt (fun (_, b) -> a == b) with
     | Some (s, _) -> s
     | None -> to_string a)
  | Comma_separated param -> a |> List.map (fun a -> print param a) |> String.concat ", "
;;
