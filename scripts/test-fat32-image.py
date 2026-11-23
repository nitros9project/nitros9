#!/usr/bin/env python3
"""Reject a malformed test volume before executing any file-manager code."""
from pathlib import Path
import subprocess
import sys
import tempfile


def main():
    with tempfile.TemporaryDirectory() as directory:
        image = Path(directory) / 'fixture.vhd'
        subprocess.run([sys.executable, str(Path(__file__).with_name('make-fat32-image.py')),
                        str(image)], check=True)
        with image.open('rb') as stream:
            boot = stream.read(512)
            backup = int.from_bytes(boot[50:52], 'little')
            stream.seek(backup * 512)
            assert stream.read(512)[71:82] == boot[71:82], 'boot volume labels differ'
            reserved = int.from_bytes(boot[14:16], 'little')
            fat_size = int.from_bytes(boot[36:40], 'little')
            root = int.from_bytes(boot[44:48], 'little')
            root_sector = reserved + boot[16] * fat_size + (root - 2) * boot[13]
            stream.seek(root_sector * 512)
            entries = stream.read(boot[13] * 512)
            labels = [entries[i:i+11] for i in range(0, len(entries), 32)
                      if entries[i+11] == 8]
            assert labels == [boot[71:82]], (labels, boot[71:82])
        print('PASS: generated FAT32 root and both boot volume labels agree')


if __name__ == '__main__':
    main()
