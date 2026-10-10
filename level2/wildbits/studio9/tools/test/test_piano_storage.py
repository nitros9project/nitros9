"""Execute the real piano painter with bank mapping and write protection.

No rendering stubs: check each physical write, stack usage, source immutability,
and byte-exact up/down images across all 88 keys in both bitmap banks.
"""
import re
from test_midi_import import CPU, Memory, TestCfg, BaseCPUTestCase, ROOT


def symbols(name):
    return {k: int(v, 16) for k, v in re.findall(
        r'^([^ ]+) EQU \$([0-9A-F]+)', (ROOT / f'.mods/{name}.sym').read_text(), re.M)}


def painter():
    sy = symbols('s9_config')
    cfg = TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
    c = CPU(Memory(cfg), cfg); cfg.ROM_START = 0x10000; m = c.memory
    m.load(0x2000, (ROOT / '.mods/CMDS/s9').read_bytes())
    src = (ROOT / '.mods/Data/Um3_D2.bin').read_bytes().ljust(8192, b'\0')
    banks = {0xd8: bytearray(src), 0xa8: bytearray(8192), 0xb8: bytearray(8192), 0xd0: bytearray(8192)}
    mapped = [0xd0]; writes = []; minimum = 0x1f00
    read, write = m.read_byte, m.write_byte
    def rb(a):
        return banks[mapped[0]][a-0xe000] if 0xe000 <= a < 0xfd00 else read(a)
    def wb(a, v):
        if 0xe000 <= a < 0xfd00:
            assert mapped[0] in (0xa8, 0xb8), ('source/score write', hex(mapped[0]), hex(a), hex(c.program_counter.value))
            writes.append((mapped[0], a-0xe000)); banks[mapped[0]][a-0xe000] = v
        else:
            assert a < 0x2000, ('code write', hex(a))
            write(a, v)
    m._read_byte_callbacks.update({a: lambda cy,pc,addr: banks[mapped[0]][addr-0xe000] for a in range(0xe000,0xfd00)})
    m._write_byte_callbacks.update({a: lambda cy,pc,addr,v: wb(addr,v) for a in range(0x2000,0x10000)})
    m.write_byte(sy['PianoSym'], 0xd8)
    m.write_byte(sy['PianoBM'], 0xa0); m.write_byte(sy['PianoBM1'], 0xb0)
    m.write_word(sy['GPMapped'], 1); m.write_word(sy['GPAddr'], 0xe000)
    m.write_byte(sy['GPTab']+1, 0xd0)
    tab = [0x00,0xb0,0x11,0xb1,0x22,0x03,0xb3,0x14,0xb4,0x15,0xb5,0x26]
    for key in range(88):
        for pressed in (0, 1, 0):
            writes.clear()
            for b in (0xa8,0xb8): banks[b][:] = b'\x11'*8192
            c.system_stack_pointer.set(0x1b00); m.write_word(0x1b00,0x1900)
            c.accu_d.set(key*256+pressed); c.index_x.set(0x1234); c.index_y.set(0); c.user_stack_pointer.set(0xe088)
            c.program_counter.set(0x2000+sy['PianoPaint'])
            for _ in range(10000):
                pc=c.program_counter.value; minimum=min(minimum,c.system_stack_pointer.value)
                if pc==0x1900: break
                if rb(pc)==0x10 and rb(pc+1)==0x3f:
                    op=rb(pc+2); c.C=0
                    if op==sy['F$MapBlk']:
                        assert c.index_x.value in banks
                        mapped[0]=c.index_x.value; c.user_stack_pointer.set(0xe000)
                    else: assert op==sy['F$ClrBlk'], hex(op)
                    c.program_counter.set(pc+3)
                else: c.get_and_call_next_op()
            else: raise AssertionError('paint did not return')
            assert (c.accu_d.value,c.index_x.value,c.index_y.value,c.user_stack_pointer.value,c.system_stack_pointer.value)==(key*256+pressed,0x1234,0,0xe088,0x1b02)
            assert mapped[0]==0xd0 and banks[0xd8]==src
            octave,pc=divmod(key+21,12); entry=tab[pc]
            if key==0: entry &= 0xcf
            col=4+6*(7*octave+(entry&7)-12)+(4 if entry&128 else 0)
            rows,width=(15,4) if entry&128 else (23,6)
            offset=sy['PianoImages']+150*((entry>>4)&3)+pressed*sy['PianoPressed']
            expected=bytearray(b'\x11'*8192)
            for r in range(rows):
                for x in range(width):
                    v=src[offset+r*width+x]
                    if v: expected[64+col+320*r+x]=v
            for b in (0xa8,0xb8): assert banks[b]==expected, ('pixel mismatch',key,pressed,b,[(hex(i),v,expected[i]) for i,v in enumerate(banks[b]) if v!=expected[i]][:12],len(writes))
    print(f'PASS 264 real key paints, both bitmaps: source bank never written, exact pixels, stack low ${minimum:04X} from $1B00, ABI and score mapping restored')


def audition_flags():
    sy=symbols('Um3P_import');cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
    c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=c.memory
    m.load(0x4000,(ROOT/'.mods/CMDS/s9p').read_bytes())
    for flags in (0,0x0101,0x807f):
        c.system_stack_pointer.set(0x1f00);m.write_word(0x1f02,ord('a'));m.write_byte(0x10b0,0xd8)
        m.write_byte(sy['UmeData_smf'],flags>>8);m.write_byte(sy['UmeData_pldebug'],flags&255)
        c.program_counter.set(0x4000+sy['PlayMain'])
        for _ in range(30):
            if c.program_counter.value==0x4000+sy['FindDataBlock']:break
            c.get_and_call_next_op()
        assert m.read_byte(0x10b0)==0xd8, 'audition overwrote PianoSym'
        assert m.read_word(sy['AuditionSavedFlags'])==flags
    print('PASS audition saves two flags without changing PianoSym')


if __name__=='__main__':
    painter();audition_flags()
