#!/usr/bin/env python3
"""Seeded assembled-PCF operations checked against real host files and PyFatFS."""
import argparse
from collections import Counter
import importlib.util
import json
from pathlib import Path
import random
import shutil
from pyfatfs.PyFatFS import PyFatFS

ROOT=Path(__file__).resolve().parents[1]
def module(name,file):
    spec=importlib.util.spec_from_file_location(name,ROOT/'scripts'/file)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result
w=module('write_test','test-pcf-write.py');reference=module('reference','pcf-random.py');fat_check=module('fat_check','check-fat-image.py')


def run(image,out,level,seed,steps,checker):
    out.mkdir(parents=True,exist_ok=True);host=out/'reference';host.mkdir()
    raw=image.read_bytes();boot=raw[:512]
    v=w.f.Volume(base=0);v.total=int.from_bytes(boot[32:36],'little');v.spc=boot[13]
    reserved=int.from_bytes(boot[14:16],'little')
    v.fatsize=int.from_bytes(boot[36:40],'little');v.data=reserved+boot[16]*v.fatsize
    v.sectors={i//512:bytearray(raw[i:i+512]) for i in range(0,len(raw),512) if any(raw[i:i+512])}
    p=w.build(out,level,v);rng=random.Random(seed);trace=[];counts=Counter()
    def call(name,**kw):
        result=p.call(name,**kw)
        assert not result[0],(level,seed,len(trace),name,kw,result)
        return result
    def guest(path):return '/pc0/RAND/'+path.name
    def verify_guest(path):
        expected=path.read_bytes();call('Open',mode=1,path=guest(path));actual=bytearray()
        while len(actual)<len(expected):
            n=call('Read',count=min(1024,len(expected)-len(actual)))[2]
            assert n>0;actual+=p.data(w.f.OUTPUT,n)
        result=p.call('Read',count=1);assert result[:2]==(1,p.s['E$EOF']),result
        call('Close');assert actual==expected,(level,seed,len(trace),path.name,'guest content mismatch')
    def checkpoint():
        media=out/'media.vhd'
        with media.open('wb') as stream:
            stream.truncate(v.total*512)
            for lba,data in v.sectors.items():stream.seek(lba*512);stream.write(data)
        with PyFatFS(str(media),read_only=True) as fs:reference.verify(fs,out)
        for sector in range(v.fatsize):
            assert v.sectors.get(reserved+sector,bytes(512))==v.sectors.get(reserved+v.fatsize+sector,bytes(512)),('FAT mirror',sector)
    call('MkDir',path='/pc0/RAND')
    for step in range(steps):
        files=sorted(host.iterdir());op=rng.choice(['create']*2+(['write','append','resize','delete'] if files else []))
        path=host/f'F{step:04}.BIN' if op=='create' else rng.choice(files)
        info={'step':step,'operation':op,'file':path.name};trace.append(info);counts[op]+=1
        # Persist the replay prefix before executing the operation.
        (out/'trace.json').write_text(json.dumps({'seed':seed,'level':level,'operations':trace},indent=2)+'\n')
        if op=='create':call('Create',mode=3,path=guest(path));call('Close');path.touch()
        elif op=='delete':call('Delete',path=guest(path));path.unlink()
        else:
            call('Open',mode=3,path=guest(path))
            if op=='resize':
                size=rng.choice([0,1,255,256,511,512,513,1023,2048,4097]);info['size']=size
                call('SetStat',status=p.s['SS.Size'],position=size)
                with path.open('r+b') as stream:stream.truncate(size)
            else:
                offset=path.stat().st_size if op=='append' else rng.choice([0,1,255,256,511,512,513,1023,4095,8191])
                data=rng.randbytes(rng.choice([1,2,31,255,256,511,512,513,1024]));info.update(offset=offset,data=data.hex())
                call('Seek',position=offset);p.m.load(w.f.OUTPUT,data)
                assert call('Write',count=len(data))[2]==len(data)
                with path.open('r+b') as stream:stream.seek(offset);stream.write(data)
            call('Close')
        if path.exists():verify_guest(path)
        if step%25==24:
            checkpoint();print(f'Level {level} seed {seed}: {step+1}/{steps} operations verified',flush=True)
    checkpoint()
    (out/'trace.json').write_text(json.dumps({'seed':seed,'level':level,'operations':trace},indent=2)+'\n')
    fat_check.check(out/'media.vhd',out/'fsck.log',checker)
    result={'passed':True,'fat_integrity_checked':True,'level':level,'seed':seed,'operations':steps,'counts':dict(counts),'files':len(list(host.iterdir()))}
    (out/'result.json').write_text(json.dumps(result,indent=2)+'\n');return result


def main():
    p=argparse.ArgumentParser();p.add_argument('--image',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--fsck',default=fat_check.default_checker());p.add_argument('--steps',type=int,default=150);p.add_argument('--seeds',type=int,nargs='+',default=[17,20261108]);a=p.parse_args()
    a.image=a.image.resolve();a.output=a.output.resolve()
    a.output.mkdir(parents=True,exist_ok=True);results=[]
    for level in (1,2):
        for seed in a.seeds:
            out=a.output/f'l{level}-s{seed}'
            if out.exists():shutil.rmtree(out)
            results.append(run(a.image,out,level,seed,a.steps,a.fsck))
    (a.output/'result.json').write_text(json.dumps(results,indent=2)+'\n')
    print('PASS: randomized PCF operations match host files, guest reads, independent FAT32 reads, and FAT mirrors',flush=True)

if __name__=='__main__':main()
