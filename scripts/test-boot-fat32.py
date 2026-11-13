#!/usr/bin/env python3
"""Run the 464-byte FAT32 Boot module on MC6809 with VHD DMA and F$BtMem."""
import importlib.util
import os
import re
from pathlib import Path
import subprocess
import tempfile
spec=importlib.util.spec_from_file_location('fat_tests',Path(__file__).with_name('test-fat32.py'))
f=importlib.util.module_from_spec(spec);spec.loader.exec_module(f)

class Boot:
    def __init__(self,module,volume,fail=None,alloc_fail=False):
        cfg=f.blk.TestCfg({'trace':False,'verbosity':0})
        self.m=f.blk.Memory(cfg);self.c=f.blk.CPU(self.m,cfg)
        # MC6809 constructor assumes <=32K RAM; writes consult cfg dynamically.
        cfg.RAM_END=0xfeff;cfg.ROM_START=0xff00
        self.s=module[1];self.volume=volume;self.reads=[];self.reg=bytearray(7)
        self.fail=fail;self.alloc_fail=alloc_fail;self.status=0;self.allocated=None
        self.m.load(0xee30,module[0])
        self.m.load(0x500,b"\xa5"*512)
        for a in range(0xff80,0xff87):self.m.add_write_byte_callback(self.write,a)
        self.m.add_read_byte_callback(lambda *_:self.status,0xff83)
    def write(self,cycles,pc,address,value):
        self.reg[address-0xff80]=value
        if address!=0xff83:return
        assert value==0,'boot attempted a disk write'
        record=int.from_bytes(self.reg[:3],'big');buffer=int.from_bytes(self.reg[4:6],'big')
        assert buffer&255==0
        self.reads.append(record)
        self.status=6 if self.fail==len(self.reads) else 0
        if not self.status:
            data=self.volume.sectors.get(record//2,bytes(512))
            self.m.load(buffer,data[(record&1)*256:((record&1)+1)*256])
    def run(self):
        c=self.c;s=self.s
        c.system_stack_pointer.set(0x7d0);self.m.write_word(0x7d0,0x1fff)
        c.program_counter.set(0xee30+s['start'])
        for _ in range(2000000):
            pc=c.program_counter.value
            if pc==0x1fff:break
            if self.m.read_word(pc)==0x103f:
                assert self.m.read_byte(pc+2)==s['F$BtMem']
                self.allocated=c.accu_d.value
                c.C=int(self.alloc_fail)
                if self.alloc_fail:c.accu_b.set(s['E$MemFul'])
                else:c.user_stack_pointer.set(0x6000)
                c.program_counter.set(pc+3)
            else:c.get_and_call_next_op()
        else:raise AssertionError(('boot hung',hex(pc),self.reads[-10:]))
        assert c.system_stack_pointer.value==0x7d2
        assert bytes(self.m.read_byte(i) for i in range(0x500,0x700))==b"\xa5"*512, "kernel tables overwritten"
        return c.C,c.accu_d.value,c.index_x.value
    def loaded(self,size):return bytes(self.m.read_byte(0x6000+i) for i in range(size))

def assemble(tmp,base=0,unit=0,cpu=0):
    (tmp/'defsfile').write_text('Level equ 2\n use os9.d\n use scf.d\n use rbf.d\n use coco.d\n')
    subprocess.run([os.environ.get('LWASM','lwasm'), '--6309' if cpu else '--6809',
        '--format=os9','--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
        '-I'+str(tmp),'-I'+str(f.ROOT/'defs'),f'-DH6309={cpu}',f'-DFATBase={base}',f'-DDISKNUM={unit}',
        str(f.ROOT/'level1/coco1/modules/boot_fat32.asm'),'-o'+str(tmp/'boot'),
        '--symbol-dump='+str(tmp/'boot.sym')],check=True,capture_output=True)
    symbols={n:int(v,16) for n,v in re.findall(r'^(\S+) (?:EQU|SET) \$([\da-fA-F]+)$',
        (tmp/'boot.sym').read_text(),re.M)}
    module=(tmp/'boot').read_bytes()
    assert len(module)==464 and int.from_bytes(module[2:4],'big')==464
    return module,symbols

def volume(spc=1,base=0,fats=2,size=None,high=False):
    v=f.Volume(base=base,spc=spc)
    v.sectors[base][16]=fats
    v.data=base+32+fats*v.fatsize
    # Traverse an entire root cluster, then another record before finding OS9BOOT.
    v.fat(2,5);v.fat(5,0x0fffffff)
    filler=v.entry('OTHER.TXT',0,0)
    v.put(2,filler*(512*spc//32))
    payload=bytes((i*73+19)&255 for i in range(size if size is not None else min(2*512*spc+276,35000)))
    chain=[10,0x10001 if high else 300,11]
    v.put(5,filler*8+v.entry('OS9BOOT',chain[0],len(payload)))
    for index,off in enumerate(range(0,len(payload),512*spc)):
        v.put(chain[index],payload[off:off+512*spc])
        v.fat(chain[index],chain[index+1] if off+512*spc<len(payload) else 0x0fffffff)
    return v,payload

def main():
    with tempfile.TemporaryDirectory(prefix='boot-fat32-') as d:
        tmp=Path(d)
        for base,unit in ((0,0),(2048,1),(0x100000,0)):
            module=assemble(tmp,base,unit)
            for spc in (1,2,4,8,16,32,64,128):
                for fats in (1,2):
                    v,payload=volume(spc,base,fats,high=spc==1)
                    p=Boot(module,v)
                    assert p.run()==(0,len(payload),0x6000),(base,spc,fats)
                    assert p.loaded(len(payload))==payload,(base,spc,fats,'data')
                    assert p.reg[6]==unit
            print(f'PASS: base {base:#x}, unit {unit}; 1/2 FATs; 1..128-sector clusters; fragmented directory/file, high cluster, full bytes')
        module=assemble(tmp)
        for size in (1,255,256,257,512,1300,33156):
            v,payload=volume(spc=64 if size>1300 else 1,size=size)
            p=Boot(module,v);assert p.run()==(0,size,0x6000)
            assert p.allocated==size and p.loaded(size)==payload
        v,payload=volume()
        good=Boot(module,v);good.run()
        for failure in range(1,len(good.reads)+1):
            p=Boot(module,v,fail=failure);assert p.run()[0]==1
        p=Boot(module,v,alloc_fail=True)
        result=p.run();assert result[0]==1 and result[1]&255==module[1]['E$MemFul']
        for spc in (0,3,6,127,255):
            v,_=volume();v.sectors[0][13]=spc
            assert Boot(module,v).run()[0]==1
        for invalid_size in (0,0xff01,0x10000):
            v,_=volume();v.put(2,v.entry('OS9BOOT',10,invalid_size))
            assert Boot(module,v).run()[0]==1
        v,_=volume();v.put(2,bytes(512));assert Boot(module,v).run()[0]==1
        v,_=volume();v.fat(10,0x0fffffff);assert Boot(module,v).run()[0]==1
        v,_=volume();v.sectors[0][11:13]=(1024).to_bytes(2,'little');assert Boot(module,v).run()[0]==1
        assert assemble(tmp,cpu=1)[0]==module[0], '6809/6309 build differs'
        print('PASS: exactly 464 bytes on both CPUs; partial/full final records; every read failure; allocation error; missing/truncated file; invalid sector/cluster/file sizes; kernel-table guards')

if __name__=='__main__':main()
