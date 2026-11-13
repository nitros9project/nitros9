#!/usr/bin/env python3
"""Assemble and execute blkdrv ABI 1 on MC6809, including an SD SPI peer.
Requires lwasm and MC6809 (pip install MC6809). No OS or physical card needed.
"""
import logging
import os
from pathlib import Path
import re
import subprocess
import tempfile
from collections import deque

logging.disable(logging.CRITICAL)
from MC6809.components.cpu6809 import CPU
from MC6809.components.memory import Memory
from MC6809.tests.test_config import TestCfg

ROOT = Path(__file__).resolve().parents[1]
DRIVER, BACKEND, STAT, STATE = 0x2000, 0x3000, 0x800, 0x900
DESC, REQ, PD, BUF, RAM, PORT = 0x1000, 0x1100, 0x1200, 0x4000, 0x5000, 0xFE90


def assemble(tmp, level, cpu=0):
    (tmp / 'defsfile').write_text(f'Level equ {level}\n use os9.d\n use scf.d\n use rbf.d\n use wildbits.d\n')
    result = {}
    for name in ('blkdrv', 'llmemblk', 'llwbsdblk'):
        source = ROOT / ('level1/wildbits/modules' if name == 'llwbsdblk' else 'level1/modules') / (name + '.asm')
        command = [os.environ.get('LWASM', 'lwasm'), '--6309' if cpu else '--6809', '--format=os9',
                   '--pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
                   '-I' + str(tmp), '-I' + str(ROOT / 'defs'), f'-DH6309={cpu}', '-Dwildbits=1',
                   str(source), '-o' + str(tmp / name), '--symbol-dump=' + str(tmp / (name + '.sym'))]
        proc = subprocess.run(command, cwd=tmp, capture_output=True, text=True)
        if proc.returncode:
            raise AssertionError(proc.stderr)
        syms = {n: int(v, 16) for n, v in re.findall(r'^(\S+) (?:EQU|SET) \$([0-9A-Fa-f]+)$',
                                                     (tmp / (name + '.sym')).read_text(), re.M)}
        result[name] = ((tmp / name).read_bytes(), syms)
    return result


