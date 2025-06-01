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

;; The value for the [implicit_transtive_deps] option is set during the CI
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
  (ppxlib
   (>= 0.33))
  (stdio
   (and
    (>= v0.17)
    (< v0.18)))))

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
   (>= 0.5.0))
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
   (>= 5.2))
  (ocamlformat
   (and
    :with-dev-setup
    (= 0.27.0)))
  (base
   (and
    (>= v0.17)
    (< v0.18)))
  (bisect_ppx
   (and
    :with-dev-setup
    (>= 2.8.3)))
  (climate
   (>= 0.5.0))
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
   (>= 1.3.0))
  (core
   (and
    (>= v0.17)
    (< v0.18)))
  (core_unix
   (and
    (>= v0.17)
    (< v0.18)))
  (expect_test_helpers_core
   (and
    (>= v0.17)
    (< v0.18)))
  (loc
   (>= 0.2.2))
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
   (>= 3.17))
  (sherlodoc
   (and
    :with-doc
    (>= 0.2)))))
