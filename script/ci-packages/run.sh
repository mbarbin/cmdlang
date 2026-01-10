#!/bin/bash
# SPDX-FileCopyrightText: 2026 Mathieu Barbin <opensource@mbarbin.org>
# SPDX-License-Identifier: MIT

set -euo pipefail

# This script resolves which OCaml packages to build/test for a given OS and
# OCaml version in CI. The configuration lives in rules.json.
#
# Why this setup instead of inline bash conditionals in the workflow?
# - The json config is easier to read and extend than nested if/elif/else
# - The script is testable: test.sh runs all combinations and the output is
#   verified via dune's expect test promotion (see dune file)
# - Changes to package selection are caught by tests before breaking CI

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CONFIG_FILE="${CI_PACKAGES_CONFIG:-$SCRIPT_DIR/rules.json}"

PROG_NAME="run.sh"

usage() {
  echo "Usage: $PROG_NAME <os> <version> <format>" >&2
  echo "  os:      Operating system (e.g., ubuntu-latest, windows-latest, macos-latest)" >&2
  echo "  version: OCaml version (e.g., 4.14, 5.2, 5.3)" >&2
  echo "  format:  Output format (dune|opam)" >&2
  exit 1
}

if [ $# -ne 3 ]; then
  usage
fi

OS="$1"
VERSION="${2%.x}" # normalize: strip .x suffix if present
FORMAT="$3"

if [ "$FORMAT" != "dune" ] && [ "$FORMAT" != "opam" ]; then
  echo "Error: format must be 'dune' or 'opam'" >&2
  exit 1
fi

# shellcheck disable=SC2016 # $os and $ocaml are jq variables, not bash
JQ_BASE='first(.rules[] | select((.os == $os or .os == "*") and (.ocaml == $ocaml or .ocaml == "*"))) | .packages'

case "$FORMAT" in
  dune)
    JQ_FILTER="$JQ_BASE | join(\",\")"
    ;;
  opam)
    JQ_FILTER="$JQ_BASE | map(\"./\\(.).opam\") | join(\" \")"
    ;;
esac

OUTPUT=$(jq -r --arg os "$OS" --arg ocaml "$VERSION" "$JQ_FILTER" "$CONFIG_FILE")

if [ -z "$OUTPUT" ]; then
  echo "Error: no matching rule for os='$OS' version='$VERSION'" >&2
  exit 1
fi

echo "$OUTPUT"
