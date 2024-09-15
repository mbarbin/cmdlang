# Cmdlang cram tests

In addition to expect tests we also have cram tests. The reason we have both is that some of the code is not easy to cover from pure OCaml code.

It is not necessary that each piece of code in cmdlang be covered by both expect-tests AND cram-tests. In priority, we favor expect-tests (we prefer writing OCaml over bash).
