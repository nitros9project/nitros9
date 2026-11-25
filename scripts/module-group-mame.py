#!/usr/bin/env python3
"""Verify real Level 2 multi-module unlink mappings, links and physical storage."""
import importlib.util
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[1]


def validate(data):
    size=8+512+64
    assert len(data)==6*4*size,('incomplete report',len(data))
    cases=[]
    for case in range(1,7):
        states=[]
        for phase in range(4):
            record=data[((case-1)*4+phase)*size:((case-1)*4+phase+1)*size]
            assert record[:2]==bytes([case,phase]) and record[6:8]==b'GR'
            word=lambda offset:int.from_bytes(record[offset:offset+2],'big')
            states.append({'a':word(2),'b':word(4),
                'dat':[word(8+0x40+i*2) for i in range(8)],
                'links':[word(8+0x80+i*2) for i in range(8)],
                'flags':list(record[8+512:])})
        first,middle,duplicate,last=states
        assert first['a']!=first['b'],(case,'modules are not distinct')
        assert all((state['a'],state['b'])==(first['a'],first['b']) for state in states)
        slot=first['a']//8192
        while slot and not first['links'][slot]:slot-=1
        assert first['links'][slot]==2,(case,'initial links',first)
        assert middle['dat']==first['dat'],(case,'survivor mappings changed')
        expected=first['links'].copy();expected[slot]-=1
        assert middle['links']==expected,(case,'first unlink references')
        assert duplicate['dat']==middle['dat'],(case,'double unlink changed mappings')
        assert duplicate['links']==middle['links'],(case,'double unlink consumed survivor reference')
        expected[slot]-=1
        assert last['links']==expected,(case,'last unlink references')
        slots=[i for i in range(8) if first['dat'][i]!=last['dat'][i]]
        assert slots and slots[0]==slot and slots==list(range(slot,slot+len(slots)))
        assert all(last['dat'][i]==0x333e for i in slots),(case,'group not unmapped')
        assert all(first['dat'][i]==last['dat'][i] for i in range(8) if i not in slots)
        blocks=[first['dat'][i] for i in slots]
        for block in blocks:
            assert middle['flags'][block]==first['flags'][block],(case,'premature reclaim')
            assert duplicate['flags'][block]==middle['flags'][block],(case,'double unlink reclaimed storage')
            if case<=4:
                assert first['flags'][block]&2,(case,'not dynamic module storage')
                assert last['flags'][block]&3==0,(case,'dynamic storage not reclaimed')
            else:
                assert first['flags'][block]&2==0,(case,'not resident storage')
                assert last['flags'][block]==first['flags'][block],(case,'resident storage reclaimed')
        if case<=2:
            assert len(slots)==1 and first['a']//8192==first['b']//8192
        else:
            assert len(slots)>1
            if case<=4:assert first['a']//8192!=first['b']//8192
        cases.append({'case':case,'kind':('one-block','multi-block','resident')[(case-1)//2],
            'unlink_order':'A,B' if case%2 else 'B,A','blocks':blocks,'states':states})
    return cases


def main():
    p=argparse.ArgumentParser();p.add_argument('--recipe',type=Path,required=True)
    p.add_argument('--cycles',type=int,default=1000)
    p.add_argument('--cpu',choices=('6809','6309'),default='6809')
    p.add_argument('--mame',default='mame');p.add_argument('--rompath',default=os.environ.get('MAME_ROMPATH',''))
    a=p.parse_args()
    if not 1 <= a.cycles <= 10000:p.error('--cycles must be between 1 and 10000')
    recipe=a.recipe.resolve();root=recipe/'.group-test';root.mkdir(exist_ok=True)
    (root/'result.json').unlink(missing_ok=True)
    for name in ('cfg','nvram','snap'):(root/name).mkdir(exist_ok=True)
    disk=root/'guest.dsk';shutil.copyfile(recipe/'l2_coco3_module_group_mame_test.dsk',disk)
    lua='completion_marker="RUNTIMEGROUPSPASS"\n'
    for key,name in [('snapshot_path','screen.png'),('console_path','console.log'),('errors_path','errors.log'),('writes_path','writes.log'),('reads_path','reads.log')]:
        lua+=key+'='+json.dumps(str(root/name))+'\n'
    lua+=(ROOT/'scripts/fat32-root-mame.lua').read_text()+(ROOT/'scripts/mame-disk-script.lua').read_text()
    (root/'run.lua').write_text(lua)
    command=[a.mame,('coco3h' if a.cpu=='6309' else 'coco3'),'-rompath',a.rompath,'-skip_gameinfo','-cfg_directory',str(root/'cfg'),
        '-nvram_directory',str(root/'nvram'),'-snapshot_directory',str(root/'snap'),'-ram','512K',
        '-ext','fdc,bios=v11','-ext:fdc:wd17xx:0','525dd','-flop1',str(disk),'-autoboot_delay','3',
        '-autoboot_script',str(root/'run.lua'),'-seconds_to_run','36000','-sound','none','-video','none','-nothrottle']
    (root/'command.json').write_text(json.dumps(command,indent=2)+'\n')
    with (root/'mame.log').open('w') as log:subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=3600)
    console=(root/'console.log').read_bytes();(root/'console.txt').write_bytes(console.replace(b'\r',b'\n'))
    assert all(marker in console for marker in (b'MODULEGROUPPASS',b'MULTIPROCESSPASS',b'RESOURCELEAKPASS',b'RUNTIMEGROUPSPASS')),('guest regression failed',str(root/'console.txt'))
    report=root/'group.report';report.unlink(missing_ok=True)
    subprocess.run(['os9','copy',str(disk)+',group.report',str(report)],check=True,capture_output=True)
    cases=validate(report.read_bytes())
    spec=importlib.util.spec_from_file_location('runtime_evidence',ROOT/'scripts/module-runtime-evidence.py')
    evidence=importlib.util.module_from_spec(spec);spec.loader.exec_module(evidence)
    def extract(name):
        target=root/name;target.unlink(missing_ok=True)
        subprocess.run(['os9','copy',str(disk)+','+name,str(target)],check=True,capture_output=True)
        return target.read_bytes()
    processes=evidence.multiprocess(extract('parent.bin'),[extract('child1.bin'),extract('child2.bin')])
    assert b'leak.tmp' not in subprocess.run(['os9','dir',str(disk)+','],check=True,capture_output=True).stdout.lower()
    resources=evidence.resources(extract('leak.bin'),a.cycles)
    spec_disk=importlib.util.spec_from_file_location('disk_evidence',ROOT/'scripts/rbf-disk-evidence.py')
    disk_evidence=importlib.util.module_from_spec(spec_disk);spec_disk.loader.exec_module(disk_evidence)
    disk_evidence.check(recipe/'l2_coco3_module_group_mame_test.dsk',disk,root)
    (root/'result.json').write_text(json.dumps({'passed':True,'cpu':a.cpu,'cases':cases,'multiprocess':processes,'resources':resources},indent=2)+'\n')
    print('PASS: synchronized two-process ownership; measured resource stability over',a.cycles,'cycles; two distinct modules in one file; single/multiple blocks; both unlink orders and extra unlink; resident preservation/dynamic reclamation; artifacts:',root)


if __name__=='__main__':main()
