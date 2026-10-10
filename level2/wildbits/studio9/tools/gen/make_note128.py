"""Derive 128th icons from the current 64th artwork, with a red notehead dot."""
from pathlib import Path
import sys

source, target = map(Path, sys.argv[1:3])
data = source.read_bytes()
assert len(data) == 11456, 'Update symbol offsets if the bank layout changes'
result = bytearray()
for offset, row in ((0x2244, 12), (0x2644, 1), (0x2044, 12), (0x2444, 1)):
    glyph = bytearray(data[offset:offset + 128])
    assert len(glyph) == 128
    # Two by two pixels inside the notehead, palette 9 = RGB(255,0,0).
    for y in (row, row + 1):
        glyph[y * 8 + 2] = 0x99
    result.extend(glyph)
target.parent.mkdir(parents=True, exist_ok=True)
target.write_bytes(result)
