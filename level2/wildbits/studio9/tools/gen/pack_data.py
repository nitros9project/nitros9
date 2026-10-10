#!/usr/bin/env python3
"""Wrap SYS data in page-aligned, single-block OS-9 data modules."""
import argparse
from pathlib import Path
BANK = 0x1b00
IMAGES = [('Chars16', 0),
          ('UmeSymbols16', 0), ('UmeSymbols16', BANK)]   # the Banner16 banks Um3_D3/D4 went 2026-09-29 (UMusE3 lays out the keyboard)
p = argparse.ArgumentParser()
p.add_argument('name')
p.add_argument('root', type=Path)
a = p.parse_args()
i = int(a.name.replace('s9_d0', 'Um3_D0').removeprefix('Um3_D'))
image, offset = IMAGES[i]
raw = (a.root / 'SYS' / (image + '.img')).read_bytes()
expected = {'Chars16': 2376,      # 2026-10-06: + the right arrow glyph
            'UmeSymbols16': 11456}    # original bank + part-type icons + the piano key images (bank layout of 2026-09-28)
if len(raw) != expected[image]:
    raise SystemExit(f'{image}: expected {expected[image]} bytes, got {len(raw)}; update the renderer layout before changing image size')
chunk = raw[offset:offset+BANK]
if not chunk:
    raise SystemExit('Empty data bank: ' + a.name)
out = a.root / 'Data'
out.mkdir(exist_ok=True)
(out / (a.name + '.bin')).write_bytes(chunk)
# 2026-09-23: a data module shorter than $1D00 could be linked into slot 7 and push the score page to slot 6
pad = "" if len(chunk) + 0x100 >= 0x1C00 else '                    fill      0,$1CFD-*           $1CFD + the CRC = $1D00 bytes: never slot 7 (2026-09-23)\n'
(out / (a.name + '.asm')).write_text(f"""                    use       defsfile
                    mod       eom,name,Data,ReEnt
                    fdb       {len(chunk)}
                    fcc       /UD/
                    fcb       1
name                fcs       /{a.name}/
                    fill      0,$100-*
payload             includebin {a.name}.bin
{pad}                    fill      0,(-*-3)&$FF
                    emod
eom                 equ       *
                    end
""")
