# Frequently Asked Questions

## Why Questions

#### Why aren't there more helpers exposed?

We are currently in an exploratory phase and need to easily update our internal representations. Adding too many helpers now would complicate this process. Therefore, we aim to balance providing enough functionality for early trials while keeping the core minimal. We plan to revisit this later with user feedback.

#### Why isn't Commandlang's Arg parser an arrow?

We are uncertain if all targeted models support branching. When writing a CLI for an OCaml program, encoding variants in the CLI can create a clear mapping between the user interface and the internal implementation. However, this approach might complicate the CLI. Commandlang aims to operate at the intersection of its targeted backends, which could be a significant constraint if you need functionality only offered in a specific backend. This is an area for future development. If you need a feature that is only available in another CLI library, commandlang might not be a good fit for your project.

## Other Questions

Feel free to ask any other questions about commandlang.
