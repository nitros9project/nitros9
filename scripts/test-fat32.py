#!/usr/bin/env python3
"""Execute assembled FAT/blkdrv against sparse but geometrically valid FAT32 media.
Requires lwasm and MC6809. --fixture-directory also emits the MAME fixture sources.
"""
import argparse
import importlib.util
import logging
import os
from pathlib import Path
import re
import subprocess
import tempfile
logging.disable(logging.CRITICAL)
ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('blkdrv_tests', ROOT/'scripts/test-blkdrv.py')
blk = importlib.util.module_from_spec(spec)
spec.loader.exec_module(blk)
blk.DRIVER, blk.BACKEND = 0x4000, 0x8000
FAT, WORK, REGS, PATH, OUTPUT, DEVTAB = 0x2000, 0x6000, 0x1300, 0x4800, 0x4800, 0x1400


def assemble_source(tmp, level, source, name, defines=()):
    (tmp/'defsfile').write_text(f'Level equ {level}\n use os9.d\n use scf.d\n use rbf.d\n use wildbits.d\n')
    p = subprocess.run([os.environ.get('LWASM', 'lwasm'), '--6809', '--format=os9',
        '--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
        '-I'+str(tmp), '-I'+str(source.parent), '-I'+str(ROOT/'defs'), '-DH6309=0', '-Dwildbits=1', *['-D'+value for value in defines], str(source),
        '-o'+str(tmp/name), '--symbol-dump='+str(tmp/(name+'.sym'))], cwd=tmp, capture_output=True, text=True)
    assert p.returncode == 0, p.stderr
    symbols = {n:int(v,16) for n,v in re.findall(r'^(\S+) (?:EQU|SET) \$([\da-fA-F]+)$', (tmp/(name+'.sym')).read_text(), re.M)}
    return (tmp/name).read_bytes(), symbols