class Machine:
    def __init__(self, modules, backend='llmemblk', base=0, blocks=4, readonly=False, fail=65535):
        cfg = TestCfg({'trace': False, 'verbosity': 0})
        self.m = Memory(cfg)
        self.c = CPU(self.m, cfg)
        self.s = modules['blkdrv'][1]
        self.bs = modules[backend][1]
        self.m.load(DRIVER, modules['blkdrv'][0])
        self.m.load(BACKEND, modules[backend][0])
        self.allocations = []
        self.allocation_sizes = {}
        self.unlinks = 0
        self.fail_link = False
        self.fail_alloc = False
        s = self.s
        self.config = DESC + s['BT.Config']
        self.byte(DESC + s['BT.Version'], 1)
        self.word(DESC + s['BT.Backend'], 0x80)
        self.m.load(DESC + 0x80, backend.encode()[:-1] + bytes([ord(backend[-1]) | 128]))
        self.word(self.config + s['BC.Port'], PORT)
        self.byte(self.config + s['BC.Flags'], int(readonly))
        self.word(self.config + s['BC.Ram'], RAM)
        self.word(self.config + s['BC.Blocks'], blocks)
        self.long(self.config + s['BC.Base'], base)
        self.word(self.config + s['BC.FailAfter'], fail)
        self.word(s['D.Proc'], 0x600)
        if 'D.SysPrc' in s:
            self.word(s['D.SysPrc'], 0x650)

    def byte(self, a, v=None):
        if v is None:
            return self.m.read_byte(a)
        self.m.write_byte(a, v)

    def word(self, a, v=None):
        if v is None:
            return self.m.read_word(a)
        self.m.write_word(a, v)

    def long(self, a, v):
        self.m.load(a, v.to_bytes(4, 'big'))

    def data(self, a, n):
        return bytes(self.byte(a + i) for i in range(n))

    def request(self, lba=0, count=1, buf=BUF, size=None):
        self.m.load(REQ, bytes([16, 1, 0, 0]) + lba.to_bytes(4, 'big') + count.to_bytes(2, 'big') +
                    buf.to_bytes(2, 'big') + (size if size is not None else min(count * 512, 65535)).to_bytes(2, 'big') + b'\xCA\xFE')

    def run(self, name, x=REQ, y=PD, cc=0, limit=3000000):
        c, s = self.c, self.s
        c.index_x.set(x)
        c.index_y.set(DESC if name == 'Init' else y)
        expected_y = c.index_y.value
        c.user_stack_pointer.set(STAT)
        c.system_stack_pointer.set(0x7000)
        self.word(0x7000, 0x1FFF)
        c.program_counter.set(DRIVER + s[name])
        c.set_cc(cc)
        for _ in range(limit):
            pc = c.program_counter.value
            if pc == 0x1FFF:
                break
            if self.data(pc, 2) == b'\x10\x3f':
                op = self.byte(pc + 2)
                if op == s['F$Link']:
                    if self.fail_link:
                        c.C = 1
                        c.accu_b.set(s['E$MNF'])
                    else:
                        c.user_stack_pointer.set(BACKEND)
                        c.index_y.set(BACKEND + self.bs['start'])
                        c.C = 0
                elif op == s['F$SRqMem']:
                    if self.fail_alloc:
                        c.C = 1
                        c.accu_b.set(s['E$MemFul'])
                    else:
                        c.user_stack_pointer.set(STATE)
                        size=(c.accu_d.value+255)&0xff00
                        c.accu_d.set(size)
                        self.allocation_sizes[STATE]=size
                        self.allocations.append(STATE)
                        c.C = 0
                elif op == s['F$SRtMem']:
                    assert c.user_stack_pointer.value in self.allocations
                    assert c.accu_d.value == self.allocation_sizes.pop(c.user_stack_pointer.value)
                    self.allocations.remove(c.user_stack_pointer.value)
                    c.C = 0
                elif op == s['F$UnLink']:
                    assert c.user_stack_pointer.value == BACKEND
                    self.unlinks += 1
                    c.C = 0
                else:
                    raise AssertionError(('unexpected syscall', hex(op)))
                c.program_counter.set(pc + 3)
            else:
                c.get_and_call_next_op()
        else:
            raise AssertionError(('did not return', name, hex(c.program_counter.value)))
        assert c.index_x.value == x and c.index_y.value == expected_y and c.user_stack_pointer.value == STAT, (name, 'register preservation')
        assert c.system_stack_pointer.value == 0x7002, (name, 'stack balance')
        assert c.get_cc_value() & 0x50 == cc & 0x50, (name, 'interrupt masks')
        assert self.word(s['D.Proc']) == 0x600, 'system process context restored'
        return c.C, c.accu_b.value

    def ok(self, name, **kw):
        result = self.run(name, **kw)
        assert result == (0, 0), (name, result)

    def error(self, name, code, **kw):
        result = self.run(name, **kw)
        assert result == (1, self.s[code]), (name, result, code)


