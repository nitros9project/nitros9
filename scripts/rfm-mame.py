#!/usr/bin/env python3
"""CoCo 3 integration fixture: local floppy OS, RFM over MAME Becker TCP.
This deliberately small peer is not a production DriveWire server.
"""
import argparse
import hashlib
import io
import shutil
import datetime
import json
import os
from pathlib import Path
import socket
import struct
import subprocess
import threading
import time
import xml.etree.ElementTree as ET

SIZES = (0, 1, 255, 256, 257, 1024, 65537)
# Each cycle starts and finishes in data, using only relative changes.
WALK = [('child', b'CHILDOK\r'), ('deep', b'DEEPOK\r'),
        ('leaf', b'LEAFOK\r'), ('..', b'DEEPOK\r'),
        ('..', b'CHILDOK\r'), ('..', b'DATAOK\r'),
        ('./child/deep', b'DEEPOK\r'), ('../..', b'DATAOK\r'),
        ('sibling', b'SIBLINGOK\r'), ('../child', b'CHILDOK\r'),
        ('deep/leaf', b'LEAFOK\r'), ('../../..', b'DATAOK\r')] * 3

def prepare(root, commands, suite, executable, child):
    root.mkdir(parents=True, exist_ok=True)
    share = root / 'share' / 'rfmtest'
    share.mkdir(parents=True, exist_ok=True)
    lines = ['echo RFM boundary and roundtrip checks']
    expected = {}
    sizes = SIZES if suite == 'all' else ()
    for size in sizes:
        name = f'b{size}'
        data = bytes((i * 73 + 19) & 255 for i in range(size))
        (share / name).write_bytes(data)
        expected[name] = hashlib.sha256(data).hexdigest()
        # Both comparisons read through RFM. Host verification catches silent
        # short copies, including cmp implementations that stop at either EOF.
        lines += [f'echo RFM {size} bytes',
                  f'copy /y0/rfmtest/{name} /dd/t{size}',
                  f'cmp /y0/rfmtest/{name} /dd/t{size}',
                  f'copy /dd/t{size} /y0/rfmtest/out{size}',
                  f'cmp /y0/rfmtest/{name} /y0/rfmtest/out{size}']
    (share / 'data' / 'child').mkdir(parents=True, exist_ok=True)
    (share / 'bin' / 'child').mkdir(parents=True, exist_ok=True)
    (share / 'data' / 'marker').write_bytes(b'DATAOK\r')
    (share / 'data' / 'child' / 'marker').write_bytes(b'CHILDOK\r')
    for relative, marker in [('child/deep', b'DEEPOK\r'), ('child/deep/leaf', b'LEAFOK\r'), ('sibling', b'SIBLINGOK\r')]:
        directory = share / 'data' / relative
        directory.mkdir(parents=True, exist_ok=True)
        (directory / 'marker').write_bytes(marker)
    shutil.copyfile(executable, share / 'bin' / 'rfmexec')
    shutil.copyfile(child, share / 'bin' / 'child' / 'rfmchild')
    shutil.copyfile(executable.parent / 'rfmfork', share / 'rfmfork')
    lines += [
        'echo RFM directory and execution checks',
        'dir /y0/rfmtest',
        '/y0/rfmtest/rfmfork >/y0/rfmtest/forkcheck',
        'dir /y0/rfmtest >/y0/rfmtest/listabs',
        'dir -e /y0/rfmtest >/y0/rfmtest/listext',
        'chd /y0/rfmtest/data',
        'dir >/y0/rfmtest/listrel',
        'dir -e >/y0/rfmtest/listrele',
        'list marker >/y0/rfmtest/dataok',
        'chd child',
        'list marker >/y0/rfmtest/childok',
        'chd ..',
        'list marker >/y0/rfmtest/parentok',
        'echo Expected error 216 from next chd',
        'chd no-such-directory',
        'list marker >/y0/rfmtest/afterfail',
        'makdir scratch',
        'echo CREATED >scratch/temp',
        'list scratch/temp >/y0/rfmtest/createok',
        'del scratch/temp',
        'dir scratch >/y0/rfmtest/listempty',
        'chx /y0/rfmtest/bin',
        'dir -x >/y0/rfmtest/listexec',
        'dir -e -x >/y0/rfmtest/listexece',
        'rfmexec >/y0/rfmtest/execok',
        'chx child',
        'dir -x >/y0/rfmtest/listexecchild',
        'rfmchild >/y0/rfmtest/execchild',
        'chx ..',
        'rfmexec >/y0/rfmtest/execparent',
        'echo Expected error 216 from next chx',
        'chx no-such-bin',
        'rfmexec >/y0/rfmtest/execafterfail',
        'list marker >/y0/rfmtest/separate',
        'chd /dd',
        'chx /dd/cmds',
        'dir /y0/rfmtest',
        'echo RFM commands finished - host must verify every output',
        'echo RFMTESTDONE >/y0/rfmtest/done']
    walk = []
    for index, (relative, _) in enumerate(WALK):
        walk += [f'chd {relative}', f'list marker >/y0/rfmtest/walk{index:02d}']
    # Enter once absolutely; all 36 subsequent changes and reads are relative.
    at = lines.index('echo Expected error 216 from next chd')
    lines[at:at] = ['echo RFM repeated relative descent and ascent'] + walk
    commands.write_text('\n'.join(lines) + '\n')
    (root / 'manifest.json').write_text(json.dumps(expected, indent=2) + '\n')
    print(f'Prepared {len(sizes)} boundary files and directory/exec tests in {share.resolve()}')

