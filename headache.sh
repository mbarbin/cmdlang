#!/bin/bash -e
# SPDX-FileCopyrightText: 2025-2026 Mathieu Barbin <mathieu.barbin@gmail.com>
# SPDX-License-Identifier: MIT

# Build exclusion list from all .headache.exclude files found in the tree.
# Paths in each file are relative to the file's location.
# Empty lines and lines starting with '#' are ignored.
EXCLUDES=()
while IFS= read -r exclude_file; do
    exclude_dir="$(dirname "$exclude_file")"
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        case "$line" in
            \#*) continue ;;
        esac
        if [ "$exclude_dir" = "." ]; then
            EXCLUDES+=("$line")
        else
            EXCLUDES+=("${exclude_dir}/${line}")
        fi
    done < "$exclude_file"
done < <(git ls-files '*.headache.exclude')

# Check if a directory matches any exclusion pattern (recursive).
is_excluded() {
    local dir="$1"
    for excl in "${EXCLUDES[@]}"; do
        if [[ "$dir" == "$excl" ]] || [[ "$dir" == "$excl"/* ]]; then
            return 0
        fi
    done
    return 1
}

# Find the nearest COPYING.HEADER by walking up from a directory.
find_header() {
    local dir="$1"
    local current="$dir"
    while [ "$current" != "." ] && [ "$current" != "/" ]; do
        if [ -f "${current}/COPYING.HEADER" ]; then
            echo "${current}/COPYING.HEADER"
            return
        fi
        current="$(dirname "$current")"
    done
    # Fall back to root
    if [ -f "COPYING.HEADER" ]; then
        echo "COPYING.HEADER"
    else
        echo "No COPYING.HEADER found for ${dir}" >&2
        return 1
    fi
}

# Discover directories containing .ml or .mli files from tracked git files.
dirs=$(git ls-files '*.ml' '*.mli' | xargs -n1 dirname | sort -u)

for dir in $dirs; do
    if is_excluded "$dir"; then
        echo "Skipping excluded directory: ${dir}"
        continue
    fi

    header=$(find_header "$dir")
    echo "Apply headache to directory ${dir} (header: ${header})"

    # Apply headache to .ml files
    if ls "${dir}"/*.ml 1> /dev/null 2>&1; then
        headache -c .headache.config -h "${header}" "${dir}"/*.ml
    fi

    # Apply headache to .mli files
    if ls "${dir}"/*.mli 1> /dev/null 2>&1; then
        headache -c .headache.config -h "${header}" "${dir}"/*.mli
    fi
done

dune fmt
