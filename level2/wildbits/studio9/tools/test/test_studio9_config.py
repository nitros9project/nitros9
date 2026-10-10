"""Execute Studio9 configuration overlay with an in-memory OS-9 filesystem."""
import posixpath,re,xml.etree.ElementTree as ET
from test_midi_import import CPU,Memory,TestCfg,BaseCPUTestCase,ROOT
CFG='/dd/sys/studio9.cfg'

def run(cwd='/s0/music',config=None,command='e',drive='/x1',bad_write=False,entry='start',dirs=None,descriptors=None,mod_error=False,heap=0xce0,resume=None):
    dirs=set(dirs or ['/s0','/s0/music','/s0/music/sub','/s1','/s1/song','/x0','/x1','/x1/scores','/x2','/x3','/x3/A&B','/x3/A&B/q"<x>'])
    sy={k:int(v,16) for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/'.mods/Um3G_config.sym').read_text(),re.M)}
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=c.memory
    m.load(0x4000,(ROOT/'.mods/CMDS/s9g').read_bytes());
    if resume is not None:m.load(0, resume)
    m.write_word(0x1f00,0x3f00)
    m.write_word(0x1f02,ord(command));m.write_word(0x1f04,0x1df0);m.load(0x1df0,drive.encode()+b'\0')
    c.system_stack_pointer.set(0x1f00);c.user_stack_pointer.set(0x1234);c.index_y.set(0);c.index_x.set(0x2345)
    c.program_counter.set(0x4000+sy[entry]);opened={};lsns={p:i+100 for i,p in enumerate(sorted(dirs))};chdirs=[]
    packets=[]
    m.write_word(0x383,0x3d00)
    if resume is None:m.write_word(0x34b,heap)
    writes=[]
    if command=='m':
        m.write_word(0x1f00,0x3f00);m.write_word(0x1f02,ord(command));c.system_stack_pointer.set(0x1f00)
    modules={}
    if descriptors is None: descriptors=[]
    for i,(dev,driver,kind) in enumerate(descriptors):
        blob=bytearray(80);blob[0:2]=b'\x87\xcd';blob[2:4]=(80).to_bytes(2,'big')
        blob[4:6]=(24).to_bytes(2,'big');blob[6]=0xf1;blob[9:11]=(48).to_bytes(2,'big')
        blob[11:13]=(56).to_bytes(2,'big');blob[0x12]=kind
        def osname(name):
            data=bytearray(name.encode());data[-1]|=128;return data
        for offset,n in [(24,dev),(48,'RBF'),(56,driver)]:blob[offset:offset+len(n)]=osname(n)
        modules[i]=bytes(blob)
    files={} if config is None else {CFG:config.encode() if isinstance(config,str) else config}
    def name(addr):
        out=[]
        while m.read_byte(addr):out.append(m.read_byte(addr));addr+=1
        return bytes(out).decode('ascii')
    def resolve(p):return posixpath.normpath(p if p.startswith('/') else cwd+'/'+p).lower()
    # Preserve source spelling for filesystem names, case-insensitive lookup.
    canonical={p.lower():p for p in dirs}
    def dirbytes(p):
        parent=p.rsplit('/',1)[0] or p
        if parent not in dirs:parent=p
        values=[('..',parent),('.',p)]+[(q.rsplit('/',1)[1],q) for q in sorted(dirs) if q.rsplit('/',1)[0]==p]
        result=b''
        for n,q in values:
            b=bytearray(n.encode());b[-1]|=128
            result+=bytes(b).ljust(29,b'\0')+lsns[q].to_bytes(3,'big')
        return result
    for step in range(300000):
        pc=c.program_counter.value
        assert c.system_stack_pointer.value > 0x104c, hex(c.system_stack_pointer.value)
        if pc==0x3d00:
            assert c.index_y.value==0, "C output callback lost static-base Y"
            packets.append(m.read_word(c.system_stack_pointer.value+2)&255);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
        if pc==0x3f00:
            assert (c.system_stack_pointer.value,c.user_stack_pointer.value,c.index_y.value,c.index_x.value)==((0x1f02 if command=='m' else 0x1f02),0x1234,0,0x2345)
            assert not opened,opened
            return dict(resume=bytes(m.read_byte(i) for i in range(0x2000)),writes=writes,cwd=cwd,config=files.get(CFG),result=c.accu_d.value,chdirs=chdirs,steps=step,packets=packets,table=bytes(m.read_byte(m.read_word(0x112d)+i) for i in range(83)) if command=='m' else None)
        if m.read_byte(pc)!=0x10 or m.read_byte(pc+1)!=0x3f:c.get_and_call_next_op();continue
        op=m.read_byte(pc+2);c.C=0
        def error(code):c.C=1;c.accu_b.set(code)
        if op==0x1a:
            if mod_error:error(207)
            else:
                base=c.index_x.value;m.load(base,bytes(2048))
                for i,blob in modules.items():
                    dat=0x600+i*16
                    m.write_word(base+i*8,0xa00+dat);m.write_word(base+i*8+4,0x2000)
                    m.write_word(base+dat,i)
                c.index_y.set(base+len(modules)*8);c.user_stack_pointer.set(0xa00)
        elif op==0x1b:
            i=m.read_word(c.accu_d.value);offset=c.index_x.value-0x2000
            data=modules[i][offset:offset+c.index_y.value]
            assert len(data)==c.index_y.value
            m.load(c.user_stack_pointer.value,data)
        elif op in (0x83,0x84):
            path=resolve(name(c.index_x.value));mode=c.accu_a.value
            if path==CFG and mode&2:writes.append((op, mode))
            if mode&128:
                if path not in canonical:error(216)
                else:
                    path=canonical[path];fd=next(i for i in range(3,32) if i not in opened);opened[fd]=[path,0,dirbytes(path)];c.accu_a.set(fd)
            elif bad_write and mode&2:error(214)
            elif path not in files and op==0x84:error(216)
            else:
                if op==0x83:files[path]=b''
                fd=next(i for i in range(3,32) if i not in opened);opened[fd]=[path,0,None];c.accu_a.set(fd)
        elif op==0x89:
            path,pos,data=opened[c.accu_a.value];data=files[path] if data is None else data
            chunk=data[pos:pos+c.index_y.value];opened[c.accu_a.value][1]+=len(chunk)
            m.load(c.index_x.value,chunk);c.index_y.set(len(chunk))
            if not chunk:error(211)
        elif op==0x8a:
            path,pos,_=opened[c.accu_a.value]
            if bad_write:error(214)
            else:
                chunk=bytes(m.read_byte(c.index_x.value+i) for i in range(c.index_y.value));old=files[path]
                files[path]=old[:pos]+chunk+old[pos+len(chunk):];opened[c.accu_a.value][1]+=len(chunk)
        elif op==0x8d:
            assert c.accu_b.value==14
            path=opened[c.accu_a.value][0];b=bytearray(path.split('/')[1].encode());b[-1]|=128;m.load(c.index_x.value,bytes(b).ljust(32,b'\0'))
        elif op==0x8e:
            assert c.accu_b.value==2
            path=opened[c.accu_a.value][0];files[path]=files[path][:((c.index_x.value<<16)|c.user_stack_pointer.value)]
        elif op==0x8f:del opened[c.accu_a.value]
        elif op==0x86:
            path=resolve(name(c.index_x.value));chdirs.append(path)
            if path not in canonical:error(216)
            else:cwd=canonical[path]
        else:raise AssertionError(hex(op))
        c.program_counter.set(pc+3)
    raise AssertionError(('instruction limit',hex(c.program_counter.value),sy))

