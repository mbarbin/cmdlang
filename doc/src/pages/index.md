<h1 align="center">
  <p align="center">Declarative Command-line Parsing for OCaml</p>
  <img
    src="./img/cmdlang.png?raw=true"
    width='385'
    alt="Logo"
  />
</h1>

<p align="center">
  <a href="https://github.com/mbarbin/cmdlang/actions/workflows/ci.yml"><img src="https://github.com/mbarbin/cmdlang/workflows/ci/badge.svg" alt="CI Status"/></a>
  <a href="https://coveralls.io/github/mbarbin/cmdlang?branch=main"><img src="https://coveralls.io/repos/github/mbarbin/cmdlang/badge.svg?branch=main" alt="Coverage Status"/></a>
  <a href="https://github.com/mbarbin/cmdlang/actions/workflows/deploy-doc.yml"><img src="https://github.com/mbarbin/cmdlang/workflows/deploy-doc/badge.svg" alt="Deploy Doc Status"/></a>
</p>

Cmdlang is a library for creating command-line parsers in OCaml. Implemented as an OCaml EDSL, its declarative specification language lives at the intersection of other well-established similar libraries.

Cmdlang doesn't include an execution engine. Instead, Cmdlang parsers are automatically translated to `cmdliner`, `core.command`, or `climate` commands for execution.

Our goal is to provide an approachable, flexible, and user-friendly interface while allowing users to choose the backend runtime that best suits their needs.
