#!/usr/bin/env python3
"""Check OS-9 headers/CRC, page alignment, and exact SYS payload reconstruction.

2026-09-15: UmeSymbols16 rides inside UMusE3's tail (blocks 6 and 7 of the module,
see cmds/s9.asm); they are verified against the UMusE3 module image. Chars16 is the s9_d0 font
module; the Banner16 modules Um3_D3/D4 went 2026-09-29 (UMusE3 lays out the keyboard itself)."""
from pathlib import Path
import sys
root = Path(sys.argv[1])
groups = [('Chars16', [0])]
# Bank 2 is 4544 bytes after the part-type icons and the 25-line piano keys (2026-09-28).
tail = [('UmeSymbols16', 0, 0xA000, 6912), ('UmeSymbols16', 6912, 0xC000, 4544)]
def crc24(data):
    crc = 0xffffff
    for byte in data:
        crc ^= byte << 16
        for _ in range(8):
            crc = ((crc << 1) ^ (0x800063 if crc & 0x800000 else 0)) & 0xffffff
    return crc ^ 0xffffff
for image, banks in groups:
    parts = []
    for bank in banks:
        name = f's9_d{bank}'
        data = (root / 'CMDS' / name).read_bytes()
        assert data[:2] == b'\x87\xcd', name
        assert int.from_bytes(data[2:4], 'big') == len(data), name
        assert len(data) % 256 == 0 and len(data) <= 0x1d00, name
        assert data[6:8] == bytes([0x40, 0x80]), name
        parity = 0
        for byte in data[:9]: parity ^= byte
        assert parity == 255, name
        assert crc24(data[:-3]) == int.from_bytes(data[-3:], 'big'), name
        start = int.from_bytes(data[4:6], 'big')
        encoded = name[:-1].encode() + bytes([ord(name[-1]) | 128])
        assert data[start:start+len(encoded)] == encoded, name
        assert data[11:14] == b'UD\x01', name
        size = int.from_bytes(data[9:11], 'big')
        assert 0 < size <= 0x1b00, name
        assert not any(data[256+size:-3]), name
        parts.append(data[256:256+size])
        print(f'{name}: {len(data)} bytes (${len(data):04X}), payload {size}, CRC OK')
    assert b''.join(parts) == (root / 'SYS' / (image + '.img')).read_bytes(), image
umuse3 = (root / 'CMDS' / 's9').read_bytes()
assert crc24(umuse3[:-3]) == int.from_bytes(umuse3[-3:], 'big'), 'UMusE3 CRC'
for image, offset, at, length in tail:
    img = (root / 'SYS' / (image + '.img')).read_bytes()
    assert umuse3[at:at+length] == img[offset:offset+length], f'{image} at ${at:04X} in UMusE3'
    print(f'UMusE3 ${at:04X}: {image}[{offset}:{offset+length}] matches')
print('Chars16 reconstructs from s9_d0; UmeSymbols16 matches UMusE3 tail blocks.')