def memory_tests(modules):
    for cc in (0, 0x10, 0x40, 0x50):
        p = Machine(modules)
        p.ok('Init', cc=cc)
        p.m.load(REQ, bytes([12, 1]) + bytes(10))
        p.ok('GetInfo', cc=cc)
        assert p.data(REQ + 4, 8) == bytes.fromhex('020000000003007f')
        pattern = bytes(range(256)) * 4
        p.m.load(BUF, pattern)
        p.byte(BUF - 1, 0xA5)
        p.byte(BUF + 1024, 0x5A)
        p.request(count=2)
        original_request = p.data(REQ, 14)
        p.ok('Write', cc=cc)
        assert p.data(RAM, 1024) == pattern
        assert p.word(REQ + 14) == 2
        p.m.load(BUF, bytes(1024))
        p.request(count=2)
        p.ok('Read', cc=cc)
        assert p.data(BUF, 1024) == pattern
        assert p.data(REQ, 14) == original_request
        assert p.byte(BUF - 1) == 0xA5 and p.byte(BUF + 1024) == 0x5A
        p.ok('Flush', cc=cc)
        p.ok('Term', cc=cc)
        assert not p.allocations and p.unlinks == 1
        p.ok('Term', cc=cc)
        assert p.unlinks == 1
    for base in (0x00FFFFFF, 0xFFFFFFFC):
        p = Machine(modules, base=base)
        p.ok('Init')
        p.request(base, 4)
        p.ok('Read')
        p.request(base, 5)
        p.error('Read', 'E$Sect')
        assert p.word(REQ + 14) == 0
        p.request(base - 1)
        p.error('Read', 'E$Sect')
    p = Machine(modules)
    p.ok('Init')
    for changes, code in [({'count': 0}, 'E$IllArg'), ({'count': 128}, 'E$IllArg'),
                           ({'size': 511}, 'E$IllArg'), ({'buf': 0xFF00}, 'E$IllArg'),
                           ({'lba': 4}, 'E$Sect')]:
        p.request(**changes)
        p.error('Read', code)
        assert p.word(REQ + 14) == 0
    for offset, value, code in [(1, 2, 'E$IllArg'), (2, 1, 'E$Unit'), (3, 1, 'E$IllArg')]:
        p.request()
        p.byte(REQ + offset, value)
        p.error('Read', code)
    p.request()
    p.byte(REQ, 1)
    p.error('Read', 'E$IllArg')
    assert p.word(REQ + 14) == 0xCAFE, 'short request must not be overwritten'
    p.byte(STAT + p.s['BV.Lock'], 1)
    p.error('Read', 'E$DevBsy')
    assert p.byte(STAT + p.s['BV.Lock']) == 1
    p = Machine(modules, readonly=True)
    p.ok('Init')
    p.request()
    p.error('Write', 'E$WP')
    for name in ('Read', 'Write'):
        for fail in (0, 1, 2):
            p = Machine(modules, fail=fail)
            p.ok('Init')
            p.request(count=2)
            if fail < 2:
                p.error(name, 'E$' + name)
            else:
                p.ok(name)
            assert p.word(REQ + 14) == fail
            assert p.byte(STAT + p.s['BV.Lock']) == 0
    for failure in ('link', 'alloc', 'abi', 'header', 'memory', 'init'):
        p = Machine(modules, blocks=0 if failure == 'init' else 4)
        p.fail_link = failure == 'link'
        p.fail_alloc = failure == 'alloc'
        if failure == 'abi':
            p.byte(BACKEND + p.bs['start'] + p.s['BH.Version'], 2)
        if failure == 'header':
            p.word(BACKEND + p.s['M$Size'], p.bs['start'] + 23 + 3)
        if failure == 'memory':
            p.word(BACKEND + p.bs['start'] + p.s['BH.Memory'], 65535)
        p.error('Init', {'link': 'E$MNF', 'alloc': 'E$MemFul', 'abi': 'E$BMode', 'header': 'E$BMode', 'memory': 'E$BMode', 'init': 'E$IllArg'}[failure])
        assert not p.allocations
        assert p.unlinks == (failure != 'link')
        p.ok('Term')
    print('  RAM: lifecycle, ABI, bounds, 32-bit carry, protection, partial I/O, register/IRQ preservation passed')


