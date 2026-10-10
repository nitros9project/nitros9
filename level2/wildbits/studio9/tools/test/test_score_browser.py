"""Execute s9d's real directory filter and extension handling on a 6809 CPU."""
import re
from test_midi_import import CPU,Memory,TestCfg,BaseCPUTestCase,ROOT

def directory(names):
    result=b''
    for name in names:
        b=bytearray(name.encode()); b[-1]|=128
        result+=bytes(b).ljust(32,b'\0')
    return result

def run(entry,args,strings,ext=None,import_result=None, importer='I'):
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT)
    cpu=CPU(Memory(cfg),cfg); cfg.ROM_START=0x10000
    m=cpu.memory; base=0x4000
    module='s9r' if entry=='ReadDirList' else 's9d'
    m.load(base,(ROOT/'.mods/CMDS'/module).read_bytes())
    sym={k:int(v,16)+base for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/f'.mods/{module}_browser.sym').read_text(),re.M)}
    for addr,text in strings.items(): m.load(addr,text.encode()+b'\0')
    if entry=='ReadDirList':
        args.append(0x3100);m.load(0x3100,b'\0'*14)
    if ext:
        args[1]=sym[ext]
    m.write_word(0x1f00,0x3f00)
    for i,arg in enumerate(args): m.write_word(0x1f02+i*2,arg)
    cpu.system_stack_pointer.set(0x1f00);cpu.index_y.set(0);cpu.user_stack_pointer.set(0x1234)
    cpu.program_counter.set(sym[entry]); pos=0
    m.write_word(0x363,0x3e00)
    imports=[]; trace=[]; bonks=0
    m.write_word(0x377,0x3d00)
    data=directory(['.','..','BACH.MID','sonata.ume','skip.ins','other.txt'])
    for _ in range(300000):
        pc=cpu.program_counter.value
        if entry=='OverlayMain' and pc in {v for k,v in sym.items() if k.startswith('Main') or k in ('OverlayMain','MidiReadScore')}:
            trace.append((next(k for k,v in sym.items() if v==pc),cpu.accu_d.value,hex(cpu.system_stack_pointer.value)))
        if pc==0x3d00:
            bonks+=1
            cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
            continue
        if import_result=='reject' and pc==sym['MainClearName']:
            assert bonks==1 and pos==0 and not imports
            assert cpu.system_stack_pointer.value==0x1e42, hex(cpu.system_stack_pointer.value)
            return 'rejected',[],None,trace
        if pc==0x3e00:
            s=cpu.system_stack_pointer.value
            imports.append([m.read_word(s+i) for i in (2,4,6)])
            assert imports[-1]==[ord(importer),ord('i'),3],imports
            assert import_result is not None
            cpu.accu_d.set(import_result);cpu.Z=int(import_result==0)
            cpu.program_counter.set(cpu.pull_word(cpu.system_stack_pointer))
            continue
        if pc==0x3f00:
            assert cpu.system_stack_pointer.value==0x1f02
            def text(addr):
                b=[]
                while m.read_byte(addr): b.append(m.read_byte(addr));addr+=1
                return bytes(b).decode()
            return cpu.accu_d.value,[text(0x2000+i*26) for i in range(cpu.accu_d.value if entry=='ReadDirList' else 2)],text(0x3000),trace
        if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
            op=m.read_byte(pc+2);cpu.C=0
            if op==0x84:
                assert import_result != 'reject', 'unsupported name reached I$Open'
                cpu.accu_a.set(3)
            elif op==0x8f: pass
            elif op==0x8d:
                assert cpu.accu_b.value==5
                cpu.index_x.set(pos>>16);cpu.user_stack_pointer.set(pos&65535)
            elif op==0x88: pos=(cpu.index_x.value<<16)|cpu.user_stack_pointer.value
            elif op==0x89:
                chunk=data[pos:pos+cpu.index_y.value];pos+=len(chunk)
                m.load(cpu.index_x.value,chunk);cpu.index_y.set(len(chunk))
                if not chunk: cpu.C=1;cpu.accu_b.set(211)
            else: raise AssertionError(hex(op))
            cpu.program_counter.set(pc+3)
        else: cpu.get_and_call_next_op()
    raise AssertionError(('instruction limit',hex(cpu.program_counter.value)))

def test():
    for name,want in [('test.mid',ord('I')),('test.MID',ord('I')),('test.lyr',ord('Y')),('test.LYR',ord('Y')),('test.mus',ord('F')),('test.MUS',ord('F')),('test.ume',1),('test.UME',1),('x.ins',0),('x.mid.ume',1)]:
        r=run('HasExtension',[0x3000,0],{0x3000:name},'strScoreExt')
        assert r[0]==want,(name,r)
    r=run('ReadDirList',[0x2000,0,0],{0x3000:''},'strScoreExt')
    assert r[0]==3 and set(r[1])=={'/..','BACH.MID','sonata.ume'},r
    r=run('ReadDirList',[0x2000,0,0],{0x3000:''},'strExtUme')
    assert r[0]==2 and set(r[1])=={'/..','sonata'},r
    for name,want in [('score','score.ume'),('score.ume','score.ume')]:
        r=run('AddExtension',[0x3000,0],{0x3000:name},'strExtUme')
        assert r[2]==want,r
    for name in ('song.mid','song.MID'):
        r=run('OverlayMain',[ord('d'),0x3000,0,ord('u'),0,0],{0x3000:name},import_result=1)
        assert r[0]==1 and r[2]=='song.ume',r
    r=run('OverlayMain',[ord('d'),0x3000,0,ord('u'),0,0],{0x3000:'bad.mid'},import_result=0)
    assert r[0]==0 and r[2]=='bad.mid',r
    r=run('OverlayMain',[ord('d'),0x3000,0,ord('u'),0,0],{0x3000:'song.lyr'},import_result=1,importer='Y')
    assert r[0]==1 and r[2]=='song.ume',r
    r=run('OverlayMain',[ord('d'),0x3000,0,ord('u'),0,0],{0x3000:'song.mus'},import_result=1,importer='F')
    assert r[0]==1 and r[2]=='song.ume',r
    for name in ('no_extension','abc','x','score.', 'score.bad'):
        r=run('OverlayMain',[ord('d'),0x3000,0,ord('u'),0,0],{0x3000:name},import_result='reject')
        assert r[0]=='rejected', r
    print('PASS: assembled Read Score browser recognizes .mid/.lyr/.mus/.ume case-insensitively; native .ume save filtering/extension unchanged')

if __name__=='__main__':test()
