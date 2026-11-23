#!/usr/bin/env bash
# Keep independent integrations in separate CI jobs, using their full recipes.
set -euo pipefail
cd "$(dirname "$0")/.."
export NITROS9DIR="$PWD"
suite=${1:?Usage: ci-filesystems-mame.sh SUITE}
common=("PYTHON=${PYTHON:-python3}" "MAME_BINARY=${MAME_BINARY:-mame}"
    "MAME_ROMPATH=${MAME_ROMPATH:?MAME_ROMPATH is required}" "FAT_CHECK=${FAT_CHECK:-fsck.fat}")
case "$suite" in
    pcf-write)
        # These are all PCF goals from check-all; RBF has its own independent job.
        make -C recipes/coco3/pcf_write_mame_test "${common[@]}" \
            "RANDOM_SEED=${RANDOM_SEED:-$(date -u +%Y%m%d)}" \
            check check-rename check-review check-random
        ;;
    pcf-readonly) make -C recipes/coco3/fat_root_mame_test "${common[@]}" check ;;
    pcf-floppy) make -C recipes/coco3/fat_mame_test "${common[@]}" check ;;
    pcf-boot) make -C recipes/coco3/fat_boot_mame_test "${common[@]}" check ;;
    rbf) make -C recipes/coco3/rbf_mame_test "${common[@]}" check ;;
    rfm) make -C recipes/coco3/rfm_mame_test "${common[@]}" check ;;
    rfm-irq)
        make -C recipes/coco3/rfm_mame_test "${common[@]}" \
            TEST_SUITE=directories TEST_IRQ_STRESS=1 check
        ;;
    *) echo "Unknown filesystem suite: $suite" >&2; exit 2 ;;
esac
