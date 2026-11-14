#!/usr/bin/env python3
"""Migrate an OS-9 game disk atomically, preserving assets and saved games."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


class Disk:
    def __init__(self, path):
        self.path = Path(path)

    def read(self, offset, size):
        with self.path.open('rb') as image:
            image.seek(offset)
            data = image.read(size)
        if len(data) != size:
            raise ValueError('Truncated OS-9 image')
        return data

    def descriptor(self, lsn):
        return self.read(lsn * 256, 256)

    def contents(self, lsn):
        fd = self.descriptor(lsn)
        size = int.from_bytes(fd[9:13], 'big')
        result = bytearray()
        for index in range(16, 256, 5):
            start = int.from_bytes(fd[index:index+3], 'big')
            count = int.from_bytes(fd[index+3:index+5], 'big')
            if not count:
                break
            result.extend(self.read(start * 256, count * 256))
        if len(result) < size:
            raise ValueError('Incomplete OS-9 file segment list')
        return bytes(result[:size])

    def entries(self, lsn):
        data = self.contents(lsn)
        entries = []
        for offset in range(0, len(data), 32):
            entry = data[offset:offset+32]
            if not entry or not entry[0]:
                continue
            name = ''
            for byte in entry[:29]:
                name += chr(byte & 127)
                if byte & 128:
                    break
            if name not in ('.', '..'):
                entries.append((name, int.from_bytes(entry[29:32], 'big')))
        return entries

    def find(self, path):
        lsn = int.from_bytes(self.read(8, 3), 'big')
        for part in Path(path).parts:
            if part in ('/', '.'):
                continue
            lsn = next((fd for name, fd in self.entries(lsn)
                        if name.casefold() == part.casefold()), None)
            if lsn is None:
                return None
        return lsn

    def is_directory(self, lsn):
        return bool(self.descriptor(lsn)[0] & 0x80)

    def allocation(self):
        header = self.read(0, 256)
        total = int.from_bytes(header[:3], 'big')
        cluster = int.from_bytes(header[6:8], 'big')
        map_size = int.from_bytes(header[4:6], 'big')
        if not cluster or total > map_size * 8 * cluster:
            raise ValueError('Unsupported OS-9 allocation geometry')
        bitmap = self.read(256, map_size)
        used = {index for index in range((total + cluster - 1) // cluster)
                if bitmap[index // 8] & (0x80 >> (index % 8))}
        return cluster, bitmap, used

    def referenced(self, cluster):
        visited, used = set(), set()

        def visit(lsn):
            if lsn in visited:
                return
            visited.add(lsn)
            used.add(lsn // cluster)
            fd = self.descriptor(lsn)
            for index in range(16, 256, 5):
                start = int.from_bytes(fd[index:index+3], 'big')
                count = int.from_bytes(fd[index+3:index+5], 'big')
                if not count:
                    break
                used.update(range(start // cluster, (start + count - 1) // cluster + 1))
            if self.is_directory(lsn):
                for _, child in self.entries(lsn):
                    visit(child)

        visit(int.from_bytes(self.read(8, 3), 'big'))
        return used

    def reclaim_moved_allocations(self, original_orphans):
        # ToolShed versions differ in whether recursive deletion releases all
        # old allocations. Reclaim only clusters orphaned by this transaction;
        # pre-existing reservations (including the kernel track) stay allocated.
        cluster, bitmap, allocated = self.allocation()
        referenced = self.referenced(cluster)
        if not referenced <= allocated:
            raise ValueError('A live file references a free cluster; source disk unchanged')
        released = allocated - referenced - original_orphans
        bitmap = bytearray(bitmap)
        for index in released:
            bitmap[index // 8] &= ~(0x80 >> (index % 8))
        with self.path.open('r+b') as image:
            image.seek(256)
            image.write(bitmap)

    def command(self, *args):
        subprocess.run(['os9', *map(str, args)], check=True,
                       stdout=subprocess.DEVNULL)

    def uppercase(self, path='.'):
        for name, lsn in self.entries(self.find(path)):
            if not self.is_directory(lsn):
                continue
            child = str(Path(path) / name)
            if name != name.upper():
                self.command('rename', f'{self.path},{child}', name.upper())
            child = str(Path(path) / name.upper())
            if self.find(child) != lsn:
                raise ValueError(f'Directory rename failed: {child}')
            self.uppercase(child)

    def merge(self, source, destination, baseline):
        src = self.find(source)
        if src is None:
            return
        if not self.is_directory(src):
            raise ValueError(f'Expected a directory: {source}')
        dest = self.find(destination)
        if dest is None:
            parent = str(Path(destination).parent)
            if self.find(parent) is None:
                raise ValueError(f'Missing destination parent: {parent}')
            self.command('makdir', f'{self.path},{destination}')
            dest = self.find(destination)
        if dest is None or not self.is_directory(dest):
            raise ValueError(f'Could not create directory: {destination}')
        for name, lsn in self.entries(src):
            target = str(Path(destination) / name)
            old = str(Path(source) / name)
            existing = self.find(target)
            if self.is_directory(lsn):
                self.merge(old, target, {})
                continue
            payload = self.contents(lsn)
            if existing is not None:
                if self.is_directory(existing):
                    raise ValueError(f'File/directory collision: {target}')
                current = self.contents(existing)
                if current == payload:
                    continue
                original = baseline.get(name.casefold())
                if original is None or not Path(original).is_file() or Path(original).read_bytes() != current:
                    raise ValueError(f'Conflicting saved data; source disk unchanged: {old} and {target}')
            metadata = self.descriptor(lsn)
            with tempfile.TemporaryDirectory() as folder:
                host = Path(folder) / 'payload'
                host.write_bytes(payload)
                self.command('copy', '-r', host, f'{self.path},{target}')
            copied = self.find(target)
            if copied is None or self.contents(copied) != payload:
                raise ValueError(f'File migration failed: {target}')
            # Preserve permissions, owner, modification time and creation date.
            # Link count, size and allocation belong to the new descriptor.
            with self.path.open('r+b') as image:
                image.seek(copied * 256)
                image.write(metadata[:8])
                image.seek(copied * 256 + 13)
                image.write(metadata[13:16])
        # Every source file is now verified at its destination. ToolShed frees
        # the old tree's allocations; the transaction still operates on a copy.
        self.command('deldir', '-q', f'{self.path},{source}')
        if self.find(source) is not None:
            raise ValueError(f'Old directory was not removed: {source}')

    def install(self, source, destination):
        source = Path(source)
        if self.find(str(Path(destination).parent)) is None:
            raise ValueError(f'Missing game command directory: {destination}')
        self.command('copy', '-r', source, f'{self.path},{destination}')
        installed = self.find(destination)
        if installed is None or self.contents(installed) != source.read_bytes():
            raise ValueError(f'Program update failed: {destination}')
        self.command('attr', '-e', '-pe', f'{self.path},{destination}')

    def check_uppercase(self, path='.'):
        for name, lsn in self.entries(self.find(path)):
            if self.is_directory(lsn):
                if name != name.upper():
                    raise ValueError(f'Lowercase directory remains: {path}/{name}')
                self.check_uppercase(str(Path(path) / name))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--disk', type=Path, required=True)
    parser.add_argument('--install', default='[]', help='JSON program updates')
    parser.add_argument('--moves', required=True, help='JSON directory moves and optional baseline assets')
    args = parser.parse_args()
    moves = json.loads(args.moves)
    with tempfile.TemporaryDirectory(dir=args.disk.resolve().parent, prefix='.layout-') as folder:
        temporary = Path(folder) / args.disk.name
        shutil.copy2(args.disk, temporary)
        disk = Disk(temporary)
        cluster, _, allocated = disk.allocation()
        original_orphans = allocated - disk.referenced(cluster)
        disk.uppercase()
        for move in moves:
            source, dest = move['source'].upper(), move['destination'].upper()
            if source != dest:
                disk.merge(source, dest, move.get('baseline', {}))
        for program in json.loads(args.install):
            disk.install(program['source'], program['destination'])
        disk.check_uppercase()
        disk.reclaim_moved_allocations(original_orphans)
        os.replace(temporary, args.disk)
    print('Migrated game directories; uppercase names and saved data verified')


if __name__ == '__main__':
    main()
