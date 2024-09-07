module Translate = Translate

let run ?exn_handler cmd ~name ~version =
  match
    Err.protect ?exn_handler (fun () ->
      Cmdliner.Cmd.eval ~catch:false (Translate.command cmd ~name ~version))
  with
  | Ok code | Error code ->
    (* We allow the function to terminate normally when [code=0]. This is
       because [bisect_ppx] instruments the out-edge of calls to [run] in
       executables. If we never return, it would create false negatives in test
       coverage. We may revisit this decision in the future if the context
       changes. *)
    if code <> 0 then exit code
;;
