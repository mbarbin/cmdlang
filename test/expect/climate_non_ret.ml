type t = Climate.For_test.Non_ret.t

let print : t -> unit = function
  | Help spec -> Climate.For_test.print_help_spec spec
  | Manpage { spec; prose } -> Climate.For_test.print_manpage spec prose [@coverage off]
  | Reentrant_query { suggestions } ->
    print_s [%sexp Reentrant_query { suggestions : string list }] [@coverage off]
  | Parse_error parse_error ->
    print_endline (Climate.For_test.Parse_error.to_string parse_error)
  | Generate_completion_script { completion_script } ->
    print_s
      [%sexp Generate_completion_script { completion_script : string }] [@coverage off]
;;