def integration():
    def load(module):
        cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
        c.memory.load(0x4000,(ROOT/'.mods/CMDS'/module).read_bytes())
        sy={k:int(v,16)+0x4000 for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/f'.mods/{module}_config.sym').read_text(),re.M)}
        c.memory.write_word(0x363,0x3e00);c.memory.write_word(0x3000,0x3f00)
        c.system_stack_pointer.set(0x3000);c.index_y.set(0);c.user_stack_pointer.set(0x1234)
        return c,sy
    for i,drive in enumerate(('s0','s1','x0','x1','x2','x3')):
        c,sy=load('s9d');m=c.memory;m.write_word(0x112d,0x1200);m.load(0x1240,b's0\0s1\0x0\0x1\0x2\0x3\0');m.write_word(0x3002,0x10+i);c.program_counter.set(sy['OverlayMain']);called=0
        for _ in range(100):
            pc=c.program_counter.value
            if pc==0x3e00:
                sp=c.system_stack_pointer.value
                assert [m.read_word(sp+a) for a in (2,4)]==[ord('G'),ord('r')]
                ptr=m.read_word(sp+6);assert ptr<0x4000
                assert bytes(m.read_byte(ptr+j) for j in range(4))==('/'+drive).encode()+b'\0'
                called+=1;c.accu_d.set(0);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
            if pc==sy['MainNormalCommand']:
                assert called==1 and c.system_stack_pointer.value==0x2f42
                assert m.read_word(0x2f42+0xc6)==ord('u') and m.read_byte(m.read_word(0x2f42+0xc2))==0
                break
            c.get_and_call_next_op()
        else:raise AssertionError('drive shortcut did not reach browser')
    for fail in (False,True):
        c,sy=load('s9r');m=c.memory;m.write_word(0x3002,0x3200);m.load(0x3200,b'sub\0');c.program_counter.set(sy['ChangeDir']);called=0
        for _ in range(100):
            pc=c.program_counter.value
            if pc==0x3f00:break
            if pc==0x3e00:
                sp=c.system_stack_pointer.value
                assert [m.read_word(sp+a) for a in (2,4)]==[ord('G'),ord('s')]
                called+=1;c.accu_d.set(0);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
            if m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
                assert m.read_byte(pc+2)==0x86
                c.C=int(fail)
                if fail:c.accu_b.set(216)
                c.program_counter.set(pc+3);continue
            c.get_and_call_next_op()
        else:raise AssertionError('browser directory change did not return')
        assert called==0 and c.accu_d.value==(65535 if fail else 0)
        assert (c.system_stack_pointer.value,c.user_stack_pointer.value,c.index_y.value)==(0x3002,0x1234,0)
    print('PASS all six drive shortcuts and browser directory-change overlay calls: correct arguments, stack strings, return values and stack preservation')

