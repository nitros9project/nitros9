#!/usr/bin/env bash
# Run every deterministic filesystem CPU suite, preserving independent failures.
set -euo pipefail
cd "$(dirname "$0")/.."
export NITROS9DIR="$PWD"
output=${1:?Usage: ci-filesystems.sh OUTPUT_DIR}
mkdir -p "$output"
output=$(cd "$output" && pwd)
python=${PYTHON:-python3}
status=0
tests=(
    test-fat32-image test-blkdrv test-cocovhd test-fat32 test-pcf-write test-pcf-rename
    test-pcf-review test-pcf-parent-time test-boot-fat32 test-readdir
    test-deldir test-rename test-rfm test-rfm-fixture
)
for test in "${tests[@]}"; do
    echo "Running $test"
    if ! "$python" -u "scripts/$test.py" 2>&1 | tee "$output/$test.log"; then
        status=1
    fi
done

# Retain fixed regression seeds and add a daily seed with replay evidence.
seed=${RANDOM_SEED:-$(date -u +%Y%m%d)}
if "$python" scripts/make-fat32-image.py "$output/random-base.vhd" \
    2>&1 | tee "$output/random-prepare.log"; then
    if ! "$python" -u scripts/test-pcf-random.py \
        --image "$output/random-base.vhd" --output "$output/random" \
        --steps "${RANDOM_CPU_STEPS:-150}" --seeds 17 20261108 "$seed" \
        --fsck "${FAT_CHECK:-fsck.fat}" 2>&1 | tee "$output/random.log"; then
        status=1
    fi
else
    status=1
fi
exit "$status"
