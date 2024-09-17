module Core_command = Command
module Command = Cmdlang.Command

type 'a t =
  { arg : 'a Command.Arg.t
  ; base : ('a Core_command.Param.t, Exn.t) Result.t
  ; climate : ('a Climate.Arg_parser.t, Exn.t) Result.t
  ; cmdliner : ('a Cmdliner.Term.t, Exn.t) Result.t
  }

let create arg =
  let base =
    let config = Cmdlang_to_base.Translate.Config.create () in
    match Cmdlang_to_base.Translate.arg arg ~config with
    | param -> Ok param
    | exception e -> Error e [@coverage off]
  in
  let climate =
    match Cmdlang_to_climate.Translate.arg arg with
    | arg_parser -> Ok arg_parser
    | exception e -> Error e [@coverage off]
  in
  let cmdliner =
    match Cmdlang_to_cmdliner.Translate.arg arg with
    | term -> Ok term
    | exception e -> Error e [@coverage off]
  in
  { arg; base; climate; cmdliner }
;;

module Backend = struct
  type t =
    | Climate
    | Cmdliner
    | Core_command
  [@@deriving enumerate, sexp_of]

  let to_string t = Sexp.to_string (sexp_of_t t)
end

module Command_line = struct
  type t =
    { prog : string
    ; args : string list
    }
end

(* Improve the display of certain exceptions encountered during our tests. *)
let () =
  Sexplib0.Sexp_conv.Exn_converter.add
    [%extension_constructor Climate.Parse_error.E]
    (function
    | Climate.Parse_error.E e ->
      List [ Atom "Climate.Parse_error.E"; Atom (Climate.Parse_error.to_string e) ] [@coverage
                                                                                      off]
    | _ -> assert false);
  Sexplib0.Sexp_conv.Exn_converter.add
    [%extension_constructor Climate.Spec_error.E]
    (function
    | Climate.Spec_error.E e ->
      List [ Atom "Climate.Spec_error.E"; Atom (Climate.Spec_error.to_string e) ] [@coverage
                                                                                    off]
    | _ -> assert false);
  ()
;;

let eval_base t { Command_line.prog = _; args } =
  match t.base with
  | Error e -> print_s [%sexp "Translation Raised", (e : Exn.t)] [@coverage off]
  | Ok param ->
    (match Core_command.Param.parse param args with
     | Ok () -> ()
     | Error e -> print_s [%sexp "Evaluation Failed", (e : Error.t)]
     | exception e -> print_s [%sexp "Evaluation Raised", (e : Exn.t)] [@coverage off])
;;

let eval_climate t { Command_line.prog; args } =
  match t.climate with
  | Error e -> print_s [%sexp "Translation Raised", (e : Exn.t)] [@coverage off]
  | Ok arg_parser ->
    (match
       let cmd = Climate.Command.singleton arg_parser in
       Climate.Command.eval cmd { program = prog; args }
     with
     | () -> ()
     | exception e -> print_s [%sexp "Evaluation Raised", (e : Exn.t)] [@coverage off])
;;

let eval_cmdliner t { Command_line.prog; args } =
  match t.cmdliner with
  | Error e -> print_s [%sexp "Translation Raised", (e : Exn.t)] [@coverage off]
  | Ok term ->
    (match
       let cmd = Cmdliner.Cmd.v (Cmdliner.Cmd.info prog) term in
       Cmdliner.Cmd.eval cmd ~argv:(Array.of_list (prog :: args))
     with
     | 0 -> ()
     | exit_code ->
       print_s [%sexp "Evaluation Failed", { exit_code : int }] [@coverage off]
     | exception e -> print_s [%sexp "Evaluation Raised", (e : Exn.t)] [@coverage off])
;;

let eval_all t command_line =
  List.iter Backend.all ~f:(fun backend ->
    print_endline
      (Printf.sprintf "----------------------------- %s" (Backend.to_string backend));
    match backend with
    | Climate -> eval_climate t command_line
    | Cmdliner -> eval_cmdliner t command_line
    | Core_command -> eval_base t command_line);
  ()
;;