def menu_tests():
    for descriptors,expected in [([],[]),([('s','rbsd',1),('b','rbdw',1)],['s','b']),([('term','vtio',0),('f0','rbmem',1),('dd','RBMEM',1),('s0','rbsd',1),('s0','rbsd',1),('s1','rbsd',1),('x0','rbdw',1),('x1','rbdw',1),('x2','rbdw',1),('x3','rbdw',1),('x4','rbdw',1)],['s0','s1','x0','x1','x2','x3']),([('long','rbsd',1),('DD','rbsd',1),('x','RbMem',1),('b','rbmemx',1)],['dd','b'])]:
        r=run(config=None,command='m',descriptors=descriptors);t=r['table'];assert t[82]==len(expected),(expected,r)
        assert [t[64+i*3:67+i*3].split(b'\0')[0].decode() for i in range(len(expected))]==expected,r
        col=79-sum(len(n)+1 for n in expected)
        for i,n in enumerate(expected):
            width=len(n)+1
            assert t[40+i*4:44+i*4]==bytes([col,185,col+width-1,191]),r
            col+=width
        assert all(t[40+i*4]==255 for i in range(len(expected),6)),r
        assert len(r['packets'])==30
        for i in range(6):
            packet=r['packets'][5*i:5*i+5]
            assert packet[:2]==[0xb7,i]
            assert packet[2]==t[40+i*4]
            n=expected[i].upper().encode().ljust(2,b'\0') if i<len(expected) else b'\0\0'
            assert packet[3:]==list(n),(expected,packet)
    r=run(command='m',mod_error=True);assert r['table'][82]==0 and r['config'] is None
    r=run(command='m',heap=0x1e00);assert r['result']==0xffff
    r=run(command='m',config='invalid XML',descriptors=[('s0','rbsd',1)]);assert r['table'][82]==1 and r['config']==b'invalid XML'
    # Longer current paths are truncated to127 characters when saved.
    parts=['a'*20,'b'*20,'c'*20,'d'*20,'e'*20,'f'*20,'g'*20]
    dirs=['/s0'];path='/s0'
    for part in parts:path+='/'+part;dirs.append(path)
    r=run(path,dirs=dirs);assert ET.fromstring(r['config']).findtext('s0')==path[:127],r
    for drive in ('s','b'):
        r=run('/'+drive,dirs=['/'+drive]);assert ET.fromstring(r['config']).findtext(drive)=='/'+drive,r
        r=run('/s0/music',r['config'],'r','/'+drive,dirs=['/s0','/s0/music','/'+drive]);assert r['cwd']=='/'+drive,r
    print('PASS loaded RBF enumeration, rbmem exclusion, duplicates/six-drive limit, missing config, syscall failure, stack-space guard, runtime widths, root restore and127-character save truncation')

