#!/usr/bin/env python3
"""Run an assembled OS-9 command on MC6809 against an in-memory RBF device.

The command executes as real 6809 code; its system calls are answered by a
small model of one RBF device. Directories hold 32-byte entry slots with the
parent and self entries first, a deleted entry leaves its slot empty as it
does on disk, every open path keeps its own position, and an entry's ID is
the sector number of its file descriptor. The number of open paths is
limited, and any call on a named path can be made to fail.
Requires MC6809 and lwasm (see test-rename.py).
"""
import importlib.util
from pathlib import Path

spec=importlib.util.spec_from_file_location('rename_tests',Path(__file__).with_name('test-rename.py'))
t=importlib.util.module_from_spec(spec);spec.loader.exec_module(t)
assemble=t.assemble
DATA=0x4000
ENDS=b'\r ,;&!|<>#^()'


class Node:
    def __init__(self,fs,name,attr,parent,data=b''):
        self.name=name;self.attr=attr;self.parent=parent or self;self.owner=fs.user
        self.data=bytearray(data);self.slots=[];self.date=bytes([126,11,22,12,0]);self.created=bytes([126,11,22])
        fs.lsn+=1;self.lsn=fs.lsn;fs.nodes[self.lsn]=self
    @property
    def isdir(self):return bool(self.attr&0x80)
    def live(self):return [n for n in self.slots if n]
    def find(self,name):
        for n in self.live():
            if n.name.lower()==name.lower():return n
    def size(self):return 32*(len(self.slots)+2) if self.isdir else len(self.data)
    def fd(self):
        return bytes([self.attr])+self.owner.to_bytes(2,'big')+self.date+bytes([1])+self.size().to_bytes(4,'big')+self.created+bytes(256-16)
    def record(self,slot):
        if slot<2:name=('..' if slot==0 else '.');lsn=(self.parent if slot==0 else self).lsn
        else:
            n=self.slots[slot-2]
            if not n:return bytes(32)
            name=n.name;lsn=n.lsn
        return bytes(t.entry(name,lsn))


class FS:
    """One RBF device, /dd, which is also the current data directory."""
    def __init__(self,tree=None,user=0,readdir=True,devtype=None):
        self.user=user;self.readdir=readdir;self.devtype=devtype;self.lsn=10;self.nodes={}
        self.root=Node(self,'dd',0xbf,None)
        if tree:self.add(self.root,tree)
    def add(self,folder,tree):
        for name,v in tree.items():
            if isinstance(v,dict):self.add(self.mkdir(folder,name,0xbf),v)
            else:self.mkfile(folder,name,v)
    def link(self,folder,node):
        for i,n in enumerate(folder.slots):
            if n is None:folder.slots[i]=node;return node
        folder.slots.append(node);return node
    def mkdir(self,folder,name,attr):return self.link(folder,Node(self,name,attr|0x80,folder))
    def mkfile(self,folder,name,data,attr=0x1b):return self.link(folder,Node(self,name,attr&0x7f,folder,data))
    def unlink(self,node):
        assert node is not self.root,'deleted the device root'
        p=node.parent;p.slots[p.slots.index(node)]=None
    def node(self,path):
        n=self.root
        for part in path.split('/'):
            if part:n=n.find(part)
        return n
    def tree(self,folder=None):
        """The device as nested dictionaries of names and file contents."""
        folder=folder or self.root
        return {n.name:(self.tree(n) if n.isdir else bytes(n.data)) for n in folder.live()}
    def lookup(self,text):
        """Return (parent, last name, node or None) or an error number."""
        if text.startswith(b'/'):
            parts=text[1:].split(b'/')
            if parts[0].lower()!=b'dd':return 'E$MNF'
            folder=self.root;parts=parts[1:]
        else:folder=self.root;parts=text.split(b'/')
        if not parts:return (folder.parent,folder.name,folder)
        for i,part in enumerate(parts):
            if not part:return 'E$BPNam'
            if set(part)=={46}:
                node=folder
                for _ in range(len(part)-1):node=node.parent
            else:node=folder.find(part.decode())
            if i==len(parts)-1:return (folder,part.decode(),node)
            if not node:return 'E$PNNF'
            if not node.isdir:return 'E$BPNam'
            folder=node


