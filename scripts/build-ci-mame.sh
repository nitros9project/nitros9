#!/usr/bin/env bash
# Build the CoCo subset of MAME 0.289 from the official release commit.
set -euo pipefail
prefix=${1:?Usage: build-ci-mame.sh PREFIX}
mkdir -p "$prefix/bin" "$prefix/libexec"
prefix=$(cd "$prefix" && pwd)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

git -c http.lowSpeedLimit=1024 -c http.lowSpeedTime=60 clone \
    --depth 1 --branch mame0289 https://github.com/mamedev/mame.git "$scratch/mame"
commit=f34f02505e32c1993c6a782b6814232cbfc74e36
if [[ $(git -C "$scratch/mame" rev-parse HEAD) != "$commit" ]]; then
    echo 'MAME release tag does not match the pinned 0.289 commit.' >&2
    exit 1
fi
make -C "$scratch/mame" -j2 \
    SUBTARGET=nitros9 SOURCES=src/mame/trs/coco12.cpp,src/mame/trs/coco3.cpp \
    USE_QTDEBUG=0 NO_USE_PORTAUDIO=1 NO_USE_PULSEAUDIO=1 NO_USE_PIPEWIRE=1 \
    NO_USE_MIDI=1 USE_TAPTUN=0 USE_PCAP=0 SYMBOLS=0 OPTIMIZE=2
install -m755 "$scratch/mame/nitros9" "$prefix/libexec/mame"
cp -R "$scratch/mame/plugins" "$prefix/plugins"
cp "$scratch/mame/COPYING" "$prefix/COPYING"
cat > "$prefix/bin/mame" <<'WRAPPER'
#!/usr/bin/env bash
set -euo pipefail
mame_root=$(cd "$(dirname "$0")/.." && pwd)
exec "$mame_root/libexec/mame" -pluginspath "$mame_root/plugins" "$@"
WRAPPER
chmod +x "$prefix/bin/mame"
"$prefix/bin/mame" -version | tee "$prefix/version.txt"
grep -Eq '^0\.289([[:space:]]|$)' "$prefix/version.txt"
