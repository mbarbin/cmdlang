let%expect_test "pp_of_sexp" =
  let test sexp = Err.For_test.handler (fun () -> Err.raise [ Err.pp_of_sexp sexp ]) in
  test [%sexp ()];
  [%expect {|
    Error: ()
    [123]
    |}];
  test [%sexp "Hello"];
  [%expect {|
    Error: Hello
    [123]
    |}];
  test [%sexp "Hello error", { x = 42 }];
  [%expect {|
    Error: Hello error (x 42)
    [123]
    |}];
  test [%sexp { x = 42 }];
  [%expect {|
    Error: (x 42)
    [123]
    |}];
  test [%sexp { x = 42; y = "why" }];
  [%expect {|
    Error: ((x 42) (y why))
    [123]
    |}];
  test [%sexp "Hello error", { x = 42 }];
  [%expect {|
    Error: Hello error (x 42)
    [123]
    |}];
  test [%sexp "Hello error", { x = 42; y = "why" }];
  [%expect {|
    Error: Hello error ((x 42) (y why))
    [123]
    |}];
  ()
;;
