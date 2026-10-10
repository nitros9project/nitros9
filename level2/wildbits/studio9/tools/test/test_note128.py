"""Execute real note packet packing, preserving legacy accidentals and stack."""
import re
from test_midi_import import CPU,Memory,TestCfg,BaseCPUTestCase,ROOT,run,smf,note

def symbols(name):
    return {k.lower():int(v,16) for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/f'.mods/{name}_new.sym').read_text(),re.M)}
main=symbols('s9');binary=(ROOT/'.mods/CMDS/s9').read_bytes()
cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);cpu=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
m=cpu.memory;m.load(0x2000,binary)
count=0
for dur in range(9):
 for dots in range(4):
  for accidental in range(5):
   for articulation in range(5):
    for stem in (0,1):
     for rest in (False,True):
      cpu.system_stack_pointer.set(0x1f00);m.write_word(0x1f00,0x1800)
      cpu.index_y.set(0);cpu.user_stack_pointer.set(0x1234)
      m.load(0x1200,bytes([dur,dots,0x20 if rest else 3,articulation,accidental]))
      for j,v in enumerate((0x1200,20,80,60,stem,0,0)):m.write_word(0x1f02+2*j,v)
      cpu.program_counter.set(0x2000+main['drawnr']);packets=[]
      for step in range(300):
       pc=cpu.program_counter.value
       if pc==0x1800:break
       if pc==0x2000+main['nfwrite']:
        n=m.read_word(cpu.system_stack_pointer.value+2)
        packets.append(bytes(m.read_byte(0x95+j) for j in range(n)))
        cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
       else:cpu.get_and_call_next_op()
      else:raise AssertionError('packet did not return')
      flags=(0x40 if dur==8 else 0) | (0 if rest else articulation*8+stem*2)
      packed=min(dur,7)*4+dots+(0 if rest else accidental*32)
      expected=bytes([0xa1 if rest else 0xa0,flags,20,80,packed]+([] if rest else [60]))
      assert packets==[expected],(dur,dots,accidental,articulation,stem,rest,packets,expected)
      assert cpu.system_stack_pointer.value==0x1f02 and cpu.user_stack_pointer.value==0x1234 and cpu.index_y.value==0
      count+=1

for ticks in (0,1,10,15,20,30,60):
 r=run(smf(note(60,duration=ticks)),native=True)
 assert r['result']==1 and len(r['notes'])==1,r
 assert r['compact']==1,r
 assert r['notes'][0][3]<=8 and len(r['rawnotes'])==2,r
 if ticks<=15:assert r['notes'][0][3]==8,r
 assert r['rawnotes'][-1][1:3]==(ticks//10).to_bytes(2,'big'),r
print(f'PASS {count} note/rest packets, legacy fields, 128th flag, short-note import/raw timing and stack preservation')

fr=symbols('s9gui');fb=(ROOT/'.mods/CMDS/s9gui').read_bytes()
for name in ('note128up','note128down'):
 cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);cpu=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
 m=cpu.memory;m.load(0x4000,fb);ptr=0x4000+fr[name]
 cpu.system_stack_pointer.set(0x1f00);m.write_word(0x1f00,0x1800)
 cpu.accu_d.set(0x0210);cpu.index_x.set(ptr);cpu.index_y.set(0x1234);cpu.user_stack_pointer.set(0x5678)
 cpu.program_counter.set(0x4000+fr['srcfix'])
 for step in range(100):
  if cpu.program_counter.value==0x1800:break
  cpu.get_and_call_next_op()
 assert m.read_byte(fr['fr4src'])==1 and cpu.index_x.value==ptr
 assert (cpu.accu_d.value,cpu.index_y.value,cpu.user_stack_pointer.value,cpu.system_stack_pointer.value)==(0x0210,0x1234,0x5678,0x1f02)
 assert bytes(m.read_byte(ptr+i) for i in range(128)).count(0x99)==2
print('PASS both red-dot glyph sources and SrcFix register/stack preservation')

for stem in (0,2):
 for noflags in (0,4):
  cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);cpu=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
  m=cpu.memory;m.load(0x4000,fb)
  m.load(0x1e,bytes([0x40|stem|noflags,20,80,0x5c,60]))
  cpu.system_stack_pointer.set(0x1f00);m.write_word(0x1f00,0x1800)
  cpu.index_y.set(0);cpu.user_stack_pointer.set(0x1234)
  cpu.program_counter.set(0x4000+fr['dnota']);images=[]
  for step in range(2000):
   pc=cpu.program_counter.value
   if pc==0x1800:break
   if pc==0x4000+fr['put2']:
    images.append(m.read_word(cpu.system_stack_pointer.value+8))
    cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
   elif pc==0x4000+fr['ledger']:
    cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
   else:cpu.get_and_call_next_op()
  else:raise AssertionError('dnota did not return')
  expected=0x4000+fr['note128up']+(128 if stem else 0)+(256 if noflags else 0)
  assert images==[expected],(stem,noflags,images,expected)
  assert cpu.system_stack_pointer.value==0x1f02 and cpu.user_stack_pointer.value==0x1234 and cpu.index_y.value==0
print('PASS renderer selects red-dot up/down and no-flags pictures; C frame balanced')

k=symbols('s9k');kb=(ROOT/'.mods/CMDS/s9k').read_bytes()
for routine in ('kprint','kparse'):
 cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);cpu=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
 m=cpu.memory;m.load(0x4000,kb)
 for key,value in (('kpdur',8),('kpdmod',0),('kpnotch',ord('c')),('kpoctch',ord('4')),('kpitmod',0),('kpartic',2)):
  (m.write_byte if key in ('kpnotch','kpoctch') else m.write_word)(k[key],value)
 m.load(0x1200,b'128c4n\0' if routine=='kparse' else b'xxxxxx\0')
 if routine=='kparse':m.write_word(k['kpdur'],3)
 cpu.system_stack_pointer.set(0x1f00);m.write_word(0x1f00,0x1800);m.write_word(0x1f02,0x1200)
 cpu.index_y.set(0);cpu.user_stack_pointer.set(0x1234);cpu.program_counter.set(0x4000+k[routine])
 for step in range(3000):
  if cpu.program_counter.value==0x1800:break
  cpu.get_and_call_next_op()
 else:raise AssertionError((routine,'did not return',hex(cpu.program_counter.value)))
 assert m.read_word(k['kpdur'])==8,(routine,m.read_word(k['kpdur']))
 assert bytes(m.read_byte(0x1200+i) for i in range(7))==b'128c4n\0'
 assert cpu.system_stack_pointer.value==0x1f02 and cpu.user_stack_pointer.value==0x1234 and cpu.index_y.value==0
print('PASS 128 duration entry formats/parses without overrunning legacy tables; stack balanced')
