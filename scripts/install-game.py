#!/usr/bin/env python3
"""Install a game's compiled modules and assets into a recipe-built OS-9 disk."""
import argparse
from pathlib import Path
import subprocess
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--disk', required=True)
    parser.add_argument('--source', required=True, type=Path)
    parser.add_argument('--prefix', default='')
    parser.add_argument('--data-dir', default='.')
    parser.add_argument('--toc', type=Path)
    parser.add_argument('--sys-exists', action='store_true')
    parser.add_argument('--existing-dir', action='append', default=[])
    for name in ('programs', 'root', 'sys', 'data-programs', 'screens'):
        parser.add_argument('--' + name, nargs='*', default=[])
    args = parser.parse_args()
    made = {'.', 'CMDS'} | ({'SYS'} if args.sys_exists else set())
    made.update(args.existing_dir)

    def destination(name):
        return str(Path(args.prefix) / name)

    def os9(*command):
        subprocess.run(['os9', *map(str, command)], check=True)

    def directory(name):
        if name in made:
            return
        parent = str(Path(name).parent)
        directory(parent)
        os9('makdir', f'{args.disk},{name}')
        made.add(name)

    def copy(source, destination, executable=False, text=False):
        directory(str(Path(destination).parent))
        flags = ['-l'] if text else []
        os9('copy', '-r', *flags, source, f'{args.disk},{destination}')
        # Some ToolShed versions report copy errors but return status zero.
        # Round-trip every payload so a full disk cannot produce a false pass.
        with tempfile.TemporaryDirectory() as temp:
            check = Path(temp) / 'payload'
            os9('copy', f'{args.disk},{destination}', check)
            expected = Path(source).read_bytes()
            if text:
                expected = expected.replace(b'\r\n', b'\n').replace(b'\n', b'\r')
            if not check.exists() or check.read_bytes() != expected:
                raise SystemExit(f'Payload copy failed: {source} -> {destination}')
        if executable:
            os9('attr', '-e', '-pe', f'{args.disk},{destination}')

    for name in args.programs:
        copy(args.source / name, destination(f'CMDS/{Path(name).name}'), True)
    for name in args.root:
        copy(args.source / name, destination(str(Path(args.data_dir) / Path(name).name)))
    for name in args.sys:
        copy(args.source / name, destination(f'SYS/{Path(name).name}'))
    for name in args.data_programs:
        copy(args.source / name, destination(str(Path(args.data_dir) / Path(name).name)), True)
    for name in args.screens:
        copy(name, destination(f'SCREENS/{Path(name).name}'), text=True)
    if args.toc:
        # Invoke the host ToolShed utility, not the game's OS-9 tocgen module.
        copy(args.toc, destination('tOC.txt'), text=True)
        subprocess.run(['tocgen', f'{args.disk},{destination("tOC.txt")}',
                        f'{args.disk},{destination("tOC")}'], check=True)


if __name__ == '__main__':
    main()
