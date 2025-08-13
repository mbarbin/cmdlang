type t = Climate.For_test.Non_ret.t

let print : t -> unit = function
  | Help { command_doc_spec; error; message } ->
    print_s [%sexp Help { command_doc_spec : _; error : bool; message : string option }];
    Climate.For_test.print_help_spec command_doc_spec
  | Manpage { command_doc_spec; prose } ->
    Climate.For_test.print_manpage command_doc_spec prose [@coverage off]
  | Reentrant_query { suggestions } ->
    print_s [%sexp Reentrant_query { suggestions : string list }] [@coverage off]
  | Parse_error { error; command_doc_spec } ->
    Climate.For_test.print_help_spec command_doc_spec;
    print_endline (Climate.For_test.Parse_error.to_string error)
  | Generate_completion_script { completion_script } ->
    print_s
      [%sexp Generate_completion_script { completion_script : string }] [@coverage off]
;;
