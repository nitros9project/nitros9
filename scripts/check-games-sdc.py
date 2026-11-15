#!/usr/bin/env python3
"""Check an SDC collection's filesystem, boot linkage, drivers and game payloads.

This is an image check, not an emulation of CoCo SDC hardware.
"""
import argparse
import json
from pathlib import Path
import subprocess
import tempfile


def modules(data):
    result = {}
    while data:
        if data[:2] != b'\x87\xcd':
            raise ValueError('Invalid OS-9 module header')
        size = int.from_bytes(data[2:4], 'big')
        if not 13 <= size <= len(data):
            raise ValueError('Invalid OS-9 module length')
        module = data[:size]
        offset = int.from_bytes(module[4:6], 'big')
        name = os9name(module, offset).lower()
        if name in result:
            raise ValueError('Duplicate module: ' + name)
        result[name] = module
        data = data[size:]
    return result


def os9name(data, offset):
    name = ''
    for byte in data[offset:]:
        name += chr(byte & 127)
        if byte & 128:
            return name
    raise ValueError('Unterminated OS-9 name')


def check(disk, build):
    def require(condition, message):
        if not condition:
            raise ValueError(message)

    with tempfile.TemporaryDirectory() as directory, disk.open('rb') as image:
        directory = Path(directory)
        def extract(name):
            target = directory / 'file'
            target.unlink(missing_ok=True)
            subprocess.run(['os9', 'copy', f'{disk},{name}', str(target)], check=True,
                           stdout=subprocess.DEVNULL)
            return target.read_bytes()

        header = image.read(256)
        require(int.from_bytes(header[:3], 'big') * 256 == disk.stat().st_size,
                'LSN0 capacity differs from image size')
        kernel = (build / 'kerneltrack').read_bytes()
        require(len(kernel) <= 18 * 256, 'Kernel track exceeds 18 sectors')
        image.seek(34 * 18 * 256)
        require(image.read(len(kernel)) == kernel, 'Kernel track missing at track 34')
        require((build / '.mods/boot_sdc').read_bytes() in kernel, 'Kernel does not contain the SDC booter')
        boot = extract('OS9Boot')
        require(boot == (build / 'bootfile').read_bytes(), 'Installed OS9Boot differs from build')
        pointer, size = int.from_bytes(header[21:24], 'big'), int.from_bytes(header[24:26], 'big')
        require(pointer > 0, 'No OS9Boot pointer')
        image.seek(pointer * 256)
        if size:
            linked = image.read(size)
        else:
            fd = image.read(256)
            linked = bytearray()
            for offset in range(16, 256, 5):
                lsn = int.from_bytes(fd[offset:offset+3], 'big')
                count = int.from_bytes(fd[offset+3:offset+5], 'big')
                if not count:
                    break
                image.seek(lsn * 256)
                linked.extend(image.read(count * 256))
            linked = linked[:int.from_bytes(fd[9:13], 'big')]
        require(linked == boot, 'Boot pointer does not load installed OS9Boot')
        names = modules(boot)
        require({'rbf', 'rbsuper', 'llcocosdc', 'dd', 'sd0', 'sd1'} <= names.keys(),
                'Missing native SDC boot modules')
        require(not {'emudsk', 'rb1773', 'rbdw'} & names.keys(), 'Unexpected emulator/floppy/DriveWire dependency')
        for name, drive in [('dd', 0), ('sd0', 0), ('sd1', 1)]:
            module = names[name]
            require(module[18] == 1 and module[19] == drive and module[21] == 128,
                    f'Incorrect RBF drive/sector configuration for /{name}')
            require(os9name(module, int.from_bytes(module[11:13], 'big')).lower() == 'rbsuper',
                    f'Incorrect driver for /{name}')
            require(b'llcocosd\xe3' in module, f'Missing SDC low-level driver in /{name}')
        require(extract('CMDS/games') == (build / '.mods/games').read_bytes(), 'Wrong game menu')
        require(extract('sysgo') == (build / '.mods/sysgo_dd').read_bytes(), 'Wrong sysgo')
        require(b'games </term' in extract('startup'), 'Startup does not run the menu')
        games = json.loads((build / 'collection.json').read_text())
        for game in games:
            prefix = 'GAMES/' + game['game']
            require(extract(prefix + '/launch'), 'Missing launcher: ' + prefix)
            for program in game['programs']:
                require(extract(prefix + '/CMDS/' + Path(program).name) ==
                        (Path(game['source']) / program).read_bytes(), 'Program differs: ' + program)
    subprocess.run(['os9', 'dcheck', str(disk)], check=True)
    return {'passed': True, 'hardware_tested': False, 'games': [g['game'] for g in games],
            'bytes': disk.stat().st_size, 'boot_modules': sorted(names)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--disk', required=True, type=Path)
    parser.add_argument('--build', required=True, type=Path)
    args = parser.parse_args()
    result_path = args.build / 'sdc-check.json'
    result_path.unlink(missing_ok=True)
    try:
        result = check(args.disk.resolve(), args.build.resolve())
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        result_path.write_text(json.dumps({'passed': False, 'error': str(error)}, indent=2) + '\n')
        raise SystemExit(str(error)) from error
    result_path.write_text(json.dumps(result, indent=2) + '\n')
    print('PASS: native SDC image, boot linkage, game programs and dcheck; hardware boot not tested')


if __name__ == '__main__':
    main()
