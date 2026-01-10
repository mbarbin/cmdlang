Test error cases for run.sh

Missing arguments:

  $ ./run.sh
  Usage: run.sh <os> <version> <format>
    os:      Operating system (e.g., ubuntu-latest, windows-latest, macos-latest)
    version: OCaml version (e.g., 4.14, 5.2, 5.3)
    format:  Output format (dune|opam)
  [1]

Invalid format:

  $ ./run.sh ubuntu-latest 5.3 invalid-format
  Error: format must be 'dune' or 'opam'
  [1]

No matching rule (config without fallback):

  $ cat > no-fallback.json << 'EOF'
  > {"rules":[{"os":"ubuntu-latest","ocaml":"5.3","packages":["cmdlang"]}]}
  > EOF

  $ CI_PACKAGES_CONFIG=no-fallback.json ./run.sh windows-latest 4.14 dune
  Error: no matching rule for os='windows-latest' version='4.14'
  [1]
