#!/usr/bin/env bash
# verify-normalize.sh
#
# Validates that asm-normalize.py produces bit-identical OS-9 modules:
#   1. Clone main to a temp dir, detach HEAD, and build it
#   2. Create feature/one-space-rule, apply normalizer, detach HEAD,
#      clean-build it, then restore the branch
#   3. Run `os9 ident` on every built module in both trees
#   4. Compare module names, sizes, and CRCs
#
# Two modules embed time-varying build timestamps and therefore always
# produce different CRCs between two builds run at different times:
#   • sysgo.asm      uses the `dts` (date-time string) directive
#   • wbinfo.as      uses the `dtb` (date-time binary) directive
# For those modules the comparison falls back to size-only; all others
# are compared by size AND CRC.
#
# Usage: bash scripts/verify-normalize.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TOOLS_PATH=/Users/boisy/Projects/coco-shelf/bin
TEMP_MAIN=/tmp/nitros9_main_build
IDENT_MAIN=/tmp/ident_main.txt
IDENT_FEATURE=/tmp/ident_feature.txt
FEATURE_BRANCH=feature/one-space-rule

export PATH="$TOOLS_PATH:$PATH"

die() { echo "ERROR: $*" >&2; exit 1; }

# Modules built from sources that embed wall-clock timestamps.
# These will have legitimately different CRCs between any two builds run at
# different times; only their sizes are compared.
# Pattern matches the final path component (basename).
TIMESTAMP_MODULES_PAT='/(sysgo(_dd|_h0)?|wbinfo)$'

# Run os9 ident on every untracked file in a repo tree; write
# "<relative-path> <hex-size> <hex-crc>" for each valid OS-9 module,
# sorted by path, to the given output file.
collect_idents() {
    local root="$1" out="$2"
    > "$out"
    while IFS= read -r rel; do
        local full="$root/$rel"
        [ -f "$full" ] || continue
        local idout size crc
        idout=$(os9 ident "$full" 2>/dev/null) || continue
        size=$(printf '%s\n' "$idout" | awk '/Module size:/{print $3}')
        crc=$( printf '%s\n' "$idout" | awk '/Module CRC /{print $4}')
        [ -n "$size" ] && [ -n "$crc" ] || continue
        printf '%s %s %s\n' "$rel" "$size" "$crc" >> "$out"
    done < <(cd "$root" && git ls-files --others --exclude-standard)
    sort -o "$out" "$out"
    echo "  → $(wc -l < "$out" | tr -d ' ') OS-9 modules collected"
}

# ── Pre-flight checks ────────────────────────────────────────────────────────
command -v os9      >/dev/null || die "os9 not found on PATH (expected in $TOOLS_PATH)"
command -v lwasm    >/dev/null || die "lwasm not found on PATH"
command -v python3  >/dev/null || die "python3 not found"

git -C "$REPO_DIR" show-ref --verify --quiet "refs/heads/$FEATURE_BRANCH" \
    && die "Branch '$FEATURE_BRANCH' already exists. Delete it first:
  git branch -D $FEATURE_BRANCH"

# ── Step 1: Clone main ───────────────────────────────────────────────────────
echo ""
echo "=== [1/7] Cloning main → $TEMP_MAIN ==="
rm -rf "$TEMP_MAIN"
git clone --branch main "$REPO_DIR" "$TEMP_MAIN"
# Detach HEAD so git branch --show-current returns "" in both builds,
# making the auto-generated defs/buildinfo identical between the two trees.
git -C "$TEMP_MAIN" checkout --detach HEAD

# ── Step 2: Build main ───────────────────────────────────────────────────────
echo ""
echo "=== [2/7] Building main (this will take a while) ==="
# Override NITROS9DIR so the clone uses its own sources, not the parent repo.
NITROS9DIR="$TEMP_MAIN" make -C "$TEMP_MAIN"

# ── Step 3: Collect main idents ──────────────────────────────────────────────
echo ""
echo "=== [3/7] Collecting main module idents ==="
collect_idents "$TEMP_MAIN" "$IDENT_MAIN"

