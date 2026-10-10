"""Execute the actual s9i machine code; mock OS-9 file I/O and score callbacks.

Usage: PYTHONPATH=<MC6809 installation> python tools/test/test_midi_import.py
The test needs the assembled .mods/CMDS/s9i. No Foenix hardware is required.
"""
import logging
import struct
import re
from pathlib import Path
from MC6809.components.cpu6809 import CPU
from MC6809.components.memory import Memory
from MC6809.tests.test_config import TestCfg
from MC6809.tests.test_base import BaseCPUTestCase

logging.disable(logging.CRITICAL)
ROOT = Path(__file__).resolve().parents[2]

def vlq(n):
    b = [n & 127]
    while n >> 7:
        n >>= 7
        b.insert(0, 128 | (n & 127))
    return bytes(b)

def smf(*tracks, ppqn=480, fmt=None):
    if fmt is None:
        fmt = int(len(tracks) > 1)
    return b'MThd'+struct.pack('>IHHH',6,fmt,len(tracks),ppqn)+b''.join(
        b'MTrk'+struct.pack('>I',len(t))+t for t in tracks)

END = b'\x00\xff\x2f\x00'

def run(data, fail_add=False, native=False):
    cfg = TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
    cpu = CPU(Memory(cfg), cfg)
    mem = cpu.memory
    cfg.ROM_START=0x10000
    binary = (ROOT/'.mods/CMDS/s9i').read_bytes()
    base = 0x4000
    mem.load(base,binary)
    symbols={k:int(v,16)+base for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/'.mods/Um3I_import.sym').read_text(),re.M)}
    hooks={symbols['MidiScoreInit']:0x3000,symbols['MidiScoreAdd']:0x3010,symbols['MidiScoreAppend']:0x3010,symbols['MidiScoreDone']:0x3020}
    for addr, target in [(0x10f8,0x3040),(0x10fa,0x3050),(0x10fc,0x3060),(0x3b5,0x3070),(0x37b,0x3030)]:
        mem.write_word(addr,target)
    cpu.system_stack_pointer.set(0x1f00)
    mem.write_word(0x1f00,0x3100)
    mem.write_word(0x1f02,ord('i'))
    mem.write_word(0x1f04,3)
    cpu.index_y.set(0)
    cpu.user_stack_pointer.set(0x1234)
    cpu.program_counter.set(base+int.from_bytes(binary[9:11],'big'))
    records=[]; errors=[]; init=[]; final=[]; pos=0; reads=[0]
    def ret(d=1):
        cpu.accu_d.set(d)
        cpu.Z = int(d == 0)
        cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
    for step in range(6000000):
        pc=cpu.program_counter.value
        if pc==0x3100:
            assert cpu.system_stack_pointer.value==0x1f02
            assert cpu.user_stack_pointer.value==0x1234
            assert cpu.index_y.value==0
            records=[bytes(mem.read_byte(0xe000+i*8+j) for j in range(8)) for i in range(mem.read_word(0x29))]
            rawnotes=[e for e in records if e[0]==0 and e[5]==0x1e and (e[3]&0xf0) in (0x80,0x90)]
            if not native: records=[e for e in records if e not in rawnotes]
            return dict(result=cpu.accu_d.value, records=records,rawnotes=rawnotes,errors=errors,init=init,final=final,
                        notes=[e for e in records if e[0]], bars=[e for e in records if not e[0] and e[5]==0], compact=mem.read_byte(0x7a),
                        parts=mem.read_word(0x58),staves=mem.read_word(0x5a),nbars=mem.read_word(0x64),
                        channels=bytes(mem.read_byte(0x3f4+i) for i in range(16)),
                        partson=bytes(mem.read_byte(0x405+i) for i in range(16)),
                        channels_on=bytes(mem.read_byte(0x415+i) for i in range(16)),
                        staffof=[mem.read_word(0xc5f+4*i) for i in range(1,17)],
                        clefs=[mem.read_word(0xc19+10*i+2) for i in range(5)], reads=reads[0])
        if not native: pc=hooks.get(pc,pc)
        if pc==0x3000:
            x=cpu.index_x.value
            init.append(bytes(mem.read_byte(x+i) for i in range(112)))
            ret()
        elif pc==0x3010:
            x=cpu.index_x.value
            n=mem.read_word(0x29)
            for i in range(8): mem.write_byte(0xe000+8*n+i,mem.read_byte(x+i))
            mem.write_word(0x29,n+1)
            ret(0 if fail_add else 1)
        elif pc==0x3020:
            final.append((cpu.accu_d.value,cpu.index_x.value)); ret()
        elif pc==0x3030:
            s=cpu.system_stack_pointer.value
            x=mem.read_word(s+2)
            text=[]
            while mem.read_byte(x):
                text.append(mem.read_byte(x)); x+=1
            errors.append(bytes(text).decode()); ret(0)
        elif pc==0x3040:
            init.append(True)
            mem.write_word(0x29,1)
            ret()
        elif pc==0x3050:
            ret()
        elif pc==0x3060:
            s=cpu.system_stack_pointer.value
            index=mem.read_word(s+2)
            mem.write_word(0x2b,index)
            ret(0xe000+8*index)
        elif pc==0x3070:
            s=cpu.system_stack_pointer.value
            index=mem.read_word(s+2)
            count=mem.read_word(0x29)
            assert count<900,'fixture exceeded simulated event page'
            for i in range(count*8-1,index*8-1,-1):
                mem.write_byte(0xe000+i+8,mem.read_byte(0xe000+i))
            mem.write_word(0x29,count+1)
            ret(0 if fail_add else 0xe000+index*8)
        elif mem.read_byte(pc)==0x10 and mem.read_byte(pc+1)==0x3f:
            op=mem.read_byte(pc+2)
            assert cpu.accu_a.value==3, ('path',cpu.accu_a.value,hex(pc))
            if op==0x88:
                pos=(cpu.index_x.value<<16)|cpu.user_stack_pointer.value
                cpu.C=0
            elif op==0x89:
                count=cpu.index_y.value
                chunk=data[pos:pos+count]
                pos+=len(chunk)
                reads[0]+=1
                mem.load(cpu.index_x.value,chunk)
                cpu.index_y.set(len(chunk))
                cpu.C=int(not chunk)
                if not chunk: cpu.accu_b.set(211)
            else: raise AssertionError(('syscall',hex(op)))
            cpu.program_counter.set(pc+3)
        else:
            cpu.get_and_call_next_op()
    raise AssertionError(('instruction limit',hex(cpu.program_counter.value)))

