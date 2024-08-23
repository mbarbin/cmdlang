(lang dune 3.16)

(name commandlang)

(generate_opam_files)

(license MIT)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin")

(source
 (github mbarbin/commandlang))

(documentation "https://mbarbin.github.io/commandlang/")

(using mdx 0.4)

(package
 (name commandlang)
 (synopsis "Declarative Command-line Parsing for OCaml")
 (depends
  (ocaml
   (>= 5.2))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (ppx_js_style
   (and
    :dev
    (>= v0.17)
    (< v0.18)))))

(package
 (name err0)
 (synopsis "Error Handling Standard Based on Human Readable Messages")
 (depends
  (ocaml
   (>= 5.2))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (ppx_js_style
   (and
    :dev
    (>= v0.17)
    (< v0.18)))
  (sexplib0
   (and
    (>= v0.17)
    (< v0.18)))
  (stdune
   (>= 3.16))))

(package
 (name err0-handler)
 (synopsis "A handler for Err0 that works well with commandlang")
 (depends
  (ocaml
   (>= 5.2))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (commandlang
   (= :version))
  (err0
   (= :version))
  (ppx_js_style
   (and
    :dev
    (>= v0.17)
    (< v0.18)))
  (sexplib0
   (and
    (>= v0.17)
    (< v0.18)))
  (stdune
   (>= 3.16))))

(package
 (name commandlang-to-base)
 (synopsis "Convert commandlang Parsers to core.command")
 (depends
  (ocaml
   (>= 5.2))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (commandlang
   (= :version))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (err0
   (= :version))
  (err0-handler
   (= :version))
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
    :dev
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
 (name commandlang-to-cmdliner)
 (synopsis "Convert commandlang Parsers to cmdliner")
 (depends
  (ocaml
   (>= 5.2))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (cmdliner
   (= 1.3.0))
  (commandlang
   (= :version))
  (err0
   (= :version))
  (err0-handler
   (= :version))
  (ppx_js_style
   (and
    :dev
    (>= v0.17)
    (< v0.18)))))

(package
 (name commandlang-to-climate)
 (synopsis "Convert commandlang Parsers to climate")
 (depends
  (ocaml
   (>= 5.2))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (climate
   (= 0.0.1~preview-0.1))
  (commandlang
   (= :version))
  (err0
   (= :version))
  (err0-handler
   (= :version))
  (ppx_js_style
   (and
    :dev
    (>= v0.17)
    (< v0.18)))))

(package
 (name commandlang-tests)
 (synopsis "Tests for commandlang")
 (depends
  (ocaml
   (>= 5.2))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (bisect_ppx
   (and
    :dev
    (>= 2.8.3)))
  (climate
   (= 0.0.1~preview-0.1))
  (cmdliner
   (= 1.3.0))
  (commandlang
   (= :version))
  (commandlang-to-base
   (= :version))
  (commandlang-to-climate
   (= :version))
  (commandlang-to-cmdliner
   (= :version))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (core_unix
   (and
    (>= v0.17)
    (< v0.18)))
  (err0
   (= :version))
  (err0-handler
   (= :version))
  (expect_test_helpers_core
   (and
    (>= v0.17)
    (< v0.18)))
  (loc0
   (>= 0.1.0))
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
    :dev
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
  (sherlodoc
   (and
    :with-doc
    (>= 0.2)))
  (stdio
   (and
    (>= v0.17)
    (< v0.18)))
  (stdune
   (>= 3.16))))
