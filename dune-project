(lang dune 3.16)

(name cmdlang)

(generate_opam_files)

(license MIT)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin <opensource@mbarbin.org>")

(source
 (github mbarbin/cmdlang))

(documentation "https://mbarbin.github.io/cmdlang/")

(using mdx 0.4)

(package
 (name cmdlang)
 (synopsis "Declarative Command-line Parsing for OCaml")
 (depends
  (ocaml
   (>= 5.2))))

(package
 (name err)
 (synopsis "Error Handling Standard Based on Human Readable Messages")
 (depends
  (ocaml
   (>= 5.2))
  (loc
   (>= 0.2.0))
  (sexplib0
   (and
    (>= v0.17)
    (< v0.18)))
  (stdune
   (>= 3.16))))

(package
 (name err-cli)
 (synopsis
  "Command line interface configuration for [Err] based on [Cmdlang]")
 (depends
  (ocaml
   (>= 5.2))
  (cmdlang
   (= :version))
  (err
   (= :version))
  (fmt
   (>= 0.9.0))
  (loc
   (>= 0.2.0))
  (logs
   (>= 0.7.0))
  (sexplib0
   (and
    (>= v0.17)
    (< v0.18)))
  (stdune
   (>= 3.16))))

(package
 (name cmdlang-to-base)
 (synopsis "Convert cmdlang Parsers to core.command")
 (depends
  (ocaml
   (>= 5.2))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (cmdlang
   (= :version))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_compare
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_enumerate
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_expect
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_hash
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_here
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_let
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (stdio
   (and
    (>= v0.17)
    (< v0.18)))))

(package
 (name cmdlang-to-cmdliner)
 (synopsis "Convert cmdlang Parsers to cmdliner")
 (depends
  (ocaml
   (>= 5.2))
  (cmdlang
   (= :version))
  (cmdliner
   (= 1.3.0))))

(package
 (name cmdlang-to-climate)
 (synopsis "Convert cmdlang Parsers to climate")
 (depends
  (ocaml
   (>= 5.2))
  (climate
   (>= 0.1.0~preview-0.1))
  (cmdlang
   (= :version))))

(package
 (name cmdlang-cmdliner-runner)
 (synopsis "A cmdlang runner using cmdliner and err")
 (depends
  (ocaml
   (>= 5.2))
  (cmdlang
   (= :version))
  (cmdlang-to-cmdliner
   (= :version))
  (cmdliner
   (= 1.3.0))
  (err
   (= :version))))

(package
 (name cmdlang-tests)
 (synopsis "Tests for cmdlang")
 (depends
  (ocaml
   (>= 5.2))
  (ocamlformat
   (and
    :with-dev-setup
    (= 0.26.2)))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (bisect_ppx
   (and
    :with-dev-setup
    (>= 2.8.3)))
  (climate
   (>= 0.1.0~preview-0.1))
  (cmdlang
   (= :version))
  (cmdlang-cmdliner-runner
   (= :version))
  (cmdlang-to-base
   (= :version))
  (cmdlang-to-climate
   (= :version))
  (cmdlang-to-cmdliner
   (= :version))
  (cmdliner
   (= 1.3.0))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (core_unix
   (and
    (>= v0.17)
    (< v0.18)))
  (err
   (= :version))
  (err-cli
   (= :version))
  (expect_test_helpers_core
   (and
    (>= v0.17)
    (< v0.18)))
  (loc
   (>= 0.2.0))
  (mdx
   (>= 2.4))
  (ppx_compare
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_enumerate
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_expect
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_hash
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_here
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_js_style
   (and
    :with-dev-setup
    (>= v0.17)
    (< v0.18)))
  (ppx_let
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_conv
   (and
    (>= v0.17)
    (< v0.18)))
  (ppx_sexp_value
   (and
    (>= v0.17)
    (< v0.18)))
  (ppxlib
   (>= 0.33))
  (stdio
   (and
    (>= v0.17)
    (< v0.18)))
  (stdune
   (>= 3.16))
  (sherlodoc
   (and
    :with-doc
    (>= 0.2)))))
