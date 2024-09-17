module Config = struct
  let logs_level_arg =
    let open Command.Std in
    let+ verbose_count =
      Arg.flag_count
        [ "verbose"; "v" ]
        ~doc:"Increase verbosity. Repeatable, but more than twice does not bring more"
    and+ verbosity =
      Arg.named_opt
        [ "verbosity" ]
        (Param.assoc
           [ "quiet", None
           ; "app", Some Logs.App
           ; "error", Some Logs.Error
           ; "warning", Some Logs.Warning
           ; "info", Some Logs.Info
           ; "debug", Some Logs.Debug
           ])
        ~docv:"LEVEL"
        ~doc:"Be more or less verbose. Takes over $(b,v)."
    and+ quiet =
      Arg.flag [ "quiet"; "q" ] ~doc:"Be quiet. Takes over $(b,v) and $(b,--verbosity)"
    in
    if quiet
    then None
    else (
      match verbosity with
      | Some verbosity -> verbosity
      | None ->
        (match verbose_count with
         | 0 -> Some Logs.Warning
         | 1 -> Some Logs.Info
         | _ -> Some Logs.Debug))
  ;;

  let fmt_style_renderer_arg =
    let open Command.Std in
    Arg.named_with_default
      [ "color" ]
      (Param.assoc [ "auto", None; "always", Some `Ansi_tty; "never", Some `None ])
      ~default:None
      ~docv:"WHEN"
      ~doc:"Colorize the output"
  ;;

  type t =
    { logs_level : Logs.level option
    ; fmt_style_renderer : Fmt.style_renderer option
    ; warn_error : bool
    }

  let default =
    { logs_level = Some Logs.Warning; fmt_style_renderer = None; warn_error = false }
  ;;

  let create
    ?(logs_level = default.logs_level)
    ?(fmt_style_renderer = default.fmt_style_renderer)
    ?(warn_error = default.warn_error)
    ()
    =
    { logs_level; fmt_style_renderer; warn_error }
  ;;

  let logs_level t = t.logs_level
  let fmt_style_renderer t = t.fmt_style_renderer
  let warn_error t = t.warn_error

  let arg =
    let open Command.Std in
    let+ warn_error = Arg.flag [ "warn-error" ] ~doc:"treat warnings as errors"
    and+ logs_level = logs_level_arg
    and+ fmt_style_renderer = fmt_style_renderer_arg in
    { logs_level; fmt_style_renderer; warn_error }
  ;;

  let to_args { logs_level; fmt_style_renderer; warn_error } =
    List.concat
      [ (match logs_level with
         | None -> [ "--quiet" ]
         | Some level ->
           (match level with
            | App -> [ "--verbosity"; "app" ]
            | Error -> [ "--verbosity"; "error" ]
            | Warning -> []
            | Info -> [ "--verbosity"; "info" ]
            | Debug -> [ "--verbosity"; "debug" ]))
      ; (match fmt_style_renderer with
         | None -> []
         | Some `Ansi_tty -> [ "--color"; "always" ]
         | Some `None -> [ "--color"; "never" ])
      ; (if warn_error then [ "--warn-error" ] else [])
      ]
  ;;
end

let setup_log ~(config : Config.t) =
  Fmt_tty.setup_std_outputs ?style_renderer:config.fmt_style_renderer ();
  let () =
    Err.Private.style_renderer
    := match config.fmt_style_renderer with
       | Some `None -> `None
       | None | Some `Ansi_tty -> `Auto
  in
  Logs.set_level config.logs_level;
  let () =
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
            | Debug -> Some Debug) [@coverage off]))
  in
  Logs.set_reporter (Logs_fmt.reporter ())
;;

let setup_config ~config =
  setup_log ~config;
  Err.Private.warn_error := config.warn_error;
  Err.Private.set_logs_counts ~err_count:Logs.err_count ~warn_count:Logs.warn_count;
  ()
;;

let set_config () =
  let open Command.Std in
  let+ config = Config.arg in
  setup_config ~config
;;
