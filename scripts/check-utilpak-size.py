#!/usr/bin/env python3
"""Keep a resident utility bundle within one 8K block minus 512 bytes."""
import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('bundle', type=Path)
    args = parser.parse_args()
    limit = 8192 - 512
    size = args.bundle.stat().st_size
    if size > limit:
        parser.exit(1, f'{args.bundle}: {size} bytes exceeds the {limit}-byte '
                    f'utilpak1 budget by {size-limit} bytes\n')
    print(f'PASS: utilpak1 {size}/{limit} bytes ({limit-size} bytes free)')


if __name__ == '__main__':
    main()
