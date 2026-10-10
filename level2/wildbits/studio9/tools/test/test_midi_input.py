"""Run resident DIN input through the real output hook and playback key queue."""
import re
from collections import deque
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT


def syms(name):
    return {k: int(v, 16) for k, v in re.findall(
        r'^([^ ]+) EQU \$([0-9A-F]+)', (ROOT / f'.mods/{name}_input.sym').read_text(), re.M)}


class Rig:
    def __init__(self):
        self.s = syms('s9'); self.p = syms('s9p'); self.r = syms('s9r')
        cfg = TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
        self.c = CPU(Memory(cfg), cfg); cfg.ROM_START = 0x10000
        self.m = self.c.memory; self.fifo = deque(); self.out = []; self.keys = []; self.frame = 0
        self.m.load(0x2000, (ROOT / '.mods/CMDS/s9').read_bytes()[:0xa000])
        self.m.load(0xc000, (ROOT / '.mods/CMDS/s9p').read_bytes())
        self.m._read_byte_callbacks[self.s['MIDI.Base']] = lambda *args: 8 | (4 if not self.fifo else 0)
        self.m._read_byte_callbacks[self.s['MIDI.Base']+1] = lambda *args: (_ for _ in ()).throw(AssertionError('app read hardware RX FIFO'))
        self.m.write_byte(self.s['MidiInPath'], 4)
        self.m._write_byte_callbacks[self.s['MIDI.Base']+1] = lambda cy, pc, a, v: self.out.append(v)
        self.m._read_byte_callbacks[self.s['T1_VAL']+2] = lambda *args: self.frame
        for i in range(self.s['MidiRouteCount']):
            self.m.write_byte(self.s['MidiRoutePaths']+i, self.s['MidiUnusedPath'])
        self.m.write_byte(self.s['MidiRoutePaths'], self.s['MidiWildbitsPath'])
        self.m.write_word(self.s['pMidiSend'], 0x2000+self.s['PianoHook'])
        self.m.write_word(self.s['pMidiEcho'], 0x2000+self.s['MidiInputService'])
        self.m.write_byte(self.s['PianoPend'], 0xfe)

    def call(self, name, player=False, arg=None, sleep_input=None):
        c, m, s = self.c, self.m, self.s
        c.system_stack_pointer.set(0x1f00); m.write_word(0x1f00, 0x1900)
        if arg is not None: m.write_word(0x1f02, arg)
        c.accu_d.set(0x1234); c.index_x.set(0x2345); c.index_y.set(0); c.user_stack_pointer.set(0x4567)
        c.program_counter.set((0xc000+self.p[name]) if player else (0x2000+s[name]))
        self.waits = []
        for _ in range(100000):
            pc = c.program_counter.value
            if pc == 0x1900: break
            assert pc != 0x2000+s['soowee'], 'live input tried to unload the caller overlay'
            if pc == 0x2000+s['PianoPaint']:
                self.keys.append((c.accu_a.value+21, c.accu_b.value, len(self.out)))
                c.program_counter.set(c.pull_word(c.system_stack_pointer)); continue
            if pc == 0xc000+self.p['Os9Call']:
                sp = c.system_stack_pointer.value
                assert m.read_word(sp+2) == s['F$Sleep']
                regs = m.read_word(sp+4); ticks = m.read_word(regs+4)
                assert ticks == 1, ticks
                self.waits.append(ticks); self.frame = (self.frame+1) % 60
                if sleep_input and len(self.waits) == 1: self.fifo.extend(sleep_input)
                c.program_counter.set(c.pull_word(c.system_stack_pointer)); continue
            if m.read_byte(pc) == 0x10 and m.read_byte(pc+1) == 0x3f:
                assert m.read_byte(pc+2) == s['I$GetStt'], (hex(pc), m.read_byte(pc+2))
                if c.accu_b.value == s['SS.MidiRead']:
                    c.C = 0 if self.fifo else 1
                    if self.fifo: c.accu_b.set(self.fifo.popleft())
                else: c.C = 1  # no keyboard/mouse event
                c.program_counter.set(pc+3); continue
            c.get_and_call_next_op()
        else: raise AssertionError(('input did not return', hex(c.program_counter.value)))
        assert c.system_stack_pointer.value == 0x1f02
        assert c.user_stack_pointer.value == 0x4567 and c.index_y.value == 0

    def playing(self):
        self.m.write_byte(self.s['MidiPlaying'], 1)
        self.m.write_word(self.s['PianoVec'], 0xc000+self.p['PianoMark'])


