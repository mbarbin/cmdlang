let%expect_test "Param.enum" =
  let open Command.Std in
  require_does_raise [%here] (fun () ->
    let+ _ = Arg.named [ "a" ] (Param.assoc []) ~doc:"empty enum" in
    (() [@coverage off]));
  [%expect {| (Invalid_argument Command.Arg.enum) |}];
  ()
;;
