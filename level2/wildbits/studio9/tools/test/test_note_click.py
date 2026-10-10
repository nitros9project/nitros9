"""CPU regressions for non-destructive clicks and native audition context."""
import re
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT

def load(name, suffix, base):
    sy={k:int(v,16) for k,v in re.findall(r'^([^ ]+) EQU \$([0-9A-F]+)',(ROOT/f'.mods/{name}_{suffix}.sym').read_text(),re.M)}
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
    c.memory.load(base,(ROOT/f'.mods/CMDS/{name}').read_bytes())
    return c,sy

def clicks():
    c,sy=load('s9','config',0x2000);m=c.memory
    for mode in (8,22):
        for pitch in (0,3,31,32):
            note=bytes([1,0,48,3,0,pitch,2,4]);brush=bytes([6,0,0,0,2]);sp=0x1e00
            m.load(0xe000,note);m.load(sy['brush'],brush);m.write_word(sp,sy['brush']);m.write_word(sp+0x33,17)
            m.write_word(sy['curcurse'],mode);c.system_stack_pointer.set(sp);c.user_stack_pointer.set(0xe000)
            c.program_counter.set(0x2000+sy['NoteEntryClick']);aud=[]
            for _ in range(100):
                pc=c.program_counter.value
                if pc==0x2000+sy['MainLoop']:break
                if pc==0x2000+sy['NoteEntryRest']:
                    assert pitch==32;break
                if pc==0x2000+sy['AuditionPlacedNote']:
                    aud.append(m.read_word(c.system_stack_pointer.value+2));c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
                c.get_and_call_next_op()
            else:raise AssertionError('click failed to return')
            assert aud==([] if pitch==32 else [17])
            assert bytes(m.read_byte(0xe000+i) for i in range(8))==note
            assert bytes(m.read_byte(sy['brush']+i) for i in range(5))==brush
            assert c.system_stack_pointer.value==sp
    print('PASS entry/plus tools: pitched notes audition without score/palette changes; rests alone reach placement')

def audition(artic=2):
    c,sy=load('s9c','audition',0x4000);m=c.memory
    records=[bytes.fromhex(s) for s in ('00000000000A0404','0000002C01194C59','0000000000000000','0000100000160302','0000100000170301','0300300300030102')]
    records[-1]=records[-1][:-1]+bytes([artic])
    source=b''.join(records);m.load(0xe000,source)
    for symbol,addr in (('pMidiEventPtr',0x3200),('vPswap',0x3210),('vCod2raw',0x3220)):
        m.write_word(sy[symbol],addr)
    m.write_word(sy['vEvents'],len(records));m.write_word(sy['vPages'],1)
    m.write_byte(sy['vGPTab']+1,0x33);m.write_byte(sy['vGPTab']+2,0x34)
    m.write_word(0x1f00,0x3100);m.write_word(0x1f02,ord('a'));m.write_word(0x1f04,len(records)-1)
    c.system_stack_pointer.set(0x1f00);c.index_y.set(0);c.user_stack_pointer.set(0x1234);c.program_counter.set(0x4000+sy['start'])
    for _ in range(20000):
        pc=c.program_counter.value;sp=c.system_stack_pointer.value
        if pc==0x3100:break
        d=None
        if pc==0x3200:
            i=m.read_word(sp+2);assert i<len(records),i;d=0xe000+8*i
        elif pc==0x3210:
            m.write_word(sy['vBase'],0xd000);d=1
        elif pc==0x3220:d=48
        if d is not None:
            c.accu_d.set(d);c.Z=int(d==0);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
        c.get_and_call_next_op()
    else:raise AssertionError(('audition did not return',hex(c.program_counter.value)))
    count=c.accu_d.value;temp=[bytes(m.read_byte(0xd000+8*i+j) for j in range(8)) for i in range(count)]
    assert bytes(m.read_byte(0xe000+i) for i in range(len(source)))==source
    assert bytes.fromhex('0000002C01194C59') in temp, temp
    assert bytes.fromhex('0000000000160302') in temp and bytes.fromhex('0000000000170301') in temp
    assert [e for e in temp if e[0]]==[bytes.fromhex('03000003000301')+bytes([2 if artic==0x82 else artic])]
    assert temp[-1][1:3]==b'\x00\x30'
    assert c.system_stack_pointer.value==0x1f02 and c.user_stack_pointer.value==0x1234 and c.index_y.value==0
    print('PASS native audition preserves channel, instrument and wide tempo; one note at time zero, unchanged original score and balanced stack')

def move_note():
    c,sy=load('s9','config',0x2000);m=c.memory
    for accepted in (0,1):
        original=bytes.fromhex('0100300300030102')*3;m.load(0xe000,original)
        m.write_word(0x1e00,0x1900);m.write_word(0x1e02,1)
        c.system_stack_pointer.set(0x1e00);c.user_stack_pointer.set(0x1234);c.index_y.set(0)
        c.program_counter.set(0x2000+sy['movenote']);heard=[]
        for _ in range(1000):
            pc=c.program_counter.value;sp=c.system_stack_pointer.value
            if pc==0x1900:break
            if pc==0x2000+sy['i2p']:
                assert m.read_word(sp+2)==1;c.accu_d.set(0xe008)
            elif pc==0x2000+sy['place']:
                assert m.read_word(sp+2)==1 and m.read_word(sp+4)==0xe008
                ptr=m.read_word(sp+6);m.write_byte(ptr+2,7);m.write_byte(ptr+3,2);c.accu_d.set(accepted)
            elif pc==0x2000+sy['AuditionPlacedNote']:heard.append(m.read_word(sp+2))
            elif pc in [0x2000+sy[n] for n in ('fixmarx','alert','plusplus','yesno')]:raise AssertionError('single-note drag reached range/prompt traversal')
            else:c.get_and_call_next_op();continue
            c.program_counter.set(c.pull_word(c.system_stack_pointer))
        else:raise AssertionError('move failed to return')
        want=bytearray(original)
        if accepted:want[13:15]=bytes([7,2])
        assert bytes(m.read_byte(0xe000+i) for i in range(24))==want
        assert heard==([1] if accepted else [])
        assert c.system_stack_pointer.value==0x1e02 and c.user_stack_pointer.value==0x1234
    print('PASS pitch drag modifies only clicked pitch/accidental, no range prompts; cancel leaves all notes intact')

if __name__=='__main__':
    clicks()
    for artic in (0,1,2,3,4,0x82):audition(artic)
    move_note()
