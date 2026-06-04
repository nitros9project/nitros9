#!/usr/bin/env python3
"""
sync_pc_assets.py — Copy Sierra AGI sound assets from local GOG / Steam
installs (Windows paths via WSL /mnt/c) into the per-game PCASSETS
directories that the NitrOS-9 Sierra game makefiles look for.

This is a helper for users who own the games legally on GOG, Steam, or
disc.  It only copies the files actually needed for SID stream extraction
(SNDDIR + VOL.*).  It does NOT download anything from the internet.

Usage:
    python3 sync_pc_assets.py            # auto-scan + report + copy
    python3 sync_pc_assets.py --dry-run  # report only, no copies
    python3 sync_pc_assets.py --list     # show what it knows about
    python3 sync_pc_assets.py -v         # verbose

Add or override search paths via the GAME_TABLE below, or pass
--extra-root /mnt/c/Some/Other/Folder to scan an additional install root.

Once a game's PCASSETS dir is populated, build polyphonic SID disks with:
    cd ~/coco-shelf/nitros9/3rdparty/packages/sierra/<game>
    make dskclean && make dskcopy
"""
from __future__ import annotations

import argparse
import os
import shutil
import sys
from pathlib import Path
from typing import Iterable

HOME = Path.home()

# Per-game configuration.
#
# 'pkg'      : NitrOS-9 sierra package directory name (and PCASSETS subdir slug).
# 'candidates': list of WSL-style paths to scan FIRST for that game's PC
#               install.  The script also walks the well-known GOG / Steam
#               roots and matches by directory name pattern (see DIR_HINTS).
# 'dir_hints': substring matches for auto-detection under generic roots.
# 'subdir'   : optional subdirectory inside the install where AGI files live
#              (e.g. GOG bundles PQ1 with the AGI version under 'EGA/').
GAME_TABLE = [
    # 'disk_hints' lists substrings (case-insensitive) to match directory
    # names under DEFAULT_DISKIMAGE_ROOTS containing raw PC floppy .img
    # files (FAT12).  Each match is run through fat12_extract.py +
    # validated; only real AGI v2/v3 SNDDIR+VOL.* gets kept.
    dict(pkg='blackcauldron',    dir_hints=['Black Cauldron', 'BlackCauldron', 'cauldron'],
         disk_hints=['black_cauldron', 'cauldron']),
    dict(pkg='christmas86',      dir_hints=['Christmas', 'XMAS', 'XMASCARD'],
         disk_hints=['xmas', 'christmas']),
    dict(pkg='goldrush',         dir_hints=['Gold Rush', 'GoldRush', 'goldrush'],
         disk_hints=['gold_rush', 'goldrush']),
    dict(pkg='kingsquest1',      dir_hints=["King's Quest 1", 'Kings Quest 1', 'KQ1', "King's Quest"],
         subdir_hints=['agi', 'ega'],
         disk_hints=['kings_quest_quest_for_the_crown', 'kings_quest_1', 'kq1']),
    dict(pkg='kingsquest2',      dir_hints=["King's Quest 2", 'Kings Quest 2', 'KQ2'],
         disk_hints=['kings_quest_2', 'kq2']),
    dict(pkg='kingsquest3',      dir_hints=["King's Quest 3", 'Kings Quest 3', 'KQ3'],
         subdir_hints=['agi', 'ega'],
         disk_hints=['kings_quest_3', 'kq3']),
    dict(pkg='kingsquest4',      dir_hints=["King's Quest 4", 'Kings Quest 4', 'KQ4'],
         subdir_hints=['agi'],
         disk_hints=['kings_quest_4', 'kq4']),
    dict(pkg='leisuresuitlarry', dir_hints=['Leisure Suit Larry 1', 'Leisure Suit Larry', 'LSL1'],
         disk_hints=['leisure_suit_larry', 'lsl1', 'lsl_1']),
    dict(pkg='manhunter1',       dir_hints=['Manhunter 1', 'Manhunter New York', 'ManhunterNY', 'Manhunter'],
         disk_hints=['manhunter_new_york', 'manhunter1', 'manhunter_1']),
    dict(pkg='manhunter2',       dir_hints=['Manhunter 2', 'Manhunter San Francisco', 'ManhunterSF'],
         disk_hints=['manhunter_san_francisco', 'manhunter2', 'manhunter_2']),
    dict(pkg='policequest1',     dir_hints=['Police Quest 1', 'Police Quest'],
         subdir_hints=['ega', 'agi'],
         disk_hints=['police_quest', 'pq1']),
    dict(pkg='spacequest1',      dir_hints=['Space Quest 1', 'Space Quest'],
         disk_hints=['space_quest_1', 'sq1']),
    dict(pkg='spacequest2',      dir_hints=['Space Quest 2'],
         disk_hints=['space_quest_2', 'sq2']),
]