class Fixture:
    def __init__(self, root, log):
        self.root = root.resolve()
        self.log = log
        self.paths = {}
        self.closed = set()
        self.errors = []
        self.lock = threading.Lock()
        self.contexts = {'data': {}, 'exec': {}}
        self.nodes = {}
        self.lsns = {}
        self.operations = []
        self.protocol_version = 3
        self.irq_polls = 0

    def event(self, **event):
        event["time"] = time.monotonic()
        with self.lock:
            self.log.write(json.dumps(event) + '\n')
            self.log.flush()

    @staticmethod
    def receive(conn, count):
        data = bytearray()
        while len(data) < count:
            chunk = conn.recv(count - len(data))
            if not chunk:
                raise EOFError('peer disconnected')
            data.extend(chunk)
        return bytes(data)

    def pathname(self, conn, owner, mode, context=False):
        data = bytearray()
        while True:
            byte = self.receive(conn, 1)[0]
            if byte == 13:
                break
            data.append(byte & 127)
            if len(data) > 255:
                raise ValueError('oversized pathname')
        text = data.decode('ascii')
        self.last_pathname = text
        absolute = text.startswith('/')
        parts = text.split('/')
        if parts[:2] == ['', 'y0']:
            text = '/'.join(parts[2:])
        kind = 'exec' if mode & 0x24 else 'data'
        base = self.root if absolute else (self.nodes[owner] if context else self.contexts[kind].get(owner, self.root))
        path = base
        for component in text.lstrip('/').split('/'):
            if not component:
                continue
            if set(component) == {'.'}:
                # OS-9's ... means ../.., .... means ../../.., etc. Shell+
                # uses this spelling while reconstructing its current prompt.
                for _ in range(len(component) - 1):
                    path = path.parent if path != self.root else path
            else:
                path = (path / component).resolve()
            if path != self.root and self.root not in path.parents:
                raise ValueError('pathname outside test share')
        return path

    def lsn(self, path):
        if path not in self.lsns:
            number = len(self.lsns) + 1
            self.lsns[path] = number
            self.nodes[number] = path
        return self.lsns[path]

    def directory(self, path):
        records = bytearray()
        # NitrOS-9 directory readers (including Shell+ PWD) expect parent first.
        entries = [('..', path.parent if path != self.root else path), ('.', path)]
        entries += [(p.name, p) for p in sorted(path.iterdir())]
        for name, node in entries:
            encoded = bytearray(name.encode('ascii'))
            if len(encoded) > 29:
                raise ValueError('fixture name exceeds OS-9 directory record')
            encoded[-1] |= 128
            records += encoded + bytes(29-len(encoded)) + self.lsn(node).to_bytes(3, 'big')
        return bytes(records)

    @staticmethod
    def stream_size(stream):
        if isinstance(stream, io.BytesIO):
            return len(stream.getbuffer())
        return os.fstat(stream.fileno()).st_size

    def descriptor(self, path):
        stat = path.stat()
        modified = datetime.datetime.fromtimestamp(stat.st_mtime)
        fd = bytearray(256)
        fd[0] = 0x3f | (0x80 if path.is_dir() else 0)
        fd[3:8] = bytes([modified.year-1900, modified.month, modified.day, modified.hour, modified.minute])
        fd[8] = 1
        size = len(self.directory(path)) if path.is_dir() else stat.st_size
        fd[9:13] = struct.pack('>I', size)
        fd[13:16] = fd[3:6]
        return fd

    def handle(self, conn):
        try:
            while True:
                opcode = self.receive(conn, 1)[0]
                if opcode in (0, 0x49, 0x54, 0xfe, 0xff, 0xf8):
                    self.event(wire=opcode)
                    continue
                if opcode == 0x5a:  # DWIO initialization; version 3 needs no polling.
                    self.receive(conn, 1)
                    conn.sendall(bytes([self.protocol_version]))
                    self.event(wire=opcode)
                    continue
                if opcode == 0x43:  # OP_SERREAD from DWIO's IRQ poller
                    self.irq_polls += 1
                    self.event(wire=opcode)
                    conn.sendall(b'\x00\x00')
                    continue
                if opcode != 0xd6:
                    raise ValueError(f'unsupported wire opcode ${opcode:02x}')
                op, pathid = self.receive(conn, 2)
                context = op in (0x11, 0x12, 0x13, 0x14, 0x15)
                if context:
                    op &= 15
                if op in (1, 2, 3, 4, 5):
                    if context:
                        header = self.receive(conn, 5)
                        pid, parent, mode = header[0], int.from_bytes(header[1:4], 'big'), header[4]
                    else:
                        pid, parent, mode = self.receive(conn, 3)
                    path = self.pathname(conn, parent, mode, context=context)
                    event = dict(op=op, path=pathid, file=str(path), pid=pid, parent=parent, mode=mode, pathname=self.last_pathname)
                    try:
                        if op == 1:
                            stream = path.open('xb+')
                        elif op == 2:
                            if bool(mode & 0x80) != path.is_dir() and path.exists():
                                raise IsADirectoryError('requested mode does not match file type')
                            if path.is_dir():
                                stream = io.BytesIO(self.directory(path))
                                stream.name = str(path)
                            else:
                                stream = path.open('rb+' if mode & 2 else 'rb')
                        elif op == 3:
                            path.mkdir()
                        elif op == 4:
                            if not path.exists():
                                raise FileNotFoundError(path)
                            if not path.is_dir():
                                raise NotADirectoryError(path)
                            if mode & 0x1b:
                                self.contexts['data'][pid] = path
                            if mode & 0x24:
                                self.contexts['exec'][pid] = path
                        elif op == 5:
                            if path.is_dir():
                                path.rmdir()
                            else:
                                path.unlink()
                        if op in (1, 2):
                            if pathid in self.paths:
                                self.paths.pop(pathid).close()
                            self.paths[pathid] = stream
                            self.closed.discard(path)
                        result = 0
                    except FileNotFoundError:
                        result = 216
                    except FileExistsError:
                        result = 218
                    except (PermissionError, IsADirectoryError, NotADirectoryError):
                        result = 214
                    event['result'] = result
                    self.operations.append(event)
                    self.event(**event)
                    conn.sendall(bytes([result]))
                    if context and op == 4 and result == 0:
                        conn.sendall(self.lsn(path).to_bytes(3, "big"))
                    continue
                stream = self.paths[pathid]
                self.event(op=op, path=pathid)
                if op == 6:
                    stream.seek(int.from_bytes(self.receive(conn, 4), 'big'))
                    conn.sendall(b'\x00')
                elif op in (7, 9):
                    count = int.from_bytes(self.receive(conn, 2), 'big')
                    data = bytearray()
                    while len(data) < count:
                        byte = stream.read(1)
                        if not byte:
                            break
                        data.extend(byte)
                        if op == 9 and byte == b'\r':
                            break
                    conn.sendall(struct.pack('>H', len(data)) + data)
                elif op in (8, 10):
                    count = int.from_bytes(self.receive(conn, 2), 'big')
                    data = self.receive(conn, count)
                    stream.write(data)
                    stream.flush()
                elif op == 11:
                    status = self.receive(conn, 1)[0]
                    self.event(status=status, path=pathid)
                    if status == 2:
                        conn.sendall(struct.pack('>I', self.stream_size(stream)))
                    elif status == 5:
                        conn.sendall(struct.pack('>I', stream.tell()))
                    elif status == 15:
                        count = int.from_bytes(self.receive(conn, 2), 'big')
                        if count > 256:
                            raise ValueError('oversized FD request')
                        conn.sendall(self.descriptor(Path(stream.name))[:count])
                    elif status == 32:
                        packet = self.receive(conn, 4)
                        lsn = (packet[0] << 16) | int.from_bytes(packet[2:], 'big')
                        conn.sendall(self.descriptor(self.nodes[lsn]))
                    elif status == 6:
                        conn.sendall(bytes([int(stream.tell() >= self.stream_size(stream))]))
                    else:
                        raise ValueError(f'fixture does not implement GetStat ${status:02x}')
                elif op == 13:
                    path = Path(stream.name)
                    stream.close()
                    del self.paths[pathid]
                    self.closed.add(path)
                    conn.sendall(b'\x00')
                else:
                    raise ValueError(f'fixture does not implement RFM operation {op}')
        except EOFError:
            self.event(disconnected=True)
        except Exception as exc:
            self.errors.append(str(exc))
            self.event(error=str(exc))
        finally:
            for stream in self.paths.values():
                stream.close()
            self.paths.clear()

    def verified(self, expected):
        for name, digest in expected.items():
            path = self.root / 'rfmtest' / ('out' + name[1:])
            if path not in self.closed or not path.is_file():
                return False
            if hashlib.sha256(path.read_bytes()).hexdigest() != digest:
                return False
        folder = self.root / 'rfmtest'
        for index, (_, marker) in enumerate(WALK):
            path = folder / f'walk{index:02d}'
            if path not in self.closed or path.read_bytes() != marker:
                return False
        for name, data in {'dataok': b'DATAOK\r', 'childok': b'CHILDOK\r',
                           'forkcheck': b'DATAOK\rRFMEXECOK\rCHILDOK\rRFMCHILDOK\r',
                           'parentok': b'DATAOK\r', 'afterfail': b'DATAOK\r',
                           'createok': b'CREATED \r', 'separate': b'DATAOK\r',
                           'execok': b'RFMEXECOK\r', 'execchild': b'RFMCHILDOK\r',
                           'execparent': b'RFMEXECOK\r', 'execafterfail': b'RFMEXECOK\r'}.items():
            path = folder / name
            if path not in self.closed or path.read_bytes() != data:
                return False
        for name, words in {'listabs': ('data', 'bin'), 'listext': ('data', 'bin'),
                            'listrel': ('marker', 'child'), 'listrele': ('marker', 'child'),
                            'listexec': ('rfmexec', 'child'), 'listexece': ('rfmexec', 'child'),
                            'listexecchild': ('rfmchild',)}.items():
            path = folder / name
            if path not in self.closed:
                return False
            text = path.read_text().lower()
            if not all(word in text for word in words):
                return False
        if not (folder / 'data/scratch').is_dir() or (folder / 'data/scratch/temp').exists():
            return False
        # Prove real remote execution loads, both error cases, and Delete ran.
        for op, file, result in [(2, 'bin/rfmexec', 0), (2, 'bin/child/rfmchild', 0),
                                 (4, 'data/no-such-directory', 216),
                                 (4, 'bin/no-such-bin', 216), (5, 'data/scratch/temp', 0)]:
            if not any(e['op'] == op and e['file'] == str(folder/file) and e['result'] == result
                       for e in self.operations):
                return False
        return folder / 'done' in self.closed