def rendering_tests():
    def load(module):
        cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000
        c.memory.load(0x4000,(ROOT/'.mods/CMDS'/module).read_bytes()[:0xa000])
        sy={k:int(v,16) for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/f'.mods/{module}_config.sym').read_text(),re.M)}
        return c,sy
    for names in ([],['s','b'],['s0','b','x3'],['s0','s1','x0','x1','x2','x3']):
        r=run(command='m',descriptors=[(n,'rbsd',1) for n in names]);table=r['table']
        c,sy=load('s9gui');m=c.memory
        for i in range(6):
            m.load(0x1e,bytes(r['packets'][i*5+1:i*5+5]));m.write_word(0x3000,0x3f00)
            c.system_stack_pointer.set(0x3000);c.index_y.set(0);c.user_stack_pointer.set(0x1234);c.program_counter.set(0x4000+sy['SetDriveLabel'])
            for _ in range(100):
                if c.program_counter.value==0x3f00:break
                c.get_and_call_next_op()
            else:raise AssertionError('label packet did not return')
            assert c.system_stack_pointer.value==0x3002 and c.user_stack_pointer.value==0x1234
        # Execute the actual shortcut draw loop, intercepting only primitives.
        m.write_word(0x3007,0x1234);m.write_word(0x3009,0x3f00);c.system_stack_pointer.set(0x3000);c.program_counter.set(0x4000+sy['dmenbar_6']);drawn=[]
        for _ in range(1000):
            pc=c.program_counter.value
            if pc==0x3f00:break
            if pc==0x4000+sy['phrase']:
                sp=c.system_stack_pointer.value;ptr=m.read_word(sp+6);label=[]
                while m.read_byte(ptr):label.append(m.read_byte(ptr));ptr+=1
                drawn.append((m.read_word(sp+2),m.read_word(sp+4),bytes(label)))
                c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
            if pc==0x4000+sy['bytblt']:
                c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
            c.get_and_call_next_op()
        else:raise AssertionError('drive draw loop did not return')
        assert drawn==[(table[40+i*4],186,(' '+n.upper()).encode()) for i,n in enumerate(names)],drawn
        assert c.system_stack_pointer.value==0x300b and c.user_stack_pointer.value==0x1234
        # Exhaust every pixel of the drive region against the actual main hit test.
        c,sy=load('s9');m=c.memory;m.write_word(0x112d,0x1200);m.load(0x1200,table);m.write_word(0x10fe,0) # score redraw saves KeepGind; must not alter menu pointer
        for px in range(54*8,640):
            c.accu_d.set(px);c.index_x.set(185);c.index_y.set(0);c.user_stack_pointer.set(0x1234)
            c.system_stack_pointer.set(0x3000);m.write_word(0x3000,0x3f00);c.program_counter.set(0x4000+sy['MenuBarHit'])
            for _ in range(500):
                if c.program_counter.value==0x3f00:break
                c.get_and_call_next_op()
            else:raise AssertionError('hit test did not return')
            want=next((10+i for i in range(len(names)) if table[40+i*4]<=px//8<=table[42+i*4]),65535)
            assert c.accu_d.value==want,(names,px,want,c.accu_d.value)
            assert c.system_stack_pointer.value==0x3002 and c.user_stack_pointer.value==0x1234 and c.index_y.value==0
        for i in range(len(names)):
            m.write_word(0x1061,10+i);m.write_word(0x3000,0x3f00);c.system_stack_pointer.set(0x3000);c.program_counter.set(0x4000+sy['InvertMenuBarHover']);seen=[]
            for _ in range(500):
                pc=c.program_counter.value
                if pc==0x3f00:break
                if pc in (0x4000+sy['SendMarkPacket'],0x4000+sy['flush']):
                    if pc==0x4000+sy['SendMarkPacket']:
                        sp=c.system_stack_pointer.value;seen.append([m.read_word(sp+a) for a in (2,4,6,8,10)])
                    c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
                c.get_and_call_next_op()
            assert seen==[[0x7303,*table[40+i*4:44+i*4]]],seen
    print('PASS actual Fran drive-label packets/draw loop and main hit/hover routines: blank, single/mixed-width and six-drive menus, four-pixel highlight shift preserved')

def protocol_tests():
    """Exercise the real Fran dispatcher, including refresh next to drive labels."""
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=c.memory
    sy={k:int(v,16) for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/'.mods/s9gui_config.sym').read_text(),re.M)}
    blob=(ROOT/'.mods/CMDS/s9gui').read_bytes();m.load(0x4000,blob)
    table=sy['tblInitData']+15;dest=0xb0
    while blob[table]!=0xd3:
        op,n=blob[table:table+2];handler=int.from_bytes(blob[table+2:table+4],'big')
        m.load(dest,bytes([op,n])+(0x4000+handler).to_bytes(2,'big'))
        if op==0xcd:assert (n,handler)==(1,sy['unimp'])
        if op==0xb7:assert (n,handler)==(4,sy['SetDriveLabel'])
        table+=4;dest+=4
    m.load(dest,b'\xd3\x00\x00\x00')
    stream=bytes([0xcd,13,0xb7,0,74,ord('S'),0,0xcd,13,0xca,13]);pos=0;presented=0
    m.write_word(0x3e00,0x3f00);c.system_stack_pointer.set(0x3e00);c.index_y.set(0);c.program_counter.set(0x4000+sy['dispatch'])
    for _ in range(20000):
        pc=c.program_counter.value
        if pc==0x4000+sy['CmdReadNext'] and pos==len(stream):break
        if pc==0x4000+sy['fread']:
            sp=c.system_stack_pointer.value;ptr=m.read_word(sp+2);count=m.read_word(sp+4)*m.read_word(sp+6)
            assert pos+count<=len(stream), 'Fran waiting for arguments not sent by UME'
            m.load(ptr,stream[pos:pos+count]);pos+=count;c.accu_d.set(count);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
        if pc==0x4000+sy['Present']:
            presented+=1;c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
        if pc==0x4000+sy['illegal']:raise AssertionError('Pipe command stream desynchronized')
        c.get_and_call_next_op()
    else:raise AssertionError('Fran dispatcher did not finish the command stream')
    assert presented==1
    assert bytes(m.read_byte(sy['FrDriveText']+i) for i in range(5))==bytes([74,32,ord('S'),0,0])
    print('PASS actual Fran dispatch: refresh, drive label, refresh and poll remain synchronized')


