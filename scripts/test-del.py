#!/usr/bin/env python3
"""Execute del, with and without -r, on MC6809 against an in-memory RBF device."""
import importlib.util
import tempfile
from pathlib import Path

spec=importlib.util.spec_from_file_location('command_peer',Path(__file__).with_name('command-peer.py'))
p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)


def tree():
    return {'tree':{'a':b'one','sub':{'b':b'x'*300,'deep':{'c':b''},'z':b'last'},'e':b'end'},'keep':b'kept'}


def tests(binary,s,level,readdir):
    def run(args,files=None,user=0,devtype=None,**kw):
        fs=p.FS(tree() if files is None else files,user=user,readdir=readdir,devtype=devtype)
        peer=p.Peer(binary,s,fs,**kw);status=peer.run(args)
        assert not peer.orphans and not peer.paths,(args,peer.orphans,peer.paths)
        return status,fs,peer
    # a whole tree goes, with one path open at a time
    status,fs,peer=run('-r tree')
    assert status==0 and fs.tree()=={'keep':b'kept'} and peer.most==1 and not peer.err,(status,fs.tree(),peer.err)
    # with only one free path
    status,fs,peer=run('-r tree',paths=1)
    assert status==0 and fs.tree()=={'keep':b'kept'}
    # options after the names, several names, a file, trailing separators
    status,fs,peer=run('tree// keep -r')
    assert status==0 and fs.tree()=={},fs.tree()
    # deep trees: the stack, not the open paths, bounds the depth
    deep=leaf={}
    for i in range(40):leaf['d']={};leaf=leaf['d']
    leaf['f']=b'bottom'
    status,fs,peer=run('-r d',files={'d':deep['d']})
    assert status==0 and fs.tree()=={} and peer.most==1
    # without -r, files are deleted and a directory is refused as before
    status,fs,peer=run('keep tree/a')
    assert status==0 and 'keep' not in fs.tree() and 'a' not in fs.tree()['tree']
    status,fs,peer=run('tree keep')
    assert status==s['E$FNA'] and fs.tree()==tree()
    # a file that can't be deleted keeps its directories, the rest goes
    status,fs,peer=run('-r tree keep',faults={('delete','tree/sub/b'):s['E$Share']})
    assert status==s['E$Share'] and fs.tree()=={'tree':{'sub':{'b':b'x'*300}}},fs.tree()
    assert peer.err==b'tree/sub/b: ERROR #%03d\r'%s['E$Share'],peer.err
    # names that would delete a directory above them are refused
    for name in ('.','..','...','tree/.','tree/sub/..','/dd','/dd/','/'):
        status,fs,peer=run('-r '+name)
        assert status==s['E$BPNam'] and fs.tree()==tree(),(name,status,fs.tree())
        assert peer.err.endswith(b': ERROR #%03d\r'%s['E$BPNam']),(name,peer.err)
    # a path that doesn't exist is reported and the next name is still deleted
    status,fs,peer=run('-r none keep')
    assert status==s['E$PNNF'] and fs.tree()=={'tree':tree()['tree']}
    assert peer.err==b'none: ERROR #%03d\r'%s['E$PNNF']
    # only the owner or the superuser may clear the directory attribute
    fs=p.FS(tree(),user=5,readdir=readdir);fs.node('tree/sub').owner=7
    peer=p.Peer(binary,s,fs);status=peer.run('-r tree')
    assert status==s['E$FNA'] and fs.tree()=={'tree':{'sub':{}},'keep':b'kept'},fs.tree()
    assert peer.err==b'tree/sub: ERROR #%03d\r'%s['E$FNA'] and fs.node('tree/sub').isdir,peer.err
    fs=p.FS(tree(),user=5,readdir=readdir);fs.node('tree/sub').owner=7;fs.user=0
    peer=p.Peer(binary,s,fs);status=peer.run('-r tree')
    assert status==0 and fs.tree()=={'keep':b'kept'}
    # a directory whose delete fails gets its directory attribute back
    status,fs,peer=run('-r tree',faults={('delete','tree/sub'):s['E$Share']})
    assert status==s['E$Share'] and fs.tree()=={'tree':{'sub':{}},'keep':b'kept'},fs.tree()
    assert fs.node('tree/sub').isdir and fs.node('tree/sub').attr==0xbf
    # an error reading a directory gives up on it, but not on the rest
    status,fs,peer=run('-r tree',faults={('readdir' if readdir else 'read','tree/sub'):s['E$Read']})
    assert status==s['E$Read'] and fs.tree()=={'tree':{'sub':tree()['tree']['sub']},'keep':b'kept'},fs.tree()
    assert peer.err==b'tree/sub: ERROR #%03d\r'%s['E$Read']
    # an error reopening a directory after a subdirectory gives up on it
    status,fs,peer=run('-r tree',faults={('open','tree'):[0,s['E$PthFul']]})
    assert status==s['E$PthFul'] and fs.tree()=={'tree':{'e':b'end'},'keep':b'kept'},fs.tree()
    assert peer.err==b'tree: ERROR #%03d\r'%s['E$PthFul'],peer.err
    # a pathlist that grows too long is reported and skipped
    long='n'*28;deep=leaf={}
    for i in range(9):leaf[long]={};leaf=leaf[long]
    leaf['f']=b'x'
    status,fs,peer=run('-r '+long,files={long:deep[long]})
    assert status==s['E$BPNam'] and fs.node('/'.join([long]*9)) is not None
    assert len(fs.tree())==1 and b'ERROR #%03d'%s['E$BPNam'] in peer.err
    # other file managers delete a directory without the attribute change
    status,fs,peer=run('-r tree',devtype=s['DT.SCF'])
    assert status==0 and fs.tree()=={'keep':b'kept'}
    kind='SS.ReadDir' if readdir else 'raw directory records'
    print(f'Level {level}: del with {kind}: -r trees, depth, one free path, failures kept with their directories, dot names and device roots refused, owner check, attribute restored, read and reopen errors, long pathlists, plain del PASS')


if __name__=='__main__':
    with tempfile.TemporaryDirectory() as folder:
        for level in (1,2):
            binary,symbols=p.assemble(Path(folder),level,'level1/cmds/del.asm')
            for readdir in (True,False):tests(binary,symbols,level,readdir)
