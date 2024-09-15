let%expect_test "Param.assoc" =
  let open Command.Std in
  require_does_raise [%here] (fun () -> Param.assoc []);
  [%expect {| (Invalid_argument Command.Param.assoc) |}];
  ()
;;