def startup_order_test():
    cfg=TestCfg(BaseCPUTestCase.UNITTEST_CFG_DICT);c=CPU(Memory(cfg),cfg);cfg.ROM_START=0x10000;m=c.memory
    sy={k:int(v,16) for k,v in re.findall(r'^(\w+) EQU \$([0-9A-F]+)',(ROOT/'.mods/s9_config.sym').read_text(),re.M)}
    blob=(ROOT/'.mods/CMDS/s9').read_bytes();m.load(0x2000,blob[:0xa000])
    def calls_to(target):
        return [i for i in range(sy['main'],sy['MainLoop']) if blob[i]==0x17 and i+3+int.from_bytes(blob[i+1:i+3],'big',signed=True)==sy[target]]
    init=calls_to('uinit');assert len(init)==1,init
    needle=bytes.fromhex('cc006d3406cc00473406');menu=blob.find(needle,sy['main'],sy['MainLoop'])
    assert menu>init[0], 'Drive enumeration runs before uinit installs C callback vectors'
    c.system_stack_pointer.set(0x1f00);c.index_y.set(0);c.user_stack_pointer.set(0x1234);c.program_counter.set(0x2000+init[0])
    stubs={0x2000+sy[n] for n in ['SetPathOption','setmouse','FreeAllBlocks']}
    for _ in range(10000):
        pc=c.program_counter.value
        if pc==0x2000+sy['soowee']:
            sp=c.system_stack_pointer.value
            assert m.read_word(sp+2)==ord('G') and m.read_word(sp+4)==ord('m')
            assert m.read_word(0x383)==0x2000+sy['charput']
            assert m.read_word(0x363)==0x2000+sy['soowee']
            assert c.index_y.value==0 and c.user_stack_pointer.value==0x1234
            print('PASS real startup order: uinit installs charput/overlay vectors before drive enumeration')
            return
        if pc in stubs:
            c.accu_d.set(0);c.program_counter.set(c.pull_word(c.system_stack_pointer));continue
        c.get_and_call_next_op()
    raise AssertionError('Startup did not reach drive enumeration')


