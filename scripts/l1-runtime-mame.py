#!/usr/bin/env python3
"""Boot Level One and verify RBF results independently from the host."""
import importlib.util
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
ROOT = Path(__file__).resolve().parents[1]
def main():
    p=argparse.ArgumentParser()
    p.add_argument('--recipe',type=Path,required=True)
    p.add_argument('--machine',choices=('coco','coco2b'),required=True)
    p.add_argument('--mame',default='mame')
    p.add_argument('--rompath',default=os.environ.get('MAME_ROMPATH',''))
    a=p.parse_args();recipe=a.recipe.resolve();root=recipe/'.l1-test'/a.machine
    root.mkdir(parents=True,exist_ok=True)
    (root/'result.json').unlink(missing_ok=True)
    for name in ('cfg','nvram','snap'):(root/name).mkdir(exist_ok=True)
    disk=root/'guest.dsk';shutil.copyfile(recipe/'l1_coco_l1_mame_test.dsk',disk)
    lua='completion_marker="L1RUNTIMEPASS"\n'
    for key,name in [('snapshot_path','screen.png'),('console_path','console.log'),('errors_path','errors.log'),('writes_path','writes.log'),('reads_path','reads.log')]:
        lua+=key+'='+json.dumps(str(root/name))+'\n'
    lua+=(ROOT/'scripts/fat32-root-mame.lua').read_text()+(ROOT/'scripts/mame-disk-script.lua').read_text()
    (root/'run.lua').write_text(lua)
    command=[a.mame,a.machine,'-rompath',a.rompath,'-skip_gameinfo','-cfg_directory',str(root/'cfg'),
        '-nvram_directory',str(root/'nvram'),'-snapshot_directory',str(root/'snap'),'-ram','64K',
        '-ext','fdc,bios=v11','-ext:fdc:wd17xx:0','525dd','-flop1',str(disk),'-autoboot_delay','3',
        '-autoboot_script',str(root/'run.lua'),'-seconds_to_run','180','-sound','none','-video','none','-nothrottle']
    (root/'command.json').write_text(json.dumps(command,indent=2))
    with (root/'mame.log').open('w') as log:
        subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=360)
    console=(root/'console.log').read_bytes();(root/'console.txt').write_bytes(console.replace(b'\r',b'\n'))
    def read(name):
        target=root/Path(name).name;target.unlink(missing_ok=True)
        subprocess.run(['os9','copy',str(disk)+','+name,str(target)],check=True,capture_output=True)
        return target.read_bytes()
    assert read('l1done')==b'L1RUNTIMEPASS\r'
    assert read('probe/data')==bytes(i%256 for i in range(513))
    listing=subprocess.run(['os9','dir',str(disk)+','],check=True,capture_output=True)
    assert b'transient' not in listing.stdout.lower(), 'temporary file was not deleted'
    spec_disk=importlib.util.spec_from_file_location('disk_evidence',ROOT/'scripts/rbf-disk-evidence.py')
    disk_evidence=importlib.util.module_from_spec(spec_disk);spec_disk.loader.exec_module(disk_evidence)
    disk_evidence.check(recipe/('l2_coco3_module_group_mame_test.dsk' if 'module-group' in Path(__file__).name else 'l1_coco_l1_mame_test.dsk'),disk,root)
    (root/'result.json').write_text(json.dumps(dict(passed=True,machine=a.machine,cpu='6809',level=1,
        checks=['boot','create directory','513-byte write/read','sector-boundary seek','relative reopen','EOF','delete']),indent=2)+'\n')
    print('PASS: Level One boot and RBF runtime on',a.machine,'artifacts:',root)
if __name__=='__main__':main()
