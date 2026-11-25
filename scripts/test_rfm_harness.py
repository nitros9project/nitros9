"""Catch emulator-harness errors without starting an emulator."""
import importlib.util
import io
from pathlib import Path
import tempfile
import unittest
spec=importlib.util.spec_from_file_location('rfm_harness',Path(__file__).with_name('rfm-mame.py'))
rfm=importlib.util.module_from_spec(spec);spec.loader.exec_module(rfm)
class HarnessTests(unittest.TestCase):
    def test_guest_script_has_os9_record_endings(self):
        with tempfile.TemporaryDirectory() as directory:
            p=Path(directory)/'commands'
            for raw in (b'echo ONE\nlist /x\n',b'echo ONE\r\nlist /x\r\n',b'echo ONE\rlist /x\r'):
                p.write_bytes(raw)
                self.assertEqual(rfm.guest_script(p),b'echo ONE\rlist /x\r')
    def test_level_one_irq_observer_has_no_gime_dependency(self):
        one=rfm.irq_stress_script(1);two=rfm.irq_stress_script(2)
        self.assertNotIn(':gime',one)
        self.assertIn('space:read_u16(0x0e)',one)
        self.assertIn(':gime',two)
        for script in (one,two):
            self.assertIn('+0x20',script)
            self.assertIn('+0x22',script)
            self.assertIn('+0x23',script)
    def test_malformed_script_cannot_create_control_character_filenames(self):
        class Input:
            def __init__(self):self.data=io.BytesIO(b'afterfail\n\r')
            def recv(self,count):return self.data.read(count)
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory).resolve();fixture=rfm.Fixture(root,io.StringIO())
            with self.assertRaisesRegex(ValueError,'control character'):
                fixture.pathname(Input(),1,1)
            self.assertEqual(list(root.iterdir()),[])
if __name__=='__main__':unittest.main()
