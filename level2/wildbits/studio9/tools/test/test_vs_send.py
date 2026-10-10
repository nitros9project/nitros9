"""Execute the VS1053 sender: hardware addresses, backpressure, overlay handle and C ABI."""
import re,sys
from pathlib import Path
from test_midi_import import CPU,Memory,TestCfg,BaseCPUTestCase
binary,symbols=map(Path,sys.argv[1:3])
syms={k.lower():int(v,16) for k,v in re.findall(r"^(\w+) EQU \$([0-9A-F]+)",symbols.read_text(),re.M)}
for value in range(256):
 cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);cpu=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
 m=cpu.memory;m.load(0x2000,binary.read_bytes());m.write_word(7,0xc000);m.write_byte(4,0)
 cpu.system_stack_pointer.set(0x1f00);m.write_word(0x1f00,0x1800)
 cpu.accu_a.set(0xa5);cpu.accu_b.set(value);cpu.index_x.set(0x1234);cpu.index_y.set(0);cpu.user_stack_pointer.set(0x4567)
 writes=[];polls=[0]
 def rd(c,pc,a):
  polls[0]+=1
  return 0x40 if polls[0]%3 else 0
 def wr(c,pc,a,v):
  writes.append((a,v));return v
 m._read_byte_callbacks[0xff54]=rd
 m._write_byte_middleware[7]=wr;m._write_byte_middleware[0xff57]=wr
 cpu.program_counter.set(0x2000+syms['midivssend'])
 for step in range(200):
  if cpu.program_counter.value==0x1800:break
  cpu.get_and_call_next_op()
 else:raise AssertionError('sender did not return')
 assert writes==[(0xff57,0),(0xff57,value)],(value,writes)
 assert polls[0]==6 and m.read_word(7)==0xc000
 assert cpu.accu_d.value==(0xa500|value)
 assert cpu.index_x.value==0x1234 and cpu.index_y.value==0 and cpu.user_stack_pointer.value==0x4567
 assert cpu.system_stack_pointer.value==0x1f02
print('PASS all256 bytes: FIFO padding, backpressure, overlay handle and D/X/Y/U/S preserved')
