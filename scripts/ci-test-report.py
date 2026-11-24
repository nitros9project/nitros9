#!/usr/bin/env python3
"""Build an offline HTML evidence report from GitHub jobs and downloaded artifacts."""
import argparse
import base64
from collections import Counter
from datetime import datetime
import hashlib
from html import escape
import json
from pathlib import Path
import shutil
from urllib.parse import quote


COVERAGE = {
    'Quick checks': 'Recipe parsing, Python regressions, representative module assembly and CRCs, Corsham ROM and resident-bundle size checks.',
    'Full build': 'CoCo 1/2 Level 1, CoCo 3 Level 2 on both CPUs, Pico-Thing variants, Corsham ROM, and selected game builds. Building is not a boot test.',
    'MAME smoke tests': 'CoCo 3 OS-9 boots on 6809 and 6309, plus the selected game on both CPUs. Guest-produced markers and game checks establish completion.',
    'Filesystem CPU regressions': 'Assembled filesystem routines execute on an MC6809 emulator, including failure injection; seeded Level 1/2 operations are compared to host files and independently checked by fsck.fat.',
    'pcf-write': 'Real FAT writes, rename/removal/sharing rejection cases, host-reference content checks, seeded operations, fsck.fat, and persistence across a fresh boot.',
    'pcf-readonly': 'Boot and load from FAT32, verify file contents and portable directory metadata, and verify that the FAT image is unchanged.',
    'pcf-floppy': 'Boot OS-9 from RBF floppy, read FAT files through PCF, compare fragmented copies and directory results, and verify no FAT writes.',
    'pcf-boot': 'Load OS9Boot from FAT32 after deleting floppy OS9Boot and clearing its boot pointer; check content and directory results and no FAT writes.',
    'rbf': 'Recursive deletion and cancellation in a nested tree, regular-file deletion, preservation of an unrelated file, and independent disk allocation checks.',
    'rfm': 'Real guest RFM requests go through a local DriveWire fixture, with protocol, returned-content, directory, and host-filesystem assertions.',
    'rfm-irq': 'RFM directory operations under forced DWIO interrupt polling, with protocol and returned-result assertions.',
    'module-groups': 'Two distinct modules in single-block, multi-block and resident groups, in both unlink orders. Check survivor execution, duplicate-unlink protection, final unmapping and storage lifetime.',
}
ARTIFACTS = {
    'MAME smoke tests': ['mame-boot-results', 'game-boot-results'],
    'Filesystem CPU regressions': ['filesystem-cpu-results'],
}
STATUS = {'success': 'Passed', 'failure': 'Failed', 'cancelled': 'Cancelled',
          'skipped': 'Skipped', 'timed_out': 'Timed out', 'in_progress': 'Running',
          'queued': 'Queued', 'action_required': 'Action required', 'neutral': 'Neutral'}


def job_name(job):
    name = job['name']
    return name[len('Filesystem integration ('):-1] if name.startswith('Filesystem integration (') else name


def conclusion(job):
    return job.get('conclusion') or job.get('status') or 'unknown'


def required_artifacts(job):
    key = job_name(job)
    if key != job['name']:
        return ['filesystem-' + key + '-results']
    return ARTIFACTS.get(key, [])


def duration(job):
    start = job.get('startedAt') or job.get('started_at')
    end = job.get('completedAt') or job.get('completed_at')
    if not start or not end:
        return '—'
    seconds = max(0, int((datetime.fromisoformat(end.replace('Z', '+00:00')) -
                          datetime.fromisoformat(start.replace('Z', '+00:00'))).total_seconds()))
    return f'{seconds // 60}m {seconds % 60:02d}s'


def table(headers, rows):
    return '<div class="table-wrap"><table><thead><tr>' + ''.join('<th>' + escape(str(h)) + '</th>' for h in headers) + '</tr></thead><tbody>' + ''.join('<tr>' + ''.join('<td>' + escape(str(v)) + '</td>' for v in row) + '</tr>' for row in rows) + '</tbody></table></div>'


def load_jobs(path, run):
    data = json.loads(path.read_text()) if path else run.get('jobs', [])
    if isinstance(data, dict):
        data = data.get('jobs', [])
    if data and isinstance(data[0], dict) and 'jobs' in data[0]:
        data = [job for page in data for job in page['jobs']]
    # The report is generated while its own job is still running.
    return [j for j in data if j['name'] != 'Test evidence report']


