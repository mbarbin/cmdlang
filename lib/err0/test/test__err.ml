let%expect_test "return" =
  Err_handler.For_test.protect (fun () -> ());
  [%expect {||}];
  ()
;;

let%expect_test "return" =
  let am_running_test () =
    print_s [%sexp (Err_handler.For_test.am_running_test () : bool)]
  in
  am_running_test ();
  [%expect {| false |}];
  Err_handler.For_test.wrap (fun () ->
    am_running_test ();
    [%expect {| true |}]);
  Err_handler.For_test.protect (fun () ->
    am_running_test ();
    [%expect {| true |}]);
  ()
;;

let%expect_test "raise" =
  Err_handler.For_test.protect (fun () ->
    Err.raise
      ~loc:(Loc.in_file ~path:(Fpath.v "path/to/my-file.txt"))
      ~hints:(Err.did_you_mean "bah" ~candidates:[ "bar"; "foo" ])
      [ Pp.text "Hello Raise" ]);
  [%expect
    {|
    File "path/to/my-file.txt", line 1, characters 0-0:
    Error: Hello Raise
    Hint: did you mean bar?
    [123]
    |}];
  ()
;;

let%expect_test "exit" =
  Err_handler.For_test.protect (fun () -> Err.exit Some_error);
  [%expect {| [123] |}];
  ()
;;

let%expect_test "reraise" =
  Err_handler.For_test.protect (fun () ->
    match
      Err.raise
        ~loc:(Loc.in_file ~path:(Fpath.v "path/to/my-file.txt"))
        ~hints:(Err.did_you_mean "bah" ~candidates:[ "bar"; "foo" ])
        [ Pp.text "Hello Raise" ]
    with
    | _ -> assert false
    | exception Err.E e ->
      let bt = Stdlib.Printexc.get_raw_backtrace () in
      Err.reraise
        bt
        e
        ~loc:(Loc.in_file ~path:(Fpath.v "path/to/other-file.txt"))
        ~exit_code:Internal_error
        [ Pp.text "Re raised with context"; Pp.verbatim "x" ]);
  [%expect
    {|
    File "path/to/my-file.txt", line 1, characters 0-0:
    Error: Hello Raise
    Hint: did you mean bar?

    File "path/to/other-file.txt", line 1, characters 0-0:
    Error: Re raised with context
    x

    Backtrace: <backtrace disabled in tests>
    [125]
    |}];
  ()
;;

let%expect_test "make" =
  let err =
    Err.make
      ~loc:(Loc.in_file ~path:(Fpath.v "path/to/my-file.txt"))
      ~hints:(Err.did_you_mean "bah" ~candidates:[ "bar"; "foo" ])
      [ Pp.text "Hello Make" ]
  in
  Err_handler.For_test.protect (fun () -> Err_handler.prerr err);
  [%expect
    {|
    File "path/to/my-file.txt", line 1, characters 0-0:
    Error: Hello Make
    Hint: did you mean bar?
    |}];
  Err_handler.For_test.protect (fun () -> Err.ok_exn (Ok ()));
  [%expect {||}];
  Err_handler.For_test.protect (fun () -> Err.ok_exn (Error err));
  [%expect
    {|
    File "path/to/my-file.txt", line 1, characters 0-0:
    Error: Hello Make
    Hint: did you mean bar?
    [123]
    |}];
  ()
;;

let%expect_test "of_stdune_message" =
  let err =
    Stdune.User_message.make
      ~loc:(Loc.in_file ~path:(Fpath.v "path/to/other-file.txt"))
      ~hints:(Err.did_you_mean "bah" ~candidates:[ "bar"; "foo" ])
      [ Pp.text "Hello Stdune" ]
    |> Err.of_stdune_user_message ~exit_code:Ok
  in
  Err_handler.For_test.protect (fun () -> Err_handler.prerr err);
  [%expect
    {|
    File "path/to/other-file.txt", line 1, characters 0-0:
    Hello Stdune
    Hint: did you mean bar?
    |}];
  ()
;;

let create_state ~config =
  let state = Err.State.create () in
  Err.State.set_config state config;
  state
;;

