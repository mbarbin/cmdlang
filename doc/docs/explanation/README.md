# Explanation

Welcome to the Explanation section of the `cmdlang` documentation. Here, we delve into the details of how `cmdlang` works, its design principles, and our future plans. This section is intended to provide a deeper understanding of the project for developers and contributors.

## Architecture

`cmdlang` is composed of several parts:

- **Core Specification Language**: A kernel command-line parsing specification language written as an OCaml EDSL.
- **OCaml Library**: Exposes a single module, `Cmdlang.Command`, with no dependencies, to build command-line parsers in total abstraction using ergonomic helpers.
- **Translation Libraries**: Convert `cmdlang` parsers at runtime into `cmdliner`, `core.command`, or `climate` parsers.

## Experimental Status

`cmdlang` is currently under construction and considered experimental. We are actively seeking feedback to validate our design and engage with other declarative command-line enthusiasts.

## Future Plans

In this section, we outline some areas of uncertainty regarding the feasibility of our design in detail. These are the areas we plan to explore next:

1. **Anonymous Arguments (Positional Arguments)**
2. **Generation of Complex Man Pages**
3. **Auto-Completion**

For more details, refer to the [Future Plans](./future_plans.md) section.

## Acknowledgements

- We are grateful for the years of accumulated work and experience that have resulted in high-quality CLI libraries like `cmdliner` and `core.command`
- `climate`'s early programming interface was a great source of inspiration. We are very thankful for their work on auto-completion and excited to see where the `climate` project goes next.

For more details, refer to the Acknowledgements section of the project on GitHub.
