#!/usr/bin/env python3
"""Build and verify a FAT32 /DD boot with no resident floppy driver."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from pyfatfs.PyFatFS import PyFatFS

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('pcf_random',ROOT/'scripts/pcf-random.py')
random_test=importlib.util.module_from_spec(spec);spec.loader.exec_module(random_test)
spec=importlib.util.spec_from_file_location('fat_check',ROOT/'scripts/check-fat-image.py')
fat_check=importlib.util.module_from_spec(spec);spec.loader.exec_module(fat_check)
spec=importlib.util.spec_from_file_location('disk_script',ROOT/'scripts/mame-script.py')
disk_script=importlib.util.module_from_spec(spec);spec.loader.exec_module(disk_script)
COMMANDS=('grfdrv','shell','mdir','dir','list','copy','cmp')

def module_names(data, lowercase=True):
    result=set();offset=0
    while offset<len(data):
        assert data[offset:offset+2]==b'\x87\xcd'
        size=int.from_bytes(data[offset+2:offset+4],'big')
        assert size>=13 and offset+size<=len(data)
        at=offset+int.from_bytes(data[offset+4:offset+6],'big');name=bytearray()
        while True:
            value=data[at];at+=1;name.append(value&127)
            if value&128:break
        result.add(name.decode().lower() if lowercase else name.decode());offset+=size
    return result

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def prepare(args):
    recipe=args.recipe.resolve();root=args.root.resolve()
    root.mkdir(parents=True,exist_ok=True)
    if args.write_test:random_test.prepare(root,args.seed,args.steps)
    stage=root/'system'
    if stage.exists():shutil.rmtree(stage)
    (stage/'CMDS').mkdir(parents=True);(stage/'SYS').mkdir()
    boot=(recipe/'bootfile').read_bytes();names=module_names(boot)
    assert {'dd','pcf','blkdrv','llcocovhd'}<=names
    assert {'pcf','blkdrv'}<=module_names(boot,lowercase=False),'runtime module names must be lowercase'
    assert 'blkdev' not in names
    assert not names&{'rbf','rb1773','d0','sysgo','shell','grfdrv'},names
    commands=COMMANDS+(('makdir','del','deldir','attr','dcheck','pwd','pxd','pcfshare','pcfrmdir','rename','pcfren') if args.write_test else ())
    for name in commands:shutil.copyfile(recipe/'.mods'/name,stage/'CMDS'/name.upper())
    shutil.copyfile(recipe/'.mods/sysgo_dd',stage/'SYSGO')
    lines=(recipe/'commands').read_text().splitlines()
    startup=(recipe/'startup').read_text()
    script_names=['/TEST.CMD']
    if args.write_test:
        lines=lines[:-1]+(root/'random-commands').read_text().splitlines()+['echo DONE>/dd/testdone']+lines[-1:]
        disk_script.answers(stage)
        (stage/'REOPEN.CMD').write_bytes(disk_script.script((recipe/'commands-reopen').read_text().splitlines()))
        # Replace the startup shell: do not retain its 2 KiB PCF script path
        # while recursive deldir and the parent/child checks allocate paths.
        startup+='if -r /dd/testdone\nex shell /dd/reopen.cmd\nelse\nex shell /dd/test.cmd\nendif\n'
        script_names+=['/REOPEN.CMD','/CANCEL.IN','/DELETE.IN']
    else:startup+='shell /dd/test.cmd\n'
    (stage/'TEST.CMD').write_bytes(disk_script.script(lines))
    (stage/'STARTUP').write_bytes(startup.replace('\n','\r').encode())
    for name in ('stdfonts','stdptrs','errmsg','helpmsg','password','motd'):
        source=recipe/'.sys'/name
        if source.exists():shutil.copyfile(source,stage/'SYS'/name.upper())
    (stage/'FRAGCOPY.BIN').write_bytes(bytes((i*73+19)&255 for i in range(1300)))
    image=root/'fat32-root.vhd'
    subprocess.run([sys.executable,str(ROOT/'scripts/make-fat32-image.py'),str(image),
        '--boot-file',str(recipe/'bootfile'),'--system-root',str(stage)],check=True)
    disk=(recipe/'bootstrap.dsk').read_bytes()
    assert disk[0x15:0x1a]==bytes(5),'floppy has an OS9Boot pointer'
    assert len((recipe/'.mods/boot_fat32').read_bytes())==464
    # Record data-sector locations independently of emulator/guest code.
    with image.open('rb') as stream:bpb=stream.read(512)
    spc=bpb[13];data=int.from_bytes(bpb[14:16],'little')+bpb[16]*int.from_bytes(bpb[36:40],'little')
    records={}
    with PyFatFS(str(image),read_only=True) as fs:
        for name in ('/OS9BOOT','/SYSGO','/STARTUP',*script_names,*(f'/CMDS/{n.upper()}' for n in commands)):
            entry=fs._get_dir_entry(name)
            chain=list(fs.fs.get_cluster_chain(entry.get_cluster()))
            count=(len(fs.readbytes(name))+255)//256
            records[name]=[2*(data+(c-2)*spc)+i for c in chain for i in range(2*spc)][:count]
    (root/'manifest.json').write_text(json.dumps({'resident':sorted(names),'records':records},indent=2))
    print('Prepared FAT32 /DD: SysGo, shell, GrfDrv, commands and startup; no RBF/floppy modules',flush=True)

def run(args):
    recipe=args.recipe.resolve();root=args.root.resolve()
    logs=root/'reopen' if args.reopen else root
    logs.mkdir(exist_ok=True)
    for folder in ('cfg','nvram','snap'):(root/folder).mkdir(exist_ok=True)
    disk=root/'bootstrap.dsk';media=root/'media.vhd'
    shutil.copyfile(recipe/'bootstrap.dsk',disk)
    if args.reopen:
        assert args.write_test and media.exists(),'reopen requires an existing writable-test image'
    else:shutil.copyfile(root/'fat32-root.vhd',media)
    hashes=(digest(disk),digest(media))
    marker='PCFPERSISTDONE' if args.reopen else ('PCFWRITEDONE' if args.write_test else 'FATROOTDONE')
    lua='eject_bootstrap=true\ncompletion_marker='+json.dumps(marker)+'\n'
    lua+='snapshot_path='+json.dumps(str(logs/'screen.png'))+'\n'
    lua+='console_path='+json.dumps(str(logs/'console.log'))+'\n'
    lua+='writes_path='+json.dumps(str(logs/'vhd-writes.log'))+'\n'
    lua+='errors_path='+json.dumps(str(logs/'errors.log'))+'\n'
    lua+='reads_path='+json.dumps(str(logs/'vhd-reads.log'))+'\n'
    lua+=(ROOT/'scripts/fat32-root-mame.lua').read_text()+'\n'
    lua+=(ROOT/'scripts/mame-disk-script.lua').read_text()
    (logs/'run.lua').write_text(lua)
    seconds=args.seconds
    cmd=[args.mame,'coco3','-rompath',args.rompath,'-skip_gameinfo','-cfg_directory',str(root/'cfg'),
        '-nvram_directory',str(root/'nvram'),'-snapshot_directory',str(root/'snap'),'-ram','512K',
        '-ext','fdc,bios=v11','-ext:fdc:wd17xx:0','525qd','-flop1',str(disk),'-hard1',str(media),
        '-autoboot_delay','3','-autoboot_script',str(logs/'run.lua'),'-seconds_to_run',str(seconds),
        '-sound','none','-nothrottle']
    cmd+=['-window'] if args.visible else ['-video','none']
    if args.video:
        args.video.parent.mkdir(parents=True,exist_ok=True)
        cmd+=['-aviwrite',str(args.video.resolve()),'-snapsize','640x480']
    print('Booting with FAT32 /DD and kernel-track-only floppy:',root,flush=True)
    with (logs/'mame.log').open('w') as log:
        subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=seconds+60)
    assert hashes[0]==digest(disk),'bootstrap floppy changed'
    if args.reopen or not args.write_test:assert hashes[1]==digest(media),'read-only FAT32 image changed'
    console=(logs/'console.log').read_bytes()
    (logs/'console.txt').write_bytes(console.replace(b'\r',b'\n'))
    startup=console.split(b'Shell+')[0]
    assert b'FAT32STARTUPDONE' in startup and b'Module Directory' in startup,'startup did not finish before the interactive shell'
    errors=[int(n) for n in (logs/'errors.log').read_text().splitlines()]
    if args.reopen:
        assert errors==[],('reopen errors',errors)
        assert b'PCFPERSISTDONE' in console and b'PCFNESTED\r' in console
        assert b'KEEP.TXT' in console and b'INNER' in console
        assert b'FINALDIR' in console
        assert console.count(b'HELDDATA\r')==2 and console.count(b'RENAMEKEEP\r')==2
        assert not (logs/'vhd-writes.log').read_text(),'reopen checks wrote to disk'
        with PyFatFS(str(media),read_only=True) as fs:random_test.verify(fs,root)
    elif args.write_test:
        assert errors==[249]*4+[1],('expected four RBF-only rejections and deldir quit',errors)
        assert b'rbf only' not in console,'redundant rejection message remains'
        assert f'RANDOMPASS{args.seed}'.encode() in console
        assert b'PCFWRITEDONE' in console and b'PCFRECURSEDONE' in console
        assert console.count(b'List directory, delete directory, or quit ?')==6
        assert console.count(b'PCFDELDENYBEGIN')==1 and console.count(b'PCFDELDENYEND')==1
        after_quit=console.split(b'PCFDELDENYEND',1)[1]
        assert all(word in after_quit for word in (b'ROOTFILE\r',b'AFILE\r',b'BFILE\r'))
        assert b'PCFSHARE PASS: 13 parent/child checks' in console
        assert b'PCFSHARE FAIL' not in console
        assert b'PCFRMDIR PASS: 14 parent/child checks' in console
        assert b'PCFRMDIR FAIL' not in console
        assert b'PCFRENAME PASS: 25 parent/child checks' in console and b'PCFRENAME FAIL' not in console
        assert b'PCFRENAMEDONE' in console
        assert console.count(b'PCFRENDENYBEGIN')==16 and console.count(b'PCFRENDENYEND')==16
        assert console.count(b'PCFRMDENYBEGIN')==8 and console.count(b'PCFRMDENYEND')==8
        writes=(logs/'vhd-writes.log').read_text().splitlines()
        assert writes and not any(line.startswith('GUARD ') for line in writes),'rejected operation wrote to disk'
        with PyFatFS(str(media),read_only=True) as fs:
            assert fs.isdir('/TOP') and fs.isdir('/TOP/INNER')
            assert fs.readbytes('/TOP/INNER/KEEP.TXT')==b'PCFNESTED\r'
            assert fs.readbytes('/NEW.TXT')==b'FIRST\rSECOND\r'
            assert fs.readbytes('/COPY.BIN')==bytes((i*73+19)&255 for i in range(1300))
            assert fs.readbytes('/SUBDIR/NEW.TXT')==b'NESTEDWRITE\r'
            assert fs.readbytes('/SUBDIR/NEST.TXT')==b'NESTED\r'
            assert set(fs.listdir('/SUBDIR'))=={'NEW.TXT','NEST.TXT','CHILD'}
            assert fs.isdir('/SUBDIR/CHILD') and fs.listdir('/SUBDIR/CHILD')==[]
            random_test.verify(fs,root)
            assert fs.readbytes('/RNTEST/FINAL.TXT')==b'HELDDATA\r'
            assert fs.readbytes('/RNTEST/FINALDIR/KEEP.TXT')==b'RENAMEKEEP\r'
            assert set(fs.listdir('/RNTEST'))=={'FINAL.TXT','FINALDIR'}
            assert not fs.exists('/TREE') and not fs.exists('/SINGLE.TXT')
            assert not fs.exists('/GONE.BIN')
            assert not fs.exists('/RMTEST') and not fs.exists('/EMPTY')
            assert not fs.exists('/SHARE.TXT') and not fs.exists('/OTHER.TXT')
    else:
        assert errors==[203],('expected only write-mode rejection from copy',errors)
        assert b'FATROOTEXEC' in console and b'FATROOTRELATIVE' in console
        assert b'FATROOTDONE' in console,'interactive tests did not finish'
        assert console.count(b'FIRST\rSECOND\rTAIL')==2 and b'NESTED' in console
        exec_listing=console.split(b'FATROOTRELATIVE',1)[1].split(b'FATROOTEXEC',1)[0]
        assert b'NEST.TXT' in exec_listing and b'CHILD' in exec_listing
    assert 'FLOPPY EJECTED' in (logs/'mame.log').read_text()
    assert re.search(rb'Bytes compared:\s*00000514',console),console[-2000:]
    assert re.search(rb'Bytes different:\s*00000000',console),console[-2000:]
    reads={int(n) for n in (logs/'vhd-reads.log').read_text().splitlines()}
    manifest=json.loads((root/'manifest.json').read_text())
    verified_files=[]
    for name,records in manifest['records'].items():
        if not args.reopen and name=='/REOPEN.CMD':continue
        if args.reopen and name not in ('/REOPEN.CMD','/OS9BOOT','/SYSGO','/STARTUP','/CMDS/GRFDRV','/CMDS/SHELL','/CMDS/MDIR','/CMDS/DIR','/CMDS/LIST','/CMDS/CMP'):continue
        assert set(records)<=reads,f'file was not fully read from VHD: {name}'
        verified_files.append(name)
    if args.write_test:fat_check.check(media,logs/'fsck.log',args.fsck)
    (logs/'result.json').write_text(json.dumps({'passed':True,'resident':manifest['resident'],
        'loaded_files':verified_files,'floppy_sha256':hashes[0],'fat32_sha256':digest(media),'write_test':args.write_test,'reopen':args.reopen,'errors':errors,
        'non_rbf_rejections':errors.count(249) if args.write_test else 0,
        'disk_scripts':True,
        'recursive_deldir':bool(args.write_test),
        'fat_integrity_checked':bool(args.write_test),
        'random_seed':args.seed if args.write_test else None,
        'random_operations':args.steps if args.write_test and not args.reopen else 0,
        'parent_child_rename_checks':25 if args.write_test and not args.reopen else 0,
        'parent_child_rmdir_checks':14 if args.write_test and not args.reopen else 0,
        'parent_child_sharing_checks':13 if args.write_test and not args.reopen else 0},indent=2))
    if args.write_test and not args.reopen:print('PASS: 25 parent/child rename checks; file/directory rename and rejection without disk writes',flush=True)
    if args.write_test and not args.reopen:print('PASS: 14 parent/child directory-removal checks; no writes on rejected removals',flush=True)
    if args.write_test and not args.reopen:print('PASS: 13 parent/child sharing checks, independent read positions, SS.Lock rejected as unsupported',flush=True)
    if args.write_test and not args.reopen:print('PASS: PCF create/write/append/copy/delete; recursive deldir removes nested files and empty directories; attr/dcheck/pxd/pwd rejected without disk writes',flush=True)
    if args.write_test and not args.reopen:print(f'PASS: {args.steps} randomized operations (seed {args.seed}) match the independent host reference',flush=True)
    if args.reopen:print('PASS: renamed files/directories, nested directories and contents persist across a fresh MAME boot; image unchanged',flush=True)
    print('PASS: FAT32 OS9Boot + /DD, disk-loaded SysGo/shell/GrfDrv/commands, startup and cmp; bootstrap unchanged',flush=True)

def main():
    p=argparse.ArgumentParser()
    p.add_argument('action',choices=('prepare','run'));p.add_argument('--recipe',type=Path,required=True)
    p.add_argument('--root',type=Path,required=True);p.add_argument('--mame',default='mame')
    p.add_argument('--rompath',default=os.environ.get('MAME_ROMPATH',''));p.add_argument('--seconds',type=int,default=260)
    p.add_argument('--write-test',action='store_true')
    p.add_argument('--reopen',action='store_true',help='Boot the previous writable run image without resetting it')
    p.add_argument('--video',type=Path)
    p.add_argument('--fsck',default=fat_check.default_checker(),help='FAT checker executable (called with -n)')
    p.add_argument('--visible',action='store_true')
    p.add_argument('--seed',type=int,default=20261108)
    p.add_argument('--steps',type=int,default=120)
    args=p.parse_args();(prepare if args.action=='prepare' else run)(args)

if __name__=='__main__':main()