class Path_:
    def __init__(self,node,mode,name):self.node=node;self.mode=mode;self.name=name;self.pos=0


class Peer:
    def __init__(self,binary,s,fs,faults=None,paths=16,steps=8000000):
        self.binary=binary;self.s=s;self.fs=fs;self.faults=dict(faults or {});self.limit=paths;self.steps=steps
    def fail(self,op,name):
        """A fault is an error number for every call, or a list of them for
        successive calls, where 0 lets the call through."""
        key=(op,name.decode() if isinstance(name,bytes) else name);f=self.faults.get(key)
        if isinstance(f,list):f=f.pop(0) if f else 0
        return f
    def run(self,args):
        s=self.s;fs=self.fs
        cfg=t.TestCfg({'trace':False,'verbosity':0});m=t.Memory(cfg);c=t.CPU(m,cfg)
        m.load(t.BASE,self.binary)
        top=DATA+s['size'];line=args.encode()+b'\r';m.load(top,line)
        c.user_stack_pointer.set(DATA);c.direct_page.set(DATA>>8);c.index_x.set(top);c.index_y.set(top+len(line))
        c.system_stack_pointer.set(top);c.program_counter.set(t.BASE+s['start'])
        self.out=bytearray();self.err=bytearray();self.paths={};self.most=0;self.orphans=[];self.calls=[]
        def get(a,n):return bytes(m.read_byte(a+i) for i in range(n))
        def put(a,b):m.load(a,bytes(b))
        def error(code):
            c.C=1;c.accu_b.set(s[code] if isinstance(code,str) else code)
        def pathname():
            x=c.index_x.value
            while m.read_byte(x)==32:x+=1
            start=x
            while m.read_byte(x) not in ENDS:x+=1
            return get(start,x-start),x
        def opened(node,mode,name):
            if len(self.paths)>=self.limit:return error('E$PthFul')
            n=min(set(range(3,64))-set(self.paths));self.paths[n]=Path_(node,mode,name)
            self.most=max(self.most,len(self.paths));c.accu_a.set(n)
        def path():
            p=self.paths.get(c.accu_a.value)
            if not p:error('E$BPNum')
            return p
        for _ in range(self.steps):
            pc=c.program_counter.value
            if get(pc,2)!=b'\x10\x3f':c.get_and_call_next_op();continue
            op=m.read_byte(pc+2);c.C=0;c.program_counter.set(pc+3)
            a=c.accu_a.value;b=c.accu_b.value
            if op==s['F$Exit']:
                return b
            elif op==s['F$PErr']:
                self.err.extend(b'ERROR #%03d\r'%b)
            elif op==s['F$ID']:c.accu_a.set(2);c.index_y.set(fs.user)
            elif op in (s['I$Open'],s['I$Create'],s['I$MakDir'],s['I$Delete'],s['I$DeletX']):
                name,end=pathname();kind={s['I$Open']:'open',s['I$Create']:'create',s['I$MakDir']:'makdir'}.get(op,'delete')
                self.calls.append((kind,name.decode()))
                fault=self.fail(kind,name)
                if fault:error(fault);continue
                found=fs.lookup(name)
                if isinstance(found,str):error(found);continue
                folder,last,node=found
                if kind=='open':
                    if not node:error('E$PNNF');continue
                    if bool(a&s['DIR.'])!=node.isdir:error('E$FNA');continue
                    opened(node,a,name)
                elif kind in ('create','makdir'):
                    if node:error('E$CEF');continue
                    if kind=='makdir':fs.mkdir(folder,last,b)
                    else:
                        node=fs.mkfile(folder,last,b'',b);opened(node,a,name)
                else:
                    if not node:error('E$PNNF');continue
                    if node.isdir and fs.devtype in (None,s['DT.RBF']):error('E$FNA');continue
                    assert all(p.node is not node for p in self.paths.values()),('deleted while open',name)
                    if node.slots and node.live():self.orphans.append(name.decode())
                    fs.unlink(node)
                if not c.C:c.index_x.set(end)
            elif op==s['I$Close']:
                if path():del self.paths[a]
            elif op in (s['I$Read'],s['I$ReadLn']):
                if a==0:error('E$EOF');continue
                p=path()
                if not p:continue
                fault=self.fail('read',p.name)
                if fault:error(fault);continue
                n=p.node;data=b''.join(n.record(i) for i in range(len(n.slots)+2)) if n.isdir else bytes(n.data)
                if p.pos>=len(data):error('E$EOF');continue
                chunk=data[p.pos:p.pos+c.index_y.value]
                if op==s['I$ReadLn'] and b'\r' in chunk:chunk=chunk[:chunk.index(b'\r')+1]
                put(c.index_x.value,chunk);p.pos+=len(chunk);c.index_y.set(len(chunk))
            elif op in (s['I$Write'],s['I$WritLn']):
                data=get(c.index_x.value,c.index_y.value)
                if op==s['I$WritLn'] and b'\r' in data:data=data[:data.index(b'\r')+1]
                if a in (1,2):(self.out if a==1 else self.err).extend(data);continue
                p=path()
                if not p:continue
                fault=self.fail('write',p.name)
                if fault:error(fault);continue
                if not p.mode&s['WRITE.']:error('E$BMode');continue
                d=p.node.data
                if len(d)<p.pos:d.extend(bytes(p.pos-len(d)))
                d[p.pos:p.pos+len(data)]=data;p.pos+=len(data)
            elif op==s['I$Seek']:
                p=path()
                if p:p.pos=(c.index_x.value<<16)|c.user_stack_pointer.value
            elif op==s['I$GetStt']:
                p=None if a<3 else path()
                if a>=3 and not p:continue
                if b==s['SS.Opt']:
                    opt=bytearray(32);opt[0]=fs.devtype if fs.devtype is not None else s['DT.RBF']
                    if p:opt[s['PD.ATT']-s['PD.OPT']]=p.node.attr
                    put(c.index_x.value,opt)
                elif b==s['SS.ReadDir']:
                    if not fs.readdir:error('E$UnkSvc');continue
                    assert c.index_y.value in (32,45) and p.node.isdir,('SS.ReadDir',c.index_y.value)
                    fault=self.fail('readdir',p.name)
                    if fault:error(fault);continue
                    slot=max(p.pos//32,2)
                    while slot-2<len(p.node.slots) and not p.node.slots[slot-2]:slot+=1
                    if slot-2>=len(p.node.slots):error('E$EOF');continue
                    n=p.node.slots[slot-2];p.pos=(slot+1)*32
                    put(c.index_x.value,(p.node.record(slot)+n.fd()[:13])[:c.index_y.value])
                elif b==s['SS.FDInf']:
                    y=c.index_y.value;n=fs.nodes[((y>>8)<<16)|c.user_stack_pointer.value]
                    put(c.index_x.value,n.fd()[:y&255])
                elif b==s['SS.FD']:
                    y=c.index_y.value;put(c.index_x.value,p.node.fd()[:256 if y>>8 else y])
                elif b==s['SS.Size']:
                    size=p.node.size();c.index_x.set(size>>16);c.user_stack_pointer.set(size&0xffff)
                elif b==s['SS.EOF']:
                    if p.pos>=p.node.size():error('E$EOF')
                    else:c.accu_b.set(0)
                else:raise AssertionError(('GetStt',b))
            elif op==s['I$SetStt']:
                p=path()
                if not p:continue
                fault=self.fail('setstt',p.name)
                if fault:error(fault);continue
                if b==s['SS.Size']:
                    size=(c.index_x.value<<16)|c.user_stack_pointer.value;d=p.node.data
                    del d[size:];d.extend(bytes(size-len(d)))
                elif b==s['SS.FD']:
                    fd=get(c.index_x.value,16);n=p.node
                    if p.mode&s['WRITE.']:
                        if fs.user==0:n.owner=int.from_bytes(fd[1:3],'big')
                        n.date=fd[3:8];n.created=fd[13:16]
                    n.attr=fd[0]
                else:raise AssertionError(('SetStt',b))
            else:raise AssertionError(('unexpected system call',hex(op)))
        raise AssertionError('the command did not exit')