def exit_cache_tests():
    r=run(command='r');assert r['config'] is None and not r['writes'] and r['cwd']=='/x1'
    r=run('/x1/scores',command='r',drive='/s0',resume=r['resume'])
    assert r['config'] is None and not r['writes'] and r['cwd']=='/s0/music'
    r=run('/s0/music',command='e',resume=r['resume'])
    doc=ET.fromstring(r['config']);assert doc.findtext('s0')=='/s0/music' and doc.findtext('x1')=='/x1/scores' and r['writes']
    old=b'<studio9><future value="42"/><x1>/x1/scores</x1></studio9>'
    r=run('/s0/music',old,'r','/x1');assert r['config']==old and not r['writes']
    r=run('/x1/scores',old,'e',resume=r['resume']);assert b'<future value="42"/>' in r['config']
    r=run('/s0/music',b'bad XML','e');assert r['config']==b'bad XML' and not r['writes']
    r=run(command='e',heap=0x1e00);assert not r['writes'] and r['config'] is None
    print('PASS configuration remains in RAM across drive changes; only exit writes; unknown XML preserved; malformed config/insufficient memory left intact')


def test():
    startup_order_test()
    protocol_tests()
    integration()
    menu_tests()
    rendering_tests()
    exit_cache_tests()
    r=run();doc=ET.fromstring(r['config']);assert doc.findtext('s0')=='/s0/music',r
    config=r['config']
    for cwd in ('/s1/song','/x0','/x1/scores','/x2','/x3/A&B/q"<x>'):
        r=run(cwd,config);config=r['config'];ET.fromstring(config)
    doc=ET.fromstring(config);assert len(doc)==6
    for drive,path in [('s0','/s0/music'),('s1','/s1/song'),('x0','/x0'),('x1','/x1/scores'),('x2','/x2'),('x3','/x3/A&B/q"<x>')]:
        r=run('/s0/music/sub',config,'r','/'+drive);assert r['cwd']==('/s0/music/sub' if drive=='s0' else path),r
    unknown='<studio9>\n<future value="42">keep me</future>\n<x1>/x1/scores</x1>\n</studio9>\n'
    r=run('/s0/music',unknown);assert b'<future value="42">keep me</future>' in r['config'];ET.fromstring(r['config'])
    # Replace longer with shorter and vice versa; no stale suffix after write.
    r=run('/s0',r['config']);assert ET.fromstring(r['config']).findtext('s0')=='/s0'
    for bad in (None,b'',b'junk',b'<studio9><x1>/x1/scores</x1>',b'<studio9>'+b' '*1100+b'</studio9>',b'<studio9><x1>/x1/missing</x1></studio9>',b'<studio9><x1>/s0/music</x1></studio9>',b'<studio9><x1>/x1/../s0</x1></studio9>',b'<studio9><x1>/x1/&bogus;</x1></studio9>'):
        r=run('/s0/music',bad,'r','/x1');assert r['cwd']=='/x1',r
    r=run('/s0/music',unknown,'r','/x1',bad_write=True);assert r['cwd']=='/x1/scores' and r['config']==unknown.encode(),r
    r=run('/s0/music',None,'r','/x1',bad_write=True);assert r['cwd']=='/x1' and r['config'] is None,r
    print('PASS Studio9: six independent drive paths, actual directory ancestry, XML entities, unknown-setting preservation, replacement/truncation, missing/malformed/oversize configs, invalid paths, read-only saves, root fallback, stack/register/path cleanup')
if __name__=='__main__':
    import sys
    if '--cache-only' in sys.argv:exit_cache_tests()
    else:test()