def resident_modules(bootfile):
    data = bootfile.read_bytes()
    names = set()
    offset = 0
    while offset < len(data):
        if data[offset:offset+2] != b'\x87\xcd':
            raise ValueError(f'invalid module header at bootfile offset {offset}')
        length = int.from_bytes(data[offset+2:offset+4], 'big')
        if length < 12 or offset + length > len(data):
            raise ValueError('invalid bootfile module length')
        pos = offset + int.from_bytes(data[offset+4:offset+6], 'big')
        name = bytearray()
        while pos < offset + length:
            byte = data[pos]
            name.append(byte & 127)
            pos += 1
            if byte & 128:
                break
        names.add(name.decode('ascii').lower())
        offset += length
    required = {'rfm', 'rfmdrv', 'y0', 'dwio'}
    if not required <= names:
        raise ValueError('missing resident RFM modules: ' + ', '.join(sorted(required - names)))
    return names

def run(args):
    resident_modules(args.disk.resolve().parent / 'bootfile')
    print('Bootfile contains RFM, rfmdrv, Y0 and DWIO', flush=True)
    root = args.root.resolve()
    expected = json.loads((root / 'manifest.json').read_text())
    share = root / 'share'
    for size in SIZES:
        (share / 'rfmtest' / f'out{size}').unlink(missing_ok=True)
    for name in ('forkcheck', 'done', 'listabs', 'listext', 'listrel', 'listrele', 'listempty',
                 'listexec', 'listexece', 'listexecchild',
                 'dataok', 'childok', 'parentok', 'afterfail', 'createok', 'separate',
                 'execok', 'execchild', 'execparent', 'execafterfail'):
        (share / 'rfmtest' / name).unlink(missing_ok=True)
    for index in range(len(WALK)):
        (share / 'rfmtest' / f'walk{index:02d}').unlink(missing_ok=True)
    scratch = share / 'rfmtest/data/scratch'
    if scratch.exists():
        shutil.rmtree(scratch)
    cfg = root / 'cfg'
    cfg.mkdir(exist_ok=True)
    xml = ET.Element('mameconfig', version='10')
    inputs = ET.SubElement(ET.SubElement(xml, 'system', name='coco3'), 'input')
    ET.SubElement(inputs, 'port', tag=':beckerport', type='CONFIG', mask='1', defvalue='0', value='1')
    ET.SubElement(inputs, 'port', tag=':dwsock:drivewire_port', type='CONFIG', mask='65535', defvalue='65504', value=str(args.port))
    ET.ElementTree(xml).write(cfg / 'coco3.cfg')
    lua = root / 'capture.lua'
    auto_command = '' if args.interactive or args.input_probe else 'shell </dd/rfmauto\n'
    probe_commands = {2700: 'load utilpak1\n', 3600: 'chd /y0/rfmtest/data\n',
                      4200: 'd', 4500: 'ir\n', 4800: 'echo AFTER\n'} if args.input_probe else {}
    irq_lua = '''
  -- Make the existing DWIO VIRQ due every frame, while RFM is doing I/O.
  local ram = emu.item(manager.machine.devices[":ram"].items["0/m_pointer"])
  local mmu = emu.item(manager.machine.devices[":gime"].items["0/m_mmu"])
  local stat = ram:read(0x0e)*256 + ram:read(0x0f)
  if frames >= 2700 and stat ~= 0 then
    local phys = (mmu:read(stat >> 13) & 63)*8192 + (stat & 8191)
    if phys+0x24 < ram.count then
    ram:write(phys+0x20,1) -- Vi.Cnt low
    ram:write(phys+0x22,1) -- Vi.Rst low
    ram:write(phys+0x23,ram:read(phys+0x23)|1) -- Vi.IFlag
    end
  end
''' if args.irq_stress else ''
    probe_lua = '\n'.join(f'  if frames == {frame} then emu.keypost({json.dumps(command)}) end'
                          for frame, command in probe_commands.items())
    lua.write_text(f"""emu.keypost({json.dumps('DOS' + chr(10))})
local frames = 0
emu.register_frame_done(function()
  frames = frames + 1
{probe_lua}
{irq_lua}
  if frames == 2700 then
    emu.keypost({json.dumps(auto_command)})
  end
  if frames % 300 == 0 then
    manager.machine.screens[":screen"]:snapshot({json.dumps(str(root / 'screen.png'))})
    if {str(args.input_probe).lower()} then
      manager.machine.screens[":screen"]:snapshot(string.format({json.dumps(str(root / 'probe-%04d.png'))}, frames))
    end
  end
end)
""")
    with socket.socket() as listener, (root / 'protocol.jsonl').open('w') as protocol, (root / 'mame.log').open('w') as log:
        listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        listener.bind(('127.0.0.1', args.port))
        listener.listen(1)
        listener.settimeout(1)
        fixture = Fixture(share, protocol)
        if args.irq_stress:
            fixture.protocol_version = 0xff
        stopping = threading.Event()
        def serve():
            while not stopping.is_set():
                try:
                    conn, _ = listener.accept()
                except socket.timeout:
                    continue
                with conn:
                    conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
                    conn.settimeout(args.seconds)
                    fixture.handle(conn)
        thread = threading.Thread(target=serve, daemon=True)
        thread.start()
        command = [args.mame, 'coco3', '-rompath', args.rompath, '-skip_gameinfo',
                   '-cfg_directory', str(cfg), '-nvram_directory', str(root/'nvram'),
                   '-snapshot_directory', str(root/'snap'), '-ram', '512K',
                   '-ext', 'fdc,bios=v11', '-ext:fdc:wd17xx:0', '525qd',
                   '-seconds_to_run', str(args.seconds), '-flop1', str(args.disk.resolve()), '-autoboot_delay', '3', '-autoboot_script', str(lua)]
        if not args.interactive:
            command += ['-video', 'none', '-sound', 'none']
        else:
            command += ['-window']
        print('Starting local RFM fixture and CoCo 3 MAME', flush=True)
        print('Logs:', root, flush=True)
        process = subprocess.Popen(command, stdout=log, stderr=subprocess.STDOUT)
        passed = False
        try:
            deadline = time.monotonic() + args.seconds
            while process.poll() is None and time.monotonic() < deadline:
                if fixture.errors:
                    raise RuntimeError('; '.join(fixture.errors))
                if fixture.root / 'rfmtest/done' in fixture.closed and not fixture.verified(expected):
                    raise RuntimeError('Guest completed, but host assertions failed; inspect returned files and protocol.jsonl')
                if not passed and fixture.verified(expected):
                    if args.irq_stress and fixture.irq_polls == 0:
                        raise RuntimeError("IRQ stress did not exercise the DWIO poller")
                    passed = True
                    print(f'PASS: {len(expected)} binary roundtrips; chd/chx, relative paths, dir/dir -e, remote execution, errors and cleanup', flush=True)
                    if args.irq_stress:
                        print(f"IRQ polls serviced: {fixture.irq_polls}", flush=True)
                    if not args.interactive:
                        break
                time.sleep(.2)
        finally:
            stopping.set()
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
            thread.join(timeout=2)
        if not passed and args.input_probe:
            print('Input probe complete; inspect probe-*.png and protocol.jsonl', flush=True)
            return
        if not passed:
            raise SystemExit(f'RFM checks did not complete. Inspect {root}/mame.log and protocol.jsonl')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='action', required=True)
    prep = sub.add_parser('prepare')
    prep.add_argument('--suite', choices=('all', 'directories'), default='all')
    prep.add_argument('--executable', type=Path, required=True)
    prep.add_argument('--child', type=Path, required=True)
    prep.add_argument('--root', type=Path, required=True)
    prep.add_argument('--commands', type=Path, required=True)
    launch = sub.add_parser('run')
    launch.add_argument('--root', type=Path, required=True)
    launch.add_argument('--disk', type=Path, required=True)
    launch.add_argument('--mame', default='mame')
    launch.add_argument('--rompath', required=True)
    launch.add_argument('--port', type=int, choices=range(65500, 65510), default=65504)
    launch.add_argument('--seconds', type=int, default=180)
    launch.add_argument('--interactive', action='store_true')
    launch.add_argument('--input-probe', action='store_true')
    launch.add_argument('--irq-stress', action='store_true', help='enable DWIO virtual-channel IRQ polling every frame')
    args = parser.parse_args()
    if args.action == 'prepare':prepare(args.root, args.commands, args.suite, args.executable, args.child)
    else:run(args)