class Volume:
    def __init__(self, base=2048, spc=1, active=0):
        self.base, self.total, self.fatsize, self.spc = base, 70000, 600, spc
        # Keep the FAT32 minimum cluster count for larger clusters too.
        self.total = 1200+32+68768*spc
        self.data = base+32+1200
        self.sectors = {}
        boot = bytearray(512)
        boot[:3] = b'\xeb\x58\x90'
        boot[3:11] = b'FATTEST '
        boot[11:13] = (512).to_bytes(2,'little')
        boot[13] = spc
        boot[14:16] = (32).to_bytes(2,'little')
        boot[16] = 2
        boot[21] = 0xf8
        boot[28:32] = base.to_bytes(4,'little')
        boot[32:36] = self.total.to_bytes(4,'little')
        boot[36:40] = self.fatsize.to_bytes(4,'little')
        boot[40:42] = (0x81 if active else 0).to_bytes(2,'little')
        boot[44:48] = (2).to_bytes(4,'little')
        boot[48:50] = (1).to_bytes(2,'little')
        boot[50:52] = (6).to_bytes(2,'little')
        boot[510:512] = b'\x55\xaa'
        self.sectors[base] = boot
        self.active = active
        self.fat(0, 0x0ffffff8)
        self.fat(1, 0xffffffff)
        for cluster in (2,3,5,6,7,11):
            self.fat(cluster, 0x0fffffff)
        self.fat(10,300)
        self.fat(300,11)
        self.hello = b'FIRST\rSECOND\rTAIL'
        self.fragment = bytes((i*73+19)&255 for i in range(2*512*spc+276))
        self.put(3,self.hello)
        self.put(10,self.fragment[:512*spc])
        self.put(300,self.fragment[512*spc:1024*spc])
        self.put(11,self.fragment[1024*spc:])
        self.put(6,b'NESTED\r')
        self.put(7,self.entry('.',7,0,0x10)+self.entry('..',5,0,0x10))
        self.put(5,self.entry('.',5,0,0x10)+self.entry('..',0,0,0x10)+
                 self.entry('NEST.TXT',6,7)+self.entry('CHILD',7,0,0x10))
        root = self.entry('HELLO.TXT',3,len(self.hello))+self.entry('FRAG.BIN',10,len(self.fragment))+\
               self.entry('EMPTY.TXT',0,0)+self.entry('SUBDIR',5,0,0x10)+\
               bytes([0xe5])+bytes(31)+self.entry('LFNSLOT',0,0,0x0f)+self.entry('VOLUME',0,0,8)
        self.put(2,root)

    def fat(self, cluster, value):
        for f in (self.active,):
            sector = self.base+32+f*self.fatsize+cluster//128
            data = self.sectors.setdefault(sector,bytearray(512))
            off = cluster%128*4
            data[off:off+4] = value.to_bytes(4,'little')

    def put(self, cluster, data):
        assert len(data)<=512*self.spc
        for i in range((len(data)+511)//512):
            self.sectors[self.data+(cluster-2)*self.spc+i] = bytearray(data[i*512:(i+1)*512].ljust(512,b'\0'))

    @staticmethod
    def entry(name, cluster, size, attr=0x20):
        entry=bytearray(32)
        if name in ('.','..'):
            entry[:11]=name.encode().ljust(11,b' ')
        else:
            base,_,ext=name.partition('.')
            entry[:11]=base.encode().ljust(8,b' ')+ext.encode().ljust(3,b' ')
        entry[11]=attr
        entry[20:22]=(cluster>>16).to_bytes(2,'little')
        entry[26:28]=(cluster&65535).to_bytes(2,'little')
        entry[28:32]=size.to_bytes(4,'little')
        date=((2026-1980)<<9)|(11<<5)|8
        entry[24:26]=date.to_bytes(2,'little')
        entry[16:18]=date.to_bytes(2,'little')
        entry[22:24]=((12<<11)|(34<<5)).to_bytes(2,'little')
        return bytes(entry)

    def fixture(self, directory):
        directory.mkdir(parents=True,exist_ok=True)
        template=(ROOT/'scripts/fixtures/llfatfixture.asm').read_text()
        lines=['FixtureLast equ $%08x'%(self.base+self.total-1),'FixtureCount equ %d'%len(self.sectors), 'SectorTable']
        for index,lba in enumerate(sorted(self.sectors)):
            lines += [' fdb $%04x,$%04x,sector%d-SectorTable,%d'%(lba>>16,lba&65535,index,len(self.sectors[lba].rstrip(b'\0')))]
        for index,lba in enumerate(sorted(self.sectors)):
            lines.append('sector%d'%index)
            data=self.sectors[lba].rstrip(b'\0')
            for off in range(0,len(data),16):
                lines.append(' fcb '+','.join('$%02x'%b for b in data[off:off+16]))
        (directory/'fatfixture-data.asm').write_text('\n'.join(lines)+'\n')
        (directory/'llfatfixture.asm').write_text(template)
        return directory/'llfatfixture.asm'


class FatMachine(blk.Machine):
    def __init__(self, modules, fat, volume):
        super().__init__(modules, backend='llmemblk')
        self.fs = fat[1]
        self.m.load(FAT,fat[0])
        self.volume=volume
        self.m.load(blk.BACKEND,modules['fixture'][0])
        self.bs=modules['fixture'][1]
        self.word(blk.PD+self.s['PD.DEV'],DEVTAB)
        self.word(DEVTAB+self.s['V$STAT'],blk.STAT)
        self.word(DEVTAB+self.s['V$DESC'],blk.DESC)
        self.word(DEVTAB+self.s['V$DRIV'],blk.DRIVER)
        if 'V$DRIVEX' in self.s:
            self.word(DEVTAB+self.s['V$DRIVEX'],blk.DRIVER+self.s['start'])
        self.long(blk.DESC+self.fs['FT.Base'],volume.base)
        self.long(blk.DESC+self.fs['FT.Length'],volume.total)
        self.word(blk.PD+self.s['PD.RGS'],REGS)
        self.byte(blk.PD+self.s['PD.CNT'],1)
        self.word(0x600+self.s['P$DIO'],DEVTAB)
        self.word(0x600+self.s['P$DIO']+6,DEVTAB)
        if 'P$Task' in self.s:
            self.byte(0x600+self.s['P$Task'],3)
        self.fail_move=False
        self.ok('Init')

    def call(self, name, mode=None, path=None, count=0, position=0, status=0, cookie=0, cc=0, close_count=0):
        if name=='Close':self.byte(blk.PD+self.s['PD.CNT'],close_count)
        if mode is not None:self.byte(blk.PD+self.s['PD.MOD'],mode)
        if path is not None:self.m.load(PATH,path.encode()+b'\r')
        self.word(REGS+self.s['R$X'],PATH if path is not None else OUTPUT)
        self.word(REGS+self.s['R$Y'],count)
        self.byte(REGS+self.s['R$B'],status)
        if name=='Seek' or (name=='SetStat' and status==self.s['SS.Size']):
            self.word(REGS+self.s['R$X'],position>>16)
            self.word(REGS+self.s['R$U'],position&65535)
        if status==self.s['SS.FDInf']:
            self.word(REGS+self.s['R$Y'],((cookie>>16)<<8)|count)
            self.word(REGS+self.s['R$U'],cookie&65535)
        c,s=self.c,self.s
        c.index_x.set(0x1717);c.index_y.set(blk.PD);c.user_stack_pointer.set(REGS)
        c.system_stack_pointer.set(0x7000);self.word(0x7000,0x1fff)
        entry=self.fs['start']+name*3 if isinstance(name,int) else self.fs[name]
        c.program_counter.set(FAT+entry);c.set_cc(cc)
        for _ in range(3000000):
            pc=c.program_counter.value
            if pc==0x1fff:break
            if self.data(pc,2)==b'\x10\x3f':
                op=self.byte(pc+2)
                if op==s['F$SRqMem']:
                    assert c.accu_d.value==self.fs['F.Len']
                    c.user_stack_pointer.set(WORK);self.allocations.append(WORK);c.C=0
                elif op==s['F$SRtMem']:
                    self.allocations.remove(c.user_stack_pointer.value);c.C=0
                elif op in (s.get('F$GProcP',-1),s['F$Find64']):
                    process=getattr(self,'processes',{1:0x600}).get(c.accu_a.value)
                    if process is None:c.C=1
                    else:c.index_y.set(process);c.C=0
                elif op==s.get('F$LDABX',-1):
                    c.accu_a.set(self.byte(c.index_x.value))
                elif op==s.get('F$Move',-1):
                    if pc==FAT+self.fs['MoveBytes']:
                        user=self.byte(0x600+s['P$Task']);system=self.byte(s['D.SysTsk'])
                        incoming=c.index_x.value==self.word(WORK+self.fs['F.Dest'])
                        assert (c.accu_a.value,c.accu_b.value)==((user,system) if incoming else (system,user)),('transfer task direction',name)
                    if self.fail_move:c.accu_b.set(s['E$IBA']);c.C=1
                    else:
                        self.m.load(c.user_stack_pointer.value,self.data(c.index_x.value,c.index_y.value));c.C=0
                else:raise AssertionError(('unexpected syscall',op,name))
                c.program_counter.set(pc+3)
            else:c.get_and_call_next_op()
        else:raise AssertionError(('loop',name,hex(c.program_counter.value)))
        assert c.system_stack_pointer.value==0x7002,(name,'stack',hex(c.system_stack_pointer.value))
        assert c.index_x.value==0x1717 and c.index_y.value==blk.PD and c.user_stack_pointer.value==REGS,(name,'registers')
        assert c.get_cc_value()&0x50==cc&0x50
        return c.C,c.accu_b.value,self.word(REGS+s['R$Y'])


def build(tmp,level,v):
    modules=blk.assemble(tmp,level)
    modules['fixture']=assemble_source(tmp,level,v.fixture(tmp),'llfatfixture')
    fat=assemble_source(tmp,level,ROOT/'level1/modules/pcf.asm','pcf')
    return modules,fat


def copy_checks(p):
    # Differential check against the original LoadVal/StoreVal sequence,
    # including high-bit offsets, arithmetic flags and caller registers.
    c=p.c
    def invoke(name):
        c.system_stack_pointer.set(0x7000);p.word(0x7000,0x1fff)
        c.program_counter.set(FAT+p.fs[name])
        for _ in range(100):
            if c.program_counter.value==0x1fff:break
            c.get_and_call_next_op()
        else:raise AssertionError(('helper loop',name))
        assert c.system_stack_pointer.value==0x7002
    for source,target in [('F.Start','F.Child'),('F.Child','F.Pos'),('F.Scan','F.Offset')]:
        source,target=p.fs[source],p.fs[target]
        for value in (0,0x7fffffff,0x80000000,0xffffffff,0x12345678):
            for flags in (0,1,0x50,0x51,0xaf):
                results=[]
                for implementation in ('legacy','copy','fields'):
                    p.m.load(WORK,bytes(256));p.long(WORK+source,value)
                    c.user_stack_pointer.set(WORK);c.index_y.set(0x1818)
                    c.accu_d.set(source*256+target);c.set_cc(flags)
                    if implementation=='copy':invoke('CopyVal')
                    elif implementation=='fields':
                        c.accu_a.set((source-128)&255);invoke('LoadField')
                        c.accu_a.set((target-128)&255);invoke('StoreField')
                    else:
                        c.index_x.set(WORK+source);invoke('LoadVal')
                        c.index_x.set(WORK+target);invoke('StoreVal')
                    results.append((p.data(WORK,256),c.accu_d.value,c.index_x.value,
                                    c.index_y.value,c.user_stack_pointer.value,c.get_cc_value()))
                assert results[0]==results[1]==results[2],('copy semantics',source,target,value,flags)
    # Unsigned word addition must propagate carry through all 32 bits.
    for value in (0,0x7fffffff,0xffff0000,0xffffffff):
        for amount in (0,1,32,64,127,65535):
            p.long(WORK+p.fs['F.Val'],value)
            c.user_stack_pointer.set(WORK);c.index_x.set(0x1717);c.index_y.set(0x1818)
            c.accu_d.set(amount);c.set_cc(0xf1);invoke('AddWord')
            total=value+amount
            assert p.data(WORK+p.fs['F.Val'],4)==(total&0xffffffff).to_bytes(4,'big')
            assert c.C==int(total>0xffffffff) and c.accu_d.value==((total>>16)&65535)
            assert c.index_x.value==0x1717 and c.index_y.value==0x1818 and c.user_stack_pointer.value==WORK
            assert c.get_cc_value()&0xd0==0xd0 # ADCA may change half-carry, as before.
            p.long(WORK+p.fs['F.Val'],0x89abcdef);p.long(WORK+p.fs['F.Pos'],value)
            c.accu_d.set(amount);c.set_cc(0xf1);invoke('AddPosition')
            assert p.data(WORK+p.fs['F.Pos'],4)==(total&0xffffffff).to_bytes(4,'big')
            assert p.data(WORK+p.fs['F.Val'],4)==bytes.fromhex('89abcdef')
            assert c.C==int(total>0xffffffff) and c.accu_d.value==((total>>16)&65535)
            assert c.index_x.value==0x1717 and c.index_y.value==0x1818 and c.user_stack_pointer.value==WORK
            assert c.get_cc_value()&0xd0==0xd0
        field=p.fs['F.Child'];p.long(WORK+field,value)
        c.accu_a.set((field-128)&255);c.set_cc(0xf1);invoke('IncField')
        result=(value+1)&0xffffffff
        assert p.data(WORK+field,4)==p.data(WORK+p.fs['F.Val'],4)==result.to_bytes(4,'big')
        assert c.C==int(value==0xffffffff) and c.accu_d.value==(result&65535)
        assert c.index_x.value==WORK+field and c.index_y.value==0x1818 and c.user_stack_pointer.value==WORK
        assert c.get_cc_value()&0xd0==0xd0 # ADCA may change half-carry, as before.
    # Clamp FAT years to 1980..2107; retain other byte behavior.
    for axis in range(6):
        for byte in range(256):
            clock=[126,11,8,12,34,58];clock[axis]=byte
            year,month,day,hour,minute,second=clock
            month=month or 1;day=day or 1;year=min(max(year,80),207)-80
            expected=bytes(((minute*32 | second//2)&255,
                            (hour*8 | minute//8)&255,
                            (month*32 | day)&255,
                            (year*2 | month//8)&255))
            p.m.load(WORK+p.fs['F.Time'],bytes(clock))
            c.user_stack_pointer.set(WORK);c.index_x.set(0x1717);c.index_y.set(0x1818)
            invoke('EncodeTime')
            assert p.data(WORK+p.fs['F.Entry']+22,4)==expected,('timestamp',clock)
            assert c.C==(second&1)
            assert c.index_x.value==0x1717 and c.index_y.value==0x1818 and c.user_stack_pointer.value==WORK
    dates={(high,low) for high in (0,1,2,127,128,255) for low in range(256)}
    dates|={(high,low) for high in range(256) for low in (0,31,32,127,128,255)}
    for high,low in sorted(dates):
        p.m.load(OUTPUT,bytes((low,high)))
        c.index_x.set(OUTPUT);c.index_y.set(OUTPUT+16);c.accu_b.set(0x5a)
        invoke('DateToOS9')
        assert p.data(OUTPUT+16,3)==bytes((high//2+80,((high&1)<<3)|(low>>5),low&31))
        assert c.index_x.value==OUTPUT and c.index_y.value==OUTPUT+16 and c.accu_b.value==0x5a
    p.m.load(WORK,bytes(256))


def test(tmp,level):
    v=Volume()
    modules,fat=build(tmp,level,v)
    p=FatMachine(modules,fat,v)
    print('pcf Level',level,'module',len(fat[0]),'bytes',flush=True)
    copy_checks(p)
    p.byte(blk.STAT+p.s['V.BUSY'],1)
    for slot in range(13):
        assert p.call(slot,cc=0x50)[:2]==(1,p.s['E$DevBsy']),('busy entry',slot)
        assert p.byte(blk.STAT+p.s['V.BUSY'])==1
    p.byte(blk.STAT+p.s['V.BUSY'],0)
    print('  copy/arithmetic/timestamp equivalence and all 13 busy ABI entry slots passed',flush=True)
    def ok(name,**kw):
        r=p.call(name,**kw)
        assert not r[0],(name,r)
        return r
    def err(name,code,**kw):
        r=p.call(name,**kw)
        assert r[:2]==(1,p.s[code]),(name,r,code)
        return r
    err('MkDir','E$WP',path='/pc0/NEW.DIR')
    assert p.allocations==[blk.STATE]
    for suffix in ('', '   ', ', ', ' /pc0/frag.bin'):
        ok('Open',mode=1,path='/pc0/hello.txt'+suffix)
        consumed=len('/pc0/hello.txt')+len(suffix)-len(suffix.lstrip(' ,'))
        assert p.word(REGS+p.s['R$X'])==PATH+consumed,('pathname return',suffix)
        ok('Close')
    ok('Open',mode=1,path='/pc0/hello.txt')
    ok('Close',close_count=1)
    assert WORK in p.allocations,'duplicated path freed prematurely'
    ok('Read',count=128)
    assert p.data(OUTPUT,len(v.hello))==v.hello
    err('Read','E$EOF',count=1)
    ok('Seek',position=0)
    r=ok('ReadLn',count=128)
    assert r[2]==6 and p.data(OUTPUT,6)==b'FIRST\r'
    r=ok('ReadLn',count=128)
    assert r[2]==7 and p.data(OUTPUT,7)==b'SECOND\r'
    ok('GetStat',status=p.s['SS.Size'])
    assert p.word(REGS+p.s['R$U'])==len(v.hello)
    ok('Close')
    assert p.allocations==[blk.STATE]
    ok('Open',mode=1,path='/pc0/frag.bin')
    r=ok('Read',count=2000)
    assert r[2]==len(v.fragment)
    assert p.data(OUTPUT,len(v.fragment))==v.fragment
    for pos in (511,512,513,1023,1024,1299,0):
        ok('Seek',position=pos)
        r=ok('Read',count=33)
        assert p.data(OUTPUT,r[2])==v.fragment[pos:pos+r[2]],pos
    ok('Close')
    ok('Open',mode=1,path='/pc0/subdir/nest.txt')
    r=ok('Read',count=32)
    assert p.data(OUTPUT,r[2])==b'NESTED\r'
    ok('Close')
    ok('ChgDir',mode=1,path='/pc0/subdir')
    ok('Open',mode=1,path='nest.txt')
    ok('Close')
    ok('ChgDir',mode=1,path='child')
    ok('ChgDir',mode=1,path='...')
    ok('Open',mode=1,path='hello.txt')
    ok('Close')
    ok('Open',mode=0x81,path='/pc0')
    r=ok('Read',count=512)
    assert p.data(OUTPUT,2)==b'.\xae'
    assert p.data(OUTPUT+32,1)==b'\xae'
    assert p.data(OUTPUT+64,9)==b'HELLO.TX\xd4'
    cookie=int.from_bytes(p.data(OUTPUT+64+29,3),'big')
    ok('GetStat',status=p.s['SS.FDInf'],cookie=cookie,count=16)
    assert int.from_bytes(p.data(OUTPUT+9,4),'big')==len(v.hello)
    assert p.data(OUTPUT+3,5)==bytes([126,11,8,12,34])
    ok('Close')
    for count in (32,45):
        ok('Open',mode=0x81,path='/pc0')
        for index,(name,size) in enumerate((('HELLO.TXT',17),('FRAG.BIN',1300),('EMPTY.TXT',0),('SUBDIR',0)),1):
            p.m.load(OUTPUT,b'\x55'*64)
            r=ok('GetStat',status=p.s['SS.ReadDir'],count=count)
            assert r[2]==count
            result=p.data(OUTPUT,count)
            assert result[:len(name)]==name[:-1].encode()+bytes([ord(name[-1])|128])
            assert int.from_bytes(result[29:32],'big')==index
            assert p.data(OUTPUT+count,1)==b'\x55'
            if count==45:
                assert int.from_bytes(result[41:45],'big')==size
                assert result[35:40]==bytes([126,11,8,12,34])
                assert bool(result[32]&0x80)==(name=='SUBDIR')
                ok('GetStat',status=p.s['SS.FDInf'],cookie=index,count=16)
                assert p.data(OUTPUT,13)==result[32:45],'FD and ReadDir metadata differ'
                assert p.data(OUTPUT+13,3)==bytes([126,11,8])
        err('GetStat','E$EOF',status=p.s['SS.ReadDir'],count=count)
        ok('Seek',position=0)
        ok('GetStat',status=p.s['SS.ReadDir'],count=count)
        assert p.data(OUTPUT,9)==b'HELLO.TX\xd4'
        for bad in (0,31,33,44,46,65535):
            err('GetStat','E$BPNam',status=p.s['SS.ReadDir'],count=bad)
        ok('Seek',position=1)
        err('GetStat','E$BPNam',status=p.s['SS.ReadDir'],count=count)
        ok('Close')
    ok('Open',mode=0x81,path='/pc0/subdir')
    for name in ('NEST.TXT','CHILD'):
        ok('GetStat',status=p.s['SS.ReadDir'],count=45)
        assert p.data(OUTPUT,len(name))==name[:-1].encode()+bytes([ord(name[-1])|128])
    err('GetStat','E$EOF',status=p.s['SS.ReadDir'],count=32)
    ok('Close')
    if level==2:
        ok('Open',mode=0x81,path='/pc0')
        p.fail_move=True
        err('GetStat','E$IBA',status=p.s['SS.ReadDir'],count=45)
        p.fail_move=False
        ok('Seek',position=0)
        ok('GetStat',status=p.s['SS.ReadDir'],count=45)
        assert p.data(OUTPUT,9)==b'HELLO.TX\xd4'
        ok('Close')
    ok('Open',mode=1,path='/pc0/hello.txt')
    p.m.load(OUTPUT,b'\x55'*257)
    ok('GetStat',status=p.s['SS.FD'],count=256)
    assert p.data(OUTPUT+1,2)==bytes(2) and p.byte(OUTPUT+8)==1
    assert p.data(OUTPUT+13,3)==bytes([126,11,8])
    assert p.data(OUTPUT+16,240)==bytes(240)
    assert p.byte(OUTPUT+256)==0x55
    err('GetStat','E$FNA',status=p.s['SS.ReadDir'],count=32)
    err('ReadOnly','E$WP',status=p.s['SS.Rename'])
    ok('Close')
    err('Open','E$WP',mode=2,path='/pc0/new.txt')
    err('Open','E$PNNF',mode=1,path='/pc0/missing')
    assert p.allocations==[blk.STATE]
    print('  files, fragmentation, ReadLn, seek, chd, directory view and metadata passed',flush=True)


def extended_tests(tmp,level):
    def machine(volume):
        modules,fat=build(tmp,level,volume)
        return FatMachine(modules,fat,volume)
    # Geometry, active FAT selection, superfloppy and non-24-bit device LBAs.
    for base,spc,active in ((0,1,0),(0x01000000,2,1),(2048,4,0)):
        v=Volume(base=base,spc=spc,active=active);p=machine(v)
        assert p.call('Open',mode=1,path='/pc0/frag.bin')[0]==0
        result=p.call('Read',count=len(v.fragment))
        assert result[0]==0 and result[2]==len(v.fragment),(base,spc,result)
        assert p.data(OUTPUT,len(v.fragment))==v.fragment
        p.call('Close')
    # Both directory context and file clusters retain their fourth byte.
    v=Volume();olddata=v.data;oldsectors=dict(v.sectors)
    rootcluster=0x01000002
    clusters=0x01000100
    v.fatsize=(clusters+2+127)//128
    v.total=32+2*v.fatsize+clusters
    v.data=v.base+32+2*v.fatsize
    boot=v.sectors[v.base]
    boot[32:36]=v.total.to_bytes(4,'little')
    boot[36:40]=v.fatsize.to_bytes(4,'little')
    boot[44:48]=rootcluster.to_bytes(4,'little')
    v.sectors={v.base:boot}
    for sector,data in oldsectors.items():
        if sector>=olddata:
            cluster=sector-olddata+2
            if cluster==2:cluster=rootcluster
            if cluster==3:cluster=rootcluster+1
            v.put(cluster,data)
    for cluster in (rootcluster,rootcluster+1,5,6,7,11):v.fat(cluster,0x0fffffff)
    v.fat(10,300);v.fat(300,11)
    root=v.sectors[v.data+(rootcluster-2)]
    root[:32]=v.entry('HELLO.TXT',rootcluster+1,len(v.hello))
    p=machine(v)
    assert not p.call('ChgDir',mode=1,path='/pc0')[0]
    assert p.data(0x600+p.s['P$DIO']+2,4)==rootcluster.to_bytes(4,'big')
    assert not p.call('Open',mode=1,path='hello.txt')[0]
    assert not p.call('Read',count=32)[0]
    assert p.data(OUTPUT,len(v.hello))==v.hello
    p.call('Close')
    assert not p.call('ChgDir',mode=1,path='subdir')[0]
    assert not p.call('ChgDir',mode=1,path='..')[0]
    assert p.data(0x600+p.s['P$DIO']+2,4)==rootcluster.to_bytes(4,'big')
    # Bad on-disk geometry must fail without leaking the per-path workspace.
    mutations=[(510,b'\0\0'),(11,b'\0\x04'),(13,b'\x03'),(16,b'\0'),(17,b'\x01\0'),
               (32,(2000).to_bytes(4,'little')),(36,(1).to_bytes(4,'little')),
               (40,b'\x82\0'),(42,b'\x01\0'),(44,(1).to_bytes(4,'little')),
               (32,(0xffffffff).to_bytes(4,'little'))]
    for off,data in mutations:
        v=Volume();v.sectors[v.base][off:off+len(data)]=data;p=machine(v)
        result=p.call('Open',mode=1,path='/pc0/hello.txt')
        assert result[:2]==(1,p.s['E$BTyp']),(off,result)
        assert p.allocations==[blk.STATE]
    # A fragmented file cannot silently terminate early or follow corrupt links.
    for link in (0,1,0x0ffffff0,0x0ffffff7,0x0fffffff,10,100000):
        v=Volume();v.fat(10,link);p=machine(v)
        assert not p.call('Open',mode=1,path='/pc0/frag.bin')[0]
        result=p.call('Read',count=1500)
        assert result[:2]==(1,p.s['E$BTyp']) and result[2]==512,(link,result)
        assert int.from_bytes(p.data(WORK+p.fs['F.Pos'],4),'big')==512
        p.call('Close')
    v=Volume();v.fat(2,2);v.put(2,v.entry('FILL',3,1)*16);p=machine(v)
    result=p.call('Open',mode=0x81,path='/pc0')
    assert result[:2]==(1,p.s['E$BTyp']),result
    assert p.allocations==[blk.STATE]
    # Corruption beyond a valid file's logical EOF is not accessed.
    v=Volume();p=machine(v)
    assert not p.call('Open',mode=1,path='/pc0/empty.txt')[0]
    assert p.call('Read',count=0)[:2]==(0,0)
    assert p.call('Read',count=1)[:2]==(1,p.s['E$EOF'])
    p.call('Close')
    for path in ('/pc0/subdir/nest.txt','/pc0/SUBDIR/../hello.txt','/pc0/subdir/child/.../hello.txt'):
        assert not p.call('Open',mode=1,path=path)[0],path
        p.call('Close')
    assert not p.call('ChgDir',mode=1,path='/pc0/subdir')[0]
    cwd=p.data(0x600+p.s['P$DIO'],12)
    assert p.call('ChgDir',mode=1,path='missing')[0]
    assert p.data(0x600+p.s['P$DIO'],12)==cwd
    assert not p.call('ChgDir',mode=4,path='/pc0/subdir/child')[0]
    assert p.data(0x600+p.s['P$DIO']+2,4)==(5).to_bytes(4,'big')
    assert p.data(0x600+p.s['P$DIO']+8,4)==(7).to_bytes(4,'big')
    assert not p.call('Open',mode=1,path='nest.txt')[0]
    if level==2:
        p.fail_move=True
        assert p.call('Read',count=1)[:2]==(1,p.s['E$IBA'])
        assert p.data(WORK+p.fs['F.Pos'],4)==bytes(4)
        p.fail_move=False
    assert not p.call('Seek',position=0xffffffff)[0]
    assert p.call('Read',count=1)[:2]==(1,p.s['E$EOF'])
    assert p.call('ReadOnly')[:2]==(1,p.s['E$WP'])
    p.call('Close')
    print('  geometry/active FAT, high LBA, corruption/cycles, EOF, cwd rollback and move failure passed',flush=True)

def boundary_tests(tmp,level):
    def machine(volume):
        modules,fat=build(tmp,level,volume)
        assert fat[0][fat[1]['name']:fat[1]['name']+3]==b'pc\xe6'
        return FatMachine(modules,fat,volume)
    def ok(p,name,**kw):
        result=p.call(name,**kw)
        assert not result[0],(name,kw,result)
        return result
    def error(p,name,code,**kw):
        result=p.call(name,**kw)
        assert result[:2]==(1,p.s[code]),(name,kw,result,code)

    # Enumeration crosses both sector and noncontiguous cluster boundaries.
    for spc in (1,2):
        v=Volume(spc=spc);capacity=16*spc;rows=[];expected=[]
        for i in range(capacity+5):
            name=f'F{i:07d}.TXT';size=(i+1)*7
            row=v.entry(name,10,size)
            if i%11==4:row=bytes([0xe5])+row[1:]
            elif i%11==6:row=v.entry('LFNSLOT',0,0,0x0f)
            elif i%11==8:row=v.entry('VOLUME',0,0,8)
            else:expected.append((i,name,size))
            rows.append(row)
        v.fat(2,400);v.fat(400,0x0fffffff)
        v.put(2,b''.join(rows[:capacity]));v.put(400,b''.join(rows[capacity:]))
        p=machine(v)
        for count in (32,45):
            ok(p,'Open',mode=0x81,path='/pc0')
            for slot,name,size in expected:
                ok(p,'GetStat',status=p.s['SS.ReadDir'],count=count)
                record=p.data(OUTPUT,count)
                assert record[:len(name)]==name[:-1].encode()+bytes([ord(name[-1])|128])
                assert int.from_bytes(record[29:32],'big')==slot+1
                if count==45:assert int.from_bytes(record[41:45],'big')==size
            error(p,'GetStat','E$EOF',status=p.s['SS.ReadDir'],count=count)
            # Rewind directly into the second cluster, then use the legacy FD view.
            slot,name,size=next(e for e in expected if e[0]>=capacity)
            ok(p,'Seek',position=64+slot*32)
            ok(p,'GetStat',status=p.s['SS.ReadDir'],count=count)
            assert p.data(OUTPUT,len(name))==name[:-1].encode()+bytes([ord(name[-1])|128])
            ok(p,'GetStat',status=p.s['SS.FDInf'],cookie=slot+1,count=16)
            assert int.from_bytes(p.data(OUTPUT+9,4),'big')==size
            error(p,'GetStat','E$IllArg',status=p.s['SS.FDInf'],cookie=capacity+6,count=16)
            ok(p,'Close')
            assert p.allocations==[blk.STATE]
        _,name,size=expected[-1]
        ok(p,'Open',mode=1,path='/pc0/'+name.lower())
        result=ok(p,'Read',count=size+10)
        assert result[2]==size and p.data(OUTPUT,size)==v.fragment[:size]
        ok(p,'Close')

    # CR at the final byte of a sector/cluster, plus an unterminated last line.
    v=Volume();payload=b'A'*511+b'\r'+b'B'*511+b'\r'+b'end'
    v.put(10,payload[:512]);v.put(300,payload[512:1024]);v.put(11,payload[1024:])
    v.sectors[v.data][32:64]=v.entry('FRAG.BIN',10,len(payload))
    p=machine(v);ok(p,'Open',mode=1,path='/pc0/frag.bin')
    for line in (payload[:512],payload[512:1024],b'end'):
        result=ok(p,'ReadLn',count=2000)
        assert result[2]==len(line) and p.data(OUTPUT,len(line))==line
    error(p,'ReadLn','E$EOF',count=1)
    for pos in (510,511,512,1023,1024):
        ok(p,'Seek',position=pos)
        ok(p,'ReadLn',count=0)
        result=ok(p,'ReadLn',count=2000)
        want=payload[pos:].split(b'\r')[0]
        if b'\r' in payload[pos:]:want+=b'\r'
        assert result[2]==len(want) and p.data(OUTPUT,len(want))==want
    error(p,'Write','E$BMode',count=32)
    error(p,'WriteLn','E$BMode',count=32)
    error(p,'SetStat','E$WP',status=p.s['SS.Rename'])
    ok(p,'Close')
    for vector in (0,4):
        error(p,vector,'E$WP',mode=2,path='/pc0/hello.txt')
    error(p,2,'E$WP',path='/pc0/newdir')

    # A two-cluster directory cycle is rejected and releases its workspace.
    v=Volume();v.fat(2,400);v.fat(400,2)
    for cluster in (2,400):v.put(cluster,v.entry('FILL',3,1)*16)
    p=machine(v);error(p,'Open','E$BTyp',mode=0x81,path='/pc0')
    assert p.allocations==[blk.STATE]
    # Repeated opens/closes and descriptor span failure must not leak memory.
    v=Volume();p=machine(v)
    for _ in range(8):
        ok(p,'Open',mode=1,path='/pc0/hello.txt');ok(p,'Close')
        assert p.allocations==[blk.STATE]
    p.long(blk.DESC+p.fs['FT.Length'],v.total-1)
    error(p,'Open','E$BTyp',mode=1,path='/pc0/hello.txt')
    assert p.allocations==[blk.STATE]
    print('  directory sector/cluster boundaries, metadata/cookies, line boundaries, all write vectors, two-node cycles and repeated cleanup passed',flush=True)


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--fixture-directory',type=Path)
    args=parser.parse_args()
    if args.fixture_directory:
        Volume().fixture(args.fixture_directory)
    else:
        with tempfile.TemporaryDirectory(prefix='fat32-test-') as d:
            for level in (1,2):
                test(Path(d),level)
                extended_tests(Path(d),level)
                boundary_tests(Path(d),level)
