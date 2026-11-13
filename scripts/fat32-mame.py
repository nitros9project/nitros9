#!/usr/bin/env python3
"""Boot local OS-9 in CoCo 3 MAME and verify guest FAT/blkdrv results on disk."""
import argparse
import hashlib
import re
import json
import os
from pathlib import Path
import subprocess
import shutil

ROOT=Path(__file__).resolve().parents[1]

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--disk',type=Path,required=True)
    parser.add_argument('--fat-image',type=Path,required=True)
    parser.add_argument('--fat-boot',action='store_true',help='Remove the floppy OS9Boot and its boot pointer before testing')
    parser.add_argument('--mame',default='mame')
    parser.add_argument('--rompath',default=os.environ.get('MAME_ROMPATH',''))
    parser.add_argument('--seconds',type=int,default=400)
    parser.add_argument('--video',type=Path,help='Record the guest screen to an AVI file')
    args=parser.parse_args()
    root=(args.disk.parent/'.fat-test').resolve()
    root.mkdir(exist_ok=True)
    for directory in ('cfg','nvram','snap'):(root/directory).mkdir(exist_ok=True)
    disk=root/'guest.dsk'
    shutil.copyfile(args.disk,disk)
    if args.fat_boot:
        subprocess.run(['os9','del',str(disk)+',OS9Boot'],check=True,capture_output=True)
        # DD.BT (3 bytes) and DD.BSZ (2 bytes): no RBF boot fallback.
        with disk.open('r+b') as stream:
            stream.seek(0x15);stream.write(bytes(5))
        print('Removed floppy OS9Boot and cleared its RBF boot pointer',flush=True)
    media=root/'media.vhd'
    shutil.copyfile(args.fat_image,media)
    def digest(path):
        with path.open('rb') as stream:return hashlib.file_digest(stream,'sha256').digest()
    before=digest(media)
    lua=root/'run.lua'
    commands=(ROOT/'recipes/coco3/fat_mame_test/fatauto').read_text().splitlines()
    lua.write_text('commands={\n'+
        ''.join(' '+json.dumps(command+'\n')+',\n' for command in commands if command)+
        '}\nsnapshot_path='+json.dumps(str(root/'screen.png'))+'\n'+
        (ROOT/'scripts/fat32-mame.lua').read_text())
    command=[args.mame,'coco3','-rompath',args.rompath,'-skip_gameinfo','-cfg_directory',str(root/'cfg'),
        '-nvram_directory',str(root/'nvram'),'-snapshot_directory',str(root/'snap'),'-ram','512K',
        '-ext','fdc,bios=v11','-ext:fdc:wd17xx:0','525qd','-flop1',str(disk),'-hard1',str(media),
        '-seconds_to_run',str(args.seconds),'-autoboot_delay','3','-autoboot_script',str(lua),
        '-video','none','-sound','none','-nothrottle']
    if args.video:
        args.video.parent.mkdir(parents=True,exist_ok=True)
        command += ['-aviwrite',str(args.video.resolve()),'-snapsize','640x480']
    print('Running CoCo 3 MAME; artifacts:',root,flush=True)
    with (root/'mame.log').open('w') as log:
        process=subprocess.Popen(command,stdout=log,stderr=subprocess.STDOUT)
        try:
            process.wait(timeout=args.seconds+60)
        except subprocess.TimeoutExpired:
            process.terminate();process.wait(timeout=10)
            raise RuntimeError('MAME wall-clock timeout; inspect screen.png')
    if process.returncode:raise RuntimeError('MAME failed; inspect mame.log')
    assert digest(media)==before,'read-only FAT32 image changed'
    def extract(name):
        dest=root/name
        dest.unlink(missing_ok=True)
        subprocess.run(['os9','copy',str(disk)+','+name,str(dest)],check=True,capture_output=True)
        if not dest.exists():
            raise RuntimeError(f'Guest did not produce {name}; inspect {root / "screen.png"} and mame.log')
        return dest.read_bytes()
    assert b'FAT32DONE' in extract('fatdone'),'guest did not finish'
    hello=b'FIRST\rSECOND\rTAIL'
    # list uses ReadLn and adds a final line ending for an unterminated final line.
    for name in ('fathello','fatparent'):
        assert extract(name).rstrip(b'\r\n')==hello,(name,'content')
    assert extract('fatnest').rstrip(b'\r\n')==b'NESTED'
    expected=bytes((i*73+19)&255 for i in range(1300))
    assert extract('fatfrag')==expected,'fragmented file copy differs'
    comparison=extract('fatcmp')
    assert re.search(rb'Bytes compared:\s*00000514',comparison),comparison
    assert re.search(rb'Bytes different:\s*00000000',comparison),comparison
    for name in ('fatdir','fatdire'):
        data=extract(name).upper()
        for entry in (b'HELLO.TXT',b'FRAG.BIN',b'EMPTY.TXT',b'SUBDIR'):
            assert entry in data,(name,entry)
        assert b'LFNSLOT' not in data and b'VOLUME' not in data
    extended=extract('fatdire')
    assert b'ID' in extended and b'Sector' not in extended,'dir did not use the portable interface'
    assert b'NEST.TXT' in extract('fatxdir').upper()
    if args.fat_boot:print('PASS: OS9Boot loaded from FAT32 with no floppy boot file',flush=True)
    print('PASS: real-image OS-9 pcf/blkdrv open/read/ReadLn, fragmented copy, chd/chx, dir and dir -e',flush=True)

if __name__=='__main__':main()