def test_routes():
    t=Rig();c,m,s=t.c,t.m,t.s
    m.load(0xc000,(ROOT/'.mods/CMDS/s9r').read_bytes())
    m.load(s['MidiRouteNames'],bytes([0xa5])*(s['MidiRouteCount']*s['MidiNameSize']))
    c.system_stack_pointer.set(0x1f00);m.write_word(0x1f00,0x1900)
    c.accu_d.set(0x1234);c.index_x.set(0x2345);c.index_y.set(0);c.user_stack_pointer.set(0x4567)
    c.program_counter.set(0x2000+s['MidiInitRoutes']);calls=0
    for _ in range(5000):
        pc=c.program_counter.value
        if pc==0x1900:break
        if pc==0x2000+s['soowee']:
            frame=c.system_stack_pointer.value
            assert m.read_word(frame+2)==ord('R') and m.read_word(frame+4)==ord('i')
            # soowee removes its module argument before calling the overlay.
            m.write_word(frame+2,ord('i'))
            c.program_counter.set(0xc000+t.r['start']);calls+=1;continue
        if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
            op=m.read_byte(pc+2)
            if op==s['I$Open']: c.accu_a.set(3)
            elif op==s['F$Link']: c.user_stack_pointer.set(0x7000)
            elif op not in (s['I$Close'],s['F$UnLink']): raise AssertionError(op)
            c.C=0; c.program_counter.set(pc+3); continue
        c.get_and_call_next_op()
    else:raise AssertionError('cold MIDI initialization did not return')
    assert calls==1 and c.system_stack_pointer.value==0x1f02
    assert (c.accu_d.value,c.index_x.value,c.index_y.value,c.user_stack_pointer.value)==(0x1234,0x2345,0,0x4567)
    assert bytes(m.read_byte(s['MidiRouteNames']+i) for i in range(9))==b'Wildbits\0'
    assert m.read_byte(s['MidiRoutePaths'])==s['MidiWildbitsPath']
    assert all(m.read_byte(s['MidiRoutePaths']+i)==s['MidiUnusedPath'] for i in range(1,s['MidiRouteCount']))
    assert m.read_word(s['pMidiEcho'])==0x2000+s['MidiInputService']
    assert m.read_word(s['pMidiSend'])==0x2000+s['MidiSendSelected']
    assert m.read_byte(s['UmeData_midiser'])==1 and m.read_byte(s['Vs1053Out'])==0
    print('PASS startup route initialization through s9r dispatch; defaults, pointers and caller stack/registers preserved')


def test():
    t = Rig()
    t.m.write_byte(t.s['UmeData_smf'], 1)
    t.fifo.extend([0x92, 60]); t.call('MidiInputService')
    assert t.out == [] and t.keys == []
    t.fifo.extend([100, 61, 0, 0xf8, 0x82, 60, 64]); t.call('MidiInputService')
    assert t.out == [0x92,60,100,0x92,61,0,0xf8,0x82,60,64], t.out
    assert [(n,v) for n,v,_ in t.keys] == [(60,1),(61,0),(60,0)]
    assert t.m.read_byte(t.s['UmeData_smf']) == 1
    assert t.c.accu_d.value == 0x1234 and t.c.index_x.value == 0x2345
    assert all(when >= 3 for _,_,when in t.keys)
    t.fifo.extend([0x93,67,80,0xb3,123,0]); t.call('MidiInputService')
    assert [(n,v) for n,v,_ in t.keys[-88:]] == [(n,0) for n in range(21,109)]

    t = Rig(); t.playing()
    t.m.write_byte(t.s['UmeData_runstat'], 0x97)
    t.m.write_byte(t.s['UmeData_reserved_00CE'], 0x97)
    t.fifo.extend([0x92,60,100,64,110]); t.call('CheckAbort', player=True)
    assert t.out == [0x92,60,100,0x92,64,110], t.out
    assert t.keys == [(60,1,6),(64,1,6)], t.keys
    assert t.m.read_byte(t.s['PianoQN']) == 0 and t.m.read_byte(t.s['MidiPlaying']) == 1
    assert t.m.read_byte(t.s['UmeData_runstat']) == 0
    assert t.m.read_byte(t.s['UmeData_reserved_00CE']) == 0
    t.fifo.extend([0x82,60,0,64,0]); t.call('CheckAbort', player=True)
    assert [(n,v) for n,v,_ in t.keys[-2:]] == [(60,0),(64,0)]

    t = Rig(); t.playing()
    t.call('SleepTicks', player=True, arg=4, sleep_input=[0x90,72,127])
    assert t.waits == [1]*4 and t.out == [0x90,72,127], (t.waits,t.out)
    assert t.keys == [(72,1,3)], t.keys

    t = Rig(); t.fifo.extend([0xf0,1,2,0xf8,3,0xf7]); t.call('MidiInputService')
    assert t.out == [0xf8,0xf0,1,2,3,0xf7] and not t.keys
    t = Rig(); t.fifo.extend([0xf8]*70); t.call('MidiInputService')
    assert len(t.out)==64 and len(t.fifo)==6
    t.call('MidiInputService'); assert len(t.out)==70 and not t.fifo
    print('PASS DIN -> real MIDI output/piano hook: split packets, running status, note on/off, velocity zero, silence, realtime, SysEx; playback queue flush and one-tick waits; no overlay switch; balanced stack/registers')


if __name__ == '__main__': test_routes(); test()
