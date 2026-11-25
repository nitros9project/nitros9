#!/usr/bin/env bash
# Keep independent integrations in separate CI jobs, using their full recipes.
set -euo pipefail
cd "$(dirname "$0")/.."
export NITROS9DIR="$PWD"
suite=${1:?Usage: ci-filesystems-mame.sh SUITE}
platform=${FILESYSTEM_PLATFORM:-l2-${CPU:-6809}}
case "$platform" in
    l1-coco) level=1; cpu=6809; machine=coco ;;
    l1-coco2b) level=1; cpu=6809; machine=coco2b ;;
    l2-6809) level=2; cpu=6809; machine=coco3 ;;
    l2-6309) level=2; cpu=6309; machine=coco3h ;;
    *) echo "Unknown filesystem platform: $platform" >&2; exit 2 ;;
esac
if [[ "$suite" == module-groups && "$level" != 2 ]]; then
    echo "DAT mapping tests require Level Two; Level One has no DAT mappings" >&2
    exit 2
fi
common=("CPU=$cpu" "LEVEL=$level" "MAME_MACHINE=$machine" "PYTHON=${PYTHON:-python3}" "MAME_BINARY=${MAME_BINARY:-mame}"
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
    module-groups) make -C recipes/coco3/module_group_mame_test "${common[@]}" check ;;
    rbf) make -C recipes/coco3/rbf_mame_test "${common[@]}" check ;;
    rfm) make -C recipes/coco3/rfm_mame_test "${common[@]}" check ;;
    rfm-irq)
        make -C recipes/coco3/rfm_mame_test "${common[@]}" \
            TEST_SUITE=directories TEST_IRQ_STRESS=1 check
        ;;
    *) echo "Unknown filesystem suite: $suite" >&2; exit 2 ;;
esac
