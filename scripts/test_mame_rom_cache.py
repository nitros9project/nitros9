"""ROM cache hits and test consumers must not contact the download host."""
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

class RomCacheTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        self.script=self.root/'setup-mame-roms.sh'
        shutil.copyfile(Path(__file__).with_name('setup-mame-roms.sh'),self.script)
        self.payload=self.root/'payload';self.payload.write_bytes(b'verified fixture')
        checksum=hashlib.sha256(self.payload.read_bytes()).hexdigest()
        self.names=['first.zip','second.zip']
        (self.root/'mame-roms.sha256').write_text(''.join(f'{checksum}  {n}\n' for n in self.names))
        self.roms=self.root/'roms';self.roms.mkdir()
        self.calls=self.root/'calls'
        self.bin=self.root/'bin';self.bin.mkdir()
        curl=self.bin/'curl'
        curl.write_text('#!/usr/bin/env bash\nset -eu\necho call >> "$CALLS"\nwhile [ "$1" != -o ]; do shift; done\ncp "$PAYLOAD" "$2"\nif [ "${FAIL_DOWNLOAD:-0}" = 1 ]; then exit 22; fi\n')
        curl.chmod(0o755)
        self.env=dict(os.environ,PATH=str(self.bin)+os.pathsep+os.environ['PATH'],CALLS=str(self.calls),PAYLOAD=str(self.payload))
    def run_setup(self,*args,success=True):
        result=subprocess.run(['bash',str(self.script),str(self.roms),*args],env=self.env,capture_output=True)
        self.assertEqual(result.returncode==0,success,result.stderr.decode())
    def test_cold_cache_downloads_once_then_reuses_verified_files(self):
        self.run_setup();self.assertEqual(len(self.calls.read_text().splitlines()),2)
        self.run_setup();self.assertEqual(len(self.calls.read_text().splitlines()),2)
    def test_consumer_verifies_without_downloading(self):
        for name in self.names:shutil.copyfile(self.payload,self.roms/name)
        self.run_setup('--verify-only');self.assertFalse(self.calls.exists())
        (self.roms/self.names[0]).write_bytes(b'corrupt')
        self.run_setup('--verify-only',success=False);self.assertFalse(self.calls.exists())
    def test_failed_download_does_not_install_partial_archive(self):
        self.env['FAIL_DOWNLOAD']='1';self.run_setup(success=False)
        self.assertEqual(list(self.roms.iterdir()),[])
    def test_producer_repairs_only_corrupt_archive(self):
        for name in self.names:shutil.copyfile(self.payload,self.roms/name)
        (self.roms/self.names[0]).write_bytes(b'corrupt')
        self.run_setup();self.assertEqual(len(self.calls.read_text().splitlines()),1)

if __name__=='__main__':unittest.main()
