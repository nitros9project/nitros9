"""Diagnostic: actual Squawk/format/input return path, with OS mouse/key fixtures.
Fran rendering is not emulated here; a passing result does not resolve the
reported second mCY dialog on hardware.
"""
import re
from test_midi_import import CPU,Memory,TestCfg,BaseCPUTestCase,ROOT

def setup():
 sy={k:int(v,16) for k,v in re.findall(r'^([^ ]+) EQU \$([0-9A-F]+)',(ROOT/'.mods/s9_config.sym').read_text(),re.M)}
 cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=c.memory
 m.load(0x2000,(ROOT/'.mods/CMDS/s9').read_bytes());c.user_stack_pointer.set(0);c.index_y.set(0x1fff);c.system_stack_pointer.set(0x1f00);m.write_byte(0x1f00,13);c.program_counter.set(sy['start']+0x2000)
 for _ in range(50000):
  if c.program_counter.value==sy['CallMain']+0x2000:break
  c.get_and_call_next_op()
 else:raise AssertionError('C initialization failed')
 c.index_y.set(0)
 return c,sy

def test(full=False):
 c,sy=setup();m=c.memory;base=0x2000
 m.write_byte(sy["MIDI.Base"],sy["MIDI.RxEmpty"])
 records=[bytes.fromhex(e) for e in ['0000000000000000','0000009900194c59','0000000000160100','0000000000170100','0100000300030002']]
 m.load(0xe000,b''.join(records));m.write_word(sy['nparts'],1);m.write_byte(0x3f4,0);m.load(0x7eb,b'Piano\0')
 m.write_word(0x1e00,0x1f80);m.write_word(0x1e02,4);c.system_stack_pointer.set(0x1e00);c.user_stack_pointer.set(0x1234);c.program_counter.set(base+sy['squawk']);out=[];hits=[];trace=[]
 for _ in range(150000):
  pc=c.program_counter.value;sp=c.system_stack_pointer.value
  trace.append((hex(pc),hex(sp),hex(c.accu_d.value),hex(c.index_x.value),hex(c.user_stack_pointer.value)));trace=trace[-35:]
  if pc==0x1f80:break
  if pc in (base+sy['i2p'],base+sy['plusplus'],base+sy['decdec']):
   i=m.read_word(sp+2) if pc==base+sy['i2p'] else m.read_word(sy['curind'])+(1 if pc==base+sy['plusplus'] else -1)
   m.write_word(sy['curind'],i);c.accu_d.set(0xe000+8*i);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
  if pc==base+sy['FPutc']:
   out.append(m.read_word(sp+2)&255);c.accu_d.set(out[-1]);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
  if full and pc in [base+sy[n] for n in ('automouse','bell','FFlush')]:
   name=next(n for n in ('automouse','bell','FFlush') if pc==base+sy[n]);hits.append(name)
   c.accu_d.set(13 if name=='kmouse' else 0);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
  if not full and pc in [base+sy[n] for n in ('dialogue','flush','hitenter','wkill')]:
   hits.append(next(n for n in ('dialogue','flush','hitenter','wkill') if pc==base+sy[n]));c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
  if full and m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
   op=m.read_byte(pc+2);c.C=0
   if op==sy['I$GetStt']:
    if c.accu_b.value==sy['SS.Mouse']:
     c.accu_a.set(0);c.index_x.set(300);c.index_y.set(200)
    elif c.accu_b.value==sy['SS.Ready']:c.index_x.set(1)
    else:raise AssertionError(('getstat',c.accu_b.value))
   elif op==sy['I$Read']:
    m.write_byte(c.index_x.value,13);c.index_y.set(1)
   else:raise AssertionError(('OS call',op,hex(pc),trace))
   c.program_counter.set(pc+3);continue
  c.get_and_call_next_op()
 else:raise AssertionError(('squawk did not return',hex(c.program_counter.value),bytes(out),hits))
 print('report',bytes(out));print('calls',hits,'SP',hex(c.system_stack_pointer.value),'U',hex(c.user_stack_pointer.value),'Y',hex(c.index_y.value))
 assert c.system_stack_pointer.value==0x1e02 and c.user_stack_pointer.value==0x1234 and c.index_y.value==0
 if not full:assert hits[-2:]==['hitenter','wkill']
 return bytes(out)
if __name__=='__main__':test();test(True)
