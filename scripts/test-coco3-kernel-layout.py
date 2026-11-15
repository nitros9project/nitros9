#!/usr/bin/env python3
"""Assemble both CoCo 3 kernels and reject unsafe constant-page layouts."""
import argparse
from pathlib import Path
import re
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--lwasm', default='lwasm')
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    root = args.root.resolve()
    source = (root / 'level2/modules/kernel/krn.asm').read_text()
    includes = ('defs', 'level2/modules/kernel', 'level2/coco3/modules',
                'level1/modules/kernel', 'level1/modules')
    with tempfile.TemporaryDirectory(prefix='coco3-kernel-') as directory:
        work = Path(directory)
        (work / 'defsfile').write_text('Level equ 2\n use os9.d\n use scf.d\n use rbf.d\n use coco.d\n')
        for cpu, native in ((6809, 0), (6309, 1)):
            command = [args.lwasm, '--6309', '--format=os9', '--no-warn=ifp1',
                       '--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
                       '-Dcoco3=1', f'-DH6309={native}', '-I.']
            command += ['-I' + str(root / path) for path in includes]
            command += ['krn.asm', '--output=krn', '--map=krn.map']
            def assemble(text):
                (work / 'krn.asm').write_text(text)
                return subprocess.run(command, cwd=work, capture_output=True, text=True)
            result = assemble(source)
            assert result.returncode == 0, result.stdout + result.stderr
            symbols = dict((name, int(value, 16)) for name, value in re.findall(
                r'Symbol: (\S+) .* = ([0-9A-Fa-f]+)', (work / 'krn.map').read_text()))
            data = (work / 'krn').read_bytes()
            assert len(data) == 0xF00, (cpu, len(data))
            assert 0xE00 <= symbols['IRQTaskSwitch'] < 0xF00
            assert symbols['SWIStack'] == (0xEDD if native else 0xEDF)
            # Hardware vectors must branch to their actual handler, with NOP padding.
            for offset, name in zip(range(0xEEE, 0xF00, 3),
                                    ('SWI3VCT', 'SWI2VCT', 'FIRQVCT', 'IRQVCT', 'SWIVCT', 'NMIVCT')):
                assert data[offset] == 0x20 and data[offset + 2] == 0x12
                displacement = int.from_bytes(data[offset + 1:offset + 2], signed=True)
                assert offset + 2 + displacement == symbols[name]
                assert 0xE00 <= symbols[name] < 0xF00
            # Guard against growth before the fixed page and inside the vector tail.
            for label, broken, expected in (
                ('page overflow', source.replace('                    use       fnproc.asm', '                    fill $12,$1000\n                    use       fnproc.asm'), 'fill'),
                ('tail shift', source.replace('                    emod', '                    fcb 0\n                    emod'), 'register stack must be')):
                assert broken != source
                result = assemble(broken)
                output = result.stdout + result.stderr
                assert result.returncode != 0 and expected in output, (cpu, label, output)
            print(f'{cpu}: layout, six vector targets, and overflow guards passed')


if __name__ == '__main__':
    main()
