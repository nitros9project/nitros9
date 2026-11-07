#!/usr/bin/env python3
"""Prepare plain host files for a CoCo 3 RFM-root boot test."""
import argparse
from pathlib import Path
import shutil
import json
import os
import pty
import socket
import subprocess
import threading
import time
import xml.etree.ElementTree as ET


def modules(data):
    result=[]
    offset=0
    while offset<len(data):
        assert data[offset:offset+2]==b'\x87\xcd',f'bad module at {offset}'
        size=int.from_bytes(data[offset+2:offset+4],'big')
        assert size>=12 and offset+size<=len(data)
        name_at=offset+int.from_bytes(data[offset+4:offset+6],'big')
        name=bytearray()
        while name_at<offset+size:
            value=data[name_at];name_at+=1;name.append(value&127)
            if value&128:break
        result.append(name.decode('ascii'))
        offset+=size
    return result


def prepare(recipe,root):
    root.mkdir(parents=True,exist_ok=True)
    host=root/'host';dd=host/'DD'
    for name in ('CMDS','SYS'):(dd/name).mkdir(parents=True,exist_ok=True)
    boot=(recipe/'bootfile').read_bytes()
    names={n.lower() for n in modules(boot)}
    assert {'rfm','rfmdrv','dd','dwio'}<=names
    assert not names&{'rbf','rb1773','rbdw'},'RBF must not be available as a fallback'
    (host/'OS9Boot').write_bytes(boot)
    shutil.copyfile(recipe/'.mods/sysgo_dd',dd/'sysgo')
    for name in ('grfdrv','shell','utilpak1','cmp'):
        shutil.copyfile(recipe/'.mods'/name,dd/'CMDS'/name)
    for source in (recipe/'.sys').iterdir():
        if source.is_file() and source.suffix not in ('.map','.list'):
            shutil.copyfile(source,dd/'SYS'/source.name)
    for name in ('bootok','bootmodules','bootlisting'):(dd/name).unlink(missing_ok=True)
    disk=(recipe/'bootstrap.dsk').read_bytes()
    assert disk[0x15:0x1a]==bytes(5),'bootstrap disk must not reference a local OS9Boot'
    print(f'Prepared {len(boot)}-byte remote OS9Boot; no RBF modules. Host root: {host.resolve()}')


