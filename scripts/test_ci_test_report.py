"""Evidence reports must not turn missing, failed, or skipped checks into passes."""
import base64
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('ci_report', Path(__file__).with_name('ci-test-report.py'))
report = importlib.util.module_from_spec(spec)
spec.loader.exec_module(report)


class ReportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.artifacts = self.root / 'artifacts'
        self.artifacts.mkdir()
        self.run = {'id': 123, 'run_number': 42, 'head_sha': 'a' * 40,
                    'repository': {'full_name': 'nitros9project/nitros9'}}

    def build(self, jobs):
        result = report.generate(self.artifacts, self.run, jobs, self.root / 'output')
        return result, (self.root / 'output/index.html').read_text()

    def test_group_transitions_screenshot_and_escaped_log_are_reviewable(self):
        artifact = self.artifacts / 'filesystem-module-groups-results'
        artifact.mkdir()
        states = [{'links': [count] + [0]*7, 'dat': [10 if count else 0x333e] + [0x333e]*7}
                  for count in (2, 1, 1, 0)]
        (artifact / 'result.json').write_text(json.dumps({'passed': True, 'cases': [
            {'case': 1, 'kind': 'one-block', 'unlink_order': 'A,B', 'states': states}]}))
        # A real one-pixel PNG; verify the report embeds its bytes.
        png = base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=')
        (artifact / 'screen.png').write_bytes(png)
        (artifact / 'console.txt').write_text('<script>alert(1)</script>\rPASS')
        (artifact / 'guest.dsk').write_bytes(b'disk image stays in original artifact')
        result, html = self.build([{'name': 'Filesystem integration (module-groups)', 'conclusion': 'success'}])
        self.assertEqual(result['verdict'], 'Completed checks passed')
        self.assertIn('2 → 1 → 1 → 0', html)
        self.assertIn('data:image/png;base64,' + base64.b64encode(png).decode(), html)
        self.assertIn('&lt;script&gt;', html)
        self.assertNotIn('<script>', html)
        inventory = json.loads((self.root / 'output/evidence-index.json').read_text())
        self.assertTrue(next(i for i in inventory if i['path'].endswith('result.json'))['sha256'])
        self.assertNotIn('report_path', next(i for i in inventory if i['path'].endswith('guest.dsk')))

    def test_failure_and_skips_remain_visible_without_artifacts(self):
        result, html = self.build([{'name': 'Full build', 'conclusion': 'failure'},
                                   {'name': 'MAME smoke tests', 'conclusion': 'skipped'}])
        self.assertEqual(result['verdict'], 'Checks failed or were interrupted')
        self.assertIn('Not executed in this run', html)
        self.assertIn('Failed', html)

    def test_passed_job_with_missing_artifact_is_incomplete(self):
        result, _ = self.build([{'name': 'Filesystem CPU regressions', 'conclusion': 'success'}])
        self.assertEqual(result['verdict'], 'Review incomplete or conflicting evidence')
        self.assertIn('missing', result['warnings'][0])

    def test_all_skipped_jobs_do_not_claim_tests_passed(self):
        result, _ = self.build([{'name': 'Full build', 'conclusion': 'skipped'}])
        self.assertEqual(result['verdict'], 'No checks executed')

    def test_pending_run_does_not_claim_completion(self):
        result, _ = self.build([{'name': 'Full build', 'status': 'in_progress', 'conclusion': None}])
        self.assertEqual(result['verdict'], 'Run still in progress')

    def test_structured_failure_overrides_green_job(self):
        artifact = self.artifacts / 'filesystem-rbf-results'
        artifact.mkdir()
        (artifact / 'result.json').write_text('{"passed": false}')
        result, _ = self.build([{'name': 'Filesystem integration (rbf)', 'conclusion': 'success'}])
        self.assertEqual(result['verdict'], 'Review incomplete or conflicting evidence')

    def test_paginated_job_metadata_excludes_report_job(self):
        p = self.root / 'jobs.json'
        p.write_text(json.dumps([{'jobs': [{'name': 'Full build', 'conclusion': 'success'}]},
                                 {'jobs': [{'name': 'Test evidence report', 'status': 'in_progress'}]}]))
        self.assertEqual(len(report.load_jobs(p, self.run)), 1)


if __name__ == '__main__':
    unittest.main()