def note(pitch,start=0,duration=480,channel=0):
    return vlq(start)+bytes([0x90|channel,pitch,100])+vlq(duration)+bytes([0x80|channel,pitch,0])+END

def times(events):
    return [int.from_bytes(e[1:3],'big') for e in events]

def test_opening_silence():
    # Opening silence may be a partial bar or several complete bars. Keep
    # exact raw MIDI times; notation rests must cover each interval once.
    for tick in (600, 1920, 4500):
        r=run(smf(note(60,tick,480)),native=True)
        assert r['result']==1,r
        rests=[e for e in r['notes'] if e[5]==0x20]
        assert rests and rests[0][1:3]==b'\0\0',r
        intervals=[(int.from_bytes(e[1:3],'big'),384 >> e[3]) for e in rests]
        assert all(t+n<=tick*48//480 for t,n in intervals),intervals
        assert all(a+n==b for (a,n),(b,_) in zip(intervals,intervals[1:])),intervals
        assert [(int.from_bytes(e[1:3],'big'),e[3]&0xf0) for e in r['rawnotes']]==[(tick*48//480,0x90),((tick+480)*48//480,0x80)],r
    print('PASS actual S9I: partial/multiple opening measures have rests, no overlap, exact MIDI timestamps; stack/Y/U preserved')

def test():
    test_opening_silence()
    r=run(smf(note(60)))
    assert r['result']==1,r
    assert r['notes']==[bytes([1,0,0,3,0,3,0,130])],r
    assert times(r['bars'])==[0,192] and r['final']==[(48,2)],r
    assert [(e[3],e[4],e[7]&127) for e in r['rawnotes']]==[(0x90,60,100),(0x80,60,0)],r
    assert r['init'][0][16]==1,r
    r=run(smf(b'\x00\x90\x3c\x64'+vlq(240)+b'\x40\x64'+vlq(240)+b'\x3c\x00'+vlq(240)+b'\x40\x00'+END))
    assert r['result']==1 and len(r['notes'])==2,r
    assert times(r['notes'])==[0,24] and [e[0] for e in r['notes']]==[1,1],r
    # tracks merge in time order: the channel heard first becomes part 1
    r=run(smf(note(67,480,480,2),note(61,0,240,0)))
    assert r['result']==1 and len(r['notes'])==2,r
    assert r['init'][0][:2]==bytes([0xC0,0xC2]) and r['init'][0][16:18]==bytes([1,0]) and r['init'][0][96:98]==bytes([0,2]),r
    assert times(r['notes'])==[0,48] and [e[0] for e in r['notes']]==[1,2] and r['notes'][0][6]==2 and r['notes'][1][6]==0,r
    assert times(r['rawnotes'])==sorted(times(r['rawnotes'])),r
    # a part whose first note is below middle C goes to the bass staff, 12 steps up
    r=run(smf(note(60,channel=0),note(48,channel=1)))
    assert r['result']==1 and r['init'][0][16:18]==bytes([1,3]),r
    assert [(e[5],e[6]) for e in r['notes']]==[(3,0),(2,0)],r
    # one channel across the registers stays ONE part; its staff follows the range's middle (55 = tenor)
    r=run(smf(note(60)[:-4]+note(48,480)[:-4]+note(62,960)),native=True)
    assert r['parts']==1 and r['staffof'][:1]==[2] and r['channels'][:1]==b'\0',r
    assert [(e[0],e[5]) for e in r['notes']]==[(1,5),(1,254),(1,6)],r
    # a part is an instrument: two channels with the same program share it; different programs do not
    prog=lambda ch,n: bytes([0,0xC0|ch,n])
    r=run(smf(prog(0,5)+note(60,channel=0)[:-4]+prog(1,5)+note(64,channel=1)))
    assert r['init'][0][:2]==bytes([6,0]) and r['init'][0][96]==0 and [e[0] for e in r['notes']]==[1,1],r
    r=run(smf(prog(0,5)+note(60,channel=0)[:-4]+prog(1,7)+note(64,channel=1)))
    assert r['init'][0][:2]==bytes([6,8]) and r['init'][0][96:98]==bytes([0,1]) and [e[0] for e in r['notes']]==[1,2],r
    r=run(smf(note(60,channel=0),note(48,channel=1)),native=True)
    assert r['staves']==5 and r['clefs']==[0,5,6,1,4] and r['staffof'][:2]==[1,3],r
    # MIDI channel 10 is the percussion staff, whatever its pitch
    r=run(smf(note(60,channel=0),note(72,channel=9)),native=True)
    assert r['staves']==5 and r['staffof'][:2]==[1,4] and [e[5] for e in r['notes']]==[3,16],r
    meta=b'\x00\xff\x51\x03\x07\xa1\x20\x00\xff\x58\x04\x03\x02\x18\x08'
    r=run(smf(meta+note(60)))
    assert r['result']==1,r
    assert times(r['records'][:1])==[0] and r['records'][0][5]==0,r
    assert r['records'][1][5]==0x19 and r['records'][1][3]==120,r
    assert r['records'][2][5:]==bytes([10,3,4]),r
    r=run(smf(b'\x00\xc0\x05\x00\xb0\x07\x64'+note(60)))
    assert r['result']==1 and r['records'][1][3:5]==bytes([0xc0,0x85]),r
    r=run(smf(b'\x00\xff\x01'+vlq(500)+b'x'*500+note(60)))
    assert r['result']==1,r
    r=run(smf(note(60,0,100),ppqn=100))
    assert r['result']==1 and r['final']==[(48,2)],r
    r=run(smf(b'\x00\x90\x3c\x64'+vlq(480)+b'\xff\x2f\x00'))
    assert r['result']==1 and len(r['notes'])==1,r
    bad=[b'no MIDI',smf(note(60),fmt=2),smf(note(60),ppqn=0xe728),smf(note(60),ppqn=0),
         smf(note(60))[:-1],smf(b'\x00\x3c\x64'+END),smf(b'\x81\x80\x80\x80\x00'+END),
         smf(note(12)),smf(note(60,1000000,480)),smf(b'\x00\xff\x51\x03\0\0\0'+END),
         smf(*([note(60)]*33))]
    for data in bad:
        r=run(data)
        assert r['result']==0 and r['errors'] and not r['init'],r
    fixture=smf(note(60))
    for end in range(len(fixture)):
        r=run(fixture[:end])
        assert r['result']==0 and not r['init'],(end,r)
    chord=b''.join(b'\x00\x90'+bytes([48+i,100]) for i in range(17))+vlq(480)+b'\xff\x2f\0'
    r=run(smf(chord))
    assert r['result']==1 and len(r['notes'])==17 and r['init'][0][:2]==bytes([0xC0,0]) and r['init'][0][16]==2,r
    assert len(r['rawnotes'])==34,r
    r=run(smf(note(60)),fail_add=True)
    assert r['result']==0 and 'memory' in r['errors'][0],r
    r=run(smf(note(67,480,480,2),note(61,0,240,0)),native=True)
    assert r['result']==1 and r['parts']==2 and r['staves']==5,r
    assert r['channels'][:2]==bytes([0,2]),r
    assert r['records'][0][0]==0 and r['records'][0][5]==0 and r['records'][0][1:3]==b'\0\0',r
    assert times(r['records'])==sorted(times(r['records'])),r
    r=run(smf(meta+note(60,0,480*10)),native=True)
    assert r['result']==1,r
    assert times(r['bars'])==[0,144,288,432,576] and r['nbars']==5,r
    assert [int.from_bytes(e[3:5],'big') for e in r['bars']]==[1,2,3,4,5],r
    # a time signature on a bar line already laid down: no second one
    late=vlq(3840)+b'\xff\x58\x04\x03\x02\x18\x08'+END
    r=run(smf(note(60,3840),late),native=True)
    assert r['result']==1 and times(r['bars'])==[0,192,384,528],r
    kinds=[(int.from_bytes(e[1:3],'big'),e[0],e[5]) for e in r['records']]
    assert kinds.index((384,0,0))<kinds.index((384,1,3))<kinds.index((384,0,0x0a)),kinds
    # a time signature off the beat, at a tick where a lower track already put a note: its bar line goes in front
    late=vlq(4000)+b'\xff\x58\x04\x03\x02\x18\x08'+END
    r=run(smf(note(60,4000),late),native=True)
    assert r['result']==1 and times(r['bars'])==[0,192,384,400,544],r
    kinds=[(int.from_bytes(e[1:3],'big'),e[0],e[5]) for e in r['records']]
    assert kinds.index((400,0,0))<kinds.index((400,0,0x1e))<kinds.index((400,0,0x0a)),kinds
    assert [int.from_bytes(e[3:5],'big') for e in r['bars']]==[1,2,3,4,5],r
    r=run(smf(note(60),note(64)),native=True)
    assert r['result']==1 and r['parts']==1 and r['channels'][:1]==b'\0',r
    assert {e[0] for e in r['notes']}=={1},r
    # 18 notes over 16 channels: still 16 parts, no error
    many=b''.join(note(48+(i%16)*2+(i//16)*20,channel=i%16)[:-4] for i in range(18))+END
    r=run(smf(many),native=True)
    assert r['result']==1 and r['parts']==16 and len(r['notes'])==18,r
    r=run(smf(*(note(48+i,channel=i) for i in range(16))),native=True)
    assert r['result']==1 and r['parts']==16 and r['staves']==5,r
    assert r['staffof'][:16]==[3]*5+[2]*4+[4]+[2]*2+[1]*4,r
    assert len(r['rawnotes'])==32,r
    # every append lands behind the last event: the simulated page never shifts
    big=b''.join(vlq(0 if i==0 else 120)+bytes([0x90,60+i%12,100])+vlq(120)+bytes([0x80,60+i%12,0]) for i in range(200))+END
    r=run(smf(big),native=True)
    assert r['result']==1 and len(r['notes'])==200 and times(r['records'])==sorted(times(r['records'])),r
    print('PASS: assembled importer: notes, running status, overlap, merged tracks, treble/bass staves, tempo, meter, bar lines, channel messages, buffered reads, PPQN, EOT, malformed/unsupported input and allocation failure')

if __name__=='__main__': test()
