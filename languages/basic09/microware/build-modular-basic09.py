#!/usr/bin/env python3
"""Build combined Basic09/RunB OS9 module from modular source files."""

import os
import struct
import subprocess
import sys


def header_parity(image):
    xor = 0
    for b in image[:8]:
        xor ^= b
    return xor ^ 0xff


def module_crc(data, length):
    accum = 0xffffff
    for i in range(length):
        accum &= 0x00ffffff
        b = data[i] << 16
        b ^= accum
        accum = (accum << 8) & 0xffffffff
        b >>= 16
        bits = bin(b).count('1')
        accum ^= (b << 1) ^ (b << 6)
        if bits & 1:
            accum ^= 0x00800021
    return accum & 0x00ffffff


def main():
    if len(sys.argv) < 3:
        print(f"usage: {sys.argv[0]} basic09|runb output [lwasm-defs...]", file=sys.stderr)
        sys.exit(1)

    mode, outfile, *extra_defs = sys.argv[1:]

    if mode not in ('basic09', 'runb'):
        print("mode must be basic09 or runb", file=sys.stderr)
        sys.exit(1)

    here = os.path.dirname(os.path.abspath(sys.argv[0]))
    nitros9_dir = os.environ.get('NITROS9DIR')
    if not nitros9_dir:
        sys.exit("NITROS9DIR must point to a NitrOS-9 source checkout")
    defs_dir = os.path.join(os.path.abspath(nitros9_dir), 'defs')
    src = here
    outdir = os.path.abspath(os.path.dirname(outfile))
    build = os.path.join(outdir, '.modular-build', mode)
    os.makedirs(build, exist_ok=True)

    modules = ['comand', 'compil', 'binder', 'stmts', 'exprsn', 'cnvio']

    defs = ['-DNOS9VER=', '-DNOS9MAJ=', '-DNOS9MIN=']
    if mode == 'runb':
        defs.append('-DINCLUDED=6')  # RUNTIM+MATHPAK; expression form evaluates before b09type defines the symbols
    defs.extend(extra_defs)

    objs = []
    for module in modules:
        obj = os.path.join(build, module)
        cmd = [
            'lwasm',
            '--no-warn=ifp1',
            '--6309',
            '--format=os9',
            '--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
            f'--includedir={src}',
            f'--includedir={defs_dir}',
            *defs,
            f'-o{obj}',
            os.path.join(src, f'{module}.asm'),
        ]
        result = subprocess.run(cmd)
        if result.returncode != 0:
            sys.exit(f"failed assembling {module}")
        objs.append(obj)

    image = bytearray()
    starts = []
    for obj in objs:
        starts.append(len(image))
        with open(obj, 'rb') as f:
            image += f.read()

    size = len(image)
    if size > 0xffff:
        sys.exit(f"modular output is too large: {size}")

    struct.pack_into('>H', image, 0x02, size)

    for i in range(1, len(starts)):
        struct.pack_into('>H', image, 0x0d + i * 2, starts[i])

    image[0x08] = header_parity(image)

    crc = module_crc(image, size - 3) ^ 0xffffff
    image[size - 3] = (crc >> 16) & 0xff
    image[size - 2] = (crc >> 8) & 0xff
    image[size - 1] = crc & 0xff

    if module_crc(image, size) != 0x800fe3:
        sys.exit("internal CRC failure")

    with open(outfile, 'wb') as f:
        f.write(image)


if __name__ == '__main__':
    main()
