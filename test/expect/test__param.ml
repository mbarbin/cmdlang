module Command = Cmdlang.Command

let test param to_string =
  Arg_test.create
    (let%map_open.Command p = Arg.pos ~pos:0 param ~doc:"param" in
     print_endline (to_string p))
;;

let%expect_test "string" =
  let t1 = test Command.Param.string Fn.id in
  Arg_test.eval_all t1 { prog = "test"; args = [ "hello" ] };
  [%expect
    {|
    ----------------------------- Climate
    hello
    ----------------------------- Cmdliner
    hello
    ----------------------------- Core_command
    hello
    |}];
  ()
;;

let%expect_test "int" =
  let t1 = test Command.Param.int Int.to_string_hum in
  Arg_test.eval_all t1 { prog = "test"; args = [ "1_234" ] };
  [%expect
    {|
    ----------------------------- Climate
    1_234
    ----------------------------- Cmdliner
    1_234
    ----------------------------- Core_command
    1_234
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "not-an-int" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E
      "Failed to parse the argument at position 0: invalid value: \"not-an-int\" (not an int)"))
    ----------------------------- Cmdliner
    test: INT argument: invalid value 'not-an-int', expected an integer
    Usage: test [OPTION]… INT
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"failed to parse INT value \\\"not-an-int\\\"\\n(Failure \\\"Int.of_string: \\\\\\\"not-an-int\\\\\\\"\\\")\")"))
    |}];
  ()
;;

let%expect_test "float" =
  let t1 = test Command.Param.float Float.to_string in
  Arg_test.eval_all t1 { prog = "test"; args = [ "1_234" ] };
  [%expect
    {|
    ----------------------------- Climate
    1234.
    ----------------------------- Cmdliner
    1234.
    ----------------------------- Core_command
    1234.
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "1.234" ] };
  [%expect
    {|
    ----------------------------- Climate
    1.234
    ----------------------------- Cmdliner
    1.234
    ----------------------------- Core_command
    1.234
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "not-an-number" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E
      "Failed to parse the argument at position 0: invalid value: \"not-an-number\" (not an float)"))
    ----------------------------- Cmdliner
    test: FLOAT argument: invalid value 'not-an-number', expected a floating
          point number
    Usage: test [OPTION]… FLOAT
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"failed to parse FLOAT value \\\"not-an-number\\\"\\n(Invalid_argument \\\"Float.of_string not-an-number\\\")\")"))
    |}];
  ()
;;

let%expect_test "bool" =
  let t1 = test Command.Param.bool Bool.to_string in
  Arg_test.eval_all t1 { prog = "test"; args = [ "true" ] };
  [%expect
    {|
    ----------------------------- Climate
    true
    ----------------------------- Cmdliner
    true
    ----------------------------- Core_command
    true
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "false" ] };
  [%expect
    {|
    ----------------------------- Climate
    false
    ----------------------------- Cmdliner
    false
    ----------------------------- Core_command
    false
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "not-a-bool" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E
      "Failed to parse the argument at position 0: invalid value: \"not-a-bool\" (not an bool)"))
    ----------------------------- Cmdliner
    test: BOOL argument: invalid value 'not-a-bool', either 'true' or 'false'
    Usage: test [OPTION]… BOOL
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"failed to parse BOOL value \\\"not-a-bool\\\"\\n(Failure \\\"valid arguments: {false,true}\\\")\")"))
    |}];
  ()
;;

let save_file ~path ~contents =
  Out_channel.with_open_bin path (fun oc -> Out_channel.output_string oc contents)
;;

let%expect_test "file" =
  (* When using [Param.file] [cmdliner] requires a file of the given name to exist
     on disk. *)
  let t1 = test Command.Param.file Fn.id in
  Arg_test.eval_all t1 { prog = "test"; args = [ "foo.txt" ] };
  [%expect
    {|
    ----------------------------- Climate
    foo.txt
    ----------------------------- Cmdliner
    test: FILE argument: no 'foo.txt' file or directory
    Usage: test [OPTION]… FILE
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    foo.txt
    |}];
  save_file ~path:"foo.txt" ~contents:"Foo";
  Arg_test.eval_all t1 { prog = "test"; args = [ "foo.txt" ] };
  [%expect
    {|
    ----------------------------- Climate
    foo.txt
    ----------------------------- Cmdliner
    foo.txt
    ----------------------------- Core_command
    foo.txt
    |}]
;;

let%expect_test "assoc" =
  let module E = struct
    type t =
      | A
      | B
    [@@deriving enumerate, sexp_of]

    let to_string t = Sexp.to_string (sexp_of_t t)
  end
  in
  let t1 =
    test (Command.Param.assoc (List.map E.all ~f:(fun e -> E.to_string e, e))) E.to_string
  in
  Arg_test.eval_all t1 { prog = "test"; args = [ "A" ] };
  [%expect
    {|
    ----------------------------- Climate
    A
    ----------------------------- Cmdliner
    A
    ----------------------------- Core_command
    A
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "B" ] };
  [%expect
    {|
    ----------------------------- Climate
    B
    ----------------------------- Cmdliner
    B
    ----------------------------- Core_command
    B
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "Not_an_e" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E
      "Failed to parse the argument at position 0: invalid value: \"Not_an_e\" (valid values are: A, B)"))
    ----------------------------- Cmdliner
    test: invalid value 'Not_an_e', expected either 'A' or 'B'
    Usage: test [OPTION]… ARG
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"failed to parse VAL value \\\"Not_an_e\\\"\\n(Failure \\\"valid arguments: {A,B}\\\")\")"))
    |}];
  ()
;;

