#!/usr/bin/env python3
"""Run the real RBF/deldir commands in MAME and check the resulting floppy."""
import argparse
import json
import importlib.util
import os
import re
from pathlib import Path
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('disk_script',ROOT/'scripts/mame-script.py')
disk_script=importlib.util.module_from_spec(spec);spec.loader.exec_module(disk_script)

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--recipe',type=Path,required=True)
    p.add_argument('--mame',default='mame')
    p.add_argument('--rompath',default=os.environ.get('MAME_ROMPATH',''))
    p.add_argument('--visible',action='store_true')
    a=p.parse_args();recipe=a.recipe.resolve();root=recipe/'.rbf-test';root.mkdir(exist_ok=True)
    for name in ('cfg','nvram','snap'):(root/name).mkdir(exist_ok=True)
    disk=root/'guest.dsk';shutil.copyfile(recipe/'l2_coco3_rbf_mame_test.dsk',disk)
    commands=(recipe/'commands').read_text().splitlines()
    disk_script.answers(root)
    (root/'TEST.CMD').write_bytes(disk_script.script(commands))
    (root/'STARTUP').write_bytes((recipe/'startup').read_text().replace('\n','\r').encode()+b'shell /dd/test.cmd\r')
    for name in ('TEST.CMD','CANCEL.IN','DELETE.IN','STARTUP'):
        subprocess.run(['os9','copy','-r',str(root/name),str(disk)+','+name.lower()],check=True,capture_output=True)
    # Compare allocation checks with the fully installed, unexecuted test disk.
    pristine=root/'pristine.dsk';shutil.copyfile(disk,pristine)
    lua='completion_marker="RBFREGRESSIONPASS"\n'
    for key,name in [('snapshot_path','screen.png'),('console_path','console.log'),('errors_path','errors.log'),('writes_path','writes.log'),('reads_path','reads.log')]:
        lua+=key+'='+json.dumps(str(root/name))+'\n'
    lua+=(ROOT/'scripts/fat32-root-mame.lua').read_text()
    lua+=(ROOT/'scripts/mame-disk-script.lua').read_text()
    (root/'run.lua').write_text(lua)
    cmd=[a.mame,'coco3','-rompath',a.rompath,'-skip_gameinfo','-cfg_directory',str(root/'cfg'),'-nvram_directory',str(root/'nvram'),'-snapshot_directory',str(root/'snap'),'-ram','512K','-ext','fdc,bios=v11','-ext:fdc:wd17xx:0','525dd','-flop1',str(disk),'-autoboot_delay','3','-autoboot_script',str(root/'run.lua'),'-seconds_to_run','900','-sound','none','-nothrottle']
    cmd+=['-window'] if a.visible else ['-video','none']
    with (root/'mame.log').open('w') as log:subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=960)
    console=(root/'console.log').read_bytes();(root/'console.txt').write_bytes(console.replace(b'\r',b'\n'))
    errors=[int(x) for x in (root/'errors.log').read_text().splitlines()]
    assert errors==[1],errors
    assert b'RBFSTARTUPDONE' in console and b'RBFREGRESSIONPASS' in console
    assert console.count(b'List directory, delete directory, or quit ?')==6
    def listing(path):
        r=subprocess.run(['os9','dir',str(disk)+','+path],capture_output=True,check=True)
        return r.stdout
    check=subprocess.run(['os9','dcheck',str(disk)],capture_output=True,check=True)
    (root/'dcheck.log').write_bytes(check.stdout+check.stderr)
    lines=check.stdout.splitlines()
    assert b'0 bad file decriptor sector' in lines
    assert b'0 clusters in file structure but not in allocation map' in lines
    assert b'0 previously allocated cluster found' in lines
    baseline=subprocess.run(['os9','dcheck',str(pristine)],capture_output=True,check=True)
    pattern=rb'^Logical sector (\d+) .* in allocation map but not in file structure$'
    assert set(re.findall(pattern,check.stdout,re.M))==set(re.findall(pattern,baseline.stdout,re.M)), 'changed orphan allocations'
    directory=listing('');assert b'tree' not in directory.lower() and b'single' not in directory.lower(),directory
    dest=root/'keep.txt';dest.unlink(missing_ok=True)
    subprocess.run(['os9','copy',str(disk)+',keep.txt',str(dest)],check=True,capture_output=True)
    assert dest.read_bytes()==b'UNRELATED\r'
    assert all(x in console.split(b'RBFCANCELDONE',1)[1] for x in (b'ROOTFILE\r',b'AFILE\r',b'BFILE\r'))
    result={'passed':True,'disk_scripts':True,'errors':errors,'recursive_directory_prompts':6,'unrelated_file_preserved':True,'rbf_integrity_checked':True,'disk':str(disk)}
    (root/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print('PASS: RBF recursive deldir, nested cancellation, regular-file deletion, unrelated file preservation; artifacts:',root)

if __name__=='__main__':main()