# spacequest0 is the freeware fan-game SQ0:R; handled separately via
# the existing SQ0R_PCASSETS workflow.  It is not in GAME_TABLE because
# it is never found in a commercial GOG/Steam install.

DEFAULT_SEARCH_ROOTS = [
    '/mnt/c/GOG Games',
    '/mnt/c/Program Files (x86)/GOG Galaxy/Games',
    '/mnt/c/Program Files (x86)/GOG.com',
    '/mnt/c/Program Files/Steam/steamapps/common',
    '/mnt/c/Program Files (x86)/Steam/steamapps/common',
    '/mnt/c/Steam/steamapps/common',
    '/mnt/c/Games',
    '/mnt/d/GOG Games',
    '/mnt/d/Games',
    '/mnt/d/SteamLibrary/steamapps/common',
    '/mnt/e/GOG Games',
    '/mnt/e/Games',
]

# Roots scanned for raw FAT12 floppy .img files (one subdir per game).
# Used after the GOG/Steam scan; extracted files are validated and only
# kept if they parse as real AGI sound data.
DEFAULT_DISKIMAGE_ROOTS = [
    '/mnt/c/OldGames',
    '/mnt/c/oldgames',
    '/mnt/c/old_games',
    '/mnt/d/OldGames',
    '/mnt/d/oldgames',
]


def find_agi_dir(install_root: Path, subdir_hints: Iterable[str] = ()) -> Path | None:
    """Return the directory inside `install_root` that contains SNDDIR + VOL.*.

    Searches the root first, then any 1-level subdirectories whose name
    matches a hint (case-insensitive), then *all* immediate subdirectories.
    """
    def has_agi(d: Path) -> bool:
        if not d.is_dir():
            return False
        names = {p.name.upper() for p in d.iterdir() if p.is_file()}
        return 'SNDDIR' in names and any(n.startswith('VOL.') for n in names)

    if has_agi(install_root):
        return install_root
    hints_lower = [h.lower() for h in subdir_hints]
    subs = sorted([p for p in install_root.iterdir() if p.is_dir()],
                  key=lambda p: (
                      0 if any(h in p.name.lower() for h in hints_lower) else 1,
                      p.name.lower()))
    for sub in subs:
        if has_agi(sub):
            return sub
    return None


def matches_game(dirname: str, hints: Iterable[str]) -> bool:
    name = dirname.lower()
    return any(h.lower() in name for h in hints)


def scan_roots(roots: list[Path]) -> dict[str, Path]:
    """Return {pkg: agi_dir_path} for every game found in `roots`."""
    found: dict[str, Path] = {}
    for root in roots:
        if not root.is_dir():
            continue
        for entry in sorted(root.iterdir()):
            if not entry.is_dir():
                continue
            for game in GAME_TABLE:
                if game['pkg'] in found:
                    continue
                if matches_game(entry.name, game['dir_hints']):
                    agi = find_agi_dir(entry, game.get('subdir_hints', ()))
                    if agi:
                        found[game['pkg']] = agi
                        break
    return found


