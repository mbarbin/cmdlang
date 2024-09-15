---
slug: introducing-cmdlang
title: Yet Another CLI Library (well, not really)
authors: [mbarbin]
tags: [cmdlang, climate, cmdliner, core.command, stdlib.arg]
---

https://discuss.ocaml.org/t/cmdlang-yet-another-cli-library-well-not-really/15258

Greetings fellow camlers,

I hope you had a nice summer! Mine took an unexpected turn when, roughly at the same time, I wrote my first `cmdliner` subcommand and heard about `climate` for the first time. My experience with OCaml CLI so far had been centered around `core.command`.

When I read climate's [terminology](https://github.com/gridbugs/climate?tab=readme-ov-file#terminology) section and how it defines `Terms`, `Arguments`, and `Parameters`, something clicked. Seeing how `climate`'s API managed to make positional and named arguments fit so nicely together, I thought: "Wow, for the first time, it seems I'll be able to write a CLI spec on a whiteboard without referring to some code I never seem to get right (I am looking at you, core.command's anonymous arguments)."

I got quite excited and thought: "Can I switch to `climate` today?" But reality checked: it's not on opam yet, still under construction, I'm not sure what the community will do, etc.

Implementing my own engine for an API resembling `climate` felt like a wasted effort, knowing about the work happening in `climate`. Still, having a `'a Param.t`, `'a Arg.t`, and `'a Command.t` type that I would get to know and love felt too good to pass up.

I stared at the `climate` types for a while, and filled with happy thoughts about a bright CLI future, it occurred to me: can I use an API like `climate` but compile it down to existing libraries such as `cmdliner` or `core.command`? (and `climate` too!). I wrote down the following types:

**climate**

```ocaml
'a Param.t     -> 'a Climate.Arg_parser.conv
'a Arg.t       -> 'a Climate.Arg_parser.t
'a Command.t   -> 'a Climate.Command.t
```

**cmdliner**

```ocaml
'a Param.t     -> 'a Cmdliner.Arg.conv
'a Arg.t       -> 'a Cmdliner.Term.t
'a Command.t   -> 'a Cmdliner.Cmd.t
```

**core.command**

```ocaml
'a Param.t     -> 'a core.Command.Arg_type.t
'a Arg.t       -> 'a core.Command.Param.t
unit Command.t -> core.Command.t
```

... which I interpreted as stating the following theorem:

> There exists an abstraction to encode OCaml CLIs that lives in the intersection of what's expressible in other well established libraries.

"One EDSL to command them all," so to speak. I couldn't resist the temptation to build actual terms for these types. That gave birth to [cmdlang](https://github.com/mbarbin/cmdlang).

As a test, I switched one of my projects to `cmdlang`, with `cmdliner` as a backend. I liked the [changes](https://github.com/mbarbin/bopkit/pull/14) I made in the process. The 1-line [bin/main.ml](https://github.com/mbarbin/bopkit/blob/main/bin/main.ml) is now the only place that specifies which backend I want to use; the rest of the code is programmed solely against the `cmdlang` API. This means I'll be able to easily experiment with compiling down to `climate` in the future.

I am not against the multiplicity of solutions in general, but I tend to feel uneasy when incompatible libraries emerge, partitioning the ecosystem. As a community, we know too many examples of this. In this instance, I want to call the `core.command` vs `cmdliner` situation a ... cli-vage.

I don't see my work on `cmdlang` as competing with these other libraries. Quite the contrary, it makes it easier for me to experiment with them without much changes while exploring the subject of CLI in general. Also, as a library author, if you wish to expose CLI helpers to your users, a library like `cmdlang` will give you a pleasant way to do so, as you can express your helpers with it, knowing your users will have the choice to translate them to the backend of their choice.

Before writing this post, I had a very pleasant chat with @gridbugs. I want to make it clear that I do not think `cmdlang` is competing with `climate` either. I think `climate` is a very promising library and I believe it will, in due time, deliver auto-completion to many - this has been a highly anticipated feature within the community. I wish to dedicate the initial work that I did on `cmdlang` to @gridbugs due to the impactful influence climate had on my work, and how it helped me improve my general understanding of declarative CLI libraries.

These are very early days for `cmdlang`. There are still areas I am fuzzy on, and I haven't really validated the whole design yet. I have put some thoughts in this [Future Plans](https://mbarbin.github.io/cmdlang/docs/explanation/future_plans/) page. One thing that I did not initially include there would be to explore the feasibility of writing a mini-compiler for `cmdlang` targeting `stdlib.arg` as a runner. I am not sure how much you'd end up restricting `cmdlang` for this to work. I thought that'd be a fun project to tackle at a future point, as it would make a nice addition to the overall architecture of the project.

I'd welcome your input to help me shape the future of `cmdlang` if you have an interest in this project.

Thanks for reading!
