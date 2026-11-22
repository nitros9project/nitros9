#!/usr/bin/env python3
"""Execute copy, with and without -d, on MC6809 against an in-memory RBF device."""
import importlib.util
import tempfile
from pathlib import Path

spec=importlib.util.spec_from_file_location('command_peer',Path(__file__).with_name('command-peer.py'))
p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)
BIG=bytes(range(256))*12


def source():
    return {'src':{'a':b'one','big':BIG,'sub':{'b':b'two','deep':{'c':b''}},'z':b'last'}}


def copying(*pairs):return b''.join(b'copying %s to %s\r'%(a.encode(),b.encode()) for a,b in pairs)


def cant(name):return b"copy: can't open %s - "%name.encode()


def tests(binary,s,level,readdir):
    def run(args,files=None,closed=True,**kw):
        fs=p.FS(source() if files is None else files,readdir=readdir)
        peer=p.Peer(binary,s,fs,**kw);status=peer.run(args)
        assert not closed or not peer.paths,(args,peer.paths)
        return status,fs,peer
    def err(code):return b'ERROR #%03d\r'%s[code]
    files=[('a','a'),('big','big'),('sub/b','sub/b'),('sub/deep/c','sub/deep/c'),('z','z')]
    # a tree is copied whole, under the destination's name
    status,fs,peer=run('-d src dst')
    assert status==0 and fs.tree()['dst']==source()['src'] and not peer.err,(status,fs.tree(),peer.err)
    assert peer.out==copying(*(('src/'+a,'dst/'+b) for a,b in files)),peer.out
    assert peer.most==3,peer.most
    # attributes, owner and dates come with each file and directory
    fs=p.FS(source(),readdir=readdir)
    a=fs.node('src/a');a.attr=0x3f;a.owner=9;a.date=bytes([99,1,2,3,4]);fs.node('src/sub').attr=0xbb;fs.node('src').attr=0xa7
    peer=p.Peer(binary,s,fs);status=peer.run('-d -p src dst')
    b=fs.node('dst/a')
    assert status==0 and not peer.out and (b.attr,b.owner,b.date)==(0x3f,9,bytes([99,1,2,3,4])),(b.attr,b.owner,b.date)
    assert fs.node('dst/sub').attr==0xbb and fs.node('dst').attr==0xa7
    # with only three free paths, and through a deep tree
    status,fs,peer=run('-d -p src dst',paths=3)
    assert status==0 and fs.tree()['dst']==source()['src']
    deep=leaf={}
    for i in range(60):leaf['d']={};leaf=leaf['d']
    leaf['f']=b'bottom'
    status,fs,peer=run('-d -p d e',files={'d':deep['d']})
    assert status==0 and fs.tree()['e']==deep['d']
    # a tree too deep for the stack is refused, not overrun
    deep=leaf={}
    for i in range(100):leaf['d']={};leaf=leaf['d']
    status,fs,peer=run('-d -p d e',files={'d':deep['d']})
    assert status==s['E$StkOvf'] and peer.err==err('E$StkOvf')
    # an existing destination directory is merged into
    files_=source();files_['dst']={'old':b'kept','sub':{'x':b'y'}}
    status,fs,peer=run('-d -p src dst',files=files_)
    want=source()['src'];want['old']=b'kept';want['sub']['x']=b'y'
    assert status==0 and fs.tree()['dst']==want,fs.tree()['dst']
    # an existing destination file fails once
    files_=source();files_['dst']=b'file'
    status,fs,peer=run('-d src dst',files=files_)
    assert status==s['E$FNA'] and peer.out==cant('dst') and peer.err==err('E$FNA') and fs.tree()['dst']==b'file'
    # a file already in the destination is reported, the rest is copied
    files_=source();files_['dst']={'sub':{'b':b'old'}}
    status,fs,peer=run('-d -p src dst',files=files_)
    want=source()['src'];want['sub']['b']=b'old'
    assert status==s['E$CEF'] and fs.tree()['dst']==want and peer.out==cant('dst/sub/b'),(fs.tree(),peer.out)
    # -r replaces it
    files_=source();files_['dst']={'sub':{'b':b'old'}}
    status,fs,peer=run('-d -p -r src dst',files=files_)
    assert status==0 and fs.tree()['dst']==source()['src']
    # -a stops at the first failure
    files_=source();files_['dst']={'sub':{'b':b'old'}}
    status,fs,peer=run('-d -p -a src dst',files=files_,closed=False)
    assert status==s['E$CEF'] and 'z' not in fs.tree()['dst'] and peer.out==cant('dst/sub/b')
    # errors in a directory are reported against it, and copying carries on
    status,fs,peer=run('-d -p src dst',faults={('readdir' if readdir else 'read','src/sub'):s['E$Read']})
    want=source()['src'];want['sub']={}
    assert status==s['E$Read'] and fs.tree()['dst']==want and peer.out==cant('src/sub'),(fs.tree()['dst'],peer.out)
    status,fs,peer=run('-d -p src dst',faults={('makdir','dst/sub'):s['E$Full']})
    want=source()['src'];del want['sub']
    assert status==s['E$Full'] and fs.tree()['dst']==want and peer.out==cant('dst/sub')
    status,fs,peer=run('-d -p src dst',faults={('open','src/sub'):[s['E$PthFul']]})
    want=source()['src'];want['sub']={}
    assert status==s['E$PthFul'] and fs.tree()['dst']==want and peer.out==cant('src/sub'),(fs.tree()['dst'],peer.out)
    status,fs,peer=run('-d -p src dst',faults={('open','src'):[0,s['E$PthFul']]})
    assert status==s['E$PthFul'] and set(fs.tree()['dst'])=={'a','big','sub'} and peer.out==cant('src'),(fs.tree()['dst'],peer.out)
    # a pathlist that grows too long is reported against the directory
    # holding the entry, whichever of the two paths is the longer
    long='n'*28;pre='p'*28
    def chain(n):
        deep=leaf={}
        for i in range(n):leaf[long]={};leaf=leaf[long]
        leaf['f']=b'x';return deep[long]
    def depth(node):
        d=0
        while node and [n for n in node.live() if n.isdir]:node=[n for n in node.live() if n.isdir][0];d+=1
        return d
    status,fs,peer=run(f'-d -p {pre}/{long} c',files={pre:{long:chain(9)}})
    assert status==s['E$BPNam'] and depth(fs.node('c'))==6 and peer.err==err('E$BPNam')
    assert peer.out==cant('/'.join([pre]+[long]*7)),peer.out
    status,fs,peer=run(f'-d -p {long} {pre}/{pre}/c',files={long:chain(9),pre:{pre:{}}})
    assert status==s['E$BPNam'] and depth(fs.node(pre+'/'+pre+'/c'))==6 and peer.out==cant('/'.join([long]*7)),(depth(fs.node(pre+'/'+pre+'/c')),peer.out)
    # trailing separators are dropped
    status,fs,peer=run('-d -p src// dst/')
    assert status==0 and fs.tree()['dst']==source()['src']
    # -w puts each source in the directory under its last name
    files_=source();files_['out']={};files_['one']=b'1'
    status,fs,peer=run('-d -w=out src one',files=files_)
    assert status==0 and fs.tree()['out']=={'src':source()['src'],'one':b'1'}
    assert peer.out==copying(*(('src/'+a,'out/src/'+b) for a,b in files),('one','out/one')),peer.out
    files_=source();files_['out']={}
    status,fs,peer=run('-d -w=out src/sub',files=files_)
    assert status==0 and fs.tree()['out']=={'sub':source()['src']['sub']}
    # with -w, a name of only dots is refused and the next is copied
    for name in ('.','..','src/..','src/.'):
        files_=source();files_['out']={};files_['one']=b'1'
        status,fs,peer=run('-d -p -w=out '+name+' one',files=files_)
        assert status==s['E$BPNam'] and fs.tree()['out']=={'one':b'1'} and peer.out==cant(name),(name,status,peer.out)
    # a missing source is reported
    status,fs,peer=run('-d none dst')
    assert status==s['E$PNNF'] and peer.out==cant('none') and 'dst' not in fs.tree()
    # a file is copied as before
    status,fs,peer=run('-d src/big b')
    assert status==0 and fs.tree()['b']==BIG and peer.out==copying(('src/big','b'))
    status,fs,peer=run('src/big b')
    assert status==0 and fs.tree()['b']==BIG and not peer.out
    # names that don't fit the form are refused
    status,fs,peer=run('-d src a b')
    assert status==0 and peer.out==b'copy: must specify output directory if more than 2 files\r' and set(fs.tree())=={'src'}
    status,fs,peer=run('-d src')
    assert status==0 and not peer.out and set(fs.tree())=={'src'}
    status,fs,peer=run('-d -s src dst')
    assert status==0 and not peer.out and set(fs.tree())=={'src'}
    kind='SS.ReadDir' if readdir else 'raw directory records'
    print(f'Level {level}: copy with {kind}: -d trees, attributes and owners, three free paths, depth and stack limit, merging, existing files with -r and -a, directory errors, long pathlists, -w, dot names, plain copy, usage PASS')


if __name__=='__main__':
    with tempfile.TemporaryDirectory() as folder:
        for level in (1,2):
            binary,symbols=p.assemble(Path(folder),level,'level1/cmds/copy.asm')
            for readdir in (True,False):tests(binary,symbols,level,readdir)