let%expect_test "config" =
  let config = Err.Config.create ~mode:Default ~warn_error:false () in
  print_s [%sexp (Err_handler.Config.to_args config : string list)];
  [%expect {| () |}];
  let config = Err.Config.create ~mode:Verbose ~warn_error:true () in
  print_s [%sexp (Err_handler.Config.to_args config : string list)];
  [%expect {| (--verbose --warn-error) |}];
  let config = Err.Config.create ~mode:Debug ~warn_error:true () in
  print_s [%sexp (Err_handler.Config.to_args config : string list)];
  [%expect {| (--debug --warn-error) |}];
  ()
;;

let%expect_test "state getters" =
  let state =
    create_state ~config:(Err.Config.create ~mode:Default ~warn_error:false ())
  in
  print_s [%sexp (Err.State.mode state : Err.Config.Mode.t)];
  [%expect {| Default |}];
  print_s [%sexp (Err.State.is_debug_mode state : bool)];
  [%expect {| false |}];
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  let state =
    create_state ~config:(Err.Config.create ~mode:Verbose ~warn_error:true ())
  in
  print_s [%sexp (Err.State.mode state : Err.Config.Mode.t)];
  [%expect {| Verbose |}];
  print_s [%sexp (Err.State.is_debug_mode state : bool)];
  [%expect {| false |}];
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  let state = create_state ~config:(Err.Config.create ~mode:Debug ~warn_error:true ()) in
  print_s [%sexp (Err.State.mode state : Err.Config.Mode.t)];
  [%expect {| Debug |}];
  print_s [%sexp (Err.State.is_debug_mode state : bool)];
  [%expect {| true |}];
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  ()
;;

let%expect_test "multiple errors" =
  Err_handler.For_test.wrap
  @@ fun () ->
  Err.error ~loc:(Loc.in_file ~path:(Fpath.v "my/file1")) [ Pp.text "Hello Error1" ];
  Err.error ~loc:(Loc.in_file ~path:(Fpath.v "my/file2")) [ Pp.text "Hello Error1" ];
  [%expect
    {|
    File "my/file1", line 1, characters 0-0:
    Error: Hello Error1

    File "my/file2", line 1, characters 0-0:
    Error: Hello Error1
    |}];
  ()
;;

let%expect_test "error" =
  Err_handler.For_test.wrap
  @@ fun () ->
  let state =
    create_state ~config:(Err.Config.create ~mode:Default ~warn_error:false ())
  in
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  Err.error ~state [ Pp.text "Hello Error1" ];
  [%expect {| Error: Hello Error1 |}];
  Err.error ~state [ Pp.text "Hello Error2" ];
  [%expect {| Error: Hello Error2 |}];
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| true |}];
  Err.State.reset state;
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  ()
;;

let%expect_test "error handler" =
  Err_handler.For_test.protect (fun () -> Err.error [ Pp.text "Hello Error1" ]);
  [%expect {|
    Error: Hello Error1
    [123]
    |}];
  ()
;;

let%expect_test "warning" =
  Err_handler.For_test.wrap
  @@ fun () ->
  let state =
    create_state ~config:(Err.Config.create ~mode:Default ~warn_error:false ())
  in
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  Err.warning ~state [ Pp.text "Hello Warning1" ];
  [%expect {| Warning: Hello Warning1 |}];
  Err.warning ~state [ Pp.text "Hello Warning2" ];
  [%expect {| Warning: Hello Warning2 |}];
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  Err.State.reset state;
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  let state =
    create_state ~config:(Err.Config.create ~mode:Default ~warn_error:true ())
  in
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  Err.warning ~state [ Pp.text "Hello Warning1" ];
  [%expect {| Warning: Hello Warning1 |}];
  Err.warning ~state [ Pp.text "Hello Warning2" ];
  [%expect {| Warning: Hello Warning2 |}];
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| true |}];
  Err.State.reset state;
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  ()
;;

let%expect_test "warning handler" =
  Err_handler.For_test.protect (fun () -> Err.warning [ Pp.text "Hello Warning1" ]);
  [%expect {| Warning: Hello Warning1 |}];
  let state =
    create_state ~config:(Err.Config.create ~mode:Default ~warn_error:true ())
  in
  Err_handler.For_test.protect ~state (fun () ->
    Err.warning ~state [ Pp.text "Hello Warning1" ]);
  [%expect {|
    Warning: Hello Warning1
    [123]
    |}];
  ()
