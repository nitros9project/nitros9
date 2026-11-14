#!/bin/bash
#
# Build the primary NitrOS-9 product recipes from source
#
set -euo pipefail

ls -al
export NITROS9DIR="$(pwd)"
# The workflow checks nitros9-languages out inside the workspace, but this
# script runs under sudo, which drops the workflow's LANGUAGES setting, and
# the recipes otherwise look for the checkout beside NITROS9DIR.
if [ -d "$NITROS9DIR/nitros9-languages" ]; then
    export LANGUAGES="$NITROS9DIR/nitros9-languages"
fi
if [ -d "$NITROS9DIR/nitros9-games" ]; then
    export NITROS9_GAMES_DIR="$NITROS9DIR/nitros9-games"
fi

# Catch unresolved merges and makefile parse failures in every recipe, including
# optional recipes that are too expensive or dependency-heavy for routine CI.
if git grep -n -E '^(<<<<<<< |>>>>>>> |=======$)' -- ':!archive'; then
    echo "Unresolved merge conflict markers found."
    exit 1
fi

while IFS= read -r makefile; do
    recipe_dir="$(dirname "$makefile")"
    make -C "$recipe_dir" --no-print-directory -n clean >/dev/null
done < <(find recipes -mindepth 2 -maxdepth 3 -name makefile -print | sort)

make -C recipes/coco/floppy
make -C recipes/coco/dw
make -C recipes/coco3/floppy
make -C recipes/coco3/dw

# CPU variants share intermediate paths, so rebuild from clean directories.
for recipe in recipes/coco3/floppy recipes/coco3/dw; do
    make -C "$recipe" clean
    make -C "$recipe" CPU=6309
done

# Check launcher selection without starting MAME or rebuilding the disk image.
for cpu in 6809 6309; do
    machine=coco3
    if [ "$cpu" = 6309 ]; then
        machine=coco3h
    fi
    launch=$(make -s -C recipes/coco3/floppy -n run CPU="$cpu" \
        MAME_BINARY=mame -o l2_coco3.dsk | awk '/^mame /')
    if [[ "$launch" != "mame $machine "* ]]; then
        echo "Unexpected MAME launch command for CPU=$cpu: $launch" >&2
        exit 1
    fi
done

make -C recipes/picothing/l1
make -C recipes/picothing/l1_6309
make -C recipes/picothing/l1dw
make -C recipes/picothing/l1dw_6309
make -C recipes/picothing/l2
make -C recipes/picothing/l2_6309
make -C recipes/picothing/l2dw
make -C recipes/picothing/l2dw_6309
make -C recipes/picothing/l2_mega
make -C recipes/picothing/l2_mega_6309
make -C recipes/picothing/l2dw_mega
make -C recipes/picothing/l2dw_mega_6309

# Representative assembly, asset-heavy, and Sierra builds from games/main.
for game in rogue arcadepak christmas86; do
    for cpu in 6809 6309; do
        make -C recipes/coco3/games GAME="$game" CPU="$cpu"
    done
done
