#!/usr/bin/env python3
"""Print the RGB value of one or more pixels in a PNG.

A tiny, dependency-free PNG reader (Python standard library only) used by
scripts/test-vcon.sh to sample the video-console screenshot that usim09pt
writes.  It decodes 8-bit non-interlaced PNGs of colour type 0 (grey),
2 (RGB), 4 (grey+alpha) or 6 (RGBA) -- which is what usim09pt emits -- and
prints one "x,y R G B" line per requested coordinate.

Usage:  pngpix.py IMAGE.png X,Y [X,Y ...]
"""

import struct
import sys
import zlib


def _paeth(a, b, c):
    p = a + b - c
    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


def load_rgb(path):
    """Return (width, height, pixels) where pixels[y][x] = (r, g, b)."""
    data = open(path, "rb").read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG file")
    pos = 8
    width = height = depth = colour = None
    raw = b""
    while pos < len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        ctype = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + length]
        pos += 12 + length          # length + type + body + CRC
        if ctype == b"IHDR":
            width, height, depth, colour, _comp, _filt, interlace = \
                struct.unpack(">IIBBBBB", body)
            if depth != 8:
                raise ValueError("only 8-bit PNGs are supported")
            if interlace:
                raise ValueError("interlaced PNGs are not supported")
        elif ctype == b"IDAT":
            raw += body
        elif ctype == b"IEND":
            break
    channels = {0: 1, 2: 3, 4: 2, 6: 4}[colour]
    stride = width * channels
    buf = zlib.decompress(raw)
    prev = bytearray(stride)
    rows = []
    src = 0
    for _ in range(height):
        ftype = buf[src]
        src += 1
        line = bytearray(buf[src:src + stride])
        src += stride
        for i in range(stride):
            a = line[i - channels] if i >= channels else 0
            b = prev[i]
            c = prev[i - channels] if i >= channels else 0
            if ftype == 1:
                line[i] = (line[i] + a) & 0xFF
            elif ftype == 2:
                line[i] = (line[i] + b) & 0xFF
            elif ftype == 3:
                line[i] = (line[i] + ((a + b) >> 1)) & 0xFF
            elif ftype == 4:
                line[i] = (line[i] + _paeth(a, b, c)) & 0xFF
        prev = line
        row = []
        for x in range(width):
            base = x * channels
            if channels >= 3:
                row.append((line[base], line[base + 1], line[base + 2]))
            else:                       # greyscale: replicate to R=G=B
                row.append((line[base], line[base], line[base]))
        rows.append(row)
    return width, height, rows


def main(argv):
    if len(argv) < 3:
        sys.stderr.write(__doc__)
        return 2
    width, height, rows = load_rgb(argv[1])
    for spec in argv[2:]:
        x, y = (int(v) for v in spec.split(","))
        if not (0 <= x < width and 0 <= y < height):
            sys.stderr.write("coordinate %s out of range %dx%d\n"
                             % (spec, width, height))
            return 2
        r, g, b = rows[y][x]
        print("%d,%d %d %d %d" % (x, y, r, g, b))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