class SDCard:
    """Byte-level SPI peer: real assembled Exchange/SendCommand run unmodified."""
    def __init__(self, machine, hc=True, v1=False, csize=0x3FFFFF):
        self.p = machine
        self.hc, self.v1, self.csize = hc, v1, csize
        self.selected = False
        self.idle = True
        self.command = []
        self.responses = deque()
        self.value = 255
        self.commands = []
        self.storage = {}
        self.write_lba = None
        self.write_data = None
        self.absent = False
        self.protected = False
        self.spi_stuck = False
        self.no_token = False
        self.reject_write = False
        self.program_error = False
        self.busy_forever = False
        self.init_forever = False
        self.remove_at = None
        self.csd = bytearray(16)
        if hc:
            self.csd[0] = 0x40
            self.csd[7:10] = csize.to_bytes(3, 'big')
            self.last = (csize << 10) | 1023
        else:
            # 4096 C_SIZE units * 512-byte blocks * 512 multiplier = 1 GiB.
            self.csd[5] = 9
            self.csd[6:9] = bytes([3, 255, 192])
            self.csd[9:11] = bytes([3, 128])
            self.last = 0x1FFFFF
        m = machine.m
        m.add_read_byte_callback(lambda *_: (0x40 if self.absent else 0) | (0x80 if self.protected else 0), machine.bs['SYS0'])
        m.add_read_byte_callback(lambda *_: 128 if self.spi_stuck else 0, PORT)
        m.add_write_byte_callback(self.control, PORT)
        m.add_write_byte_callback(self.exchange, PORT + 1)
        m.add_read_byte_callback(lambda *_: self.value, PORT + 1)

    def control(self, cycles, pc, address, value):
        self.selected = bool(value & 1)
        if not self.selected:
            self.command.clear()
            self.responses.clear()
            self.write_lba = None
            self.write_data = None

    def exchange(self, cycles, pc, address, value):
        self.value = 255
        if not self.selected:
            return
        if self.responses:
            self.value = self.responses.popleft()
            return
        if self.busy_forever:
            self.value = 0
            return
        if self.write_lba is not None:
            if self.write_data is None:
                if value == 0xFE:
                    self.write_data = bytearray()
            else:
                self.write_data.append(value)
                if len(self.write_data) == 514:
                    if not self.reject_write:
                        self.storage[self.write_lba] = bytes(self.write_data[:512])
                    self.write_lba = None
                    self.write_data = None
                    self.responses.extend([0x0B if self.reject_write else 0xE5, 0, 0, 255])
            return
        if not self.command:
            if value & 0xC0 != 0x40:
                return
        self.command.append(value)
        if len(self.command) != 6:
            return
        command, arg = self.command[0] & 63, int.from_bytes(self.command[1:5], 'big')
        self.commands.append((command, arg))
        self.command.clear()
        if command == 0:
            self.idle = True
            self.responses.append(1)
        elif command == 8:
            self.responses.extend([5] if self.v1 else [1, 0, 0, 1, 0xAA])
        elif command == 55:
            self.responses.append(int(self.idle))
        elif command == 41:
            self.idle = self.init_forever
            self.responses.append(int(self.idle))
        elif command == 58:
            self.responses.extend([0, 0xC0 if self.hc else 0x80, 0xFF, 0x80, 0])
        elif command == 16:
            assert arg == 512
            self.responses.append(0)
        elif command == 9:
            self.responses.extend([0, 255, 0xFE, *self.csd, 0, 0])
        elif command == 17:
            lba = arg if self.hc else arg // 512
            assert self.hc or arg % 512 == 0
            self.responses.append(0)
            if not self.no_token:
                self.responses.extend([255, 0xFE, *self.storage.get(lba, bytes([lba & 255]) * 512), 0, 0])
            if lba == self.remove_at:
                self.absent = True
        elif command == 24:
            self.write_lba = arg if self.hc else arg // 512
            assert self.hc or arg % 512 == 0
            self.responses.append(0)
        elif command == 13:
            self.responses.extend([0, 4 if self.program_error else 0])
        else:
            raise AssertionError(('unexpected SD command', command, hex(arg)))


