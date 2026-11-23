#!/usr/bin/env bash
# Install smoke-test dependencies without relying on the runner's Azure mirror.
set -euo pipefail
scratch=$(mktemp -d)
trap 'sudo rm -rf "$scratch"' EXIT
chmod 755 "$scratch"
mkdir -p "$scratch/lists/partial"

# Isolate both sources and indexes. A failed update must not silently reuse
# stale indexes from the runner's original repositories.
apt_options=(
    -o "Dir::Etc::sourcelist=$scratch/sources.list"
    -o 'Dir::Etc::sourceparts=-'
    -o "Dir::State::lists=$scratch/lists"
    -o 'Acquire::ForceIPv4=true'
    -o 'Acquire::http::Timeout=15'
    -o 'Acquire::https::Timeout=15'
    -o 'Acquire::Retries=1'
    -o 'APT::Update::Error-Mode=any'
)
for mirror in https://archive.ubuntu.com/ubuntu https://us.archive.ubuntu.com/ubuntu; do
    echo "Installing MAME using $mirror"
    cat > "$scratch/sources.list" <<EOF
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] $mirror noble main universe
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] $mirror noble-updates main universe
deb [signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg] $mirror noble-security main universe
EOF
    if sudo timeout 90 apt-get "${apt_options[@]}" update &&
       sudo timeout 180 apt-get "${apt_options[@]}" install -y mame xvfb xauth; then
        exit 0
    fi
    echo "MAME installation failed using $mirror; trying the next mirror." >&2
done
echo 'Unable to install MAME from either Ubuntu mirror.' >&2
exit 1
