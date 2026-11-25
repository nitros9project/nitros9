"""Startup evidence must precede cases regardless of interactive banner timing."""
import importlib.util
from pathlib import Path
import unittest
spec=importlib.util.spec_from_file_location('disk_script',Path(__file__).with_name('mame-script.py'))
script=importlib.util.module_from_spec(spec);spec.loader.exec_module(script)
class StartupEvidenceTests(unittest.TestCase):
    def test_both_banner_orders_and_directory_capitalizations(self):
        for text in (b'Shell+\rModule directory\rDONE\rRUN 1 dir',b'Module Directory\rDONE\rShell+\rRUN 1 dir'):
            self.assertTrue(script.startup_before_cases(text,b'DONE'))
    def test_late_missing_or_unstarted_startup_does_not_pass(self):
        for text in (b'RUN 1 dir\rModule Directory\rDONE',b'Module Directory\rRUN 1 dir',b'Module Directory\rDONE'):
            self.assertFalse(script.startup_before_cases(text,b'DONE'))
if __name__=='__main__':unittest.main()
