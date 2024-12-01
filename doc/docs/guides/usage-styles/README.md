# Usage Styles

This section demonstrates how to use the helper modules available in `cmdlang` and how to add them to the scope using different styles commonly used in the OCaml community.

Depending on your preference and the conventions of your project, you can choose from various styles to incorporate `cmdlang` into your code. The `Command.Std` module provides a convenient way to access all the standard components of `cmdlang`, while directly using `Cmdlang`, local open statements, or aliases can offer more explicit control over the scope.

## Introducing Command to the scope

To define commands, you need to import the `cmdlang` package. This packages defines an OCaml library named `Cmdlang`, which exports a single module named `Command`. There are several ways `Command` may be brought to scope.

### Import via flags

The approach recommended by the `cmdlang` authors is to avoid mentioning the name `cmdlang` directly in your OCaml files. Instead, configure the project dependencies to open `Cmdlang` via flags in your dune file:

<!-- $MDX skip -->
```lisp
(library
 (name my_library)
 (flags :standard -open Cmdlang)
 (libraries cmdlang))
```

However, other options are possible. For example, you can use an import file to specify module aliases:

### Import file

A common practice consists in having an `import.ml` file per directory, where you can specify module aliases.

<!-- $MDX skip -->
```ocaml
module Command = Cmdlang.Command
```

Then, each other file in the directory starts with:

<!-- $MDX skip -->
```ocaml
open! Import
```

Setup that way, the module `Command` is effectively bound to `Cmdlang.Command` in all the files.

### Local aliases

If your project doesn't use import files, you can always move this alias near the parts where the command are defined.

<!-- $MDX skip -->
```ocaml
module Command = Cmdlang.Command

(* Define your commands below. *)
```

In the rest of the guide, we'll assume that the module is available as `Command`.

## Declarative styles

### Using let+ and let open

In this style, the applicative syntax part is implemented via the use of `let+` and `and+` [binding operators](https://ocaml.org/manual/5.2/bindingops.html).

They are introduced to the scope, alongside the common modules `Arg` and `Param` via a local open of `Command.Std`.

<!-- $MDX file=usage_styles.ml,part=let_plus_std -->
```ocaml
let _ : unit Command.t =
  Command.make
    ~summary:"A command skeleton"
    (let open Command.Std in
     let+ (_ : int) = Arg.named [ "n" ] Param.int ~doc:"A value for n"
     and+ () = Arg.return () in
     ())
;;
```

This is the main style recommended by the cmdlang authors.

#### No Indentation Tweak with @@

Some people prefer limiting the indentation of large blocks with the help of the infix operator `@@`. In this context, this may look like this:

<!-- $MDX file=usage_styles.ml,part=let_plus_std_no_indent -->
```ocaml
let _ : unit Command.t =
  Command.make ~summary:"A command skeleton"
  @@
  let open Command.Std in
  let+ (_ : int) = Arg.named [ "n" ] Param.int ~doc:"A value for n"
  and+ () = Arg.return () in
  ()
;;
```

The cmdlang authors do not have much experience with this style at the time of writing.

### Using let-syntax and map_open

An alternative based on the `let%map_open` operator of [ppx_let](https://github.com/janestreet/ppx_let) is also supported.

<!-- $MDX file=usage_styles.ml,part=let_map_open -->
```ocaml
let _ : unit Command.t =
  Command.make
    ~summary:"A command skeleton"
    (let%map_open.Command () = Arg.return ()
     and () = Arg.return () in
     ())
;;
```

### Other styles

`cmdlang` aims to be flexible and accommodate various coding styles. If you have a specific style or use case that is not covered here, please reach out to us. We are open to feedback and can make adjustments to the interface to better support your needs.

## Conclusion

This guide has shown you different ways to use the helper modules in `cmdlang`, including a standard recommended by the authors. Feel free to experiment with these styles and choose the one that best suits your project.
