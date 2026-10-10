"""Run the assembled s9r directory scanner, including OS-9 seek and C ABI."""
import re
from test_midi_import import CPU,Memory,TestCfg,BaseCPUTestCase,ROOT

def check(n):
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
    cpu=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=cpu.memory
    base=0x4000;m.load(base,(ROOT/'.mods/CMDS/s9r').read_bytes())
    syms={k:int(v,16)+base for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/'.mods/Um3R_browser.sym').read_text(),re.M)}
    names=[f'score{i:04}.lyr' for i in range(n)]
    records=[]
    for name in names:
        b=bytearray(name.encode());b[-1]|=128;records.append(bytes(b).ljust(32,b'\0'))
    data=b''.join(records);allnames=[];pages=[];ctx=0x2f00;pos=0
    m.load(ctx,b'\0'*14)
    for page in range(n//64+2):
        m.load(0x2000,b'\xa5'*(64*26+32))
        m.write_word(0x1f00,0x3f00)
        for i,arg in enumerate([0x2000,syms['strScoreExt'],0,ctx]):m.write_word(0x1f02+i*2,arg)
        cpu.system_stack_pointer.set(0x1f00);cpu.user_stack_pointer.set(0x1234);cpu.index_y.set(0)
        cpu.program_counter.set(syms['ReadDirList'])
        for steps in range(1500000):
            pc=cpu.program_counter.value
            if pc==0x3f00:break
            if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
                op=m.read_byte(pc+2);cpu.C=0
                if op==0x84:cpu.accu_a.set(3);pos=0
                elif op==0x8f:pass
                elif op==0x88:pos=(cpu.index_x.value<<16)|cpu.user_stack_pointer.value
                elif op==0x89:
                    chunk=data[pos:pos+cpu.index_y.value];pos+=len(chunk)
                    m.load(cpu.index_x.value,chunk);cpu.index_y.set(len(chunk))
                    if not chunk:cpu.C=1;cpu.accu_b.set(211)
                else:raise AssertionError(hex(op))
                cpu.program_counter.set(pc+3)
            else:cpu.get_and_call_next_op()
        else:raise AssertionError(('hung',n,page,hex(pc)))
        count=cpu.accu_d.value;assert count<=64,(n,page,count)
        assert cpu.system_stack_pointer.value==0x1f02
        assert cpu.user_stack_pointer.value==0x1234
        assert cpu.index_y.value==0
        assert bytes(m.read_byte(0x2000+64*26+i) for i in range(32))==b'\xa5'*32,'list overflow'
        for i in range(count):
            b=[];a=0x2000+i*26
            while m.read_byte(a):b.append(m.read_byte(a));a+=1
            allnames.append(bytes(b).decode())
        pages.append(count)
        if not m.read_byte(ctx+4):break
    assert sorted(allnames)==names and len(allnames)==len(set(allnames)),(n,pages,allnames)
    print('PASS',n,'entries; pages',pages,'; guard bytes, S/U/Y preserved')

def picker():
    """Real FilePickMenu and ReadDirList; only UI callbacks and OS calls are stubbed."""
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
    c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=c.memory;base=0x4000
    m.load(base,(ROOT/'.mods/CMDS/s9r').read_bytes())
    sy={k:int(v,16) for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/'.mods/Um3R_browser.sym').read_text(),re.M)}
    names=[f'score{i:04}.lyr' for i in range(193)]
    data=b''.join(n[:-1].encode()+bytes([ord(n[-1])|128])+bytes(32-len(n)) for n in names)
    sp=0x3000;frame=sp-2-sy['BrowserFrameSize'];buf=0x3500
    m.write_word(sp,0x3f00)
    for i,a in enumerate([buf,base+sy['strScoreExt'],0,0,0]):m.write_word(sp+2+2*i,a)
    m.write_byte(buf,0);m.load(0x3300,b'\xa5'*64)
    callbacks={0x375:0x3e00,0x383:0x3e02,0x379:0x3e04,0x39f:0x3e08}
    # Locate printf's shared vector from the master symbol rather than guessing.
    callbacks[sy['UmeData_pprintf']]=0x3e06
    for addr,target in callbacks.items():m.write_word(addr,target)
    stubs={base+sy[n] for n in ('WinDefine','WinCtlCC','WinEnd','WinCtl90')}
    c.system_stack_pointer.set(sp);c.index_y.set(0);c.user_stack_pointer.set(0x1234);c.program_counter.set(base+sy['FilePickMenu'])
    # Previous at first page, forward to final partial page, forward at end,
    # backward twice, forward once, and select the first entry on page two.
    actions=['up','down','down','down','down','up','up','down','pick']
    expected=[0,0,1,2,3,3,2,1,2];seen=[];pos=0;mouse=0
    def ret():c.program_counter.set(c.pull_word(c.system_stack_pointer))
    for _ in range(9000000):
        pc=c.program_counter.value
        if pc==0x3f00:break
        if pc==0x3e00:
            page=m.read_word(frame+sy['BrowserPageNumOff']);count=m.read_word(frame+sy['BrowserNrecsOff']);seen.append(page)
            assert page==expected[len(seen)-1] and count==min(64,193-page*64),(page,count,seen)
            a=frame+sy['BrowserListOff'];got=[]
            for i in range(count):
                s=bytes(m.read_byte(a+i*26+j) for j in range(26)).split(b'\0')[0].decode();got.append(s)
            assert sorted(got)==names[page*64:page*64+count],(page,got)
            action=actions[len(seen)-1]
            if action=='pick':picked=got[0];c.accu_d.set(1)
            else:
                mouse=(72 if action=='up' else 75)*8+4
                c.accu_d.set(m.read_word(frame+sy['BrowserNlinesOff'])*3)
            ret();continue
        if pc==0x3e08:
            s=c.system_stack_pointer.value;m.write_word(m.read_word(s+2),mouse);m.write_word(m.read_word(s+4),0);c.accu_d.set(1);ret();continue
        if pc in stubs or pc in (0x3e02,0x3e04,0x3e06):ret();continue
        if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
            op=m.read_byte(pc+2);c.C=0
            if op==0x84:c.accu_a.set(3);pos=0
            elif op==0x8f:pass
            elif op==0x88:pos=(c.index_x.value<<16)|c.user_stack_pointer.value
            elif op==0x89:
                chunk=data[pos:pos+c.index_y.value];pos+=len(chunk);m.load(c.index_x.value,chunk);c.index_y.set(len(chunk))
                if not chunk:c.C=1;c.accu_b.set(211)
            else:raise AssertionError(hex(op))
            c.program_counter.set(pc+3)
        else:c.get_and_call_next_op()
    else:raise AssertionError(('picker hung',hex(pc),seen))
    assert seen==expected
    assert c.system_stack_pointer.value==sp+2 and c.user_stack_pointer.value==0x1234 and c.index_y.value==0
    assert bytes(m.read_byte(buf+i) for i in range(len(picked)+1))==picked.encode()+b'\0'
    assert bytes(m.read_byte(0x3300+i) for i in range(64))==b'\xa5'*64
    print('PASS real picker: 64-entry pages, separate arrow hit areas, both end stops, previous/next/backtracking, file selection and C stack/U/Y')

if __name__=='__main__':
    for n in (0,1,63,64,65,128,129,600):check(n)
    picker()
