"""Check PDF links, navigation, images, and truthful failure/skip reporting."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

HAVE_PDF = all(importlib.util.find_spec(name) for name in ('reportlab', 'pypdf'))


def module(name, filename):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name(filename))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


@unittest.skipUnless(HAVE_PDF, 'PDF report dependencies are tested in the report job')
class PdfReportTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.html = module('evidence_html', 'ci-test-report.py')
        cls.pdf = module('evidence_pdf', 'ci-test-report-pdf.py')

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.artifacts = self.root / 'artifacts'
        self.artifacts.mkdir()
        self.run = {'id': 42, 'head_sha': 'a'*40}

    def build(self, jobs):
        from pypdf import PdfReader
        report = self.root / 'report'
        self.html.generate(self.artifacts, self.run, jobs, report)
        output = self.pdf.render(report, report / 'test-report.pdf')
        self.assertTrue(output.read_bytes().startswith(b'%PDF'))
        reader = PdfReader(output)
        return reader, ' '.join('\n'.join(page.extract_text() for page in reader.pages).split())

    def test_pdf_contains_clickable_job_links_bookmarks_and_images(self):
        from PIL import Image
        artifact = self.artifacts / 'mame-boot-results'
        artifact.mkdir()
        (self.artifacts / 'game-boot-results').mkdir()
        Image.new('RGB', (32, 24), 'green').save(artifact / 'screen.png')
        reader, text = self.build([
            {'name': 'MAME smoke tests', 'conclusion': 'success', 'url': 'https://example.com/job/7'},
            {'name': 'Full build', 'conclusion': 'failure'},
            {'name': 'Filesystem integration (rbf)', 'conclusion': 'skipped'},
        ])
        urls = [annotation.get_object().get('/A', {}).get('/URI')
                for page in reader.pages for annotation in page.get('/Annots', [])]
        self.assertIn('https://example.com/job/7', urls)
        self.assertTrue(reader.outline)
        self.assertGreater(sum(len(page.images) for page in reader.pages), 0)
        self.assertIn('Checks failed or were interrupted', text)
        self.assertIn('Not executed in this run', text)

    def test_pdf_includes_recorded_group_counts(self):
        artifact = self.artifacts / 'filesystem-module-groups-results'
        artifact.mkdir()
        states = [{'links': [count]+[0]*7, 'dat': [10 if count else 0x333e]+[0x333e]*7}
                  for count in (2, 1, 1, 0)]
        (artifact / 'result.json').write_text(json.dumps({'passed': True, 'cases': [
            {'kind': 'one-block', 'unlink_order': 'A,B', 'states': states}]}))
        _, text = self.build([{'name': 'Filesystem integration (module-groups)', 'conclusion': 'success'}])
        self.assertIn('2 -> 1 -> 1 -> 0', text)
        self.assertIn('333E', text)

    def test_pdf_preserves_missing_evidence_warning(self):
        _, text = self.build([{'name': 'Filesystem CPU regressions', 'conclusion': 'success'}])
        self.assertIn('Review incomplete or conflicting evidence', text)
        self.assertIn('missing from this report', text)


if __name__ == '__main__':
    unittest.main()
