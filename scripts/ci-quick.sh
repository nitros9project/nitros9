#!/usr/bin/env bash
# Source-level checks without game/language checkouts, disk images, or MAME.
set -euo pipefail
cd "$(dirname "$0")/.."
export NITROS9DIR="$PWD"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

if git grep -n -E '^(<<<<<<< |>>>>>>> |=======$)' -- ':!archive'; then
    echo "Unresolved merge conflict markers found." >&2
    exit 1
fi

printf '%s\n' '.PHONY: ci-parse' 'ci-parse: ; @:' > "$scratch/parse.mak"
while IFS= read -r makefile; do
    make -C "$(dirname "$makefile")" -f makefile -f "$scratch/parse.mak" \
        --no-print-directory -n ci-parse >/dev/null
done < <(git ls-files 'recipes/**/makefile')

python3 -m unittest discover -s scripts -p 'test_*.py'
python3 scripts/test-rfm-fixture.py
if [ -d tests ]; then
    python3 -m unittest discover -s tests -p 'test_*.py'
fi

# Reuse the actual recipe's module lists and flags, with separate scratch
# outputs per profile. Do not build libraries, games, or filesystem images.
cat > "$scratch/modules.mak" <<'MAKE'
.PHONY: ci-modules
ci-modules: $(addprefix $(MODDIR)/,$(KERNEL_TRACK) $(BOOTMODS))
MAKE
for profile in l1-6809 l2-6809 l2-6309; do
    recipe=recipes/coco3/floppy
    if [ "$profile" = l1-6809 ]; then recipe=recipes/coco/floppy; fi
    make -C "$recipe" -f makefile -f "$scratch/modules.mak" \
        MODDIR="$scratch/$profile" CPU="${profile#*-}" ci-modules
    for module in "$scratch/$profile/"*; do
        case "$(basename "$module")" in
            rel|rel_*)
                # CoCo boot tracks prepend six Disk BASIC sync/entry bytes.
                dd if="$module" of="$scratch/rel-module" bs=1 skip=6 2>/dev/null
                module="$scratch/rel-module"
                ;;
        esac
        identification=$(os9 ident "$module")
        if [[ "$identification" != *'(Good)'* || "$identification" == *'(Bad)'* ]]; then
            echo "$identification" >&2
            exit 1
        fi
    done
    echo "PASS: $profile system modules and CRCs"
done

# Included once the Corsham ROM recipe lands; this also guards its size limit.
if [ -f recipes/corsham/makefile ]; then
    make -C recipes/corsham check
fi
