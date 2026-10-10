"""Imported parts must sound without a manual Tutti/channel reset."""
import re
from pathlib import Path
from test_musica_import import run, musica, rec
from test_musica_pitch import native_pitches
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT


def channel_map():
    sy = {k:int(v,16) for k,v in re.findall(r'^([^ ]+) EQU \$([0-9A-F]+)',
        (ROOT/'.mods/Um3F_import.sym').read_text(),re.M)}
    for channel in range(16):
        cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
        c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=c.memory
        m.load(0x4000,(ROOT/'.mods/CMDS/s9f').read_bytes())
        m.load(sy['staves'],b'\xa5'*(7*10+17*4))
        m.write_byte(0x3000,1);m.write_byte(0x3060,channel)
        m.write_word(sy['pMidiNewScore'],0x3200);m.write_word(sy['pMidiStaffInit'],0x3210)
        c.system_stack_pointer.set(0x1f00);m.write_word(0x1f00,0x3100)
        c.index_x.set(0x3000);c.index_y.set(0);c.user_stack_pointer.set(0x1234)
        c.program_counter.set(0x4000+sy['MidiScoreInit'])
        for _ in range(3000):
            pc=c.program_counter.value
            if pc==0x3100:break
            if pc in (0x3200,0x3210):
                c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
            c.get_and_call_next_op()
        else:raise AssertionError('score init did not return')
        assert m.read_byte(0x3f4)==channel and m.read_byte(0x405)==1
        expected=bytearray(7*10+17*4)
        for i,clef in enumerate([0,5,6,1,4]):expected[i*10+3]=clef
        assert bytes(m.read_byte(sy['staves']+i) for i in range(len(expected)))==expected,'stale staff/part state after import'
        assert bytes(m.read_byte(0x415+i) for i in range(16))==bytes(int(i==channel) for i in range(16))
        assert c.system_stack_pointer.value==0x1f02 and c.user_stack_pointer.value==0x1234


def musica_defaults():
    r=run(musica(rec(32,0x0ad9,0x0dab,0x056d,0x123f)),native=True)
    assert r['channels'][:4]==bytes(range(4))
    assert r['partson'][:4]==b'\1'*4 and r['channels_on'][:4]==b'\1'*4
    assert r['instruments_enabled']==1
    assert {part for _,part,_,_ in native_pitches(r)}=={1,2,3,4}
    data=Path('E:/cygwin64/home/taylo/wildbits-buildkit/notes/musica-audit-20260930/64.MUS').read_bytes()
    r=run(data[:1034+64*9]+b'\0\x39\x83',native=True)
    pitches=native_pitches(r)
    assert len(pitches)==len([e for e in r['notes'] if e[5]!=32])
    assert {part for _,part,_,_ in pitches}=={e[0] for e in r['notes'] if e[5]!=32}
    print(f'PASS all 16 assigned channels enabled at import, balanced stack; 4 Musica voices and all {len(pitches)} pitched notes in the opening 64 records of 64.MUS reach native playback without Tutti/Ith->Ith')


if __name__=='__main__':channel_map();musica_defaults()
