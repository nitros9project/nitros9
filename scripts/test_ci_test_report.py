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

    def test_cpu_and_level_one_jobs_find_their_own_evidence(self):
        jobs=[{'name':'Filesystem integration (module-groups-6309)','conclusion':'success'},
              {'name':'Level One runtime (coco2b)','conclusion':'success'}]
        for job in jobs:
            for name in report.required_artifacts(job):
                artifact=self.artifacts/name;artifact.mkdir()
                (artifact/'result.json').write_text('{"passed":true}')
        result,html=self.build(jobs)
        self.assertFalse(result['warnings'])
        self.assertIn('CoCo 1/2 Level One boots',html)
        self.assertIn('Two-process ownership and measured resource cycles',html)

    def test_measured_resource_checkpoints_are_visible(self):
        artifact=self.artifacts/'filesystem-module-groups-6809-results';artifact.mkdir()
        metrics=dict(free_blocks=47,processes=5,tasks=4,paths=5)
        (artifact/'result.json').write_text(json.dumps(dict(passed=True,resources=dict(cycles=1000,
            checkpoints=[dict(sequence=n,metrics=metrics) for n in (0,100,1000)]))))
        _,html=self.build([{'name':'Filesystem integration (module-groups-6809)','conclusion':'success'}])
        self.assertIn('1000 balanced cycles',html)
        self.assertIn('Free 8K blocks',html)
        self.assertIn('<td>1000</td><td>47</td>',html)

    def test_shared_level_profiles_route_to_matching_evidence(self):
        jobs=[]
        for profile in ('l1-coco','l1-coco2b','l2-6809','l2-6309'):
            name='filesystem-rbf-'+profile+'-results'
            artifact=self.artifacts/name;artifact.mkdir()
            (artifact/'result.json').write_text('{"passed":true}')
            jobs.append(dict(name='Filesystem integration (rbf-'+profile+')',conclusion='success'))
        result,html=self.build(jobs)
        self.assertFalse(result['warnings'])
        self.assertNotIn('Supporting setup job',html)

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
