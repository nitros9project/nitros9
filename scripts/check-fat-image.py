#!/usr/bin/env python3
"""Run the platform FAT checker read-only and retain its complete report."""
import hashlib
import shutil
import subprocess
from pathlib import Path


def default_checker():
    return shutil.which('fsck_msdos') or shutil.which('fsck.fat') or '/sbin/fsck_msdos'


def check(image,log,checker=None):
    def digest():
        with Path(image).open('rb') as stream:return hashlib.file_digest(stream,'sha256').digest()
    before=digest()
    command=[checker or default_checker(),'-n',str(image)]
    result=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    Path(log).write_bytes(result.stdout)
    if digest()!=before:raise RuntimeError(f'FAT checker modified the image: {image}')
    if result.returncode:
        raise RuntimeError(f'FAT integrity check failed ({result.returncode}); see {log}')
    print(f'PASS: read-only FAT integrity check; report: {log}',flush=True)
