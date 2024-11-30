## 0.0.9 (2024-11-30)

### Added

- Added an example of migration from `core.command` to `climate` (#20, @mbarbin).
- Added migration utils (#20, @mbarbin).
- Improve code coverage, added tests (#20, @mbarbin).

### Changed

- Document presence in stdlib-runner help (required, default, etc.) (#19, @mbarbin).
- Minor refactor in stdlib-runner (#19, @mbarbin).
- Upgrade to `climate.0.3.0` (#19, @mbarbin).

### Fixed

- Fix trailing dot additions in `to-cmdliner` for cases such as `?.` and `..` (#19, @mbarbin).

### Removed

- Removed config option `auto_add_short_aliases` from to-base translation (not useful) (#20, @mbarbin).

## 0.0.8 (2024-11-14)

### Added

- Add more ci-checks: macOS, Windows, OCaml 4.14 (#17, @mbarbin).
- Add a new backend based on `stdlib.arg` (#16, @mbarbin).

### Changed

- Internal refactor to intermediate representations used in cmdlang-to-base (#16, @mbarbin).

### Fixed

- Enable build with `ocaml.4.14` (#17, @mbarbin).

### Removed

- Remove `Param.assoc`. We require now the `to_string` function found in `Enums` (#16, @mbarbin).

## 0.0.7 (2024-11-10)

### Removed

- Moved `err`, `err-cli` and `cmdlang-cmdliner-runner` to [pp-log](https://github.com/mbarbin/pp-log).

## 0.0.6 (2024-10-24)

### Changed

- Prepare documentation for initial release.
- Upgrade to `climate.0.1.0`.
- Make opam files pass opam-repository linting rules.
- Upgrade Docusaurus.

## 0.0.5 (2024-09-17)

### Added

- Expose `param` & `arg` translators.
- Increase test coverage.

### Changed

- Include `>>|` infix operator in `Command.Std`.
- Separate the translation from the runner in 2 separate packages to keep dependencies isolated.

### Fixed

- Fix handling of `docv` when translating to `core.command`.

### Removed

- Removed most of applicative infix operators - keep only `>>|`.

## 0.0.4 (2024-09-07)

### Changed

- Rename project `cmdlang`.

## 0.0.3 (2024-09-03)

### Changed

- Refactor `Err` - undocumented changes while we're stabilizing.
- Refactor the separation between `Err` and `Err_handler`. Keep only the cli part separate and rename it `err-cli`.

### Fixed

- Fix some unintended behavior related to raising and catching errors with `err0` and `erro-handler`. Added tests to cover and characterize different use cases.

## 0.0.2 (2024-08-23)

### Changed

- Make `cmdlang-err` and standalone library called `err0` so it can be used more broadly. Split the handler part as a separated lib `err0-handler`.

## 0.0.1 (2024-08-22)

### Added

- Added library `Err` establishing a standard for error handling in cmdlang CLIs.

## 0.0.1_preview-0.1 (2024-08-19)

### Added

- Added basic support for `readme`.
- Added `Arg.named_multi`.
- Added param helpers: `stringable`,`validated strings`, `comma_separated`.
- Basic support for positional arguments.
- Enabled instrumentation.
- Adopted OCaml Code of Conduct.
- Added a FAQ page.
- Added test libraries.

### Changed

- Internal changes to AST to make it more consistent.
- Improve generation of man pages when using `cmdliner` as target.
- Update tutorial to include positional arguments.

### Fixed

- Translation to `core.command` requires `(unit -> _) Command.t`
