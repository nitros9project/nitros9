#!/usr/bin/env python3
"""fcb2bin.py - extract raw binary from OS-9 FCB-format .asm file.

Usage:
    python3 scripts/fcb2bin.py input.asm output.bin
    python3 scripts/fcb2bin.py input.asm   # writes to stdout
"""

import sys
import re


def parse_fcb_file(path: str) -> bytes:
    data: list[int] = []
    with open(path, 'r', errors='replace') as fh:
        for raw in fh:
            line = raw.rstrip('\r\n')
            # Only care about lines that contain 'fcb' with hex byte values.
            # Handles both "Lhhhh    fcb  $xx,$xx..." and "         fcb  $xx,..."
            m = re.search(
                r'\bfcb\s+(\$[0-9A-Fa-f]{1,2}(?:,\$[0-9A-Fa-f]{1,2})*)',
                line, re.IGNORECASE)
            if not m:
                continue
            for tok in re.findall(r'\$([0-9A-Fa-f]{1,2})', m.group(1)):
                data.append(int(tok, 16))
    return bytes(data)


def main() -> None:
    if len(sys.argv) < 2:
        print(f'Usage: {sys.argv[0]} input.asm [output.bin]', file=sys.stderr)
        sys.exit(1)

    data = parse_fcb_file(sys.argv[1])
    if not data:
        print('No FCB data found', file=sys.stderr)
        sys.exit(1)

    print(f'Extracted {len(data)} bytes', file=sys.stderr)

    if len(sys.argv) >= 3:
        with open(sys.argv[2], 'wb') as fh:
            fh.write(data)
    else:
        sys.stdout.buffer.write(data)


if __name__ == '__main__':
    main()
