#!/usr/bin/env python3
"""Assemble Level 1 kernels and compare the full build with a Git baseline.

Usage: python3 scripts/check-level1-features.py [--baseline HEAD] [--assembler lwasm]
Requires Git and LWASM. All generated sources and binaries stay in a temporary
folder. Tests defaults and explicit feature enablement against the baseline,
then assembles individual disabled switches and the TurbOS lite/core profiles.
This verifies assembly and binary compatibility, not runtime behavior.
"""
import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile

PORTS = (
    'coco1', 'coco1_6309', 'coco2', 'coco2_6309', 'coco2b', 'atari',
    'tano', 'mc09', 'dalpha', 'deluxe', 'dplus', 'corsham', 'd64',
    'wildbits', 'picothing',
)
FLAGS = (
    '_FF_MODCHECK', '_FF_UNIFIED_IO', '_FF_BOOTING', '_FF_ID',
    '_FF_SPRIOR', '_FF_SSWI', '_FF_IRQ_POLL',
)
MODULES = ('krn', 'krnp2')


def assemble(assembler, root, port, module, target, switches=()):
    subprocess.run([
        assembler, '--6309', '--format=os9',
        '--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
        '-I' + str(root / 'defs'), '-I' + str(root / 'level1' / port),
        '-I' + str(root / 'level1/modules/kernel'), '-D' + port + '=1',
        *switches, str(root / 'level1/modules/kernel' / (module + '.asm')),
        '-o' + str(target),
    ], cwd=target.parent, check=True, capture_output=True)
    return target.read_bytes()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', default='HEAD')
    parser.add_argument('--assembler', default='lwasm')
    args = parser.parse_args()
    assembler = shutil.which(args.assembler)
    if not assembler:
        parser.error('assembler not found: ' + args.assembler)
    root = Path(__file__).resolve().parents[1]
    revision = subprocess.check_output(
        ['git', 'rev-parse', args.baseline], cwd=root, text=True).strip()
    with tempfile.TemporaryDirectory(prefix='nitros9-kernel-features-') as temp:
        work = Path(temp)
        baseline = work / 'baseline'
        baseline.mkdir()
        archive = subprocess.run(
            ['git', 'archive', revision, 'defs', 'level1'], cwd=root,
            check=True, capture_output=True).stdout
        subprocess.run(['tar', '-xf', '-', '-C', str(baseline)],
                       input=archive, check=True)
        for port in PORTS:
            for module in MODULES:
                expected = assemble(assembler, baseline, port, module, work / 'before')
                for switches in [(), tuple('-D' + f + '=1' for f in FLAGS)]:
                    actual = assemble(assembler, root, port, module, work / 'after', switches)
                    if actual != expected:
                        raise RuntimeError(f'{port}/{module}: differs from {revision}')
            print(f'{port}: defaults and explicit full build match baseline')
        profiles = [[f] for f in FLAGS]
        profiles += [list(FLAGS), [f for f in FLAGS if f != '_FF_UNIFIED_IO'], ['_FF_SWI']]
        for port in PORTS:
            for disabled in profiles:
                for module in MODULES:
                    assemble(assembler, root, port, module, work / 'disabled',
                             ['-D' + f + '=0' for f in disabled])
            print(f'{port}: all ten disabled-feature configurations assemble')
        print(f'PASS: 60 binary comparisons and 300 disabled-feature assemblies; baseline {revision}')


if __name__ == '__main__':
    try:
        main()
    except subprocess.CalledProcessError as error:
        detail = error.stderr or error.stdout or b''
        print(detail.decode() if isinstance(detail, bytes) else detail)
        raise SystemExit(error.returncode)