;;

let%expect_test "info & debug" =
  let test state =
    Err_handler.For_test.protect ~state (fun () ->
      Err.info ~state [ Pp.text "Hello Info1" ];
      Err.debug ~state [ Pp.text "Hello Debug1" ])
  in
  let state = create_state ~config:(Err.Config.create ~mode:Default ()) in
  test state;
  [%expect {||}];
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  let state = create_state ~config:(Err.Config.create ~mode:Verbose ()) in
  test state;
  [%expect {| Info: Hello Info1 |}];
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  let state = create_state ~config:(Err.Config.create ~mode:Debug ()) in
  test state;
  [%expect {|
    Info: Hello Info1

    Debug: Hello Debug1
    |}];
  print_s [%sexp (Err.State.had_errors state : bool)];
  [%expect {| false |}];
  ()
;;

let%expect_test "exn_handler" =
  Err_handler.For_test.protect (fun () -> failwith "Hello Exn");
  [%expect
    {|
    Internal Error: Failure("Hello Exn") <backtrace disabled in tests>
    [125]
    |}];
  let exn_handler = function
    | Failure msg -> Some (Err.make [ Pp.text msg ])
    | _ -> None
  in
  Err_handler.For_test.protect ~exn_handler (fun () -> failwith "Hello Exn");
  [%expect {|
    Error: Hello Exn
    [123]
    |}];
  Err_handler.For_test.protect ~exn_handler (fun () -> invalid_arg "Hello Exn");
  [%expect
    {|
    Internal Error: Invalid_argument("Hello Exn") <backtrace disabled in tests>
    [125]
    |}];
  ()
;;

let%expect_test "non-test handler" =
  Err_handler.For_test.wrap
  @@ fun () ->
  let result =
    Err_handler.protect
      (fun () -> failwith "Hello Exn")
      ~exn_handler:(function
        | Failure msg -> Some (Err.make [ Pp.text msg ])
        | _ -> None [@coverage off])
  in
  [%expect {| Error: Hello Exn |}];
  print_s [%sexp (result : (unit, int) Result.t)];
  [%expect {| (Error 123) |}];
  ()
;;

let%expect_test "raise_s" =
  Err_handler.For_test.protect (fun () ->
    Err.raise_s
      ~loc:(Loc.in_file ~path:(Fpath.v "path/to/my-file.txt"))
      ~hints:(Err.did_you_mean "bah" ~candidates:[ "bar"; "foo" ])
      "Hello Raise"
      [%sexp { hello = 42 }]);
  [%expect
    {|
    File "path/to/my-file.txt", line 1, characters 0-0:
    Error: Hello Raise
    (hello 42)
    Hint: did you mean bar?
    [123]
    |}];
  ()
;;

let%expect_test "reraise" =
  Err_handler.For_test.protect (fun () ->
    match
      Err.raise_s
        ~loc:(Loc.in_file ~path:(Fpath.v "path/to/my-file.txt"))
        ~hints:(Err.did_you_mean "bah" ~candidates:[ "bar"; "foo" ])
        "Hello Raise"
        [%sexp { hello = 42 }]
    with
    | _ -> assert false
    | exception Err.E e ->
      let bt = Stdlib.Printexc.get_raw_backtrace () in
      Err.reraise_s
        bt
        e
        ~loc:(Loc.in_file ~path:(Fpath.v "path/to/other-file.txt"))
        "Re raised with context"
        [%sexp { x = 42 }]);
  [%expect
    {|
    File "path/to/my-file.txt", line 1, characters 0-0:
    Error: Hello Raise
    (hello 42)
    Hint: did you mean bar?

    File "path/to/other-file.txt", line 1, characters 0-0:
    Error: Re raised with context
    (x 42)
    [123]
    |}];
  ()
;;

let%expect_test "raise without handler" =
  require_does_raise [%here] (fun () -> Err.raise [ Pp.text "Hello" ]);
  [%expect {| ("(Err.E Hello (Exit 123))") |}];
  ()
;;
