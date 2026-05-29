#!/usr/bin/env python3
"""
pt_copy_src_tree.py - Copy a host directory tree onto an OS-9 disk image,
applying `os9 copy -l` (LF -> CR end-of-line translation) only to files
that look like source / text, and a plain `os9 copy` to everything else.

Usage:
    python3 scripts/pt_copy_src_tree.py <hostdir> <target.dsk> <subpath>

Examples:
    python3 scripts/pt_copy_src_tree.py 3rdparty \\
        dsks/NOS9_6809_L2_DEV_picothing_x0.dsk 3rdparty/src

`subpath` is the directory on the OS-9 volume (relative to the volume
root) that will receive the contents of `hostdir`.  Subdirectories are
created on demand.  Files that fail to copy print a warning to stderr
but do not stop the run; the script returns non-zero only if it could
not start at all.
"""
import os
import subprocess
import sys
from pathlib import Path

# Extensions that should be translated LF -> CR by `os9 copy -l`.
TEXT_EXTS = {
    '.asm', '.as', '.s', '.c', '.h', '.cc', '.cpp',
    '.b09', '.bas', '.man', '.txt', '.md',
    '.mak', '.d', '.def',
    '.html', '.htm', '.xml', '.css', '.js',
    '.py', '.pl', '.sh',
    '.menu_am', '.menu', '.list', '.map',
}

# Filenames (case-insensitive) that count as text regardless of extension.
TEXT_NAMES = {
    'makefile', 'readme', 'changelog', 'license', 'copying',
    'defsfile', 'authors', 'todo', 'install', 'news', 'history',
}

# Filenames to skip entirely (host noise).
SKIP_NAMES = {'.ds_store', '.gitignore', '.gitattributes', '.hgignore'}

# OS-9 RBF directory entries reserve 29 bytes for the filename, but the
# last character carries the end-of-name sentinel (high bit set), so the
# usable length is 28 characters. Empirically, `os9 copy` exits non-zero
# (sometimes silently, sometimes "badly formed pathname") for any host
# filename of 29 chars or more.
OS9_NAME_MAX = 28


def classify(path: Path) -> str:
    name_lower = path.name.lower()
    if name_lower in SKIP_NAMES:
        return 'skip'
    if path.suffix.lower() in TEXT_EXTS:
        return 'text'
    if name_lower in TEXT_NAMES:
        return 'text'
    if not path.suffix and path.is_file():
        # Sniff up to 1 KiB - if it's printable ASCII / tabs / CRs / LFs,
        # treat as text. Catches scripts and extension-less READMEs.
        try:
            sample = path.read_bytes()[:1024]
        except OSError:
            return 'binary'
        if not sample:
            return 'binary'
        textish = sum(1 for b in sample
                      if b in (9, 10, 13) or 32 <= b < 127)
        if textish / len(sample) > 0.95:
            return 'text'
    return 'binary'


def run_os9(*args) -> bool:
    r = subprocess.run(['os9', *args], capture_output=True, text=True)
    if r.returncode != 0:
        msg = (r.stderr or r.stdout).strip().splitlines()[-1:]
        # args[-2] is the host source (or makdir target); show it for context
        sys.stderr.write(f'  ! os9 {args[0]} {args[-2]} -> {args[-1]}: '
                         f'{msg[0] if msg else "(no output)"}\n')
        return False
    return True


def main():
    if len(sys.argv) != 4:
        sys.stderr.write(__doc__)
        sys.exit(1)

    host_dir = Path(sys.argv[1]).resolve()
    target_dsk = sys.argv[2]
    subpath = sys.argv[3].strip('/')

    if not host_dir.is_dir():
        sys.stderr.write(f'not a directory: {host_dir}\n')
        sys.exit(1)

    # Root subdir on the disk; ignore failure if it already exists.
    run_os9('makdir', f'{target_dsk},{subpath}')

    text_count = bin_count = skip_count = fail_count = 0

    for root, dirs, files in os.walk(host_dir):
        dirs.sort()
        rel = Path(root).relative_to(host_dir)
        rel_str = '' if str(rel) == '.' else str(rel).replace(os.sep, '/')

        for d in sorted(dirs):
            sub = f'{subpath}/{rel_str}/{d}' if rel_str else f'{subpath}/{d}'
            run_os9('makdir', f'{target_dsk},{sub}')

        for f in sorted(files):
            src = Path(root) / f
            kind = classify(src)
            if kind == 'skip':
                skip_count += 1
                continue
            if len(f) > OS9_NAME_MAX:
                sys.stderr.write(f'  ~ skipping (name {len(f)} > '
                                 f'{OS9_NAME_MAX} chars): {src}\n')
                skip_count += 1
                continue
            disk_path = (f'{target_dsk},{subpath}/{rel_str}/{f}'
                         if rel_str else f'{target_dsk},{subpath}/{f}')
            args = ['copy', '-r']
            if kind == 'text':
                args.append('-l')
            args += [str(src), disk_path]
            if run_os9(*args):
                if kind == 'text':
                    text_count += 1
                else:
                    bin_count += 1
            else:
                fail_count += 1

    sys.stderr.write(f'  copied {text_count} text + {bin_count} binary files'
                     f' (skipped {skip_count}, failed {fail_count})\n')
    sys.exit(1 if fail_count else 0)


if __name__ == '__main__':
    main()
