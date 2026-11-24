#!/usr/bin/env python3
"""Standard-library checks for the OS-9 semantics required by Shell+ PWD."""
import importlib.util
import io
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('rfm_mame', Path(__file__).with_name('rfm-mame.py'))
rfm = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rfm)

class Input:
    def __init__(self, path):
        self.data = io.BytesIO(path.encode('ascii') + b'\r')
    def recv(self, count):
        return self.data.read(count)

class Wire:
    def __init__(self, packet):
        self.input = io.BytesIO(packet)
        self.output = bytearray()
    def recv(self, count):
        return self.input.read(count)
    def sendall(self, data):
        self.output.extend(data)

class Paths(unittest.TestCase):
    def test_dot_spellings_and_separate_contexts(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            data = root / 'one/two/three'
            executable = root / 'bin/tools'
            data.mkdir(parents=True)
            executable.mkdir(parents=True)
            peer = rfm.Fixture(root, io.StringIO())
            peer.contexts['data'][7] = data
            peer.contexts['exec'][7] = executable
            cases = [('.', data), ('..', data.parent), ('...', data.parent.parent),
                     ('....', root), ('.....', root), ('../../..', root),
                     ('../three', data), ('./marker', data/'marker')]
            for spelling, expected in cases:
                with self.subTest(path=spelling):
                    self.assertEqual(peer.pathname(Input(spelling), 7, 1), expected)
            self.assertEqual(peer.pathname(Input('tool'), 7, 4), executable/'tool')
            self.assertEqual(peer.pathname(Input('/y0/one'), 7, 1), root/'one')

    def test_cookies_survive_pid_context_changes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            old, new = root/'old', root/'new'
            old.mkdir()
            new.mkdir()
            peer = rfm.Fixture(root, io.StringIO())
            cookie = peer.lsn(old)
            peer.contexts['data'][7] = new
            peer.contexts['exec'][7] = new
            for mode in (1,4):
                self.assertEqual(peer.pathname(Input('marker'), cookie, mode, context=True), old/'marker')
            self.assertEqual(peer.lsn(old), cookie)

    def test_drivewire4_capability_and_irq_poll(self):
        class Wire:
            def __init__(self):
                self.input=io.BytesIO(b'\x5a\x01\x43')
                self.output=bytearray()
            def recv(self,count):return self.input.read(count)
            def sendall(self,data):self.output.extend(data)
        with tempfile.TemporaryDirectory() as directory:
            peer=rfm.Fixture(Path(directory),io.StringIO())
            peer.protocol_version=0xff
            wire=Wire()
            peer.handle(wire)
            self.assertEqual(wire.output,b'\xff\x00\x00')
            self.assertEqual(peer.irq_polls,1)
            self.assertFalse(peer.errors)

    def test_parent_record_precedes_current_record(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            child = root/'child'
            child.mkdir()
            peer = rfm.Fixture(root, io.StringIO())
            records = peer.directory(child)
            self.assertEqual(records[:2], b'.\xae')
            self.assertEqual(records[32], 0xae)
            self.assertEqual(peer.nodes[int.from_bytes(records[29:32], 'big')], root)
            self.assertEqual(peer.nodes[int.from_bytes(records[61:64], 'big')], child)

    def test_readdir_handshake_records_metadata_eof_and_following_request(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            (root/'a.txt').write_bytes(b'hello')
            (root/'bdir').mkdir()
            peer = rfm.Fixture(root, io.StringIO())
            records = peer.directory(root)
            stream = io.BytesIO(records[:64] + bytes(32) + records[64:])
            stream.name = str(root)
            peer.paths[7] = stream
            get = b'\xd6\x0b\x07\x2e'
            wire = Wire(get + b'\x00\x20' + get + b'\x00\x2d' +
                        get + b'\x00\x20' + get + b'\x00\x2d' +
                        b'\xd6\x0b\x07\x05\xd6\x0d\x07')
            expected = (b'\x00\x00' + records[64:96] +
                        b'\x00\x00' + records[96:128] + peer.descriptor(root/'bdir')[:13] +
                        b'\x00\xd3\x00\xd3' + (160).to_bytes(4, 'big') + b'\x00')
            peer.handle(wire)
            self.assertEqual(wire.output, expected)
            self.assertFalse(peer.errors)

    def test_readdir_bad_size_preserves_cursor_and_protocol(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            peer = rfm.Fixture(root, io.StringIO())
            stream = io.BytesIO(peer.directory(root))
            stream.name = str(root)
            peer.paths[7] = stream
            wire = Wire(b'\xd6\x0b\x07\x2e\x00\x21\xd6\x0b\x07\x05')
            peer.handle(wire)
            self.assertEqual(wire.output, b'\x00\xcb' + bytes(4))
            self.assertFalse(peer.errors)

    def test_readdir_file_rejection_does_not_consume_next_request(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            file = root/'file'
            file.write_bytes(b'hello')
            peer = rfm.Fixture(root, io.StringIO())
            peer.paths[7] = file.open('rb')
            wire = Wire(b'\xd6\x0b\x07\x2e\xd6\x0b\x07\x02\xd6\x0d\x07')
            peer.handle(wire)
            self.assertEqual(wire.output, b'\xcb' + (5).to_bytes(4, 'big') + b'\x00')
            self.assertFalse(peer.errors)

if __name__ == '__main__':
    unittest.main()
