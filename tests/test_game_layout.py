"""Exercise the OS-9 directory migration against disposable real disk images."""
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'scripts/game-layout.py'
spec = importlib.util.spec_from_file_location('game_layout', SCRIPT)
layout = importlib.util.module_from_spec(spec)
spec.loader.exec_module(layout)


class MenuTests(unittest.TestCase):
    def test_full_titles_unique_uppercase_directories_and_terminal_width(self):
        spec = importlib.util.spec_from_file_location('game_collection', ROOT / 'scripts/game-collection.py')
        collection = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(collection)
        selectors = {p.stem for p in (ROOT / 'recipes/coco3/games/configs').glob('*.mak')}
        self.assertEqual(set(collection.GAME_TITLES), selectors)
        games = [{'game': game, 'cols': 40} for game in sorted(selectors)]
        directories = [collection.game_directory(game) for game in games]
        self.assertEqual(len(set(directories)), len(directories))
        for directory in directories:
            self.assertEqual(directory, directory.upper())
            self.assertLessEqual(len(Path(directory).name), 29)
        source = collection.menu_source(games)
        import re
        menu = source.split('menu\n', 1)[1].split('menuend', 1)[0]
        text = bytes(int(b, 16) for b in re.findall(r'\$([0-9a-f]{2})', menu)).decode('ascii')
        for title in ["King's Quest III", 'Microscopic Mission', 'Sub Battle Simulator']:
            self.assertIn(title, text)
        self.assertTrue(all(len(line) <= 80 for line in text.splitlines()))
        self.assertIn('/DD/GAMES/SUBBATTLESIMULATOR/launch', source)


@unittest.skipUnless(shutil.which('os9'), 'ToolShed os9 is required')
class LayoutTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.folder = Path(self.temporary.name)
        self.image = self.folder / 'test.vhd'
        self.os9('format', '-e', '-l4096', '-c4', '-q', self.image)
        for name in ['GAMES', 'GAMES/rogue', 'GAMES/rogue/CMDS', 'ROGUE',
                     'ROGUE/savedgames', 'GAMES/subsim', 'SUB']:
            self.os9('makdir', f'{self.image},{name}')
        self.saved = b'OS-9 saved game\0\xff\x87\xcd\r\n'
        self.put('ROGUE/savedgames/player.sav', self.saved)
        self.put('ROGUE/rogue.dat', b'active data')
        self.put('GAMES/rogue/rogue.dat', b'baseline')
        self.put('GAMES/rogue/CMDS/rogue', b'executable')
        self.os9('attr', '-e', '-pe', f'{self.image},GAMES/rogue/CMDS/rogue')
        self.put('GAMES/subsim/play', b'launcher')
        self.put('SUB/captain.sav', b'captain data')
        baseline = self.folder / 'baseline'
        baseline.write_bytes(b'baseline')
        self.installs = []
        self.moves = [
            {'source': 'GAMES/SUBSIM', 'destination': 'GAMES/SUBBATTLESIMULATOR'},
            {'source': 'ROGUE', 'destination': 'GAMES/ROGUE',
             'baseline': {'rogue.dat': str(baseline)}},
            {'source': 'SUB', 'destination': 'GAMES/SUBBATTLESIMULATOR'},
        ]

    def os9(self, *args):
        subprocess.run(['os9', *map(str, args)], check=True,
                       stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

    def put(self, path, payload):
        host = self.folder / 'payload'
        host.write_bytes(payload)
        self.os9('copy', '-r', host, f'{self.image},{path}')

    def migrate(self, success=True):
        result = subprocess.run([sys.executable, str(SCRIPT), '--disk', str(self.image),
                                 '--moves', json.dumps(self.moves), '--install', json.dumps(self.installs)],
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        self.assertEqual(result.returncode == 0, success, result.stderr.decode())

    def test_saved_data_permissions_allocation_and_idempotence(self):
        before = layout.Disk(self.image)
        cluster, _, allocated = before.allocation()
        orphans = allocated - before.referenced(cluster)
        executable = before.descriptor(before.find('GAMES/rogue/CMDS/rogue'))[0]
        self.migrate()
        disk = layout.Disk(self.image)
        self.assertIsNone(disk.find('ROGUE'))
        self.assertIsNone(disk.find('SUB'))
        self.assertIsNone(disk.find('GAMES/SUBSIM'))
        disk.check_uppercase()
        self.assertEqual(disk.contents(disk.find('GAMES/ROGUE/SAVEDGAMES/player.sav')), self.saved)
        self.assertEqual(disk.contents(disk.find('GAMES/ROGUE/rogue.dat')), b'active data')
        self.assertEqual(disk.contents(disk.find('GAMES/SUBBATTLESIMULATOR/captain.sav')), b'captain data')
        self.assertEqual(disk.contents(disk.find('GAMES/SUBBATTLESIMULATOR/play')), b'launcher')
        self.assertEqual(disk.descriptor(disk.find('GAMES/ROGUE/CMDS/rogue'))[0], executable)
        cluster, _, allocated = disk.allocation()
        self.assertEqual(allocated - disk.referenced(cluster), orphans)
        digest = hashlib.sha256(self.image.read_bytes()).digest()
        self.migrate()
        self.assertEqual(hashlib.sha256(self.image.read_bytes()).digest(), digest)

    def test_program_update_and_failure_are_atomic(self):
        program = self.folder / 'new-program'
        program.write_bytes(b'updated game executable')
        self.installs = [{'source': str(program), 'destination': 'GAMES/ROGUE/CMDS/rogue'}]
        self.migrate()
        disk = layout.Disk(self.image)
        fd = disk.find('GAMES/ROGUE/CMDS/rogue')
        self.assertEqual(disk.contents(fd), program.read_bytes())
        self.assertEqual(disk.descriptor(fd)[0] & 0x24, 0x24)
        self.assertEqual(disk.contents(disk.find('GAMES/ROGUE/SAVEDGAMES/player.sav')), self.saved)
        self.installs[0]['source'] = str(self.folder / 'missing-program')
        digest = hashlib.sha256(self.image.read_bytes()).digest()
        self.migrate(success=False)
        self.assertEqual(hashlib.sha256(self.image.read_bytes()).digest(), digest)

    def test_conflicting_saved_data_leaves_source_unchanged(self):
        self.put('ROGUE/player.sav', b'root save')
        self.put('GAMES/rogue/player.sav', b'different private save')
        digest = hashlib.sha256(self.image.read_bytes()).digest()
        self.migrate(success=False)
        self.assertEqual(hashlib.sha256(self.image.read_bytes()).digest(), digest)


if __name__ == '__main__':
    unittest.main()
