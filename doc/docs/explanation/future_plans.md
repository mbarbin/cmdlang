# Future Plans

In this section, we outline some areas of uncertainty regarding the feasibility of our design in detail. These are the areas we plan to explore next.

## Positional Arguments

*Also known as anonymous arguments in `core.command`.*

One of the key areas we need to investigate further is the handling of anonymous arguments, also known as positional arguments in `cmdliner` and `climate`. Due to the differences in how these arguments are managed in `core.command`, translating them may not be as straightforward as it is for named arguments.

However, we have a good intuition that by reducing some of the expressiveness of what we allow to construct, we can solve cases that are sufficient in practice. For example, enforcing that positional arguments be defined in left-to-right order in the specification might be a viable approach.

### Tasks
- [x] Investigate handling of anonymous arguments in `cmdliner` and `climate` (Completed: Aug 2024)
- [x] Develop a strategy for translating positional arguments in `core.command` (Completed: Aug 2024)
- [x] Implement left-to-right order enforcement for positional arguments when compiling to `core.command` (Completed: Aug 2024)

## Generation of Complex Man Pages

Another area of focus is the generation of complex man pages. `cmdliner` has excellent support for these. Currently, we have added basic support for one-line summaries of help messages to get started. However, we believe we could reuse most of the design of `cmdliner` and add it as optional information to the specification language.

The rendering to simple strings could be exported by a standalone `cmdliner` helper library to reduce dependencies. We could then reuse and integrate this in the translation to `core.command` and `climate`. This part is more prospective and may require some coordination with the developers of other libraries.

### Tasks
- [x] Add support for one-line summaries and readme help pages.
- [ ] Design optional information for specification language based on `cmdliner`
- [ ] Create a standalone helper library for rendering to simple strings
- [ ] Integrate design into translation to `core.command` and `climate`

## Auto-Completion

The third point is by far the most challenging but also a source of significant added value: auto-completion. This has been a highly anticipated feature within the community, and we have recently seen progress in this area, particularly with the `climate` developers working on integrating support for auto-completion.

We envision a potential hybrid translation mode where a `commandlang` command is translated into both `cmdliner` and `climate` — `cmdliner` for runtime execution and `climate` to generate completion scripts. This approach leaves the question of reentrant completion as future work.

Given the ongoing developments in other libraries regarding auto-completion, we will carefully consider how `commandlang`'s unique architecture can accommodate and leverage these changes. This will require thoughtful planning and possibly significant adjustments as the landscape evolves.

### Tasks
- [ ] Research auto-completion support in `climate`
- [ ] Develop a hybrid translation mode for `commandlang` commands
- [ ] Implement auto-completion feature
