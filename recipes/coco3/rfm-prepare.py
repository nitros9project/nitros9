#!/usr/bin/env python3
"""Install a plain-file RFM system in this recipe directory."""
import argparse
from pathlib import Path
import shutil

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--recipe', type=Path, required=True)
parser.add_argument('--commands', nargs='+', required=True)
parser.add_argument('--sys-binary', nargs='+', required=True)
parser.add_argument('--sys-text', nargs='+', required=True)
parser.add_argument('--startup', type=Path, required=True)
args = parser.parse_args()
root = args.recipe.resolve()

# Keep the export root at the recipe directory, but expose only runtime files
# through /DD. System files remain at the recipe top level as build outputs.
dd = root / 'DD'
if dd.is_symlink():
    if dd.readlink() != Path('.'):
        raise SystemExit('Unexpected DD symlink; refusing to replace it')
    dd.unlink()  # Migrate the earlier DD -> . layout without touching files.
dd.mkdir(exist_ok=True)
for name in ('CMDS', 'SYS', 'sysgo', 'startup'):
    link = dd / name
    target = Path('..') / name
    if link.is_symlink():
        if link.readlink() != target:
            raise SystemExit(f'Unexpected link {link}; refusing to replace it')
    elif link.exists():
        raise SystemExit(f'{link} already exists; refusing to replace it')
    else:
        link.symlink_to(target, target_is_directory=name in ('CMDS', 'SYS'))

for name in ('CMDS', 'SYS'):
    (root / name).mkdir(exist_ok=True)
shutil.copyfile(root / 'bootfile', root / 'OS9Boot')
shutil.copyfile(root / '.mods/sysgo_dd', root / 'sysgo')
(root / 'sysgo').chmod(0o755)
for name in args.commands:
    target = root / 'CMDS' / name
    shutil.copyfile(root / '.mods' / name, target)
    target.chmod(0o755)
for name in args.sys_binary:
    shutil.copyfile(root / '.sys' / name, root / 'SYS' / name)

def text_file(source, target):
    data = source.read_bytes().replace(b'\r\n', b'\n').replace(b'\r', b'\n')
    target.write_bytes(data.replace(b'\n', b'\r'))

for name in args.sys_text:
    text_file(root / '.sys' / name, root / 'SYS' / name)
text_file(args.startup, root / 'startup')
print(f'RFM root: {root}; OS9Boot, CMDS, SYS, sysgo, startup; DD contains runtime links only')
