module Logs_level = struct
  type t = Logs.level =
    | App
    | Error
    | Warning
    | Info
    | Debug
  [@@deriving equal, sexp_of]
end

module Fmt_style_renderer = struct
  type t =
    [ `Ansi_tty
    | `None
    ]
  [@@deriving equal, sexp_of]
end

module Config_with_sexp = struct
  module Internal = struct
    type t =
      { logs_level : Logs_level.t option
      ; fmt_style_renderer : Fmt_style_renderer.t option
      ; warn_error : bool
      }
    [@@deriving equal, sexp_of]
  end

  type t = Err_cli.Config.t

  let to_internal t =
    { Internal.logs_level = Err_cli.Config.logs_level t
    ; fmt_style_renderer = Err_cli.Config.fmt_style_renderer t
    ; warn_error = Err_cli.Config.warn_error t
    }
  ;;

  let equal t1 t2 = Internal.equal (to_internal t1) (to_internal t2)
  let sexp_of_t (t : t) = [%sexp (to_internal t : Internal.t)]
end

let roundtrip_test original_config =
  let args = Err_cli.Config.to_args original_config in
  let term =
    let open Cmdliner.Term.Syntax in
    let+ config =
      Cmdlang_to_cmdliner.Translate.Private.Arg.project
        (Cmdlang.Command.Private.To_ast.arg Err_cli.Config.arg)
    in
    Err_cli.setup_config ~config;
    if Config_with_sexp.equal original_config config
    then print_s [%sexp { args : string list; config : Config_with_sexp.t }]
    else
      print_s
        [%sexp
          "Roundtrip Failed"
          , { args : string list
            ; original_config : Config_with_sexp.t
            ; config : Config_with_sexp.t
            }] [@coverage off]
  in
  let cmd = Cmdliner.Cmd.v (Cmdliner.Cmd.info "err_cli") term in
  match Cmdliner.Cmd.eval cmd ~argv:(Array.of_list ("err_cli" :: args)) with
  | 0 -> ()
  | exit_code -> print_s [%sexp "Evaluation Failed", { exit_code : int }] [@coverage off]
  | exception e -> print_s [%sexp "Evaluation Raised", (e : Exn.t)] [@coverage off]
;;

let%expect_test "roundtrip" =
  roundtrip_test (Err_cli.Config.create ());
  [%expect
    {|
    ((args ())
     (config ((logs_level (Warning)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  roundtrip_test (Err_cli.Config.create ~logs_level:None ());
  [%expect
    {|
    ((args (--quiet))
     (config (
       (logs_level         ())
       (fmt_style_renderer ())
       (warn_error false))))
    |}];
  roundtrip_test (Err_cli.Config.create ~logs_level:(Some App) ());
  [%expect
    {|
    ((args (--verbosity app))
     (config ((logs_level (App)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  roundtrip_test (Err_cli.Config.create ~logs_level:(Some Error) ());
  [%expect
    {|
    ((args (--verbosity error))
     (config ((logs_level (Error)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  roundtrip_test (Err_cli.Config.create ~logs_level:(Some Warning) ());
  [%expect
    {|
    ((args ())
     (config ((logs_level (Warning)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  roundtrip_test (Err_cli.Config.create ~logs_level:(Some Info) ());
  [%expect
    {|
    ((args (--verbosity info))
     (config ((logs_level (Info)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  roundtrip_test (Err_cli.Config.create ~logs_level:(Some Debug) ());
  [%expect
    {|
    ((args (--verbosity debug))
     (config ((logs_level (Debug)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  roundtrip_test (Err_cli.Config.create ~fmt_style_renderer:None ());
  [%expect
    {|
    ((args ())
     (config ((logs_level (Warning)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  roundtrip_test (Err_cli.Config.create ~fmt_style_renderer:(Some `Ansi_tty) ());
  [%expect
    {|
    ((args (--color always))
     (config (
       (logs_level         (Warning))
       (fmt_style_renderer (Ansi_tty))
       (warn_error false))))
    |}];
  roundtrip_test (Err_cli.Config.create ~fmt_style_renderer:(Some `None) ());
  [%expect
    {|
    ((args (--color never))
     (config (
       (logs_level         (Warning))
       (fmt_style_renderer (None))
       (warn_error false))))
    |}];
  roundtrip_test (Err_cli.Config.create ~warn_error:true ());
  [%expect
    {|
    ((args (--warn-error))
     (config ((logs_level (Warning)) (fmt_style_renderer ()) (warn_error true))))
    |}];
  ()
;;

(* In addition to testing roundtrip, we also check the parsing of certain
   arguments that do not necessarily roundtrip (such as when there's another
   ways of expressing a certain onfig). *)
let parse args =
  let term =
    let open Cmdliner.Term.Syntax in
    let+ config =
      Cmdlang_to_cmdliner.Translate.Private.Arg.project
        (Cmdlang.Command.Private.To_ast.arg Err_cli.Config.arg)
    in
    Err_cli.setup_config ~config;
    print_s [%sexp { args : string list; config : Config_with_sexp.t }]
  in
  let cmd = Cmdliner.Cmd.v (Cmdliner.Cmd.info "err_cli") term in
  match Cmdliner.Cmd.eval cmd ~argv:(Array.of_list ("err_cli" :: args)) with
  | 0 -> ()
  | exit_code -> print_s [%sexp "Evaluation Failed", { exit_code : int }] [@coverage off]
  | exception e -> print_s [%sexp "Evaluation Raised", (e : Exn.t)] [@coverage off]
;;

let%expect_test "parse verbose count" =
  parse [];
  [%expect
    {|
    ((args ())
     (config ((logs_level (Warning)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  parse [ "-v" ];
  [%expect
    {|
    ((args (-v))
     (config ((logs_level (Info)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  parse [ "-v"; "-v" ];
  [%expect
    {|
    ((args (-v -v))
     (config ((logs_level (Debug)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  parse [ "-v"; "-v"; "-v" ];
  [%expect
    {|
    ((args (-v -v -v))
     (config ((logs_level (Debug)) (fmt_style_renderer ()) (warn_error false))))
    |}];
  ()
;;