# ── Step 4: Create feature branch ────────────────────────────────────────────
echo ""
echo "=== [4/7] Creating $FEATURE_BRANCH from main ==="
git -C "$REPO_DIR" checkout -b "$FEATURE_BRANCH" main

# ── Step 5: Apply normalizer ──────────────────────────────────────────────────
echo ""
echo "=== [5/7] Normalizing all .as/.asm files ==="
find "$REPO_DIR" \( -name '*.as' -o -name '*.asm' \) ! -path '*/.git/*' \
    | xargs python3 "$REPO_DIR/scripts/asm-normalize.py"
CHANGED=$(git -C "$REPO_DIR" diff --name-only | wc -l | tr -d ' ')
echo "  → $CHANGED source files modified"

# ── Step 6: Clean-build feature branch ───────────────────────────────────────
echo ""
echo "=== [6/7] Clean-building $FEATURE_BRANCH (this will take a while) ==="
make -C "$REPO_DIR" clean
# Remove all untracked build artifacts left over from prior builds on other
# branches (e.g. 3rdparty binaries that make clean doesn't purge).  git clean
# only removes UNTRACKED files, so the normalizer's tracked source changes
# are fully preserved.  scripts/ is excluded so the normalizer itself is not
# deleted.
git -C "$REPO_DIR" clean -fxd --quiet --exclude=scripts/
# Detach HEAD so buildinfo is generated with the same branch name ("") as the
# main clone build, keeping the two builds' buildinfo strings identical.
git -C "$REPO_DIR" checkout --detach HEAD
make -C "$REPO_DIR"
# Restore the feature branch (working-tree changes from normalizer are kept).
git -C "$REPO_DIR" checkout "$FEATURE_BRANCH"

# ── Step 7: Collect feature idents and compare ────────────────────────────────
echo ""
echo "=== [7/7] Collecting feature module idents ==="
collect_idents "$REPO_DIR" "$IDENT_FEATURE"

# ── Comparison ───────────────────────────────────────────────────────────────
echo ""
echo "=== COMPARISON ==="

# Split each ident file into two subsets:
#   • non-timestamp modules: compare name + size + CRC
#   • timestamp modules (dts/dtb): compare name + size only
MAIN_CRC=/tmp/ident_main_crc.txt
FEAT_CRC=/tmp/ident_feature_crc.txt
MAIN_SZ=/tmp/ident_main_sz.txt
FEAT_SZ=/tmp/ident_feature_sz.txt

grep -Ev "$TIMESTAMP_MODULES_PAT" "$IDENT_MAIN"    > "$MAIN_CRC"
grep -Ev "$TIMESTAMP_MODULES_PAT" "$IDENT_FEATURE" > "$FEAT_CRC"
grep -E  "$TIMESTAMP_MODULES_PAT" "$IDENT_MAIN"    | awk '{print $1,$2}' > "$MAIN_SZ"
grep -E  "$TIMESTAMP_MODULES_PAT" "$IDENT_FEATURE" | awk '{print $1,$2}' > "$FEAT_SZ"

CRC_COUNT=$(wc -l < "$MAIN_CRC" | tr -d ' ')
SZ_COUNT=$(wc -l  < "$MAIN_SZ"  | tr -d ' ')
echo "  $CRC_COUNT modules compared by name + size + CRC"
echo "  $SZ_COUNT  modules compared by name + size only (dts/dtb timestamp sources)"

PASS=1

echo ""
echo "--- name + size + CRC ---"
if diff "$MAIN_CRC" "$FEAT_CRC"; then
    echo "  OK"
else
    PASS=0
fi

echo ""
echo "--- name + size (timestamp modules) ---"
if diff "$MAIN_SZ" "$FEAT_SZ"; then
    echo "  OK"
else
    PASS=0
fi

echo ""
if [ "$PASS" -eq 1 ]; then
    echo "SUCCESS: all OS-9 module sizes and CRCs match."
    echo "The normalizer is semantically neutral — safe to commit."
else
    echo "DIFFERENCES FOUND. The normalizer changed binary output."
    echo "Investigate before committing."
    exit 1
fi
