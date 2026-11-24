#!/usr/bin/env python3
"""Run resident/dynamic module unlink on MC6809 and check SysGo's scratch area."""
import importlib.util
import os
import re
import subprocess
import tempfile
from pathlib import Path

spec=importlib.util.spec_from_file_location('peers',Path(__file__).with_name('test-rename.py'))
t=importlib.util.module_from_spec(spec);spec.loader.exec_module(t)


def unlink_test(tmp):
    (tmp/'source.asm').write_text('Level equ 2\n use os9.d\n use coco.d\n org 0\n'+
        (t.ROOT/'level1/modules/kernel/funlink.asm').read_text())
    subprocess.run([os.environ.get('LWASM','lwasm'),'--6309','--format=os9',
        '--pragma=condundefzero','-DH6309=0','-I'+str(t.ROOT/'defs'),str(tmp/'source.asm'),
        '-o'+str(tmp/'module'),'--symbol-dump='+str(tmp/'symbols')],check=True)
    symbols=dict((n,int(v,16)) for n,v in re.findall(r'^(\S+) (?:EQU|SET) \$([0-9A-Fa-f]+)$',(tmp/'symbols').read_text(),re.M))
    binary=(tmp/'module').read_bytes();s=symbols
    for flags in (s['RAMinUse'],s['RAMinUse']|s['ModBlock'],0x80):
        for references in (0,1,2):
            cfg=t.TestCfg({'trace':False,'verbosity':0});m=t.Memory(cfg);c=t.CPU(m,cfg)
            m.load(t.BASE,binary)
            proc,regs,blocks,entry,dat=0x600,0x900,0xa00,0xb00,0xc00
            def word(a,v):m.write_word(a,v)
            word(s['D.Proc'],proc);word(s['D.BlkMap'],blocks)
            word(s['D.ModDir'],entry);word(s['D.ModEnd'],entry+s['MD$ESize'])
            word(regs+s['R$U'],0xe100)
            for slot in range(8):word(proc+s['P$DATImg']+slot*2,s['DAT.Free'])
            word(proc+s['P$DATImg']+14,10);word(proc+s['P$Links']+14,max(1,references))
            m.write_byte(blocks+10,flags)
            word(entry+s['MD$MPtr'],0x100);word(entry+s['MD$MPDAT'],dat)
            word(entry+s['MD$MBSiz'],0x1000);word(entry+s['MD$Link'],references)
            word(dat,10)
            c.user_stack_pointer.set(regs);c.system_stack_pointer.set(0x7800)
            word(0x7800,0x1fff);c.program_counter.set(t.BASE+s['FUnLink'])
            for _ in range(10000):
                pc=c.program_counter.value
                if pc==0x1fff:break
                if m.read_word(pc)==0x103f:
                    assert m.read_byte(pc+2)==s['F$LDDDXY']
                    c.accu_a.set(s['Prgrm']);c.accu_b.set(0);c.C=0;c.program_counter.set(pc+3)
                else:c.get_and_call_next_op()
            else:raise AssertionError('unlink did not return')
            assert not c.C and c.system_stack_pointer.value==0x7802
            released=int(references>0)
            assert m.read_word(proc+s['P$Links']+14)==max(1,references)-released
            assert m.read_word(entry+s['MD$Link'])==references-released
            mapping=m.read_word(proc+s['P$DATImg']+14)
            assert mapping==(s['DAT.Free'] if references==1 else 10)
            reclaim=flags & s['ModBlock'] and references==1
            assert m.read_byte(blocks+10)==(0 if reclaim else flags)
            assert m.read_word(entry+s['MD$MPDAT'])==(0 if reclaim else dat)
    print('F$UnLink: resident/ROM mappings released without reclaiming storage; dynamic reclamation, shared links and zero-count unlink no-op PASS')


if __name__=='__main__':
    with tempfile.TemporaryDirectory() as folder:
        tmp=Path(folder)
        unlink_test(tmp)
        for level in (1,2):
            binary,s=t.assemble(tmp,level,'level1/modules/sysgo.asm')
            size=int.from_bytes(binary[11:13],'big')
            assert size >= (s['P$Size']+250 if level==2 else 252)
        print('SysGo: Level 2 descriptor scratch buffer leaves a separate stack; Level 1 allocation retained PASS')
