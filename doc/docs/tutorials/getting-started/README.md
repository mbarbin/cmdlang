# Getting Started

In this tutorial, we'll create a small calculator in OCaml, export it as a command-line tool, and demonstrate the use of the `cmdlang` library along the way.

We'll create a CLI that can perform operations like:

```sh
$ ./my-calculator --op=add 1 2.5
3.5
```

(a classic of the genre!)

## Installation

`cmdlang` is currently under development and is not yet published to opam. Instead, it is available through a custom [opam repository](https://github.com/mbarbin/opam-repository.git), which must be added to your opam switch.

For example, if you are using a local opam switch, follow these steps:

<!-- $MDX skip -->
```sh
$ cd /path/to/your/local/switch
$ eval $(opam env)
$ opam repo add mbarbin https://github.com/mbarbin/opam-repository.git
```

Once this is set up, you can install `cmdlang` as usual with opam:

<!-- $MDX skip -->
```sh
$ opam install cmdlang
```

We will update this section as the project progresses.

## Packaging

To keep the dependencies separate, our command will be implemented in its own library, with the runtime instantiation in a separate folder.

### Lib

First, create a `lib/` directory and a `lib/dune` file for our library, listing `cmdlang` as a dependency.

`Cmdlang` is designed to expose a single module named `Command`. To bind `Command` directly to `Cmdlang.Command` in our scope, we use the `-open` flag in the dune setup. You can use different styles if you prefer.

<!-- $MDX skip -->
```lisp
(library
 (name getting_started)
 (flags :standard -open Cmdlang)
 (libraries cmdlang))
```

Next, create an empty command-line skeleton that we will complete incrementally.

<!-- $MDX skip -->
```ocaml
let cmd =
  Command.make
    ~summary:"A simple calculator"
    (let open Command.Std in
     let+ () = Arg.return () in
     ())
;;
```

Finally, export this command via the mli:

<!-- $MDX file=getting_started.mli,part=export -->
```ocaml
val cmd : unit Command.t
```

### Bin

Create a `bin/` directory and a `bin/dune` file to set up the build rules for our executable.

As you'll learn, `cmdlang` doesn't come with its own command runner. Instead, it is designed to use existing runners from the community. For this tutorial, we'll use `cmdliner` as our command runner.

**Install step**

<!-- $MDX skip -->
```sh
$ opam install cmdlang-cmdliner-runner
```

**Setup bin/dune**

<!-- $MDX skip -->
```lisp
(executable
 (name main)
 (libraries cmdlang_cmdliner_runner getting_started))
```

An invocation of `cmdliner` for a `cmdlang` command may look like this:

<!-- $MDX file=main.ml -->
```ocaml
let () =
  Cmdlang_cmdliner_runner.run
    Getting_started.cmd
    ~name:"my-calculator"
    ~version:"%%VERSION%%"
;;
```

You'll notice how we've:
1. Used a cmdlang translator library to obtain a cmdliner command.
2. Used the cmdliner library to evaluate (run) our command.

## Implementation

With our build rules set, it's time to start coding!

### Adding Operations

We'll add an operator module that supports some binary operations:

<!-- $MDX file=getting_started.ml,part=start -->
```ocaml
module Operator = struct
  type t =
    | Add
    | Mul

  let all = [ Add; Mul ]

  let to_string = function
    | Add -> "add"
    | Mul -> "mul"
  ;;

  let eval op a b =
    match op with
    | Add -> a +. b
    | Mul -> a *. b
  ;;
end
```

Next, we'll start exposing the functionality via the command-line interface.

### Adding Arguments

Let's revisit our empty skeleton:

<!-- $MDX skip -->
```ocaml
let cmd =
  Command.make
    ~doc:"A simple calculator"
    (let open Command.Std in
     let+ () = Arg.return () in
     ())
;;
```

Argument parsing is done using a style called "applicative syntax". This means you bind the arguments you wish to parse with the `let+` and `and+` keywords, and then you can use these arguments in the body of your command.

Let's add three arguments:

- One for the operation we'd like to compute.
- Two additional arguments to get the operands.

To do this, we need to insert lines in the `let+` section and fill the body of the command with actual code:

<!-- $MDX skip -->
```ocaml
let cmd =
  Command.make
    ~doc:"A simple calculator"
    (let open Command.Std in
     let+ _ (* ADD NEW   *) = _
     and+ _ (* ARGUMENTS *) = _
     and+ _ (* HERE      *) = _ in
     in
     (* AND THE COMMAND BODY HERE *)
     ())
;;
```
The library is designed with ocaml-lsp completion in mind, so remember:

1. Argument builders are in a module called `Command.Std.Arg`
2. Argument parameter builders are in a module called `Command.Std.Param` (to parse the `"add"` part of the complete `"--op=add"` argument)

Since we've opened `Command.Std` in this section, the modules we need are `Arg` and `Param`.

<!-- $MDX skip -->
```ocaml
let cmd =
  Command.make
    ~doc:"A simple calculator"
    (let open Command.Std in
     let+ op = Arg.(* <== After typing "Arg." you can now enjoy
                          user-friendly ocaml-lsp completion. *)
     ...
```

We've found a suitable helper in the `Arg` API to parse the mandatory `--op` named argument. This argument expects a parameter, which is the value supplied along with the argument, such as in `--op=add`.

Similarly, remember that parameter parsing helpers are in the `Param` module:

<!-- $MDX skip -->
```ocaml
let cmd =
  Command.make
    ~doc:"A simple calculator"
    (let open Command.Std in
     let+ op =
       Arg.named_req
         [ "op" ]
         ~doc:"operation to perform"
         (Param. (* <== After typing "Param." you can now enjoy
                        user-friendly ocaml-lsp completion.*)
     ...
```

### Completing the Program

At this point, we have everything we need to complete our calculator.

<!-- $MDX file=getting_started.ml,part=final -->
```ocaml
let cmd =
  Command.make
    ~summary:"A simple calculator"
    (let open Command.Std in
     let+ op =
       Arg.named
         [ "op" ]
         (Param.enumerated (module Operator))
         ~docv:"OP"
         ~doc:"operation to perform"
     and+ a = Arg.pos ~pos:0 Param.float ~docv:"a" ~doc:"first operand"
     and+ b = Arg.pos ~pos:1 Param.float ~docv:"b" ~doc:"second operand"
     and+ verbose = Arg.flag [ "verbose" ] ~doc:"print debug information" in
     if verbose then Printf.printf "op: %s, a: %f, b: %f\n" (Operator.to_string op) a b;
     print_endline (Operator.eval op a b |> string_of_float))
;;
```

### Running the Command

That's it! We're ready to enjoy the full features of our command line tool.

```sh
$ ./my-calculator --op=mul 3 7.2 --verbose
op: mul, a: 3.000000, b: 7.200000
21.6
```

Our CLI includes a generated help page:

<details open>
<summary>
Output of "./my-calculator --help"
</summary>

```sh
$ ./my-calculator --help=plain
NAME
       my-calculator - A simple calculator

SYNOPSIS
       my-calculator [--op=OP] [--verbose] [OPTION]… a b

ARGUMENTS
       a (required)
           first operand.

       b (required)
           second operand.

OPTIONS
       --op=OP (required)
           operation to perform. OP must be either 'add' or 'mul'.

       --verbose
           print debug information.

COMMON OPTIONS
       --help[=FMT] (default=auto)
           Show this help in format FMT. The value FMT must be one of auto,
           pager, groff or plain. With auto, the format is pager or plain
           whenever the TERM env var is dumb or undefined.

       --version
           Show version information.

EXIT STATUS
       my-calculator exits with:

       0   on success.

       123 on indiscriminate errors reported on standard error.

       124 on command line parsing errors.

       125 on unexpected internal errors (bugs).

```
</details>

Additionally, we don't need to worry about handling invalid usages, this is done for us by `cmdliner`:

```sh
$ ./my-calculator --op=not-found 1 2.5
my-calculator: option '--op': invalid value 'not-found', expected either
               'add' or 'mul'
Usage: my-calculator [--op=OP] [--verbose] [OPTION]… a b
Try 'my-calculator --help' for more information.
[124]
```

```sh
$ ./my-calculator --op=add true 2.5
my-calculator: a argument: invalid value 'true', expected a floating point
               number
Usage: my-calculator [--op=OP] [--verbose] [OPTION]… a b
Try 'my-calculator --help' for more information.
[124]
```

## Conclusion

In this tutorial, we've created a command-line interface and exposed its entry point from a library. Then, we've used the `cmdlang_to_cmdliner` translation step and set up dune build rules to create an executable that runs this command with `cmdliner` as a backend.

While we've covered the basics, there are additional features you might want to explore, such as generating complete man pages and setting up auto-completion. We'll cover these advanced topics in other parts of the documentation.

Happy command parsing!