let%expect_test "enumerated" =
  let module E = struct
    type t =
      | A
      | B
    [@@deriving enumerate]

    let to_string = function
      | A -> "A"
      | B -> "B"
    ;;
  end
  in
  let t1 = test (Command.Param.enumerated (module E)) E.to_string in
  Arg_test.eval_all t1 { prog = "test"; args = [ "A" ] };
  [%expect
    {|
    ----------------------------- Climate
    A
    ----------------------------- Cmdliner
    A
    ----------------------------- Core_command
    A
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "B" ] };
  [%expect
    {|
    ----------------------------- Climate
    B
    ----------------------------- Cmdliner
    B
    ----------------------------- Core_command
    B
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "Not_an_e" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E
      "Failed to parse the argument at position 0: invalid value: \"Not_an_e\" (valid values are: A, B)"))
    ----------------------------- Cmdliner
    test: invalid value 'Not_an_e', expected either 'A' or 'B'
    Usage: test [OPTION]… ARG
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"failed to parse VAL value \\\"Not_an_e\\\"\\n(Failure \\\"valid arguments: {A,B}\\\")\")"))
    |}];
  ()
;;

let%expect_test "stringable" =
  let module Id : sig
    type t

    val of_string : string -> t
    val to_string : t -> string
  end = struct
    type t = string

    let to_string t = t
    let of_string t = t
  end
  in
  let t1 = test (Command.Param.stringable (module Id)) Id.to_string in
  Arg_test.eval_all t1 { prog = "test"; args = [ "my-id" ] };
  [%expect
    {|
    ----------------------------- Climate
    my-id
    ----------------------------- Cmdliner
    my-id
    ----------------------------- Core_command
    my-id
    |}];
  ()
;;

let%expect_test "validated_string" =
  let module Id = struct
    type t =
      | A
      | B
      | Id_length_8 of string

    let to_string = function
      | A -> "A"
      | B -> "B"
      | Id_length_8 id -> id
    ;;

    let of_string = function
      | "A" -> Ok A
      | "B" -> Ok B
      | str when String.length str = 8 -> Ok (Id_length_8 str)
      | _ -> Error (`Msg "invalid id")
    ;;
  end
  in
  let t1 = test (Command.Param.validated_string (module Id)) Id.to_string in
  Arg_test.eval_all t1 { prog = "test"; args = [ "A" ] };
  [%expect
    {|
    ----------------------------- Climate
    A
    ----------------------------- Cmdliner
    A
    ----------------------------- Core_command
    A
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "B" ] };
  [%expect
    {|
    ----------------------------- Climate
    B
    ----------------------------- Cmdliner
    B
    ----------------------------- Core_command
    B
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "Id_size8" ] };
  [%expect
    {|
    ----------------------------- Climate
    Id_size8
    ----------------------------- Cmdliner
    Id_size8
    ----------------------------- Core_command
    Id_size8
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "Id_of_size12" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E
      "Failed to parse the argument at position 0: invalid id"))
    ----------------------------- Cmdliner
    test: invalid id
    Usage: test [OPTION]… ARG
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"failed to parse VAL value \\\"Id_of_size12\\\"\\n(Msg \\\"invalid id\\\")\")"))
    |}];
  ()
;;

let%expect_test "comma_separated" =
  let module E = struct
    type t =
      | A
      | B
    [@@deriving enumerate]

    let to_string = function
      | A -> "A"
      | B -> "B"
    ;;
  end
  in
  let t1 =
    test
      (Command.Param.comma_separated (Command.Param.enumerated (module E)))
      (fun ts -> String.concat ~sep:"," (List.map ts ~f:E.to_string))
  in
  Arg_test.eval_all t1 { prog = "test"; args = [ "A" ] };
  [%expect
    {|
    ----------------------------- Climate
    A
    ----------------------------- Cmdliner
    A
    ----------------------------- Core_command
    A
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "B" ] };
  [%expect
    {|
    ----------------------------- Climate
    B
    ----------------------------- Cmdliner
    B
    ----------------------------- Core_command
    B
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "A,B" ] };
  [%expect
    {|
    ----------------------------- Climate
    A,B
    ----------------------------- Cmdliner
    A,B
    ----------------------------- Core_command
    A,B
    |}];
  (* At the moment the translation does not consistently determine whether the
     empty list is accepted. This is arguably a bug/limitation of the current
     implementation. *)
  Arg_test.eval_all t1 { prog = "test"; args = [ "" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E
      "Failed to parse the argument at position 0: invalid value: \"\" (valid values are: A, B)"))
    ----------------------------- Cmdliner

    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"failed to parse VAL value \\\"\\\"\\n(Failure \\\"Command.Spec.Arg_type.comma_separated: empty list not allowed\\\")\")"))
    |}];
  Arg_test.eval_all t1 { prog = "test"; args = [ "Not_an_e" ] };
  [%expect
    {|
    ----------------------------- Climate
    ("Evaluation Raised" (
      Climate.Parse_error.E
      "Failed to parse the argument at position 0: invalid value: \"Not_an_e\" (valid values are: A, B)"))
    ----------------------------- Cmdliner
    test: invalid element in list ('Not_an_e'): invalid value 'Not_an_e',
          expected either 'A' or 'B'
    Usage: test [OPTION]… ARG
    Try 'test --help' for more information.
    ("Evaluation Failed" ((exit_code 124)))
    ----------------------------- Core_command
    ("Evaluation Failed" (
      "Command.Failed_to_parse_command_line(\"failed to parse VAL value \\\"Not_an_e\\\"\\n(Failure \\\"valid arguments: {A,B}\\\")\")"))
    |}];
  ()
;;