def generate(artifacts, run, jobs, output):
    output.mkdir(parents=True, exist_ok=True)
    evidence = output / 'evidence'
    evidence.mkdir(exist_ok=True)
    repository = run.get('repository', {}).get('full_name', 'nitros9project/nitros9')
    run_id = run.get('id') or run.get('databaseId')
    url = run.get('html_url') or f'https://github.com/{repository}/actions/runs/{run_id}'
    sha = run.get('head_sha') or run.get('headSha', 'unknown')
    number = run.get('run_number') or run.get('number') or run_id
    warnings, manifest, saved = [], [], {}
    sources = sorted(p for p in artifacts.rglob('*') if p.is_file()
                     and p.relative_to(artifacts).parts[0] != 'test-evidence-report'
                     and p.resolve().is_relative_to(artifacts.resolve()))
    available = {p.name for p in artifacts.iterdir() if p.is_dir()}
    for job in jobs:
        if conclusion(job) == 'success':
            for name in required_artifacts(job):
                if name not in available:
                    warnings.append(f'{job["name"]} passed, but its {name} artifact is missing from this report.')
    for source in sources:
        relative = source.relative_to(artifacts)
        size = source.stat().st_size
        item = {'artifact': relative.parts[0], 'path': str(relative), 'bytes': size}
        # Disk images remain in their original artifacts. Copy reviewable text,
        # raw group records, and screenshots, with bounded size per file.
        include = (source.suffix.lower() in {'.json', '.jsonl', '.log', '.txt', '.cmd', '.lua', '.png'}
                   or source.name == 'group.report') and size <= 2_000_000
        if include:
            target = evidence / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
            item['sha256'] = hashlib.sha256(source.read_bytes()).hexdigest()
            item['report_path'] = str(target.relative_to(output))
            saved[source] = target.relative_to(output).as_posix()
        manifest.append(item)
    def link(source):
        return '<a href="' + quote(saved[source], safe='/') + '">' + escape(source.name) + '</a>'
    def text(source):
        return source.read_text(errors='replace').replace('\r', '\n')
    def badge(status):
        return '<span class="badge ' + escape(status) + '">' + escape(STATUS.get(status, status)) + '</span>'
    def result_details(source):
        try:
            data = json.loads(source.read_text())
        except (ValueError, OSError) as error:
            warnings.append(f'Cannot parse {source.relative_to(artifacts)}: {error}')
            return ''
        html = ''
        if isinstance(data, dict):
            if data.get('passed') is False:
                warnings.append(f'Structured result records failure: {source.relative_to(artifacts)}')
            cases = data.get('cases')
            if isinstance(cases, list) and cases:
                rows = []
                for case in cases:
                    states = case.get('states', [])
                    if not states:
                        continue
                    slots = [i for i, value in enumerate(states[0]['links']) if value == 2]
                    if not slots:
                        warnings.append(f'No starting group count of 2 in case {case.get("case")} of {source.relative_to(artifacts)}')
                        continue
                    slot = slots[0]
                    rows.append([case.get('kind'), case.get('unlink_order'),
                                 ' → '.join(str(state['links'][slot]) for state in states),
                                 ' → '.join(f'{state["dat"][slot]:04X}' for state in states)])
                html += '<h4>Recorded group counts and mappings</h4><p>Stages: both linked → first unlink → extra unlink → final unlink. 333E means an unmapped slot. Survivor execution is asserted in the guest; the screenshot alone cannot establish it.</p>'
                html += table(['Group', 'Unlink order', 'P$Links', 'DAT entry (hex)'], rows)
            facts = [(key.replace('_', ' '), data[key]) for key in (
                'passed', 'write_test', 'reopen', 'fat_integrity_checked', 'rbf_integrity_checked',
                'unrelated_file_preserved', 'random_seed', 'random_operations',
                'parent_child_rename_checks', 'parent_child_rmdir_checks',
                'parent_child_sharing_checks', 'recursive_directory_prompts', 'errors') if key in data]
            if facts:
                html += table(['Recorded field', 'Value'], facts)
                if 'errors' in data:
                    html += '<p class="muted">Error lists can include deliberately tested rejections. The runner assertions decide which errors are expected; an empty list is not assumed.</p>'
        elif isinstance(data, list) and data and all(isinstance(d, dict) and 'operations' in d and 'seed' in d for d in data):
            html += '<h4>Seeded CPU stress runs</h4>' + table(['OS level', 'Seed', 'Operations', 'Content checks passed', 'Independent FAT check'], [
                [d.get('level'), d['seed'], d['operations'], d.get('passed'), d.get('fat_integrity_checked')] for d in data])
            html += f'<p>{sum(d["operations"] for d in data)} recorded operations across {len(data)} level/seed combinations. These rows are read from the result file, not inferred from the configured target.</p>'
            if any(d.get('passed') is False for d in data):
                warnings.append(f'Seeded stress result records failure: {source.relative_to(artifacts)}')
        return '<div class="result"><p class="file">' + escape(str(source.relative_to(artifacts))) + ' · ' + link(source) + '</p>' + html + '</div>'
    cards = []
    for job in jobs:
        key, state = job_name(job), conclusion(job)
        wanted = required_artifacts(job)
        files = [p for p in sources if p.relative_to(artifacts).parts[0] in wanted]
        body = '<p>' + escape(COVERAGE.get(key, 'Supporting setup job; see its step log for details.')) + '</p>'
        job_url = job.get('html_url') or job.get('url') or url
        body += '<p><a href="' + escape(job_url, quote=True) + '">Open job and assertion logs ↗</a> · ' + escape(duration(job)) + '</p>'
        results = [p for p in files if p.name == 'result.json' and p in saved]
        if key == 'Filesystem CPU regressions':
            results = [p for p in results if p.parent.name == 'random']
        for source in results:
            body += result_details(source)
        screenshots = [p for p in files if p.name == 'screen.png' and p in saved]
        if key == 'MAME smoke tests':
            screenshots = [p for p in screenshots if 'mame-boot-results' in p.parts]
            screenshots += [p for p in files if p.name == 'game.png' and p in saved]
        for source in screenshots[:6]:
            encoded = base64.b64encode(source.read_bytes()).decode()
            caption = str(source.relative_to(artifacts))
            body += '<figure><img loading="lazy" src="data:image/png;base64,' + encoded + '" alt="' + escape(caption, quote=True) + '"><figcaption>' + escape(caption) + '</figcaption></figure>'
        if screenshots:
            body += '<p class="muted">Visual evidence supports the recorded assertions; it does not replace content, count, protocol, or integrity checks.</p>'
        logs = [p for p in files if p in saved and (p.name in {
            'console.txt', 'console.log', 'fsck.log', 'dcheck.log', 'run.log',
            'random.log', 'test-sysgo-startup.log', 'passed.txt', 'result-normalized.txt'} or
            (key == 'Filesystem CPU regressions' and p.name.startswith('test-') and p.suffix == '.log'))]
        # Surface concise CPU and integrity evidence before larger runner logs.
        logs.sort(key=lambda p: (p.name == 'run.log', p.name))
        for source in logs[:24]:
            excerpt = text(source)
            if len(excerpt) > 6500:
                excerpt = '[Excerpt: final 6,500 characters; download the full linked log.]\n' + excerpt[-6500:]
            body += '<details><summary>' + escape(str(source.relative_to(artifacts))) + '</summary><p>' + link(source) + '</p><pre>' + escape(excerpt) + '</pre></details>'
        if state == 'skipped':
            body += '<p class="notice">Not executed in this run. A skipped job provides no runtime evidence.</p>'
        elif wanted and not files:
            body += '<p class="notice">No artifact files were available. Inspect the job log; this report cannot supply screenshot or result evidence for this job.</p>'
        cards.append('<section class="card"><div class="card-title"><h3>' + escape(job['name']) + '</h3>' + badge(state) + '</div>' + body + '</section>')
    counts = Counter(conclusion(j) for j in jobs)
    tested = [j for j in jobs if j['name'] != 'Prepare pinned MAME']
    failed = any(conclusion(j) in {'failure', 'cancelled', 'timed_out', 'action_required'} for j in tested)
    pending = any(conclusion(j) not in {'success', 'skipped', 'neutral', 'failure', 'cancelled', 'timed_out', 'action_required'} for j in tested)
    verdict = 'Checks failed or were interrupted' if failed else 'Run still in progress' if pending else 'Completed checks passed'
    if tested and all(conclusion(j) == 'skipped' for j in tested):
        verdict = 'No checks executed'
    if not tested:
        verdict = 'No test jobs recorded'
        warnings.append('Job status metadata is missing; no passing conclusion can be established.')
    if warnings and not failed and not pending:
        verdict = 'Review incomplete or conflicting evidence'
    manifest_path = output / 'evidence-index.json'
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    (output / 'run.json').write_text(json.dumps(run, indent=2) + '\n')
    (output / 'jobs.json').write_text(json.dumps(jobs, indent=2) + '\n')
    summary = {'verdict': verdict, 'run_url': url, 'sha': sha, 'counts': dict(counts), 'warnings': warnings,
               'screenshots': sum(p.suffix == '.png' for p in saved), 'evidence_files': len(saved)}
    (output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    warning_html = ''.join('<li>' + escape(w) + '</li>' for w in warnings)
    overview = ''.join('<tr><td><a href="' + escape(j.get('html_url') or j.get('url') or url, quote=True) + '">' + escape(j['name']) + '</a></td><td>' + badge(conclusion(j)) + '</td><td>' + escape(duration(j)) + '</td></tr>' for j in jobs)
    html = '''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>NitrOS-9 test evidence</title><style>
:root{color-scheme:light;--ink:#17243c;--muted:#536477;--line:#dce3eb;--blue:#174ca6;--paper:#f3f6fa}*{box-sizing:border-box}body{margin:0;background:var(--paper);color:var(--ink);font:16px/1.6 system-ui,sans-serif}main{max-width:1100px;margin:auto;padding:48px 28px}h1{font-size:42px;line-height:1.15;margin:12px 0 20px;letter-spacing:-1.2px}h2{margin:38px 0 16px;font-size:26px}h3{font-size:21px;margin:0}h4{font-size:17px;margin:20px 0 8px}.eyebrow{color:var(--blue);font-size:13px;font-weight:750;letter-spacing:2px}a{color:var(--blue);overflow-wrap:anywhere}.muted,.file,figcaption{color:var(--muted);font-size:13px}.file{overflow-wrap:anywhere}.lead{font-size:19px;max-width:850px}.card{background:white;border:1px solid var(--line);border-radius:14px;margin:20px 0;padding:26px}.card-title{display:flex;gap:16px;justify-content:space-between;align-items:center}.badge{display:inline-block;white-space:nowrap;padding:3px 11px;border-radius:20px;font-size:13px;font-weight:700;background:#edf0f5;color:#475569}.success{background:#e4f4eb;color:#17633c}.failure,.timed_out,.action_required{background:#ffe7e4;color:#a1251b}.cancelled,.skipped,.neutral{background:#eef0f3;color:#586274}.queued,.in_progress{background:#fff0cf;color:#7c5102}.stats{display:flex;gap:14px;flex-wrap:wrap;margin:24px 0}.stat{background:white;border:1px solid var(--line);border-radius:10px;padding:14px 20px;min-width:130px}.stat b{display:block;font-size:28px;line-height:1.3}.stat span{font-size:13px;color:var(--muted)}table{width:100%;border-collapse:collapse;font-size:14px}th,td{text-align:left;padding:11px 12px;border-bottom:1px solid var(--line);vertical-align:top}th{background:#f4f7fb;font-weight:650}.table-wrap{overflow:auto}figure{margin:22px 0;background:#f4f7fb;border:1px solid var(--line);border-radius:10px;overflow:hidden}figure img{display:block;width:100%;max-height:620px;object-fit:contain;background:#10181f;image-rendering:pixelated}figcaption{padding:10px 14px;overflow-wrap:anywhere}.notice{padding:14px;background:#fff3d8;border-radius:8px}details{border-top:1px solid var(--line);padding:12px 0}summary{cursor:pointer;font-size:14px;overflow-wrap:anywhere}pre{padding:16px;background:#111d30;color:#e8eef7;overflow:auto;font-size:12px;line-height:1.55;max-height:420px;border-radius:8px}.result{margin-top:20px;border-top:1px solid var(--line)}code{font-size:.9em}footer{color:var(--muted);font-size:13px;margin:34px 0}@media(max-width:650px){main{padding:24px 16px}h1{font-size:31px}.card{padding:18px}.card-title{align-items:flex-start;flex-direction:column}.stat{flex:1;min-width:110px}}@media print{details{display:block}pre{max-height:none}body{background:white}.card{break-inside:avoid}main{max-width:none}}
</style></head><body><main>'''
    html += '<div class="eyebrow">NITROS-9 · CI EVIDENCE</div><h1>' + escape(verdict) + '</h1>'
    html += '<p class="lead">A reviewable record of what ran, what the assertions established, and what remains outside the test scope.</p>'
    html += '<p>Run <a href="' + escape(url, quote=True) + '">#' + escape(str(number)) + '</a> · Commit <a href="https://github.com/' + escape(repository, quote=True) + '/commit/' + escape(sha, quote=True) + '"><code>' + escape(sha[:12]) + '</code></a></p>'
    html += '<div class="stats">' + ''.join('<div class="stat"><b>' + str(counts.get(key, 0)) + '</b><span>' + label + '</span></div>' for key, label in [('success', 'jobs passed'), ('failure', 'jobs failed'), ('skipped', 'jobs skipped')]) + '<div class="stat"><b>' + str(summary['screenshots']) + '</b><span>screenshots retained</span></div></div>'
    if warnings:
        html += '<div class="notice"><b>Evidence needs review</b><ul>' + warning_html + '</ul></div>'
    html += '<h2>What this run actually executed</h2><div class="card table-wrap"><table><thead><tr><th>Job</th><th>Result</th><th>Elapsed</th></tr></thead><tbody>' + overview + '</tbody></table></div>'
    html += '<h2>How to read the evidence</h2><p>A screenshot shows the guest screen at one point. Stronger checks compare file bytes and hashes, inspect module counts and mappings, validate protocol replies, and run independent filesystem checkers. The cards below separate recorded results from descriptions of the configured tests. A green job means its assertions passed, not that every possible case was covered.</p>'
    html += ''.join(cards)
    html += '<h2>Limits of this evidence</h2><section class="card"><ul><li>Complete-machine runtime tests primarily exercise CoCo 3 Level Two. Builds for CoCo 1/2, Pico-Thing and Corsham do not establish that those systems boot or work on hardware.</li><li>Filesystem integration normally runs on 6809; the OS and selected-game smoke tests cover both 6809 and 6309. The assembled CPU suites exercise specific routines, not every device or whole operating system.</li><li>Only the selected game is boot-tested. Building additional games is not gameplay coverage.</li><li>Fixed cases and replayable seeds are finite samples. They do not prove correctness for all concurrent schedules, media failures, hardware variants, or power loss.</li><li>Extra-unlink checks cover the zero-module-count case; they do not establish per-process ownership of every individual module.</li><li>Negative-control results from earlier development are not silently counted as tests in this run. Review the diagnostic documentation and original output separately.</li></ul></section>'
    html += '<h2>Raw evidence and reproducibility</h2><p>Download the original artifacts on the <a href="' + escape(url, quote=True) + '">run page</a> for full disk images and large traces. This report bundles reviewable logs, result JSON, screenshots, and small raw records; files over 2 MB and disk images remain in their original artifacts. Links work after extracting the complete report ZIP. Screenshots are also embedded in this HTML for offline viewing.</p><p><a href="evidence-index.json">Evidence inventory and bundled-file SHA-256 hashes</a> · <a href="summary.json">Machine-readable summary</a> · <a href="jobs.json">Job metadata</a> · <a href="run.json">Run metadata</a></p><footer>Generated from job metadata and artifacts for this run. Artifact availability is subject to GitHub retention.</footer></main></body></html>'
    (output / 'index.html').write_text(html)
    markdown = '# Test evidence report\n\n' + verdict + '\n\n' + f'Run: {url}\n\nCommit: `{sha}`\n\nDownload the **test-evidence-report** artifact, extract it, and open **index.html** for screenshots, recorded assertions, integrity logs, seeds, and coverage limits.\n\n'
    markdown += '| Job | Result |\n| --- | --- |\n' + ''.join(f'| {j["name"]} | {STATUS.get(conclusion(j), conclusion(j))} |\n' for j in jobs)
    if warnings:
        markdown += '\nEvidence warnings:\n' + ''.join('- ' + w + '\n' for w in warnings)
    (output / 'summary.md').write_text(markdown)
    return summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--artifacts', type=Path, required=True)
    parser.add_argument('--run-json', type=Path, required=True)
    parser.add_argument('--jobs-json', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.artifacts.mkdir(parents=True, exist_ok=True)
    run = json.loads(args.run_json.read_text())
    print(json.dumps(generate(args.artifacts, run, load_jobs(args.jobs_json, run), args.output)))


if __name__ == '__main__':
    main()
