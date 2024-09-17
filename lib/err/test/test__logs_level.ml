let%expect_test "log levels" =
  Err.Private.reset_counts ();
  Err.For_test.wrap
  @@ fun () ->
  let test level =
    Err.For_test.protect (fun () ->
      Logs.set_level level;
      Err.error [ Pp.text "Hello Error1" ];
      Err.warning [ Pp.text "Hello Warning1" ];
      Err.info [ Pp.text "Hello Info1" ];
      Err.debug (lazy [ Pp.text "Hello Debug1" ]))
  in
  (* [Logs.set_level] on its own is not sufficient to impact the [Err] library.
     You must either set both levels consistently, or use
     [Err_cli.setup_config]. *)
  test (Some Warning);
  [%expect {|
    Error: Hello Error1

    Warning: Hello Warning1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  test (Some Info);
  [%expect {|
    Error: Hello Error1

    Warning: Hello Warning1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  test (Some Debug);
  [%expect {|
    Error: Hello Error1

    Warning: Hello Warning1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  (* In this section we set both levels consistently ourselves. *)
  Err.Private.set_logs_level
    ~get:(fun () ->
      match Logs.level () with
      | None | Some App -> Quiet
      | Some Error -> Error
      | Some Warning -> Warning
      | Some Info -> Info
      | Some Debug -> Debug)
    ~set:(fun level ->
      (Logs.set_level
         (match level with
          | Quiet -> None
          | Error -> Some Error
          | Warning -> Some Warning
          | Info -> Some Info
          | Debug -> Some Debug) [@coverage off]));
  test None;
  [%expect {||}];
  (* Note how disabling the errors causes [had_errors] to return [false]. *)
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| false |}];
  test (Some App);
  [%expect {| |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| false |}];
  test (Some Error);
  [%expect {|
    Error: Hello Error1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  test (Some Warning);
  [%expect {|
    Error: Hello Error1

    Warning: Hello Warning1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  test (Some Info);
  [%expect
    {|
    Error: Hello Error1

    Warning: Hello Warning1

    Info: Hello Info1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  test (Some Debug);
  [%expect
    {|
    Error: Hello Error1

    Warning: Hello Warning1

    Info: Hello Info1

    Debug: Hello Debug1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  (* In this section we go through [Err_cli]. *)
  let test level =
    Err.For_test.protect (fun () ->
      Err_cli.setup_config ~config:(Err_cli.Config.create ~logs_level:level ());
      Err.error [ Pp.text "Hello Error1" ];
      Err.warning [ Pp.text "Hello Warning1" ];
      Err.info [ Pp.text "Hello Info1" ];
      Err.debug (lazy [ Pp.text "Hello Debug1" ]))
  in
  test None;
  [%expect {||}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| false |}];
  test (Some App);
  [%expect {| |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| false |}];
  test (Some Error);
  [%expect {|
    Error: Hello Error1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  test (Some Warning);
  [%expect {|
    Error: Hello Error1

    Warning: Hello Warning1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  test (Some Info);
  [%expect
    {|
    Error: Hello Error1

    Warning: Hello Warning1

    Info: Hello Info1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  test (Some Debug);
  [%expect
    {|
    Error: Hello Error1

    Warning: Hello Warning1

    Info: Hello Info1

    Debug: Hello Debug1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| true |}];
  ()
;;

let%expect_test "error when quiet" =
  (* When the logs level is set to [quiet] errors are not shown, and not
     accounted for in the [error_count] and [had_errors]. *)
  Err.For_test.protect (fun () ->
    let set_logs_level logs_level =
      Err_cli.setup_config ~config:(Err_cli.Config.create ~logs_level ())
    in
    set_logs_level None;
    Err.error [ Pp.text "Hello Exn1" ]);
  [%expect {||}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| false |}];
  ()
;;

let%expect_test "raise when quiet" =
  (* When the logs level is set to [quiet], raising errors will be non impacted
     and behaves as usual. *)
  Err.For_test.protect (fun () ->
    let set_logs_level logs_level =
      Err_cli.setup_config ~config:(Err_cli.Config.create ~logs_level ())
    in
    set_logs_level None;
    Err.raise [ Pp.text "Hello Exn1" ]);
  [%expect {|
    Error: Hello Exn1
    [123]
    |}];
  print_s [%sexp (Err.had_errors () : bool)];
  [%expect {| false |}];
  ()
;;