def run(args):
    recipe=args.recipe.resolve()
    root=args.root.resolve();host=root/'host'
    for name in ('bootok','bootmodules','bootlisting'):
        if not args.interactive:(host/'DD'/name).unlink(missing_ok=True)
    with socket.socket() as probe:
        probe.bind(('127.0.0.1',65504))
    cfg=root/'cfg';cfg.mkdir(exist_ok=True)
    x=ET.Element('mameconfig',version='10');i=ET.SubElement(ET.SubElement(x,'system',name='coco3'),'input')
    ET.SubElement(i,'port',tag=':beckerport',type='CONFIG',mask='1',defvalue='0',value='1')
    ET.ElementTree(x).write(cfg/'coco3.cfg')
    lua=root/'boot.lua';lua.write_text('''emu.keypost("DOS\\n")
    local n=0
    emu.register_frame_done(function()
     n=n+1
     if n==2700 then emu.keypost("load utilpak1\\n") end
     if n==3600 then emu.keypost("mdir >/dd/bootmodules\\n") end
     if n==3900 then emu.keypost("dir >/dd/bootlisting\\n") end
     if n==4200 then emu.keypost("echo RFMBOOTOK >/dd/bootok\\n") end
        if n%300==0 then manager.machine.screens[":screen"]:snapshot("'''+str(root/'screen.png')+'''") end
    end)
    ''')
    if args.interactive:
        lua.write_text('\n'.join(line for line in lua.read_text().splitlines()
                              if not any('n=='+str(frame) in line for frame in (2700,3600,3900,4200)))+'\n')
    master,slave=pty.openpty()
    server=subprocess.Popen([args.server,'--tcp-port','65504','--rfm-root',str(host),'--verbose'],stdout=slave,stderr=slave)
    os.close(slave)
    def capture():
        with (root/'swift.log').open('wb') as f:
            while True:
                try:data=os.read(master,8192)
                except OSError:break
                if not data:break
                f.write(data);f.flush()
    thread=threading.Thread(target=capture,daemon=True);thread.start();time.sleep(1)
    log=(root/'mame.log').open('w')
    command=[args.mame,'coco3','-rompath',args.rompath,'-skip_gameinfo','-cfg_directory',str(cfg),'-nvram_directory',str(root/'nvram'),'-ram','512K','-ext','fdc,bios=v11','-ext:fdc:wd17xx:0','525qd','-flop1',str(recipe/'bootstrap.dsk'),'-autoboot_delay','3','-autoboot_script',str(lua),'-seconds_to_run',str(args.seconds)]
    if args.interactive:command+=['-window']
    else:command+=['-video','none','-sound','none']
    mame=subprocess.Popen(command,stdout=log,stderr=subprocess.STDOUT)
    print('Testing RFM-root boot with Swift DriveWire; no virtual disk mounted',flush=True)
    try:
        until=time.monotonic()+args.seconds
        while mame.poll() is None and time.monotonic()<until:
            done=host/'DD/bootok'
            if not args.interactive and done.exists() and b'RFMBOOTOK' in done.read_bytes():break
            if server.poll() is not None:raise RuntimeError('Swift server exited')
            time.sleep(.2)
        if args.interactive:return
        failures=[]
        for name in ('bootmodules','bootlisting','bootok'):
            if not (host/'DD'/name).exists():failures.append('missing '+name)
        if (host/'DD/bootmodules').exists():
            words=(host/'DD/bootmodules').read_text().lower().split()
            for name in ('rfm','rfmdrv','dd','dwio'):
                if name not in words:failures.append('not resident: '+name)
            for name in ('rbf','rb1773','rbdw'):
                if name in words:failures.append('unexpected RBF module '+name)
        if (host/'DD/bootok').exists() and (host/'DD/bootok').read_bytes().strip()!=b'RFMBOOTOK':
            failures.append('incorrect boot completion marker')
        if (host/'DD/bootlisting').exists():
            listing=(host/'DD/bootlisting').read_text().lower()
            if not all(name in listing for name in ('cmds','sys','sysgo')):
                failures.append('incorrect remote root directory listing')
        text=(root/'swift.log').read_text(errors='replace').lower()
        for value in ('resolved=os9boot','resolved=/dd/sysgo','resolved=/dd/cmds/shell','resolved=/dd/cmds/grfdrv'):
            if value not in text:failures.append('missing remote load '+value)
        result={'server':'Swift DriveWire CLI','virtualDisks':[],'failures':failures,'passed':not failures}
        (root/'result.json').write_text(json.dumps(result,indent=2))
        print(result,flush=True)
        if failures:raise SystemExit('RFM-root boot verification failed; inspect '+str(root))
    finally:
        for process in (mame,server):
            if process.poll() is None:
                process.terminate()
                try:process.wait(timeout=5)
                except subprocess.TimeoutExpired:process.kill();process.wait()
        thread.join(timeout=2);os.close(master);log.close()

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    commands=parser.add_subparsers(dest='action',required=True)
    prep=commands.add_parser('prepare')
    launch=commands.add_parser('run')
    for command in (prep,launch):
        command.add_argument('--recipe',required=True,type=Path)
        command.add_argument('--root',required=True,type=Path)
    launch.add_argument('--server',required=True,help='Swift drivewire-cli binary')
    launch.add_argument('--mame',default='mame')
    launch.add_argument('--rompath',required=True)
    launch.add_argument('--seconds',type=int,default=180)
    launch.add_argument('--interactive',action='store_true')
    args=parser.parse_args()
    if args.action=='prepare':prepare(args.recipe.resolve(),args.root.resolve())
    else:run(args)
