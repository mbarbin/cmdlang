let () =
  let code =
    Cmdliner.Cmd.eval
      (Cmdlang_to_cmdliner.Translate.command
         Getting_started.cmd
         ~name:"my-calculator"
         ~version:"%%VERSION%%")
  in
  (* We disable coverage here because [bisect_ppx] instruments the out-edge of
     calls to [exit], which never returns. This creates false negatives in test
     coverage. We may revisit this decision in the future if the context
     changes. *)
  (exit code [@coverage off])
;;
