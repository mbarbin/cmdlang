<h1 align="center">
  <p align="center">Declarative Command-line Parsing for OCaml</p>
  <img
    src="./img/commandlang.png?raw=true"
    width='385'
    alt="Logo"
  />
</h1>

<p align="center">
  <a href="https://github.com/mbarbin/commandlang/actions/workflows/ci.yml"><img src="https://github.com/mbarbin/commandlang/workflows/ci/badge.svg" alt="CI Status"/></a>
  <a href="https://github.com/mbarbin/commandlang/actions/workflows/deploy-doc.yml"><img src="https://github.com/mbarbin/commandlang/workflows/deploy-doc/badge.svg" alt="Deploy Doc Status"/></a>
</p>

Commandlang is a library for creating command-line parsers in OCaml. Implemented as an OCaml EDSL, its declarative specification language lives at the intersection of other well-established similar libraries.

Commandlang doesn't include an execution engine. Instead, Commandlang parsers are automatically translated to `cmdliner`, `core.command`, or `climate` commands for execution.

Our goal is to provide an approachable, flexible, and user-friendly interface while allowing users to choose the backend runtime that best suits their needs.
