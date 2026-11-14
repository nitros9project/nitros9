#!/usr/bin/env python3
"""Validate the Corsham EPROM layout, OS-9 modules, and hardware vectors."""
import argparse
from pathlib import Path


def require(condition, message):
    if not condition:
        raise SystemExit(message)


def module_at(image, offset, limit):
    require(image[offset:offset+2] == b'\x87\xcd', f'Missing module at {offset:#x}')
    size = int.from_bytes(image[offset+2:offset+4], 'big')
    require(size >= 12 and offset + size <= limit, 'Module exceeds its ROM region')
    module = image[offset:offset+size]
    parity = 0
    for byte in module[:9]:
        parity ^= byte
    require(parity == 0xff, 'Bad OS-9 header parity')
    crc = 0xffffff
    for byte in module:
        crc ^= byte << 16
        for _ in range(8):
            crc = ((crc << 1) ^ (0x800063 if crc & 0x800000 else 0)) & 0xffffff
    require(crc == 0x800fe3, 'Bad OS-9 module CRC')
    index = int.from_bytes(module[4:6], 'big')
    name = ''
    while index < len(module) - 3:
        byte = module[index]
        name += chr(byte & 127)
        index += 1
        if byte & 128:
            return name.lower(), module
    raise SystemExit('Unterminated OS-9 module name')


def check(path):
    image = path.read_bytes()
    require(len(image) == 8192, 'Corsham EPROM must be exactly 8192 bytes')
    offset = 4096
    modules = {}
    for expected in ('krn', 'krnp2', 'init', 'boot'):
        name, module = module_at(image, offset, 0x1f00)
        require(name == expected, f'Expected {expected}, found {name}')
        modules[name] = module
        offset += len(module)
    name, rel = module_at(image, 0x1f00, 8192 - 16)
    require(name == 'rel' and len(rel) == 240, 'REL must occupy $FF00-$FFEF')
    vectors = [int.from_bytes(image[i:i+2], 'big') for i in range(0x1ff0, 8192, 2)]
    entry = int.from_bytes(rel[9:11], 'big')
    require(vectors == [0, 0x100, 0x103, 0x10f, 0x10c, 0x106, 0x109, 0xff00 + entry],
            'Corsham hardware vectors moved or changed')
    init = modules['init']
    for field in (29, 31, 33):
        pointer = int.from_bytes(init[field:field+2], 'big')
        require(0 < pointer < len(init)-3 and init[pointer] == 0,
                'ROM Init descriptive strings must be empty with valid offsets')
    print(f'PASS: {offset-4096}/3840 payload bytes; valid modules, REL, and vectors')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('rom', type=Path)
    check(parser.parse_args().rom)
