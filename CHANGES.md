## 0.0.1 (2024-08-22)

### Added

- Added library `Err` establishing a standard for error handling in commandlang CLIs.

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