def sd_tests(modules):
    for hc, v1 in ((True, False), (False, False), (False, True)):
        p = Machine(modules, backend='llwbsdblk')
        card = SDCard(p, hc=hc, v1=v1)
        p.ok('Init')
        assert not card.selected
        p.m.load(REQ, bytes([12, 1]) + bytes(10))
        p.ok('GetInfo')
        assert int.from_bytes(p.data(REQ + 6, 4), 'big') == card.last
        assert p.word(REQ + 4) == 512
        if not hc:
            assert (16, 512) in card.commands
        for lba in ((0x00FFFFFF, 0xFFFFFFFF) if hc else (0xFFFF, 0x1FFFFF)):
            count = 1 if lba == card.last else 2
            pattern = bytes(range(256)) * (count * 2)
            p.m.load(BUF, pattern)
            p.request(lba, count)
            p.ok('Write')
            assert p.word(REQ + 14) == count
            assert card.storage[lba] == pattern[:512]
            p.m.load(BUF, bytes(count * 512))
            p.request(lba, count)
            p.ok('Read')
            assert p.data(BUF, count * 512) == pattern
            assert p.word(REQ + 14) == count
        p.ok('Flush')
        p.ok('Term')
        assert not p.allocations and not card.selected
    for fault, code in (('protected', 'E$WP'), ('reject_write', 'E$Write'), ('program_error', 'E$Write'),
                         ('no_token', 'E$Read'), ('absent', 'E$NotRdy'), ('spi_stuck', 'E$NotRdy'),
                         ('busy_forever', 'E$NotRdy')):
        p = Machine(modules, backend='llwbsdblk')
        card = SDCard(p)
        p.ok('Init')
        setattr(card, fault, True)
        p.request()
        p.error('Read' if fault == 'no_token' else 'Write', code)
        assert p.word(REQ + 14) == 0
        assert not card.selected
        assert p.byte(STAT + p.s['BV.Lock']) == 0
        # Term must release memory/link even when flushing fails (IOMan semantics).
        result = p.run('Term')
        assert result[0] == (fault in ('absent', 'spi_stuck', 'busy_forever'))
        assert not p.allocations and p.unlinks == 1
    p = Machine(modules, backend='llwbsdblk')
    card = SDCard(p)
    p.ok('Init')
    card.remove_at = 0
    p.request(count=2)
    p.error('Read', 'E$NotRdy')
    assert p.word(REQ + 14) == 1
    # Capacity corners and malformed/incompatible CSD layouts.
    for csize in (0, 1, 0x12345, 0x3FFFFF):
        p = Machine(modules, backend='llwbsdblk')
        card = SDCard(p, csize=csize)
        p.ok('Init')
        p.m.load(REQ, bytes([12, 1]) + bytes(10))
        p.ok('GetInfo')
        assert int.from_bytes(p.data(REQ + 6, 4), 'big') == ((csize + 1) * 1024 - 1)
    for csd0 in (0, 0x80, 0xC0):
        p = Machine(modules, backend='llwbsdblk')
        card = SDCard(p)
        card.csd[0] = csd0
        p.error('Init', 'E$BMode')
        assert not p.allocations
    p = Machine(modules, backend='llwbsdblk')
    card = SDCard(p)
    card.csd[14] = 0x20
    p.ok('Init')
    p.request()
    p.error('Write', 'E$WP')
    assert not any(cmd == 24 for cmd, _ in card.commands)
    for fault in ('absent', 'spi_stuck', 'init_forever'):
        p = Machine(modules, backend='llwbsdblk')
        card = SDCard(p)
        setattr(card, fault, True)
        p.error('Init', 'E$NotRdy', limit=6000000)
        assert not p.allocations and p.unlinks == 1
        assert not card.selected
    print('  SD: SPI init, SDSC/SDHC capacity, high LBA, read/write, status, removal, timeouts and cleanup passed')


if __name__ == '__main__':
    with tempfile.TemporaryDirectory(prefix='blkdrv-test-') as directory:
        tmp = Path(directory)
        for level in (1, 2):
            modules = assemble(tmp, level)
            print(f'Level {level}: ' + ', '.join(f'{n}={len(b)} bytes' for n, (b, _) in modules.items()))
            memory_tests(modules)
            sd_tests(modules)
        for level in (1, 2):
            assemble(tmp, level, cpu=1)
        print('6809 execution and 6809/6309 Level 1/2 assembly passed')
