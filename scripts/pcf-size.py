#!/usr/bin/env python3
"""Report PCF section sizes from lwasm --symbol-dump output (module offsets).

Example: python3 scripts/pcf-size.py after.sym --before before.sym
The symbols must come from matching CPU/OS-level build configurations.
"""
import argparse
from pathlib import Path
import re

SECTIONS = (
    ('Header, dispatch, errors, arithmetic', None),
    ('Driver calls and sector caches', 'Driver'),
    ('Mount and geometry validation', 'Mount'),
    ('Cluster traversal and cycle checks', 'AddBase'),
    ('Open/create setup and pathname parsing', 'CreateImpl'),
    ('Directory lookup and entry adoption', 'Lookup'),
    ('Read, ReadLn, directory records, path lifecycle', 'ChgDirImpl'),
    ('Status, SS.ReadDir, OS-9 metadata', 'GetStatImpl'),
    ('Operation lock, sharing, write permissions', '_sharing'),
    ('Write geometry, block I/O, FAT/FSInfo updates', 'MountWriteInfo'),
    ('Cluster allocation and freeing', 'ClusterBase'),
    ('Timestamps, directory updates, create/grow', 'Stamp'),
    ('Write, WriteLn, zero-filled gaps', '_write'),
    ('Delete and file resizing', 'DeleteImpl'),
    ('WriteLn terminator scan', 'WriteLineCount'),
    ('Directory creation', 'MkDirImpl'),
    ('Directory removal and in-use checks', 'RemovableDirectory'),
    ('Same-directory rename and name validation', 'RenameEntry'),
    ('Module CRC', '_crc'),
)

def sizes(path):
    symbols = {n: int(v, 16) for n, v in re.findall(
        r'^(\S+) (?:EQU|SET) \$([\da-fA-F]+)$', path.read_text(), re.M)}
    symbols['_crc'] = symbols['eom'] - 3
    # Compact dispatch lives in the header; older builds put wrappers here.
    symbols['_sharing'] = (symbols['Create'] if symbols['Create'] > symbols['GetStatImpl']
                           else symbols['Writable'])
    symbols['_write'] = (symbols['MoveIn'] if symbols['MoveIn'] > symbols['Stamp']
                         else symbols['WriteImpl'])
    symbols.setdefault('MkDirImpl', symbols['_crc'])
    symbols.setdefault('RemovableDirectory', symbols['_crc'])
    symbols.setdefault('RenameEntry', symbols['_crc'])
    starts = [symbols[n] if n else 0 for _, n in SECTIONS] + [symbols['eom']]
    assert starts == sorted(starts), 'section boundaries are out of order'
    return [b-a for a,b in zip(starts,starts[1:])]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('symbols', type=Path)
    parser.add_argument('--before', type=Path)
    args = parser.parse_args()
    after = sizes(args.symbols)
    before = sizes(args.before) if args.before else None
    print('| Section | Bytes |' if before is None else '| Section | Before | After | Saved |')
    print('|---|---:|' if before is None else '|---|---:|---:|---:|')
    for i,(label,_) in enumerate(SECTIONS):
        print(f'| {label} | {after[i]:,} |' if before is None else
              f'| {label} | {before[i]:,} | {after[i]:,} | {before[i]-after[i]:,} |')
    print(f'| **Total** | **{sum(after):,}** |' if before is None else
          f'| **Total** | **{sum(before):,}** | **{sum(after):,}** | **{sum(before)-sum(after):,}** |')

if __name__ == '__main__':
    main()
