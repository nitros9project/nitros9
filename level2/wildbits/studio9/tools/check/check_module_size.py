"""Enforce one 8 KB block per UME module, except the two main programs."""
from pathlib import Path
import sys, os, json, hashlib

LIMIT = 8192
EXEMPT = {'s9gui', 'umuse3', 's9'}   # s9 = the UMusE3 program installed under its new name (2026-10-03)
# 2026-09-15: UMusE3 is a seven-block module - five of program (the fill in the source fails if that grows),
# then UmeSymbols16 bank 1 at $A000 and bank 2 at $C000 (4544 bytes including the 25-line piano keys, 2026-09-28).
# Chars16 is s9_d0. UMusE3 ends below $DD00 so its last block may sit in slot 7
# (the hardware hides that slot's top three pages).
UMUSE3_MAX = 6 * 8192 + 0x1D00
s9gui_MAX = 31999
# 2026-10-07: the banks are includebin slices of SYS/UmeSymbols16.img (the Python-free build): bank 1 its first $1B00
# bytes at $A000, bank 2 the rest at $C000.
BANK = 0x1B00
UMUSE3_TAIL = [(0xA000, 'SYS/UmeSymbols16.img', 0, BANK), (0xC000, 'SYS/UmeSymbols16.img', BANK, None)]


def check(paths):
    failures = []
    # Optional development guard for a definitions-only refactor. Runs as part
    # of each assembly's existing size gate, never against installed disk files.
    baseline_file = os.environ.get('UME_EXPECTED_HASHES')
    baseline = json.loads(Path(baseline_file).read_text()) if baseline_file else {}
    for path in paths:
        path = Path(path)
        size = path.stat().st_size
        if path.name in baseline and hashlib.sha256(path.read_bytes()).hexdigest() != baseline[path.name]:
            failures.append(f'{path.name}: definitions-only assembly changed its bytes')
        if path.name.lower() not in EXEMPT and size > LIMIT:
            failures.append(f'{path.name}: {size} bytes (${size:X}) exceeds the 8 KB module limit by {size-LIMIT} bytes')
        if path.name.lower() == 's9gui' and size > s9gui_MAX:
            failures.append(f's9gui: {size} bytes exceeds its {s9gui_MAX}-byte hardware-safe ceiling by {size-s9gui_MAX} bytes')
        if path.name.lower() in ('umuse3', 's9'):
            if size > UMUSE3_MAX:
                failures.append(f'UMusE3: {size} bytes ends past ${UMUSE3_MAX:X}: its last block could not sit in slot 7')
            data = path.read_bytes()
            root = path.parent.parent
            for offset, rel, start, length in UMUSE3_TAIL:
                image = (root / rel).read_bytes()
                payload = image[start:] if length is None else image[start:start+length]
                if data[offset:offset+len(payload)] != payload:
                    failures.append(f'UMusE3: {rel} is not at ${offset:X} in the tail')
    if failures:
        raise SystemExit('STOP: UME module guard failed\n' + '\n'.join(failures))


if __name__ == '__main__':
    if len(sys.argv) < 2:
        raise SystemExit('Usage: check_module_size.py MODULE [MODULE ...]')
    check(sys.argv[1:])
