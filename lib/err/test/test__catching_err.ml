(* In this test we characterize the behavior of [Err] when we are interested in
   catching errors from the user land of an upstream library that produces
   errors with [Err]. *)

module Lib = struct
  (* Favored designs : raising or returning errors. *)

  let raise () = Err.raise [ Pp.text "Hello from raising library" ]

  let return_error () =
    Result.Error (Err.create [ Pp.text "Hello from error returning library" ])
  ;;

  (* Discouraged design : emitting errors directly. *)

  let emit_error () = Err.error [ Pp.text "Hello from error emitting library" ]
end

let had_errors () =
  Err.For_test.wrap
  @@ fun () -> print_s [%sexp { had_errors = (Err.had_errors () : bool) }]
;;

(* When you catch [Err]'s then the exit code of the program is not affected -
   everything behaves as if no error had occurred. That makes sense, since no
   errors were shown to the user. *)
let%expect_test "catch" =
  Err.Private.reset_counts ();
  require_does_raise [%here] (fun () -> Lib.raise ());
  [%expect {| ("Hello from raising library" (Exit 123)) |}];
  had_errors ();
  [%expect {| ((had_errors false)) |}];
  Err.For_test.protect (fun () ->
    match Lib.raise () with
    | () -> assert false
    | exception Err.E _ -> print_endline "Caught a lib error, all is well, moving on");
  [%expect {| Caught a lib error, all is well, moving on |}];
  had_errors ();
  [%expect {| ((had_errors false)) |}];
  (* This also allows you to raise the error if you'd like, and for it to be
     caught by the handler as expected, taking care of the rendering, exit code,
     etc. *)
  Err.For_test.protect (fun () ->
    match Lib.raise () with
    | () -> assert false
    | exception Err.E e ->
      let bt = Stdlib.Printexc.get_raw_backtrace () in
      Stdlib.Printexc.raise_with_backtrace (Err.E e) bt);
  ();
  [%expect {|
    Error: Hello from raising library
    [123]
    |}]
;;

(* When you executed code that emitted errors, the exit code of the program *is*
   affected. What's different from the previous use case, is that this time an
   error was actually printed and shown to the user. It would be surprising to
   print error messages, and then exit 0 as if nothing happened. *)
let%expect_test "emit" =
  Err.Private.reset_counts ();
  had_errors ();
  [%expect {| ((had_errors false)) |}];
  Err.For_test.protect (fun () ->
    Lib.emit_error ();
    Stdlib.prerr_endline "Lib didn't raise but emitted some errors.";
    Stdlib.prerr_endline "I with to move on but there are errors on the user screen now.");
  [%expect
    {|
    Error: Hello from error emitting library
    Lib didn't raise but emitted some errors.
    I with to move on but there are errors on the user screen now.
    [123]
    |}];
  had_errors ();
  [%expect {| ((had_errors true)) |}];
  ()
;;

(* Let's go back to the previous use case. There's something unsatisfying about
   a library call returning [unit] and still affecting your end exit code. In
   fact, even if you could resume normal operation, in some ways the fact that
   the library printed on [stderr] is perhaps some design characteristic you'd
   like to avoid.

   Here we suggest an alternative design where the library return errors instead
   of printing them, giving back the control to the user. *)
let%expect_test "match" =
  Err.Private.reset_counts ();
  had_errors ();
  [%expect {| ((had_errors false)) |}];
  Err.For_test.protect (fun () ->
    match Lib.return_error () with
    | Ok () -> assert false
    | Error _ -> print_endline "Matched on a lib error, all is well, moving on");
  [%expect {| Matched on a lib error, all is well, moving on |}];
  had_errors ();
  [%expect {| ((had_errors false)) |}];
  (* This also allows you to raise the error if you'd like, and for it to be
     caught by the handler as expected, taking care of the rendering, exit code,
     etc. *)
  Err.For_test.protect (fun () ->
    match Lib.return_error () with
    | Ok () -> assert false
    | Error e ->
      let bt = Stdlib.Printexc.get_raw_backtrace () in
      Stdlib.Printexc.raise_with_backtrace (Err.E e) bt);
  [%expect {|
    Error: Hello from error returning library
    [123]
    |}];
  ()
;;
