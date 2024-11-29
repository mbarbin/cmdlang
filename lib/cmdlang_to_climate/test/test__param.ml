module Command = Cmdlang.Command

let%expect_test "param" =
  let conv (type a) param sexp_of_a params =
    let conv = Cmdlang_to_climate.Translate.param param in
    List.iter params ~f:(fun str ->
      print_s [%sexp (str : string), (conv.parse str : (a, [ `Msg of string ]) Result.t)])
  in
  conv Command.Param.int [%sexp_of: int] [ ""; "a"; "0"; "42"; "-17" ];
  [%expect
    {|
    ("" (Error (Msg "invalid value: \"\" (not an int)")))
    (a (Error (Msg "invalid value: \"a\" (not an int)")))
    (0 (Ok 0))
    (42 (Ok 42))
    (-17 (Ok -17))
    |}];
  ()
;;

module Color = struct
  type t =
    | Red
    | Green
    | Blue

  let all = [ Red; Green; Blue ]

  let to_string = function
    | Red -> "red"
    | Green -> "green"
    | Blue -> "blue"
  ;;
end

let%expect_test "enumerated" =
  let conv =
    Cmdlang_to_climate.Translate.param (Command.Param.enumerated (module Color))
  in
  List.iter Color.all ~f:(fun color -> Stdlib.Format.printf "%a\n" conv.print color);
  [%expect {|
    red
    green
    blue
    |}];
  (* Here we characterize what happens when [all] doesn't include all
     inhabitants of the enumerated [t]. *)
  let module Missing_color = struct
    include Color

    let all = [ Red; Green ]
  end
  in
  let conv =
    Cmdlang_to_climate.Translate.param (Command.Param.enumerated (module Missing_color))
  in
  List.iter Missing_color.all ~f:(fun color ->
    Stdlib.Format.printf "%a\n" conv.print color);
  [%expect {|
    red
    green
    |}];
  (match Stdlib.Format.printf "%a\n" conv.print Blue with
   | () -> assert false
   | exception Climate.Spec_error.E e -> print_endline (Climate.Spec_error.to_string e));
  [%expect
    {| Attempted to format an enum value as a string but the value does not appear in the enum declaration. Valid names for this enum are: red green |}];
  ()
;;
