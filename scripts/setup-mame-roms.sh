#!/usr/bin/env bash
# Only the preparation job may contact the ROM host. Consumers verify artifacts.
set -euo pipefail
rom_dir=${1:?Usage: setup-mame-roms.sh DIRECTORY [--verify-only]}
mode=${2:-download}
case "$mode" in download|--verify-only) ;; *) echo "Unknown mode: $mode" >&2; exit 2 ;; esac
manifest=$(cd "$(dirname "$0")" && pwd)/mame-roms.sha256
mkdir -p "$rom_dir"
cd "$rom_dir"
verify_archive() {
    printf '%s  %s\n' "$1" "$2" | sha256sum --check - > /dev/null
}
if [ "$mode" != --verify-only ]; then
    while read -r checksum archive; do
        if verify_archive "$checksum" "$archive" 2>/dev/null; then
            echo "Using verified cached ROM: $archive"
            continue
        fi
        echo "Downloading ROM: $archive"
        temporary=$(mktemp "${archive}.XXXXXX")
        trap 'rm -f "$temporary"' EXIT
        curl --ipv4 --fail --location --retry 3 --retry-all-errors \
            --connect-timeout 10 --max-time 60 \
            "https://colorcomputerarchive.com/repo/ROMs/MAME-MESS/$archive" -o "$temporary"
        verify_archive "$checksum" "$temporary"
        mv "$temporary" "$archive"
        trap - EXIT
    done < "$manifest"
fi
sha256sum --check "$manifest"
