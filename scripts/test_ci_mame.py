"""Check mirror fallback and failure handling without installing packages."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).with_name('setup-ci-mame.sh')


class MameSetupTests(unittest.TestCase):
    def run_setup(self, failure):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, content in {
                'sudo': '#!/bin/sh\nexec "$@"\n',
                'timeout': '#!/bin/sh\nshift\nexec "$@"\n',
                'apt-get': '''#!/usr/bin/env python3
import json, os, pathlib, sys
args = sys.argv[1:]
source = next(a.split('=', 1)[1] for a in args if a.startswith('Dir::Etc::sourcelist='))
mirror = pathlib.Path(source).read_text().split()[2]
operation = 'update' if 'update' in args else 'install'
with open(os.environ['APT_LOG'], 'a') as log:
    log.write(json.dumps([mirror, operation, args]) + '\\n')
failure = os.environ['APT_FAILURE']
sys.exit(int(failure == 'all' or (mirror.startswith('https://archive.') and failure == operation)))
''',
            }.items():
                path = root / name
                path.write_text(content)
                path.chmod(0o755)
            log = root / 'apt.log'
            result = subprocess.run(['bash', str(SCRIPT)], env={
                **os.environ, 'PATH': str(root) + os.pathsep + os.environ['PATH'],
                'APT_LOG': str(log), 'APT_FAILURE': failure,
            }, capture_output=True, text=True)
            calls = [json.loads(line) for line in log.read_text().splitlines()]
            return result, calls

    def test_update_failure_uses_fallback_before_installing(self):
        result, calls = self.run_setup('update')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([call[1] for call in calls], ['update', 'update', 'install'])
        self.assertIn('us.archive.ubuntu.com', calls[-1][0])
        self.assertTrue(all('APT::Update::Error-Mode=any' in call[2] for call in calls))

    def test_install_failure_retries_on_fallback_mirror(self):
        result, calls = self.run_setup('install')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([call[1] for call in calls], ['update', 'install', 'update', 'install'])

    def test_both_mirrors_failing_is_an_error(self):
        result, calls = self.run_setup('all')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual([call[1] for call in calls], ['update', 'update'])

    def test_success_does_not_contact_fallback(self):
        result, calls = self.run_setup('none')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([call[1] for call in calls], ['update', 'install'])


if __name__ == '__main__':
    unittest.main()
