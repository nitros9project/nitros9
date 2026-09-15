#!/usr/bin/env bash
#
# build-all.sh - build every Pico-Thing recipe variant and report a summary.
#
# Each subdirectory of recipes/picothing that contains a makefile is one
# variant (l1, l2, their dw and 6309 forms, and the mega images). This script
# cleans and rebuilds each in turn, captures its output to a per-variant log,
# and prints a pass/fail table at the end. It exits non-zero if any variant
# fails, so it is safe to use in CI or a pre-flight check.
#
# Usage:
#   ./build-all.sh                 build every variant (clean first)
#   ./build-all.sh l1 l2_mega      build only the named variants
#   ./build-all.sh -n l2           build without cleaning first (incremental)
#   ./build-all.sh -k              keep going is the default; -h shows help
#
# NITROS9DIR is set automatically from this script's location if unset.

set -u

# --- locate ourselves and the tree -----------------------------------------

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${NITROS9DIR:=$(cd "$script_dir/../.." && pwd)}"
export NITROS9DIR

logdir="$script_dir/build-logs"

# --- options ----------------------------------------------------------------

clean_first=1

usage() {
    sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

while [ $# -gt 0 ]; do
    case "$1" in
        -n|--no-clean) clean_first=0; shift ;;
        -h|--help)     usage 0 ;;
        --)            shift; break ;;
        -*)            echo "unknown option: $1" >&2; usage 1 ;;
        *)             break ;;
    esac
done

# --- select variants --------------------------------------------------------

if [ $# -gt 0 ]; then
    variants=("$@")
else
    variants=()
    for d in "$script_dir"/*/; do
        [ -f "$d/makefile" ] && variants+=("$(basename "$d")")
    done
    IFS=$'\n' variants=($(sort <<<"${variants[*]}")); unset IFS
fi

if [ "${#variants[@]}" -eq 0 ]; then
    echo "no variants found under $script_dir" >&2
    exit 1
fi

mkdir -p "$logdir"

# --- build each -------------------------------------------------------------

declare -a results
failures=0

echo "NITROS9DIR = $NITROS9DIR"
echo "building ${#variants[@]} variant(s): ${variants[*]}"
echo

for v in "${variants[@]}"; do
    dir="$script_dir/$v"
    if [ ! -f "$dir/makefile" ]; then
        printf '  %-14s SKIP (no makefile)\n' "$v"
        results+=("$v|SKIP")
        continue
    fi

    printf '  %-14s ... ' "$v"
    log="$logdir/$v.log"

    if [ "$clean_first" -eq 1 ]; then
        make -C "$dir" clean >/dev/null 2>&1
    fi

    if make -C "$dir" >"$log" 2>&1; then
        dsk="$(ls -1 "$dir"/*.dsk 2>/dev/null | head -1)"
        printf 'PASS  %s\n' "${dsk:+$(basename "$dsk")}"
        results+=("$v|PASS")
    else
        printf 'FAIL  (see %s)\n' "${log#"$NITROS9DIR"/}"
        results+=("$v|FAIL")
        failures=$((failures + 1))
    fi
done

# --- summary ----------------------------------------------------------------

echo
echo "summary:"
for r in "${results[@]}"; do
    printf '  %-14s %s\n' "${r%%|*}" "${r##*|}"
done

echo
if [ "$failures" -eq 0 ]; then
    echo "all builds passed"
else
    echo "$failures variant(s) failed"
fi

exit $((failures > 0 ? 1 : 0))
