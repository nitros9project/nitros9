#!/usr/bin/env bash
# Install the pinned Linux x86-64 toolchain into a writable cache directory.
set -euo pipefail
prefix=${1:?Usage: setup-ci-tools.sh PREFIX}
mkdir -p "$prefix/bin"
prefix=$(cd "$prefix" && pwd)
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
cd "$scratch"

curl --fail --location --retry 3 --max-time 120 \
    https://www.lwtools.ca/releases/lwtools/lwtools-4.25.tar.gz -o lwtools.tar.gz
curl --fail --location --retry 3 --max-time 120 \
    https://github.com/nitros9project/toolshed/releases/download/v2.6.1/toolshed-unix64-2.6.1.tgz \
    -o toolshed.tgz
sha256sum --check <<'HASHES'
9bb97e987d486d7abd85d04cb98a53f666f02785c108647b795c4a111c5eb09f  lwtools.tar.gz
aedf80da28fd82a1931de73e0823d86a9e5dbad3b7856b81308abe9ddbf48ab5  toolshed.tgz
HASHES

tar xzf lwtools.tar.gz
make -C lwtools-4.25 -j2 PREFIX="$prefix" install
# Recipes need the OS-9 command suite and Sierra's host table generator.
tar xzf toolshed.tgz --strip-components=1 -C "$prefix/bin" \
    toolshed-2.6.1/os9 toolshed-2.6.1/tocgen
chmod +x "$prefix/bin/os9" "$prefix/bin/tocgen"
