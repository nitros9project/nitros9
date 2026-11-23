#!/usr/bin/env python3
"""Verify real Level 2 multi-module unlink mappings, links and physical storage."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[1]


def validate(data):
    size=8+512+64
    assert len(data)==6*3*size,('incomplete report',len(data))
    cases=[]
    for case in range(1,7):
        states=[]
        for phase in range(3):
            record=data[((case-1)*3+phase)*size:((case-1)*3+phase+1)*size]
            assert record[:2]==bytes([case,phase]) and record[6:8]==b'GR'
            word=lambda offset:int.from_bytes(record[offset:offset+2],'big')
            states.append({'a':word(2),'b':word(4),
                'dat':[word(8+0x40+i*2) for i in range(8)],
                'links':[word(8+0x80+i*2) for i in range(8)],
                'flags':list(record[8+512:])})
        first,middle,last=states
        assert first['a']!=first['b'],(case,'modules are not distinct')
        assert all((state['a'],state['b'])==(first['a'],first['b']) for state in states)
        slot=first['a']//8192
        while slot and not first['links'][slot]:slot-=1
        assert first['links'][slot]==2,(case,'initial links',first)
        assert middle['dat']==first['dat'],(case,'survivor mappings changed')
        expected=first['links'].copy();expected[slot]-=1
        assert middle['links']==expected,(case,'first unlink references')
        expected[slot]-=1
        assert last['links']==expected,(case,'last unlink references')
        slots=[i for i in range(8) if first['dat'][i]!=last['dat'][i]]
        assert slots and slots[0]==slot and slots==list(range(slot,slot+len(slots)))
        assert all(last['dat'][i]==0x333e for i in slots),(case,'group not unmapped')
        assert all(first['dat'][i]==last['dat'][i] for i in range(8) if i not in slots)
        blocks=[first['dat'][i] for i in slots]
        for block in blocks:
            assert middle['flags'][block]==first['flags'][block],(case,'premature reclaim')
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
    p.add_argument('--mame',default='mame');p.add_argument('--rompath',default=os.environ.get('MAME_ROMPATH',''))
    a=p.parse_args();recipe=a.recipe.resolve();root=recipe/'.group-test';root.mkdir(exist_ok=True)
    for name in ('cfg','nvram','snap'):(root/name).mkdir(exist_ok=True)
    disk=root/'guest.dsk';shutil.copyfile(recipe/'l2_coco3_module_group_mame_test.dsk',disk)
    lua='completion_marker="MODULEGROUPPASS"\n'
    for key,name in [('snapshot_path','screen.png'),('console_path','console.log'),('errors_path','errors.log'),('writes_path','writes.log'),('reads_path','reads.log')]:
        lua+=key+'='+json.dumps(str(root/name))+'\n'
    lua+=(ROOT/'scripts/fat32-root-mame.lua').read_text()+(ROOT/'scripts/mame-disk-script.lua').read_text()
    (root/'run.lua').write_text(lua)
    command=[a.mame,'coco3','-rompath',a.rompath,'-skip_gameinfo','-cfg_directory',str(root/'cfg'),
        '-nvram_directory',str(root/'nvram'),'-snapshot_directory',str(root/'snap'),'-ram','512K',
        '-ext','fdc,bios=v11','-ext:fdc:wd17xx:0','525dd','-flop1',str(disk),'-autoboot_delay','3',
        '-autoboot_script',str(root/'run.lua'),'-seconds_to_run','300','-sound','none','-video','none','-nothrottle']
    with (root/'mame.log').open('w') as log:subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=360)
    console=(root/'console.log').read_bytes();(root/'console.txt').write_bytes(console.replace(b'\r',b'\n'))
    assert b'MODULEGROUPPASS' in console,('guest regression failed',str(root/'console.txt'))
    report=root/'group.report';report.unlink(missing_ok=True)
    subprocess.run(['os9','copy',str(disk)+',group.report',str(report)],check=True,capture_output=True)
    cases=validate(report.read_bytes())
    (root/'result.json').write_text(json.dumps({'passed':True,'cases':cases},indent=2)+'\n')
    print('PASS: two distinct modules in one file; single/multiple blocks; both unlink orders; resident preservation/dynamic reclamation; artifacts:',root)


if __name__=='__main__':main()
