---
slug: first-release
title: First release of cmdlang
authors: [mbarbin]
tags: [cmdlang, stdlib.arg]
---

https://discuss.ocaml.org/t/first-release-of-cmdlang/15616

Hi everyone!

A little while ago, I [posted](https://discuss.ocaml.org/t/cmdlang-yet-another-cli-library-well-not-really/15258) about [cmdlang](https://github.com/mbarbin/cmdlang), a library for creating command-line parsers in OCaml.

Today, I am happy to give you an update on this project with the announcement of an initial release of cmdlang packages to the opam-repository.

These are very early days for this project. I have started using the `cmdlang+cmdliner` combination in personal projects, and plan to experiment with `climate` in the near future. Please feel free to engage in issues/discussions, etc.

<!-- truncate -->

The most recent addition on the project is the development of an evaluation engine based on `stdlib/arg`.

I'd also like to highlight some examples from the project's tests. Developing these characterization tests was a fun way to learn more about the different CLI libraries and their differences:

- Short, long and prefix [flag names](https://github.com/mbarbin/cmdlang/blob/main/test/expect/test__flag.ml).

- Various syntaxes for [named arguments](https://github.com/mbarbin/cmdlang/blob/main/test/expect/test__named.ml) (`-pVALUE`, `-p=VALUE`, `-p VALUE`).

- Handling of [negative integers](https://github.com/mbarbin/cmdlang/blob/main/test/expect/test__negative_int_args.ml) as named arguments.

If you have ideas for more cases to add (entertaining or otherwise), I'd love to integrate them into the test suite. Thanks!

Below, you'll find details of the released packages. Happy command parsing!

**cmdlang** the user facing library to build the commands. It has no dependencies

**cmdlang-to-cmdliner** translate cmdlang commands to cmdliner

**cmdlang-to-climate** translate cmdlang commands to the newly released climate (compatibility checked with 0.1.0 & 0.2.0)

**cmdlang-stdlib-runner** an execution engine implemented on top of stdlib.arg

Thank you to @mseri and the opam-repository maintainers for their help.
