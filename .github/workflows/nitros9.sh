#!/bin/bash
#
# Build the primary NitrOS-9 product recipes from source
#
ls -al
export NITROS9DIR="$(pwd)"

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
