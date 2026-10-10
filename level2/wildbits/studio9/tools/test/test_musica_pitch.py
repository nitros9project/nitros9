"""Trace imported notation through the actual native player's pitch/accidental code."""
import re
from pathlib import Path
import json
import math, struct
from test_musica_import import run, musica, rec, ROOT, CPU, Memory, TestCfg, BaseCPUTestCase

def native_pitches(result):
    sy={k:int(v,16)+0x4000 for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/'.mods/Um3P_import.sym').read_text(),re.M)}
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=c.memory
    m.load(0x4000,(ROOT/'.mods/CMDS/s9p').read_bytes());sp=0x1d00
    def call(name,*args):
        c.system_stack_pointer.set(0x1800);m.write_word(0x1800,0x3100)
        for i,arg in enumerate(args):m.write_word(0x1802+2*i,arg)
        c.program_counter.set(sy[name]);c.index_y.set(0);c.user_stack_pointer.set(0x1234)
        for _ in range(5000):
            if c.program_counter.value==0x3100:break
            c.get_and_call_next_op()
        else:raise AssertionError(('pitch initialization did not return',name))
        assert c.system_stack_pointer.value==0x1802 and c.user_stack_pointer.value==0x1234
    # Exercise the real scale/table builders instead of supplying an idealized table.
    call('BuildScaleTable',0x3200,0)
    call('BuildPitchTable',0x3200,sp+0x5a)
    natural=bytes(m.read_byte(sp+0x5a+i) for i in range(50))
    assert natural[1:]==bytes(24+12*(i//7)+[0,2,4,5,7,9,11][i%7] for i in range(49))
    m.load(sp+0x28,natural)
    m.write_byte(0x45,0);m.write_byte(0x46,127)
    m.load(0x405,result['partson']);m.load(0x415,result['channels_on'])
    for part in range(1,result['parts']+1):
        v=sp+0x8c+16*part;m.write_word(v,result['channels'][part-1])
        m.write_word(v+6,[24,18,16,12,0][result['staffof'][part-1]])
        m.write_byte(v+14,1)
    m.write_byte(0xb4,1)
    out=[]
    for e in result['records']:
        if not e[0]:
            if e[5]<=6:m.load(sp+0x28,natural)
            continue
        if e[5]==32:continue
        m.load(0x3000,e);m.write_word(0xbb,int.from_bytes(e[5:6],'big',signed=True)&65535)
        voice=sp+0x8c+16*e[0]
        m.write_word(voice+4,0) # audition each displayed event through the actual sender
        m.write_word(voice+8,96);m.write_word(0xcd,0)
        sent=[]
        c.system_stack_pointer.set(sp);c.user_stack_pointer.set(0x3000);c.program_counter.set(sy['NoteEvent'])
        for _ in range(1500):
            pc=c.program_counter.value
            if pc==sy['FetchNextEvent']:break
            if pc==sy['MidiHwSend']:
                sent.append(m.read_word(c.system_stack_pointer.value+2)&255)
                c.program_counter.set(c.pull_word(c.system_stack_pointer))
            else:c.get_and_call_next_op()
        else:raise AssertionError(('note did not reach MIDI output',e,hex(c.program_counter.value)))
        assert sent==[0x90+result['channels'][e[0]-1],m.read_word(0xbf),96],(e,sent)
        assert c.system_stack_pointer.value==sp
        out.append((int.from_bytes(e[1:3],'big'),e[0],m.read_word(0xbf),e))
    return out

def musica_note(phase):
    return math.floor(69+12*math.log2(phase/0x123f)+0.5)

def test_calculator():
    """Run Mf2MIDI, including hardware multiplication and the real stack ABI."""
    sy={k:int(v,16) for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/'.mods/Um3F_import.sym').read_text(),re.M)}
    # Check the two fixed-point constants independently against the formula.
    boundary=(sy['MusBoundaryHi']<<16)|sy['MusBoundaryLo']
    ratio=(sy['MusRatioHi']<<16)|sy['MusRatioLo']
    assert boundary==round(0x123f*2**((104-.5-69)/12)*65536)
    assert ratio==round((2**(1/12)-1)*2**32)
    # Exhaust every nonzero input in the fixed-point algorithm against log2.
    for raw in range(1,65536):
        v,n=raw,103
        while v<32768:v*=2;n-=12
        t=boundary
        for _ in range(12):
            if v<<16<t:break
            n+=1;t+=(t*ratio)>>32
        assert n==musica_note(raw),(raw,n,musica_note(raw))
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=c.memory
    m.load(0x4000,(ROOT/'.mods/CMDS/s9f').read_bytes())
    # Author's concrete examples are independent of our generated boundaries.
    anchors={0x0ad9:60,0x091f:57,0x0c2d:62,0x089c:56,
             0x02b6:36,0x056c:48,0x0dab:64,0x123f:69,0x15b3:72,0x2b67:84}
    cases={0,1,65535,32767,32768,0xfdfd}|set(anchors)
    for note in range(1,116):
        edge=0x123f*2**((note-.5-69)/12)
        cases.update(v for v in (math.floor(edge),math.ceil(edge)) if 0<v<65536)
    for raw in sorted(cases):
        for masks in (0,0x50):
            c.system_stack_pointer.set(0x1800);m.write_word(0x1800,0x3100)
            m.load(0x17d0,b'\xa5'*8)
            c.index_x.set(0x2468);c.index_y.set(0x1357);c.user_stack_pointer.set(0x1234)
            c.accu_d.set(raw);c.set_cc(masks);c.program_counter.set(0x4000+sy['Mf2MIDI'])
            for _ in range(2000):
                if c.program_counter.value==0x3100:break
                c.get_and_call_next_op()
            else:raise AssertionError(('Mf2MIDI did not return',raw))
            want=anchors.get(raw,musica_note(raw) if raw else 0)&255
            assert c.accu_b.value==want,(hex(raw),c.accu_b.value,want)
            assert c.system_stack_pointer.value==0x1802
            assert (c.index_x.value,c.index_y.value,c.user_stack_pointer.value)==(0x2468,0x1357,0x1234)
            assert c.get_cc_value()&0x50==masks
            assert bytes(m.read_byte(0x17d0+i) for i in range(8))==b'\xa5'*8
    print('PASS all 65535 rates agree with log2; assembled Mf2MIDI boundaries, author examples, stack and IRQ masks:',len(cases)*2,'calls')

