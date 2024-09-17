## 0.0.5 (unreleased)

### Added

- Expose `param` & `arg` translators.
- Increase test coverage.

### Changed

- Include `>>|` infix operator in `Command.Std`.
- Separate the translation from the runner in 2 separate packages to keep dependencies isolated.

### Deprecated

### Fixed

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