def copy_assets(src: Path, dst: Path, verbose: bool, dry_run: bool) -> int:
    """Copy SNDDIR + VOL.* (case-insensitive) from src to dst.  Returns
    bytes copied (or that would be copied in dry-run mode)."""
    if not dry_run:
        dst.mkdir(parents=True, exist_ok=True)
    total = 0
    wanted = []
    for p in sorted(src.iterdir()):
        if not p.is_file():
            continue
        n = p.name.upper()
        if n == 'SNDDIR' or n.startswith('VOL.'):
            wanted.append(p)
    if not wanted:
        print(f'  (!) no SNDDIR/VOL.* files in {src}')
        return 0
    for p in wanted:
        out = dst / p.name.upper()  # canonicalise to uppercase for AGI tools
        size = p.stat().st_size
        total += size
        if verbose or dry_run:
            print(f'    {p.name} -> {out}  ({size:,} B)')
        if not dry_run:
            shutil.copy2(p, out)
    return total


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--dry-run', action='store_true', help='do not copy; just report')
    ap.add_argument('--list', action='store_true', help='show known games and exit')
    ap.add_argument('-v', '--verbose', action='store_true')
    ap.add_argument('--extra-root', action='append', default=[],
                    help='additional install root to scan (repeatable)')
    ap.add_argument('--game', action='append', default=[],
                    help='restrict to specific game(s) by package name (repeatable)')
    args = ap.parse_args()

    if args.list:
        print('Known games (and PCASSETS destination):')
        for g in GAME_TABLE:
            print(f"  {g['pkg']:<18}  hints: {', '.join(g['dir_hints'])}")
            print(f"    -> {HOME}/{g['pkg']}-pcassets/")
        return 0

    roots = [Path(r) for r in DEFAULT_SEARCH_ROOTS + args.extra_root]
    existing = [r for r in roots if r.is_dir()]
    if not existing:
        print('No GOG/Steam install roots found.  Use --extra-root to add one.',
              file=sys.stderr)
        return 2
    print('Scanning install roots:')
    for r in existing:
        print(f'  {r}')

    found = scan_roots(existing)
    if args.game:
        found = {k: v for k, v in found.items() if k in args.game}

    if not found:
        print('\nNo AGI installs detected.  Add --extra-root or check '
              '--list to verify dir-name hints.', file=sys.stderr)
        return 1

    print(f'\nFound {len(found)} AGI install(s):')
    total_bytes = 0
    for pkg, src in sorted(found.items()):
        dst = HOME / f'{pkg}-pcassets'
        print(f'\n[{pkg}]')
        print(f'  source: {src}')
        print(f'  dest:   {dst}')
        if dst.exists() and any(dst.iterdir()) and not args.dry_run:
            print(f'  (skipping — dest already exists and is non-empty)')
            continue
        total_bytes += copy_assets(src, dst, args.verbose, args.dry_run)

    # ---------------------------------------------------------------
    # Disk-image bootstrap.  For every game still missing, walk the
    # raw-floppy roots looking for subdirs whose name matches the
    # game's disk_hints.  Extract via fat12_extract.py to a quarantine
    # directory, validate as real AGI sound data, then promote to
    # ~/<game>-pcassets on success.
    #
    # NOTE: the OLD in-tree bootstrap that copied the NitrOS-9 source
    # tree's lowercase vol.* / sndDir was REMOVED in this fix.  Those
    # files are not original PC AGI -- the CoCo porter ran cc3snd.c on
    # them to pre-flatten the 4-voice resources to single-voice mono
    # 4-byte records, then bundled the result back into VOL containers.
    # Feeding those to the polyphonic extractor produced bogus or
    # all-FF sidcars, which the engine then dutifully played as
    # garbage music.  Without a sidcar, the engine cleanly falls back
    # to Phase 1 mono SID (which already understands the cc3 format
    # via the in-engine AGI sound playback path).
    # ---------------------------------------------------------------
    diskimage_roots = [Path(r) for r in DEFAULT_DISKIMAGE_ROOTS]
    diskimage_roots = [r for r in diskimage_roots if r.is_dir()]
    if diskimage_roots:
        print('\nScanning floppy-image roots:')
        for r in diskimage_roots:
            print(f'  {r}')
        from agi_snd_parser import validate_dir
        import subprocess
        import tempfile
        script_dir = Path(__file__).resolve().parent
        for root in diskimage_roots:
            for entry in sorted(root.iterdir()):
                if not entry.is_dir():
                    continue
                images = sorted(entry.glob('disk*.img')) + sorted(entry.glob('DISK*.IMG'))
                if not images:
                    continue
                for game in GAME_TABLE:
                    pkg = game['pkg']
                    if pkg in found:
                        continue
                    if args.game and pkg not in args.game:
                        continue
                    hints = game.get('disk_hints', [])
                    if not hints:
                        continue
                    if not any(h.lower() in entry.name.lower() for h in hints):
                        continue
                    dst = HOME / f'{pkg}-pcassets'
                    if dst.exists() and any(dst.iterdir()):
                        # Existing PCASSETS - validate before skipping.
                        parsed, attempted = validate_dir(str(dst))
                        if attempted > 0 and parsed == 0:
                            print(f'\n[{pkg}] rejecting bogus PCASSETS at {dst}')
                            print(f'  (validation: {parsed}/{attempted} sounds parsed; '
                                  f'data is not AGI v2/v3 -- likely cc3 or wrong format)')
                            if not args.dry_run:
                                import shutil as _sh
                                _sh.rmtree(dst)
                        elif parsed > 0:
                            found[pkg] = dst
                            continue
                    print(f'\n[{pkg}]  (disk-image bootstrap)')
                    print(f'  source: {entry} ({len(images)} image(s))')
                    print(f'  dest:   {dst}')
                    if args.dry_run:
                        for img in images:
                            print(f'    {img.name}')
                        continue
                    # Quarantine then validate then promote.
                    with tempfile.TemporaryDirectory(prefix=f'{pkg}-pcassets-tmp-') as tmpd:
                        cmd = ['python3', str(script_dir / 'fat12_extract.py'),
                               '--out', tmpd]
                        if args.verbose:
                            cmd.append('-v')
                        cmd += [str(img) for img in images]
                        try:
                            subprocess.run(cmd, check=True,
                                           stdout=(None if args.verbose else subprocess.DEVNULL))
                        except subprocess.CalledProcessError as e:
                            print(f'  (!) fat12_extract failed: {e}')
                            continue
                        parsed, attempted = validate_dir(tmpd)
                        if attempted == 0:
                            print(f'  (!) extracted dir has no parsable AGI sounds; rejecting')
                            continue
                        if parsed == 0:
                            print(f'  (!) {attempted} sounds attempted, none valid AGI; rejecting '
                                  f'(disk images likely SCI / AGI v1 / mislabeled)')
                            continue
                        # Promote to dst
                        dst.mkdir(parents=True, exist_ok=True)
                        import shutil as _sh
                        bytes_copied = 0
                        for f in sorted(Path(tmpd).iterdir()):
                            out = dst / f.name.upper()
                            _sh.copy2(f, out)
                            sz = out.stat().st_size
                            bytes_copied += sz
                            if args.verbose:
                                print(f'    {f.name} -> {out.name}  ({sz:,} B)')
                        total_bytes += bytes_copied
                        print(f'  validated: {parsed}/{attempted} sounds OK; '
                              f'copied {bytes_copied:,} B')
                        found[pkg] = dst
                        break

    # ---------------------------------------------------------------
    # Final sweep: validate every existing PCASSETS that we did not
    # populate this run.  If validation fails, leave the dir in place
    # but warn the user.
    # ---------------------------------------------------------------
    from agi_snd_parser import validate_dir as _vd
    pkgs_in_scope = [g['pkg'] for g in GAME_TABLE] + ['spacequest0']
    if args.game:
        pkgs_in_scope = [p for p in pkgs_in_scope if p in args.game]
    for pkg in pkgs_in_scope:
        if pkg in found:
            continue
        dst = HOME / f'{pkg}-pcassets'
        if not (dst / 'SNDDIR').exists():
            continue
        parsed, attempted = _vd(str(dst))
        if attempted > 0 and parsed == 0:
            print(f'\n[{pkg}] WARN: existing PCASSETS at {dst} is not real AGI '
                  f'data (validation: 0/{attempted}).')
            print(f'  Remove it to get clean Phase 1 mono fallback: rm -rf {dst}')
        elif parsed > 0:
            found[pkg] = dst

    print(f'\nTotal bytes {"would be " if args.dry_run else ""}copied: '
          f'{total_bytes:,}')
    if args.dry_run:
        print('\n(dry run; no files copied)')
    else:
        print('\nNext: rebuild each game with polyphonic SID:')
        for pkg in sorted(found):
            dst = HOME / f'{pkg}-pcassets'
            if (dst / 'SNDDIR').exists():
                print(f'  (cd ~/coco-shelf/nitros9/3rdparty/packages/sierra/{pkg} && '
                      f'make dskclean && make dskcopy)')
    print()

    # Report missing games as a TODO list for the user
    known = {g['pkg'] for g in GAME_TABLE}
    missing = sorted(known - set(found))
    if missing and not args.game:
        print(f'Not yet found ({len(missing)}): {", ".join(missing)}')
        print('Re-run after installing more games (or pass --extra-root).')

    return 0


if __name__ == '__main__':
    sys.exit(main())
