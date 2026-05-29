#!/usr/bin/env python3
"""
pt_select_3rdparty.py - Pick one disk image per third-party package for the
Pico-Thing /3rdparty subdirectory.

Scans a directory of .dsk/.DSK files, ignores names beginning with "NOS9",
groups remaining images by package name (stripping known variant suffixes
like _dw, _becker, _40d, _80d, and the multi-disk _d<N>_<media> prefix),
and emits one "<package>\t<path>" line per package, preferring the _dw
variant, then the bare image, else whatever else is available.

Usage:
    python3 scripts/pt_select_3rdparty.py [dsks-dir]

Default dsks-dir is "dsks/" relative to the current working directory.
"""
import re
import sys
from pathlib import Path

VARIANT_RE = re.compile(r'_(?:d\d+_)?(dw|becker|40d|80d)$', re.IGNORECASE)


def main():
    src = Path(sys.argv[1] if len(sys.argv) > 1 else 'dsks')
    files = sorted(p for p in src.iterdir()
                   if p.is_file()
                   and p.suffix.lower() == '.dsk'
                   and not p.name.startswith('NOS9'))

    # Score: higher is better when picking a variant within a group.
    # Pure _dw beats bare beats anything else; chained variants
    # (e.g. _dw_becker) rank below their pure counterpart.
    def score(stem, pkg):
        suffix_chain = stem[len(pkg):]
        if suffix_chain == '':
            return 1  # bare
        if suffix_chain.lower() == '_dw':
            return 3  # pure dw - preferred
        if '_dw' in suffix_chain.lower():
            return 2  # chained dw
        return 0  # becker / 40d / 80d / chained others

    groups = {}
    for p in files:
        # Some images chain multiple variant suffixes
        # (e.g. MicroscopicMission_dw_becker.dsk). Strip them all so
        # every variant of the same base package lands in one group.
        pkg = p.stem
        while True:
            m = VARIANT_RE.search(pkg)
            if not m:
                break
            pkg = pkg[:m.start()]
        groups.setdefault(pkg, []).append((score(p.stem, pkg), p))

    for pkg in sorted(groups):
        variants = groups[pkg]
        variants.sort(key=lambda v: (-v[0], v[1].name))
        chosen = variants[0]
        print(f'{pkg}\t{chosen[1]}')


if __name__ == '__main__':
    main()
