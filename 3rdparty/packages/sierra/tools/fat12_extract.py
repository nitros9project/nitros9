#!/usr/bin/env python3
"""
fat12_extract.py — Minimal pure-Python FAT12 floppy-image reader.

Extracts files named SNDDIR or VOL.* (case-insensitive) from one or
more raw .img floppy images into an output directory.  Sufficient for
classic Sierra AGI install disks (360 KB / 720 KB / 1.44 MB FAT12).

Usage:
    python3 fat12_extract.py --out ~/kingsquest1-pcassets \\
        disk1.img [disk2.img ...]
"""
from __future__ import annotations

import argparse
import os
import struct
import sys
from pathlib import Path


def read_bpb(img: bytes):
    """Decode the BIOS Parameter Block from a FAT12 boot sector."""
    if len(img) < 512:
        raise ValueError('image too small to be a floppy')
    # Standard DOS 3.x BPB layout
    bytes_per_sector = struct.unpack_from('<H', img, 11)[0]
    sectors_per_cluster = img[13]
    reserved_sectors = struct.unpack_from('<H', img, 14)[0]
    num_fats = img[16]
    root_entries = struct.unpack_from('<H', img, 17)[0]
    total_sectors_16 = struct.unpack_from('<H', img, 19)[0]
    sectors_per_fat = struct.unpack_from('<H', img, 22)[0]
    return dict(
        bps=bytes_per_sector,
        spc=sectors_per_cluster,
        reserved=reserved_sectors,
        nfats=num_fats,
        root_entries=root_entries,
        total_sectors=total_sectors_16,
        spf=sectors_per_fat,
    )


def read_fat12(fat_bytes: bytes, n: int) -> int:
    """Return FAT12 entry n (12-bit cluster number)."""
    off = (n * 3) // 2
    raw = fat_bytes[off] | (fat_bytes[off + 1] << 8)
    if n & 1:
        return raw >> 4
    return raw & 0xFFF


def chain(fat_bytes: bytes, start: int):
    """Yield cluster numbers in a FAT12 chain."""
    c = start
    while c != 0 and c < 0xFF0:
        yield c
        c = read_fat12(fat_bytes, c)


def parse_root_dir(img: bytes, bpb: dict):
    """Yield (name, attr, first_cluster, size) for each root directory entry."""
    root_start = (bpb['reserved'] + bpb['nfats'] * bpb['spf']) * bpb['bps']
    root_size = bpb['root_entries'] * 32
    root = img[root_start:root_start + root_size]
    for off in range(0, len(root), 32):
        e = root[off:off + 32]
        if e[0] == 0x00:
            break  # end of directory
        if e[0] == 0xE5:
            continue  # deleted
        attr = e[11]
        if attr & 0x08:  # volume label
            continue
        if attr & 0x10:  # subdirectory
            continue
        # Decode 8.3 filename
        name8 = e[0:8].decode('ascii', errors='replace').rstrip()
        ext3 = e[8:11].decode('ascii', errors='replace').rstrip()
        if ext3:
            name = f'{name8}.{ext3}'
        else:
            name = name8
        first_cluster = struct.unpack_from('<H', e, 26)[0]
        size = struct.unpack_from('<I', e, 28)[0]
        yield name, attr, first_cluster, size


def read_file(img: bytes, bpb: dict, fat_bytes: bytes,
              first_cluster: int, size: int) -> bytes:
    cluster_bytes = bpb['spc'] * bpb['bps']
    data_start = (bpb['reserved'] + bpb['nfats'] * bpb['spf']) * bpb['bps'] \
        + bpb['root_entries'] * 32
    out = bytearray()
    for c in chain(fat_bytes, first_cluster):
        # FAT clusters start numbering at 2
        sector_off = data_start + (c - 2) * cluster_bytes
        out.extend(img[sector_off:sector_off + cluster_bytes])
    return bytes(out[:size])


def want_file(name: str) -> bool:
    """Match SNDDIR or VOL.* (case-insensitive)."""
    u = name.upper()
    if u == 'SNDDIR':
        return True
    if u.startswith('VOL.'):
        return True
    return False


def process_image(img_path: Path, out_dir: Path, verbose: bool) -> int:
    img = img_path.read_bytes()
    bpb = read_bpb(img)
    fat_start = bpb['reserved'] * bpb['bps']
    fat_bytes = img[fat_start:fat_start + bpb['spf'] * bpb['bps']]

    count = 0
    for name, attr, first, size in parse_root_dir(img, bpb):
        if not want_file(name):
            if verbose:
                print(f'  skip {name}  ({size} B)')
            continue
        data = read_file(img, bpb, fat_bytes, first, size)
        out_name = name.upper()
        out_path = out_dir / out_name
        # If a same-named file already exists, prefer larger one
        if out_path.exists() and out_path.stat().st_size >= len(data):
            if verbose:
                print(f'  keep existing {out_name}  '
                      f'({out_path.stat().st_size} >= {len(data)})')
            continue
        out_path.write_bytes(data)
        print(f'  wrote {out_name}  ({len(data):,} B)  '
              f'from {img_path.name}')
        count += 1
    return count


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('images', nargs='+', help='floppy .img files (FAT12)')
    ap.add_argument('--out', required=True, help='output directory')
    ap.add_argument('-v', '--verbose', action='store_true')
    args = ap.parse_args()

    out_dir = Path(args.out).expanduser()
    out_dir.mkdir(parents=True, exist_ok=True)

    total = 0
    for img_str in args.images:
        img_path = Path(img_str)
        if not img_path.is_file():
            print(f'skipping (not a file): {img_path}', file=sys.stderr)
            continue
        print(f'\n[{img_path}]')
        total += process_image(img_path, out_dir, args.verbose)

    print(f'\nDone.  {total} file(s) extracted to {out_dir}')
    print('Contents:')
    for p in sorted(out_dir.iterdir()):
        if p.is_file():
            print(f'  {p.name:<10}  {p.stat().st_size:,} B')
    return 0


if __name__ == '__main__':
    sys.exit(main())
