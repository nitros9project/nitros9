"""Exercise font loading and the actual pipe dispatcher for appended arrow text."""
import re
from test_midi_import import CPU,Memory,TestCfg,BaseCPUTestCase,ROOT

def test():
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=c.memory
    sy={k:int(v,16) for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/'.mods/s9gui_config.sym').read_text(),re.M)}
    blob=(ROOT/'.mods/CMDS/s9gui').read_bytes();m.load(0x4000,blob)
    font=(ROOT/'.mods/SYS/Chars16.img').read_bytes();assert len(font)==2376
    m.load(0xc100,font);m.load(0x129f,b'\xa5'*16);m.load(sy['FrArrowGlyphs']+72,b'\xa5'*16)
    m.write_word(0x3e00,0x3f00);c.system_stack_pointer.set(0x3e00);c.user_stack_pointer.set(0x1234);c.index_y.set(0);c.program_counter.set(0x4000+sy['LoadFontData'])
    for _ in range(30000):
        pc=c.program_counter.value
        if pc==0x3f00:break
        if pc in [0x4000+sy[n] for n in ('SymUnmap','BankParams','LinkDataBank')]:
            c.C=0;c.accu_d.set(0)
            if pc==0x4000+sy['LinkDataBank']:c.user_stack_pointer.set(0xc000)
            c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
        if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
            assert m.read_byte(pc+2)==2 and c.user_stack_pointer.value==0xc000
            c.program_counter.set(pc+3);continue
        c.get_and_call_next_op()
    else:raise AssertionError('font load did not return')
    assert bytes(m.read_byte(0x99f+i) for i in range(2304))==font[:2304]
    assert bytes(m.read_byte(sy['FrArrowGlyphs']+i) for i in range(72))==font[-72:]
    for a in (0x129f,sy['FrArrowGlyphs']+72):assert bytes(m.read_byte(a+i) for i in range(16))==b'\xa5'*16
    assert c.user_stack_pointer.value==0x1234 and c.system_stack_pointer.value==0x3e02
    # Stream real text controls through dispatch -> vanna -> VannaBody.
    m.write_byte(sy['tgwmode'],1);m.write_byte(sy['alfacurse'],0);m.write_word(sy['wncols'],78)
    m.write_word(sy['curcol'],72);m.write_word(sy['curaddr'],0)
    stream=b'\x1d\x1e \x1f';pos=0;cells=[]
    m.write_word(0x3e00,0x3f00);c.system_stack_pointer.set(0x3e00);c.program_counter.set(0x4000+sy['dispatch'])
    for _ in range(6000):
        pc=c.program_counter.value
        if pc==0x4000+sy['CmdReadNext'] and pos==len(stream):break
        if pc==0x4000+sy['fread']:
            sp=c.system_stack_pointer.value;n=m.read_word(sp+4)*m.read_word(sp+6);assert n==1
            m.write_byte(m.read_word(sp+2),stream[pos]);pos+=1;c.accu_d.set(1);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
        if pc==0x4000+sy['ScrAddr']:
            cells.append(m.read_word(sy['curcol']));c.user_stack_pointer.set(0xd000+c.accu_d.value);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
        if pc in [0x4000+sy[n] for n in ('illegal','linefeed')]:raise AssertionError('arrow became a command or wrapped text')
        c.get_and_call_next_op()
    else:raise AssertionError('arrow dispatch did not finish')
    assert cells==[72,73,74,75],cells
    for cell,offset in ((0,2304),(1,2328),(3,2352)):
        got=bytes(m.read_byte(0xd000+cell*4+y*320+x) for y in range(6) for x in range(4))
        assert got==font[offset:offset+24]
    assert c.system_stack_pointer.value==0x3e00-2-0x4d and c.user_stack_pointer.value==0x1234
    print('PASS appended arrow font load, neighbor guards, pipe dispatcher, 8x6 pixels, character advance and stack')

if __name__=='__main__':test()
