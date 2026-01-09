(lang dune 3.17)

(name cmdlang)

(generate_opam_files)

(license MIT)

(authors "Mathieu Barbin")

(maintainers "Mathieu Barbin <opensource@mbarbin.org>")

(source
 (github mbarbin/cmdlang))

(documentation "https://mbarbin.github.io/cmdlang/")

(using mdx 0.4)

;; The value for the [implicit_transitive_deps] option is set during the CI
;; depending on the OCaml compiler version.
;;
;; This will be set to [false] iif [ocaml-version >= 5.2].
;;
;; For packaging purposes with older ocaml, it is simpler atm if the option is
;; set to [true] in the main branch.
;;
;; See: [.github/workflows/edit_dune_project_dot_ml].

(implicit_transitive_deps true)

(package
 (name cmdlang)
 (synopsis "Declarative Command-line Parsing for OCaml")
 (depends
  (ocaml
   (>= 4.14))))

(package
 (name cmdlang-to-base)
 (synopsis "Convert cmdlang Parsers to core.command")
 (depends
  (ocaml
   (>= 5.2))
  (base
   (>= v0.17))
  (cmdlang
   (= :version))
  (core
   (>= v0.17))
  (ppx_compare
   (>= v0.17))
  (ppx_enumerate
   (>= v0.17))
  (ppx_let
   (>= v0.17))
  (ppx_sexp_conv
   (>= v0.17))
  (ppx_sexp_value
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (stdio
   (>= v0.17))))

(package
 (name cmdlang-to-cmdliner)
 (synopsis "Convert cmdlang Parsers to cmdliner")
 (depends
  (ocaml
   (>= 4.14))
  (cmdlang
   (= :version))
  (cmdliner
   (>= 1.3.0))))

(package
 (name cmdlang-to-climate)
 (synopsis "Convert cmdlang Parsers to climate")
 (depends
  (ocaml
   (>= 4.14))
  (climate
   (>= 0.8.0))
  (cmdlang
   (= :version))))

(package
 (name cmdlang-stdlib-runner)
 (synopsis "A basic execution runner for cmdlang based on stdlib.arg")
 (depends
  (ocaml
   (>= 4.14))
  (cmdlang
   (= :version))))

(package
 (name cmdlang-tests)
 (synopsis "Tests for cmdlang")
 (depends
  (ocaml
   (>= 5.3))
  (base
   (>= v0.17))
  (climate
   (>= 0.8.5))
  (cmdlang
   (= :version))
  (cmdlang-stdlib-runner
   (= :version))
  (cmdlang-to-base
   (= :version))
  (cmdlang-to-climate
   (= :version))
  (cmdlang-to-cmdliner
   (= :version))
  (cmdliner
   (and
    (>= 1.3.0)
    (< 2.0)))
  (core
   (>= v0.17))
  (core_unix
   (>= v0.17))
  (expect_test_helpers_core
   (>= v0.17))
  (loc
   (>= 0.2.2))
  (mdx
   (>= 2.4))
  (ppx_compare
   (>= v0.17))
  (ppx_enumerate
   (>= v0.17))
  (ppx_expect
   (>= v0.17))
  (ppx_hash
   (>= v0.17))
  (ppx_here
   (>= v0.17))
  (ppx_let
   (>= v0.17))
  (ppx_sexp_conv
   (>= v0.17))
  (ppx_sexp_value
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (stdio
   (>= v0.17))
  (stdune
   (>= 3.17))))

(package
 (name cmdlang-dev)
 (synopsis "Package to regroup dev targets, documentation, and more")
 (allow_empty)
 (depends
  (ocaml
   (>= 5.2))
  (ocamlformat
   (= 0.28.1))
  (bisect_ppx
   (>= 2.8.3))
  (cmdlang
   (= :version))
  (cmdlang-stdlib-runner
   (= :version))
  (cmdlang-tests
   (= :version))
  (cmdlang-to-base
   (= :version))
  (cmdlang-to-climate
   (= :version))
  (cmdlang-to-cmdliner
   (= :version))
  (mdx
   (>= 2.4))
  (ppx_expect
   (>= v0.17))
  (ppx_js_style
   (>= v0.17))
  (ppxlib
   (>= 0.33))
  (sherlodoc
   (>= 0.2))))
