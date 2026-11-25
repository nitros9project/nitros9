#!/usr/bin/env python3
"""Render the structured CI evidence report as a portable, linked PDF."""
import argparse
from html import escape
import re
import json
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, PageBreak, KeepTogether


INK = colors.HexColor('#17243c')
BLUE = colors.HexColor('#174ca6')
MUTED = colors.HexColor('#536477')
LINE = colors.HexColor('#dce3eb')
PAPER = colors.HexColor('#f3f6fa')


def plain(value):
    return str(value).replace('→', ' -> ').replace('—', '-').replace('–', '-').replace('↗', '')


def render(report, output):
    summary = json.loads((report / 'summary.json').read_text())
    run = json.loads((report / 'run.json').read_text())
    jobs = json.loads((report / 'jobs.json').read_text())
    index = json.loads((report / 'evidence-index.json').read_text())
    number = run.get('run_number') or run.get('number') or run.get('id')
    url, sha = summary['run_url'], summary['sha']
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(name='ReportTitle', fontName='Helvetica-Bold', fontSize=27, leading=31, textColor=INK, spaceAfter=16))
    styles.add(ParagraphStyle(name='SectionTitle', fontName='Helvetica-Bold', fontSize=19, leading=23, textColor=INK, spaceAfter=12, keepWithNext=True))
    styles.add(ParagraphStyle(name='ReportBody', fontName='Helvetica', fontSize=10, leading=14, textColor=INK, spaceAfter=10))
    styles.add(ParagraphStyle(name='SmallText', fontName='Helvetica', fontSize=8, leading=11, textColor=MUTED, spaceAfter=8))
    styles.add(ParagraphStyle(name='CellText', fontName='Helvetica', fontSize=8, leading=11, textColor=INK))
    styles.add(ParagraphStyle(name='Eyebrow', fontName='Helvetica-Bold', fontSize=9, leading=12, textColor=BLUE, spaceAfter=12))
    story, bookmarks = [], []
    def p(value, style='ReportBody'):
        return Paragraph(escape(plain(value)), styles[style])
    def href(target, label, style='ReportBody'):
        return Paragraph('<link href="' + escape(target, quote=True) + '" color="#174ca6"><u>' + escape(plain(label)) + '</u></link>', styles[style])
    def heading(value):
        bookmark = 'section-' + str(len(bookmarks))
        item = p(value, 'SectionTitle')
        item.report_bookmark = bookmark
        bookmarks.append((bookmark, plain(value)))
        story.append(item)
    def table(headers, rows, widths=None):
        data = [[p(h, 'CellText') for h in headers]] + [[v if isinstance(v, Paragraph) else p(v, 'CellText') for v in row] for row in rows]
        item = Table(data, colWidths=widths, repeatRows=1, hAlign='LEFT')
        item.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), PAPER),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('LINEBELOW', (0, 0), (-1, -1), .4, LINE),
            ('LEFTPADDING', (0, 0), (-1, -1), 8), ('RIGHTPADDING', (0, 0), (-1, -1), 8),
            ('TOPPADDING', (0, 0), (-1, -1), 7), ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
        ]))
        return item
    def status(job):
        return job.get('conclusion') or job.get('status') or 'unknown'
    def files_for(artifact):
        return [entry for entry in index if entry['artifact'] == artifact and entry.get('report_path')]
    def image(entry, caption):
        source = report / entry['report_path']
        w, h = ImageReader(str(source)).getSize()
        scale = min(516 / w, 208 / h)
        return KeepTogether([Image(str(source), width=w*scale, height=h*scale, hAlign='LEFT'),
                             Spacer(1, 6), p(caption, 'SmallText'), Spacer(1, 8)])
    class ReportDocument(SimpleDocTemplate):
        def afterFlowable(self, flowable):
            key = getattr(flowable, 'report_bookmark', None)
            if key:
                self.canv.bookmarkPage(key)
                title = next(title for bookmark, title in bookmarks if bookmark == key)
                self.canv.addOutlineEntry(title, key, level=0, closed=False)
    def page(canvas, document):
        canvas.saveState()
        canvas.setStrokeColor(LINE)
        canvas.line(42, 754, 570, 754)
        canvas.setFillColor(BLUE)
        canvas.setFont('Helvetica-Bold', 8)
        canvas.drawString(42, 765, f'NITROS-9 / TEST EVIDENCE / RUN #{number}')
        canvas.setFillColor(MUTED)
        canvas.setFont('Helvetica', 8)
        canvas.drawString(42, 25, f'Commit {sha[:12]} | Recorded CI evidence; see scope limits')
        canvas.drawRightString(570, 25, f'Page {document.page}')
        canvas.restoreState()
    output.parent.mkdir(parents=True, exist_ok=True)
    document = ReportDocument(str(output), pagesize=letter, rightMargin=42, leftMargin=42,
        topMargin=55, bottomMargin=43, title=f'NitrOS-9 test evidence - run {number}', author='NitrOS-9 CI')
    story += [p('NITROS-9 / CI EVIDENCE', 'Eyebrow'), p(summary['verdict'], 'ReportTitle'),
              p('Screenshots and recorded assertions, with links to the original run and job logs.'),
              p(f'Run #{number} | Commit {sha}', 'SmallText'), href(url, 'Open the complete CI run and original artifacts')]
    counts = summary['counts']
    story += [table(['Jobs passed', 'Jobs failed', 'Jobs skipped', 'Screenshots retained'],
                    [[counts.get('success', 0), counts.get('failure', 0), counts.get('skipped', 0), summary['screenshots']]], [132]*4), Spacer(1, 14)]
    if summary['warnings']:
        story.append(p('Evidence warnings', 'SectionTitle'))
        story.extend(p('- ' + w) for w in summary['warnings'])
    rows = [(href(j.get('html_url') or j.get('url') or url, j['name'], 'CellText'), status(j)) for j in jobs]
    story.append(table(['Job', 'Recorded result'], rows, [402, 126]))
    story += [Spacer(1, 10), p('A passing job means its configured assertions passed. Screenshots support those checks; they do not replace byte comparisons, reference counts, protocol assertions or independent filesystem checks.', 'SmallText')]
    for job in jobs:
        if job['name'] == 'Prepare pinned MAME':
            continue
        story.append(PageBreak())
        heading(job['name'])
        story.append(p('Recorded result: ' + status(job)))
        job_url = job.get('html_url') or job.get('url') or url
        story.append(href(job_url, 'Open this job and its assertion logs'))
        if status(job) == 'skipped':
            story.append(p('Not executed in this run. This job provides no test evidence.'))
            continue
        name = job['name']
        if name.startswith('Filesystem integration ('):
            kind = name[len('Filesystem integration ('):-1]
            artifacts = ['filesystem-' + kind + '-results']
            kind = re.sub(r'-(?:l[12]-)?(?:6809|6309|coco2b|coco)$','',kind)
        elif name.startswith('Level One runtime ('):
            kind = 'level1'
            artifacts = ['level1-' + name[len('Level One runtime ('):-1] + '-results']
        elif name == 'Filesystem CPU regressions':
            kind, artifacts = 'cpu', ['filesystem-cpu-results']
        elif name == 'MAME smoke tests':
            kind, artifacts = 'smoke', ['mame-boot-results', 'game-boot-results']
        else:
            kind, artifacts = name, []
        entries = [entry for artifact in artifacts for entry in files_for(artifact)]
        if kind == 'Quick checks':
            story.append(p('Recipe parsing, Python regressions, representative system module assembly and CRCs, Corsham ROM checks, and resident-bundle size checks.'))
        elif kind == 'Full build':
            story.append(p('Build coverage includes CoCo 1/2 Level 1, CoCo 3 Level 2 on both CPUs, Pico-Thing variants, Corsham ROM and selected game images. This is compilation/image-build evidence, not proof that every platform boots.'))
        elif kind == 'cpu':
            story.append(p('Assembled filesystem routines execute on an MC6809 emulator. Cases include injected I/O failures, boundary conditions and retries. Seeded Level 1/2 operations are compared with host-side contents and checked by an independent FAT checker.'))
        elif kind == 'level1':
            story.append(p('Level One boots on the named CoCo machine and checks directory creation, 513-byte data, a sector-boundary seek, relative reopen, EOF and deletion. The host independently verifies the resulting file.'))
        elif kind == 'module-groups':
            story.append(p('Two distinct modules share single-block, multi-block or resident groups. Both unlink orders are exercised. The guest calls the survivor after the valid unlink and the extra unlink; the host checks counts, mappings and physical storage.'))
        elif kind == 'rbf':
            story.append(p('Recursive deletion and cancellation, regular-file deletion, preservation of an unrelated file, and independent allocation checks. The reserved 18-sector kernel track is expected; the runner compares allocations with the pristine disk to detect new leaks.'))
        elif kind in ('rfm', 'rfm-irq'):
            story.append(p('Guest RFM requests go through a local DriveWire fixture, with protocol, content, directory and host-filesystem assertions.' + (' This variant forces DWIO interrupt polling during directory I/O.' if kind == 'rfm-irq' else '')))
        elif kind.startswith('pcf'):
            descriptions = {
                'pcf-write': 'Writes, rename/removal/sharing rejection cases, independent host content checks, seeded operations, fsck.fat and persistence across a fresh boot.',
                'pcf-readonly': 'Boot/load from FAT32, compare contents and directory metadata, and verify the FAT image remains unchanged.',
                'pcf-floppy': 'Boot from RBF floppy, read FAT files through PCF, compare fragmented copies and directory metadata, and check no FAT writes.',
                'pcf-boot': 'Load OS9Boot from FAT32 with floppy OS9Boot deleted and its boot pointer cleared, then verify content, directory output and no FAT writes.',
            }
            story.append(p(descriptions.get(kind, 'See job logs for configured checks.')))
        elif kind == 'smoke':
            story.append(p('OS-9 boot checks and the selected game run on both 6809 and 6309. Guest-written markers and runner assertions establish completion. Only the selected game is boot-tested.'))
        if kind == 'module-groups':
            result = next((e for e in entries if e['path'].endswith('/result.json')), None)
            if result:
                data = json.loads((report / result['report_path']).read_text())
                rows = []
                for case in data.get('cases', []):
                    states = case.get('states', [])
                    slot = next((i for i, value in enumerate(states[0]['links']) if value == 2), None) if states else None
                    if slot is not None:
                        rows.append([case['kind'], case['unlink_order'], ' -> '.join(str(s['links'][slot]) for s in states),
                                     ' -> '.join(f'{s["dat"][slot]:04X}' for s in states)])
                story.append(table(['Group', 'Order', 'P$Links', 'DAT entry (hex)'], rows, [88, 48, 144, 248]))
                story.append(p('Stages: both linked, first unlink, extra unlink, final unlink. DAT value 333E means an unmapped slot.', 'SmallText'))
                if data.get('multiprocess'):
                    story.append(p('Two-process ownership: both release orders passed. The survivor executes after the parent releases its mapping and attempts stale unlinks, including while the child holds a new reference to that module.'))
                    story.append(table(['Case', 'Parent PID', 'Child PID', 'Child references'], [[c['case'], c['parent'][1]['pid'], c['child'][0]['pid'], '1 -> 1 -> 2 -> 1 -> 0'] for c in data['multiprocess']], [60,100,100,268]))
                if data.get('resources'):
                    resource=data['resources']
                    story.append(p(str(resource['cycles'])+' balanced cycles after 10 warmups. Every checkpoint must preserve all four resource counts, the process DAT, mapping references and path slots. Tasks include a constant temporary observation task.'))
                    story.append(table(['Cycle', 'Free 8K blocks', 'Processes', 'Tasks', 'Paths'], [[v['sequence'],v['metrics']['free_blocks'],v['metrics']['processes'],v['metrics']['tasks'],v['metrics']['paths']] for v in resource['checkpoints']], [80,148,100,100,100]))
        elif kind == 'cpu':
            aggregate = next((e for e in entries if e['path'].endswith('/random/result.json')), None)
            if aggregate:
                records = json.loads((report / aggregate['report_path']).read_text())
                story.append(table(['OS level', 'Seed', 'Operations', 'Passed', 'FAT checked'],
                    [[d.get('level'), d['seed'], d['operations'], d.get('passed'), d.get('fat_integrity_checked')] for d in records], [70, 128, 100, 100, 130]))
                story.append(p(f'{sum(d["operations"] for d in records)} recorded operations across {len(records)} level/seed combinations.'))
            tests = [Path(e['path']).name for e in entries if Path(e['path']).name.startswith('test-') and e['path'].endswith('.log')]
            story.append(p('Saved deterministic test logs: ' + ', '.join(sorted(tests)), 'SmallText'))
        else:
            results = []
            for entry in entries:
                if not entry['path'].endswith('/result.json') or '/l1-s' in entry['path'] or '/l2-s' in entry['path']:
                    continue
                data = json.loads((report / entry['report_path']).read_text())
                if not isinstance(data, dict):
                    continue
                selected = [(key.replace('_', ' '), data[key]) for key in (
                    'passed', 'reopen', 'fat_integrity_checked', 'rbf_integrity_checked',
                    'unrelated_file_preserved', 'random_seed', 'random_operations',
                    'parent_child_rename_checks', 'parent_child_rmdir_checks', 'parent_child_sharing_checks') if key in data]
                if selected:
                    results.append((entry, selected))
            # Keep the PDF concise; the HTML includes every result and full logs.
            for entry, selected in sorted(results, key=lambda item: '/reopen/' in item[0]['path'])[:2]:
                story.append(p('Cold-boot persistence result' if '/reopen/' in entry['path'] else 'Recorded assertions', 'SmallText'))
                story.append(table(['Field', 'Recorded value'], selected, [275, 253]))
        images = [entry for entry in entries if Path(entry['path']).name == 'screen.png']
        if kind == 'smoke':
            images = [entry for entry in images if entry['artifact'] == 'mame-boot-results']
            images += [entry for entry in entries if Path(entry['path']).name == 'game.png']
        else:
            images.sort(key=lambda entry: '/reopen/' in entry['path'])
        if kind == 'smoke':
            for i, entry in enumerate(images[:4]):
                if i and i % 2 == 0:
                    story.append(PageBreak())
                    heading('MAME smoke screenshots, continued')
                label = ('OS-9 boot' if entry['artifact'] == 'mame-boot-results' else 'Selected game')
                cpu = next((part for part in Path(entry['path']).parts if part in ('6809', '6309')), '')
                story.append(image(entry, f'{label} / {cpu} / captured guest screen'))
        else:
            if kind == 'pcf-write' and images:
                story.append(PageBreak())
                heading('PCF write and persistence screenshots')
            for entry in images[:2]:
                label = 'Cold-boot persistence screenshot' if '/reopen/' in entry['path'] else 'Captured guest screen'
                story.append(image(entry, label + '. Visual evidence supplements the runner assertions.'))
        if not entries and artifacts:
            story.append(p('No bundled artifact evidence is available for this job. Inspect its linked logs before drawing conclusions.'))
        if not artifacts:
            steps = [step for step in job.get('steps', []) if step.get('conclusion')]
            story.append(table(['Job step', 'Result'], [[step['name'], step['conclusion']] for step in steps], [402, 126]))
    story.append(PageBreak())
    heading('What this evidence does not establish')
    for line in [
        'Complete-machine runtime coverage primarily exercises CoCo 3 Level Two. Builds for other machines do not prove hardware behavior or boot success.',
        'CPU-qualified integration job names identify 6809 and native 6309 runs. Older runs may contain only 6809 integration.',
        'Only the selected game is boot-tested. Building other games is not gameplay coverage.',
        'Finite cases and recorded seeds do not prove correctness for every concurrent schedule, media failure, hardware variant or power-loss condition.',
        'Controlled two-process cases exercise stale unlinks while another process holds the group. They do not establish ownership tracking of individual modules or every possible interleaving.',
        'Screenshots show one moment. Use recorded byte/hash comparisons, counters, protocol assertions and independent filesystem checkers to assess correctness.',
        'Earlier negative controls are documented separately; they are not counted as tests rerun here.',
    ]:
        story.append(p('- ' + line))
    heading('Inspect or reproduce the result')
    story.append(href(url, 'Open the original run, assertion logs and downloadable artifacts'))
    story.append(p('The HTML report includes expandable logs, detailed JSON and an evidence inventory with SHA-256 hashes. Full disk images and files over 2 MB stay in the original test artifacts. Download the HTML evidence bundle to inspect the raw files offline. Artifact availability follows GitHub retention.'))
    document.build(story, onFirstPage=page, onLaterPages=page)
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--report', type=Path, required=True)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    print(render(args.report, args.output or args.report / 'test-report.pdf'))


if __name__ == '__main__':
    main()
