#!/usr/bin/env python3
"""Seeded guest shell operations with an independent host-filesystem reference."""
import hashlib
import json
from pathlib import Path
import random
import shutil


def prepare(root,seed=20261108,steps=120):
    host=root/'reference'
    if host.exists():shutil.rmtree(host)
    host.mkdir()
    rng=random.Random(seed);commands=['makdir /pc0/rand'];trace=[];serial=0
    def guest(path):return '/pc0/rand/'+path.relative_to(host).as_posix()
    for step in range(steps):
        files=sorted(p for p in host.rglob('*') if p.is_file())
        dirs=[host]+sorted(p for p in host.rglob('*') if p.is_dir())
        empty=[p for p in dirs if p!=host and not any(p.iterdir())]
        choices=['create']*3+['mkdir']
        if files:choices+=['append']*3+['copy','delete']
        if empty:choices+=['rmdir']
        op=rng.choice(choices);serial+=1
        if op in ('create','copy'):
            target=rng.choice(dirs)/f'F{serial:04}.TXT'
            if op=='copy':
                source=rng.choice(files);shutil.copyfile(source,target)
                command=f'copy {guest(source)} {guest(target)}'
            else:
                data=f'S{seed}N{step}X{rng.getrandbits(32):08X}'
                target.write_bytes(data.encode()+b'\r');command=f'echo {data}>{guest(target)}'
        elif op=='append':
            target=rng.choice(files);data=f'APP{step}X{rng.getrandbits(32):08X}'
            with target.open('ab') as stream:stream.write(data.encode()+b'\r')
            command=f'echo {data}>+{guest(target)}'
        elif op=='delete':
            target=rng.choice(files);target.unlink();command=f'del {guest(target)}'
        elif op=='mkdir':
            parent=rng.choice([p for p in dirs if len(p.relative_to(host).parts)<2])
            target=parent/f'D{serial:04}';target.mkdir();command=f'makdir {guest(target)}'
        else:
            target=rng.choice(empty);target.rmdir();command=f'del {guest(target)}'
        commands.append(command);trace.append({'step':step,'operation':op,'command':command})
        if step%20==19:commands.append(f'echo RANDOMCHECKPOINT{step+1}')
    commands+=['dir /pc0/rand',f'echo RANDOMPASS{seed}']
    (root/'random-commands').write_text('\n'.join(commands)+'\n')
    (root/'random-trace.json').write_text(json.dumps({'seed':seed,'steps':steps,'operations':trace},indent=2)+'\n')
    return commands


def verify(fs,root):
    host=root/'reference';checked=[]
    def walk(local,remote):
        expected={p.name.upper() for p in local.iterdir()}
        assert set(fs.listdir(remote))==expected,('directory mismatch',remote,fs.listdir(remote),expected)
        for path in sorted(local.iterdir()):
            name=remote+'/'+path.name.upper()
            if path.is_dir():assert fs.isdir(name);walk(path,name)
            else:
                actual=fs.readbytes(name);expected=path.read_bytes()
                assert actual==expected,('content mismatch',name,len(actual),len(expected))
                checked.append({'path':name,'bytes':len(actual),'sha256':hashlib.sha256(actual).hexdigest()})
    walk(host,'/RAND')
    (root/'random-verified.json').write_text(json.dumps(checked,indent=2)+'\n')
    return len(checked)
