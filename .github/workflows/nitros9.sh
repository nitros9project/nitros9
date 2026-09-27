#!/bin/bash
#
# Build the primary NitrOS-9 product recipes from source
#
ls -al
export NITROS9DIR="$(pwd)"
# The workflow checks nitros9-languages out inside the workspace, but this
# script runs under sudo, which drops the workflow's LANGUAGES setting, and
# the recipes otherwise look for the checkout beside NITROS9DIR.
if [ -d "$NITROS9DIR/nitros9-languages" ]; then
    export LANGUAGES="$NITROS9DIR/nitros9-languages"
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
