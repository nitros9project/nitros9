"""Execute Fran's note/dialog save and restore with paged backing RAM.

DMA completion and vertical blank are mocked; this does not test hardware DMA
or establish a fix for the reported K2 dialog/drag lockups.
"""
import re
from test_midi_import import CPU,Memory,TestCfg,BaseCPUTestCase,ROOT


class Fran:
    def __init__(self):
        self.sy={k:int(v,16) for k,v in re.findall(r'^([^ ]+) EQU \$([0-9A-F]+)',(ROOT/'.mods/s9gui_config.sym').read_text(),re.M)}
        cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);self.c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
        self.m=self.c.memory;self.base=0x8000;self.ram=bytearray(256*8192);self.mapping=None
        c,m,s=self.c,self.m,self.sy
        m.load(self.base,(ROOT/'.mods/CMDS/s9gui').read_bytes())
        c.user_stack_pointer.set(0);c.index_y.set(0x3fff);c.system_stack_pointer.set(0x3f00)
        m.write_byte(0x3f00,13);c.program_counter.set(self.base+s['start'])
        for _ in range(90000):
            if c.program_counter.value==self.base+s['CallMain']:break
            c.get_and_call_next_op()
        else:raise AssertionError('Fran initialization stuck')
        c.index_y.set(0)
        m.write_word(s['FrSave'],160);m.write_byte(s['FrBM0'],64);m.write_byte(s['FrWin'],255)
        m.write_word(s['FrSym'],176)
        symbols=(ROOT/'.mods/SYS/UmeSymbols16.img').read_bytes()
        self.ram[176*8192:176*8192+len(symbols)]=symbols
        m.load(0x099f,(ROOT/'.mods/SYS/Chars16.img').read_bytes())

    def oscall(self):
        c,m,s=self.c,self.m,self.sy;pc=c.program_counter.value;op=m.read_byte(pc+2)
        if op==s['F$MapBlk']:
            assert self.mapping is None
            start=c.index_x.value*8192;size=c.accu_b.value*8192
            assert 0<size<=16384 and start+size<=len(self.ram)
            m.load(0x4000,self.ram[start:start+size]);self.mapping=(start,size);c.user_stack_pointer.set(0x4000)
        elif op==s['F$ClrBlk']:
            assert self.mapping is not None
            start,size=self.mapping
            self.ram[start:start+size]=bytes(m.read_byte(0x4000+i) for i in range(size));self.mapping=None
        else:raise AssertionError(('unexpected OS call',hex(op),hex(pc)))
        c.C=0;c.program_counter.set(pc+3)

    def call(self,name,*args):
        c,m,s=self.c,self.m,self.sy
        m.write_word(0x3f00,0x3e80)
        for i,v in enumerate(args):m.write_word(0x3f02+2*i,v&65535)
        c.system_stack_pointer.set(0x3f00);c.user_stack_pointer.set(0x1234);c.program_counter.set(self.base+s[name])
        for n in range(1200000):
            pc=c.program_counter.value
            if pc==0x3e80:break
            if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:self.oscall();continue
            c.get_and_call_next_op()
        else:raise AssertionError(('Fran stuck',name,hex(pc),hex(c.system_stack_pointer.value),{v:hex(m.read_word(s[v])) for v in ('hgt','width','xr','xl','dy','igoal')}))
        assert c.system_stack_pointer.value==0x3f02 and c.user_stack_pointer.value==0x1234 and c.index_y.value==0
        return n

    def stream(self,data):
        c,m,s=self.c,self.m,self.sy;pos=0;handled=[]
        m.write_word(0x3f00,0x3e80);c.system_stack_pointer.set(0x3f00)
        c.user_stack_pointer.set(0x1234);c.program_counter.set(self.base+s['dispatch'])
        for n in range(1500000):
            pc=c.program_counter.value;sp=c.system_stack_pointer.value
            if pc==self.base+s['CmdReadNext'] and pos==len(data):break
            if pc==self.base+s['CmdDispatch']:handled.append(hex(m.read_byte(sp+5)))
            if pc==self.base+s['fread']:
                dest=m.read_word(sp+2);count=m.read_word(sp+4)*m.read_word(sp+6)
                assert pos+count<=len(data),('missing command bytes',pos,count,handled[-10:])
                m.load(dest,data[pos:pos+count]);pos+=count;c.accu_d.set(count)
                c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
            if pc==self.base+s['illegal']:raise AssertionError(('illegal command',pos,handled[-10:]))
            if pc==self.base+s['DmaFire']:
                c.C=0;c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
            if pc==self.base+s['WaitBlank']:
                c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
            if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:self.oscall();continue
            c.get_and_call_next_op()
        else:raise AssertionError(('Fran stream stuck',pos,hex(pc),hex(sp),handled[-10:]))
        print('PASS actual Fran command stream',len(data),'bytes',handled,'steps',n)


if __name__=='__main__':
    f=Fran();f.m.write_word(f.sy['lastnrx'],30);f.m.write_word(f.sy['lastaffy'],130)
    f.m.load(f.sy['arg0'],bytes([8,30,136,76,130]))
    print('erase note steps',f.call('dnota'))
    print('save steps',f.call('getnbak'))
    print('restore steps',f.call('putnbak'))
    print('dialog save steps',f.call('bytblt',0,13,75,65,117,0x13d8))
    print('dialog restore steps',f.call('bytblt',1,13,75,65,117,0x13d8))
    from test_note_drag import drag
    f=Fran();f.call('spinit');f.stream(drag())
    from test_ume_squawk import test
    f=Fran();f.call('spinit');f.stream(test(True))
    for data in (drag(),test(True)):
        f=Fran();f.call('spinit');f.m.write_byte(f.sy['FrDma'],1);f.m.write_byte(f.sy['FrBMShown'],80)
        f.stream(data)
