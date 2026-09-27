#!/bin/sh
# test-vcon.sh - end-to-end test of the Pico-Thing /V0 video console.
#
# Builds the Level 2 IDE development image (which carries the vcon driver,
# the /V0 descriptor and the gfxtest command), boots it headless under
# usim09pt, logs in over the serial console and runs "gfxtest", which
# opens /V0 and draws a fixed test pattern.  usim09pt rasterises the real
# video-pico firmware, so the screenshot it writes is what the hardware
# would show.  The test then samples the rendered panel with pngpix.py and
# checks that each shape drew in its expected colour.
#
# This is the same gfxtest program that runs on the real board (type
# "gfxtest" at the shell); here it is driven automatically so a regression
# in vcon's byte pipe, the descriptor, or the firmware render path is
# caught without a person watching the screen.
#
# Environment overrides:
#   USIM09PT   path to the usim09pt binary   (default ~/GitHub/usim/usim09pt)
#   NITROS9DIR repository root               (default: two levels above this script)
#   KEEP_SHOT  if set, keep the screenshot and print its path
#
# Exit status: 0 = all shapes rendered correctly, 1 = a check failed,
# 2 = a setup/build/run problem.

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
NITROS9DIR=${NITROS9DIR:-$(CDPATH= cd -- "$script_dir/.." && pwd)}
USIM09PT=${USIM09PT:-$HOME/GitHub/usim/usim09pt}
export NITROS9DIR

recipe="$NITROS9DIR/recipes/picothing/l2"
dsk="$recipe/test-vcon.dsk"
srec="$recipe/rel_picothing.srec"
shot=$(mktemp -t vcon-shot.XXXXXX).png
log=$(mktemp -t vcon-log.XXXXXX)

cleanup() {
    killall usim09pt 2>/dev/null || true
    rm -f "$dsk"
    if [ -n "${KEEP_SHOT:-}" ]; then
        echo "screenshot kept at $shot"
        rm -f "$log"
    else
        rm -f "$shot" "$log"
    fi
}
trap cleanup EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

[ -x "$USIM09PT" ] || { echo "usim09pt not found at $USIM09PT (set USIM09PT)" >&2; exit 2; }

echo "Building the Level 2 video-console test image..."
make -C "$recipe" DSKIMAGE="test-vcon.dsk" \
     OS9FORMAT_CMD="os9 format -e -l65536" >/dev/null
make -C "$recipe" rel_picothing.srec >/dev/null
[ -f "$srec" ] || { echo "firmware srec not built at $srec" >&2; exit 2; }

echo "Booting headless and running gfxtest..."
killall usim09pt 2>/dev/null || true
sleep 1
# Log in with an empty username (blank-name superuser), run gfxtest, then
# echo a marker so the log proves gfxtest returned to the shell cleanly.
"$USIM09PT" --timeout=200000000 \
    --input-first=95000000 --input-step=400000 \
    --input="$(printf '\r\r\rgfxtest\recho GFXDONE\r')" \
    --screenshot="$shot" \
    -d "$dsk" "$srec" >"$log" 2>&1 &

until grep -aqiE 'timeout after|POST-MORTEM' "$log" || ! pgrep -x usim09pt >/dev/null; do
    sleep 5
done
killall usim09pt 2>/dev/null || true

# gfxtest must have run and returned to the shell without an error report.
# GFXDONE proves the shell reached the command after it; a clean dev boot
# prints no "Error #..." line, so any such line is a real failure.
grep -aq 'GFXDONE' "$log" || fail "gfxtest never returned to the shell (no GFXDONE marker)"
if grep -aq 'Error #' "$log"; then
    echo "--- console log ---" >&2
    grep -aiE 'gfxtest|Error #' "$log" | cat -v >&2
    fail "the shell reported an error running gfxtest"
fi
[ -f "$shot" ] || fail "usim09pt wrote no screenshot"

# Sample the rendered panel.  Each entry is "x,y r g b" - the interior of
# a solid shape drawn by gfxtest, or a background point.  Coordinates are
# in the 1024x480 panel; colours are what the firmware LUT produces for the
# gfxtest palette (yellow reg 1, grey reg 2, white reg 3).  A change here
# means the render path changed - re-run and update after confirming the
# new picture is correct.
TOL=12
checks="
200,150 255 255 0   yellow-bar
500,150 73 73 85    grey-bar
50,50 255 255 255   white-box-corner
900,450 0 0 0       black-background
"

coords=$(echo "$checks" | awk 'NF{print $1}')
# shellcheck disable=SC2086
got=$(python3 "$script_dir/pngpix.py" "$shot" $coords) || fail "could not read the screenshot"

fails=0
while read -r xy er eg eb label; do
    [ -n "${xy:-}" ] || continue
    line=$(echo "$got" | awk -v k="$xy" '$1==k{print; exit}')
    ar=$(echo "$line" | awk '{print $2}')
    ag=$(echo "$line" | awk '{print $3}')
    ab=$(echo "$line" | awk '{print $4}')
    ok=$(awk -v ar="$ar" -v ag="$ag" -v ab="$ab" \
             -v er="$er" -v eg="$eg" -v eb="$eb" -v t="$TOL" \
        'function d(a,b){return a>b?a-b:b-a}
         BEGIN{print (d(ar,er)<=t && d(ag,eg)<=t && d(ab,eb)<=t) ? "y" : "n"}')
    if [ "$ok" = y ]; then
        printf '  ok   %-18s at %-9s = %s,%s,%s\n' "$label" "$xy" "$ar" "$ag" "$ab"
    else
        printf '  BAD  %-18s at %-9s = %s,%s,%s (expected %s,%s,%s +/-%s)\n' \
            "$label" "$xy" "$ar" "$ag" "$ab" "$er" "$eg" "$eb" "$TOL" >&2
        fails=$((fails + 1))
    fi
done <<EOF
$checks
EOF

[ "$fails" -eq 0 ] || fail "$fails shape(s) did not render in the expected colour"

echo "PASS: /V0 rendered gfxtest's pattern correctly (yellow bar, grey bar, white box)."
