# cmdlang

[![CI Status](https://github.com/mbarbin/cmdlang/workflows/ci/badge.svg)](https://github.com/mbarbin/cmdlang/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/mbarbin/cmdlang/badge.svg?branch=main)](https://coveralls.io/github/mbarbin/cmdlang?branch=main)
[![Deploy Doc Status](https://github.com/mbarbin/cmdlang/workflows/deploy-doc/badge.svg)](https://github.com/mbarbin/cmdlang/actions/workflows/deploy-doc.yml)

Declarative Command-line Parsing for OCaml.

## Synopsis

Cmdlang is a library for creating command-line parsers in OCaml. Implemented as an OCaml EDSL, its declarative specification language lives at the intersection of other well-established similar libraries.

Cmdlang doesn't include an execution engine. Instead, Cmdlang parsers are automatically translated to `cmdliner`, `core.command`, or `climate` commands for execution.

Our goal is to provide an approachable, flexible, and user-friendly interface while allowing users to choose the backend runtime that best suits their needs.

## Documentation

Cmdlang's documentation is published [here](https://mbarbin.github.io/cmdlang).

## Rationale

The OCaml community currently has two popular libraries for declarative command-line argument parsing:

1. [cmdliner](https://github.com/dbuenzli/cmdliner)
2. [core.command](https://github.com/janestreet/core), base's `Command` module.

There is also a third library under development:

3. [climate](https://github.com/gridbugs/climate), aiming to support autocompletion scripts and other conventions.

The following table reflects our understanding and preferences (ranked 1-3, most preferred first) as of the early days of `cmdlang` (your mileage may vary):

|     Library    |  Runtime (eval)        |  Ergonomic (mli)  |  CLI conventions  | Man pages  |  Auto-complete  |
|----------------|:----------------------:|:-----------------:|:-----------------:|:----------:|:---------------:|
|    cmdliner    |  Battled-tested        |         2         |          1        |  Yes       |  No             |
|  core.command  |  Battled-tested        |         2         |          3        |  No        |  Yes            |
|   climate      |  (Under Construction)  |         1         |          1        |  No        |  Yes            |

**Programming Interface**: We find the type separation between the `Arg` & `Param` types proposed by `climate` to be the easiest to understand among the three models.

**CLI syntax support**: Both `cmdliner` and `climate` support established conventions. We find that these conventions are harder to achieve with `core.command`, especially regarding its handling of long flag name arguments beginning with a single `-`.

The `cmdlang` developers are enthusiastic to the prospect of compatible ways of working with these libraries.

As developers of CLI tools written in OCaml, we aim to avoid a strong commitment to any single library if possible, especially concerning the runtime aspects. This is particularly relevant for new commands written today.

In this spirit, we created `cmdlang`, a new library that offers a unique twist: it doesn't implement its own runtime. Instead, it translates its parsers into `cmdliner`, `core.command`, or `climate` parsers, making it compatible with all their execution engines.

Our current preferred target is depicted below, but other combinations are possible:

|  Library      |  Runtime (eval)  |  Ergonomic (mli)      |  CLI conventions  |  Man pages  |  Auto-complete  |
|---------------|:----------------:|:---------------------:|:-----------------:|:-----------:|:---------------:|
|  cmdlang      |  Battled-tested  |          1            |         1         |  Yes        |  Yes*           |
|     via       |     cmdliner     |  inspired by climate  |     cmdliner      |  cmdliner   |  Hybrid*        |

`*` Auto-completion: we plan to say more about it in the doc in the near future.

Due to its architecture, `cmdlang` can be a helpful tool for implementing effective migration paths to transition from one of the existing libraries to another.

We initiated the library as part of another project where we are migrating some commands from `core.command` to `cmdliner`, with the desire to make it easy to experiment with `climate` in the future.

## Architecture

`cmdlang` is composed of several parts:

1. **Core Specification Language**:
   - A kernel command-line parsing specification language written as an OCaml EDSL.
   - Covers the intersection of what is expressible in `cmdliner`, `core.command`, and `climate`.

2. **OCaml Library**:
   - Exposes a single module, `Cmdlang.Command`, with no dependencies, to build command-line parsers in total abstraction using ergonomic helpers.
   - Supports various styles for writing command-lines, including `( let+ )` and `ppx_let`'s `let%map` or `let%map_open`.
   - Designed with ocaml-lsp in mind for user-friendly in-context completion.

3. **Translation Libraries**:
   - Convert `cmdlang` parsers at runtime into `cmdliner`, `core.command`, or `climate` parsers
   - Packaged as separate helper libraries to keep dependencies isolated.

4. **Basic execution runner based on stdlib.arg**:
   - A proof-of-concept execution engine implemented on top of `stdlib.arg`.

## Experimental Status

`cmdlang` is currently under construction and considered experimental. We are actively seeking feedback to validate our design and engage with other declarative command-line enthusiasts.

## Acknowledgements

- We are grateful for the years of accumulated work and experience that have resulted in high-quality CLI libraries like `cmdliner` and `core.command`.
- `climate`'s early programming interface was a great source of inspiration. We are very thankful for their work on auto-completion and excited to see where the `climate` project goes next.
- We would like to thank the Dune developers for the user-facing error handling of Dune (`Stdune.User_message`), on which we based the error handling scheme used in cmdlang (`Err`). By adopting a similar approach, we aim to provide a consistent and unified user experience for OCaml users across different tools and libraries.
- We are inspired by the [diataxis](https://diataxis.fr/) approach to technical documentation, which we use to structure our documentation.
