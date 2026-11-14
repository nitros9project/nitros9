#!/usr/bin/env bash
# Boot a freshly built floppy and require a result written by the guest shell.
set -euo pipefail
cpu=${1:?Usage: mame-boot-smoke.sh CPU ROMPATH OUTPUT_DIR}
rompath=$(cd "${2:?ROM directory required}" && pwd)
mkdir -p "${3:?Output directory required}"
output=$(cd "$3" && pwd)
case "$cpu" in
    6809) machine=coco3 ;;
    6309) machine=coco3h ;;
    *) echo "Unsupported CPU: $cpu" >&2; exit 1 ;;
esac
mame_binary=${MAME_BINARY:-mame}
export NITROS9DIR="$(pwd)"
recipe=recipes/coco3/floppy
printf 'link shell\nload utilpak1\necho NITROS9-BOOT-%s >/dd/ci-result\n' "$cpu" > "$output/startup"
make -C "$recipe" clean
make -C "$recipe" CPU="$cpu" STARTUP="$output/startup" > "$output/build.log" 2>&1
cp "$recipe/l2_coco3.dsk" "$output/test.dsk"
python3 "$NITROS9DIR/scripts/mame-rgb.py" --machine "$machine" --config "$output/cfg"
"$mame_binary" -help > "$output/mame-version.txt"
"$mame_binary" "$machine" -rompath "$rompath" -verifyroms > "$output/rom-audit.log" 2>&1
# Audit the controller ROMs too (system-only audits omit expansion devices).
"$mame_binary" coco_fdc -rompath "$rompath" -verifyroms >> "$output/rom-audit.log" 2>&1
cat > "$output/boot.lua" <<'LUA'
emu.keypost("DOS\n")
local frames = 0
emu.register_frame_done(function()
    frames = frames + 1
    if frames % 300 == 0 then
        manager.machine.screens[":screen"]:snapshot("screen.png")
    end
end)
LUA
# Run in the output directory so screenshots and MAME state stay with the logs.
(
    cd "$output"
    timeout 180 "$mame_binary" "$machine" -rompath "$rompath" \
        -cfg_directory cfg -nvram_directory nvram -snapshot_directory snap \
        -skip_gameinfo -sound none -video soft -window -nothrottle -ram 512K \
        -ext fdc,bios=v11 -ext:fdc:wd17xx:0 525qd \
        -flop1 test.dsk -autoboot_delay 3 -autoboot_script boot.lua \
        -seconds_to_run 90 > mame.log 2>&1
)
# MAME exiting successfully alone does not prove OS-9 booted.
os9 copy "$output/test.dsk,ci-result" "$output/result.txt"
# ShellPlus echo leaves a trailing space before the OS-9 carriage return.
tr -d ' \r\n' < "$output/result.txt" > "$output/result-normalized.txt"
if [[ $(cat "$output/result-normalized.txt") != "NITROS9-BOOT-$cpu" ]]; then
    echo "Guest boot marker missing or incorrect for CPU=$cpu" >&2
    exit 1
fi
echo "PASS: $machine booted OS-9 and wrote the CPU=$cpu marker to floppy"