def source_notes(data, limit=None):
    """Independent source timeline for non-repeating regression excerpts."""
    pos=(5 if data[0]==0 else 0)+1029
    tick=0; half=1; out=[[] for _ in range(4)]; count=0
    while data[pos]:
        length=data[pos]
        assert length not in (0xfb,0xfd), 'repeat needs expansion before this fixture'
        if length<128:
            phases=struct.unpack_from('>4H',data,pos+1)
            for voice,phase in enumerate(phases):
                out[voice].append((tick,musica_note(phase) if phase else None))
            duration={127:384,11:32,5:16}.get(length,length*3)+half
            half=duration&1;tick+=duration//2
        pos+=9;count+=1
        if limit and count==limit:break
    return out,pos

def compare_file(path, limit=None):
    data=path.read_bytes(); source,end=source_notes(data,limit)
    result=run(data[:end]+b'\0\x39\x83',native=True)
    assert not result['errors'],(path,result['errors'])
    played=native_pitches(result)
    for tick,voice,pitch,e in played:
        expected=next(p for t,p in reversed(source[voice-1]) if t<=tick)
        assert pitch==expected,(path,tick,voice,pitch,expected,e)
    print('PASS',path.name,len(played),'native notated pitches == calculated source pitches == actual MIDI Note On bytes')
    return played

if __name__=='__main__':
    test_calculator()
    # Every chromatic note across the usable native range. A note's staff
    # and accidental are interpreted by real s9p, then its MIDI sender runs.
    for note in range(24,108):
        phase=round(0x123f*2**((note-69)/12))
        result=run(musica(rec(32,phase,0,0,0)),native=True)
        assert [p for _,_,p,_ in native_pitches(result)]==[note],note
    result=run(musica(rec(32,0x0b7e,0,0,0),rec(32,0x0ad9,0,0,0)),native=True)
    assert [p for _,_,p,_ in native_pitches(result)]==[61,60]
    assert result['notes'][1][6]==4
    # Reject outside native notation range; never transpose/clamp/fold silently.
    result=run(musica(rec(32,257,0,0,0)),native=True)
    assert result['result']==0 and 'C1' in result['errors'][0] and not result['init']
    result=run(musica(rec(32,0xfdfd,0,0,0)),native=True)
    assert result['result']==0 and 'C1-B7' in result['errors'][0] and not result['init']
    print('PASS C-sharp then C cancellation; all 84 native chromatic pitches reach matching MIDI output')
    compare_file(Path('D:/CoCo/Disks/musica/MOON_RIV.MUS'))
    compare_file(Path('E:/cygwin64/home/taylo/wildbits-buildkit/notes/musica-audit-20260930/64.MUS'),64)
    for name in ['BEAT_IT.MUS','9TO5.MUS']:
        path=Path('D:/CoCo/Disks/musica')/name
        if path.exists():compare_file(path,64)
