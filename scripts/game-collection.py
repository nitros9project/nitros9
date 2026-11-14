#!/usr/bin/env python3
"""Build a single EmuDsk game library from the shared game recipe manifests."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import tempfile

INSTALLER = Path(__file__).with_name('install-game.py')


def run(*args, **kwargs):
    return subprocess.run(list(map(str, args)), check=True, **kwargs)


def available(args):
    games = []
    for config in sorted((args.recipe / 'configs').glob('*.mak')):
        source = re.search(r'^GAME_SOURCE\s*=\s*(\S+)', config.read_text(), re.MULTILINE)
        if source and (args.source / source[1] / 'Makefile').is_file():
            games.append(config.stem)
    print(' '.join(games))


def manifest(args):
    record = vars(args).copy()
    record.pop('action')
    record.pop('output')
    record['source'] = str(args.source.resolve())
    record['startup'] = str(args.startup.resolve()) if args.startup else ''
    record['root'] = list(dict.fromkeys(record['root']))
    record['revisions'] = Path('revisions.txt').read_text()
    args.output.write_text(json.dumps(record, indent=2) + '\n')


def menu_source(games):
    # The menu forks the normal OS-9 shell to run each game's launch script.
    # Games own their current directory and terminal; the menu remains on /TERM.
    text = '\x0cNitrOS-9 Games - select a number (0 exits)\r\r'
    for index in range(0, len(games), 2):
        cells = [f'{i+1:2d}. {games[i]["game"]:<24}' for i in range(index, min(index+2, len(games)))]
        text += ''.join(cells) + '\r'
    text += '\rSelection: '
    raw = list(text.replace('\r', '\r\n').encode('ascii'))
    lines = ['        fcb ' + ','.join(f'${b:02x}' for b in raw[i:i+16]) for i in range(0, len(raw), 16)]
    labels = '\n'.join(f'path{i} fcc "/dd/GAMES/{g["game"]}/launch"\n        fcb 13' for i, g in enumerate(games))
    table = '\n'.join(f'        fdb path{i}-paths,dev{game["cols"]}-paths' for i, game in enumerate(games))
    return f'''GameCount equ {len(games)}
menu
{chr(10).join(lines)}
menuend equ *
paths
{table}
{labels}
dev32   fcc "/g40"
        fcb 13
dev40   fcc "/g40"
        fcb 13
dev80   fcc "/term"
        fcb 13'''


def prepare(args):
    supported = subprocess.check_output(['make', '-s', '-C', str(args.recipe), 'list'], text=True).split()
    if not args.games or len(set(args.games)) != len(args.games) or any(g not in supported for g in args.games):
        raise SystemExit('GAMES must be a nonempty list of distinct supported game names')
    records = []
    for game in args.games:
        run('make', '-C', args.recipe, f'GAME={game}', f'CPU={args.cpu}', 'TRANSPORT=floppy', 'payload')
        path = args.recipe / '.build' / game / args.cpu / 'floppy/manifest.json'
        records.append(json.loads(path.read_text()))
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / 'collection.json').write_text(json.dumps(records, indent=2) + '\n')
    (args.output / 'menu-data.asm').write_text(menu_source(records))
    (args.output / 'revisions.txt').write_text(''.join(g['game'] + '\n' + g['revisions'] + '\n' for g in records))
    (args.output / 'startup.collection').write_text('link shell\nload utilpak1\ngames </term\n')


def descriptor(args):
    text = args.source.read_text().replace('A.TermW', f'A.W{args.number}')
    text = re.sub(r'(wnum\s+set\s+)0\b', rf'\g<1>{args.number}', text)
    text = text.replace('/Term/', f'/{args.name}/')
    args.output.write_text(text)


def menu(args):
    args.output.write_text(menu_source(json.loads(args.manifest.read_text())))


def sierra_toc(game):
    # FindVol indexes this table by volume number (volume N uses entry N).
    # ReadDiskVol eagerly opens every volume in an entry. Keep each group
    # small so large games leave room for stdio, VIRQ and temporary files.
    volumes = {int(Path(p).suffix[1:]) for p in game['root'] if Path(p).name.startswith('vol.')}
    if 0 not in volumes or max(volumes) > 15:
        raise SystemExit(f'Invalid Sierra volume set for {game["game"]}')
    return ''.join('d1 s1 v0' + (f' v{v}' if v in volumes else '') + '\n'
                   for v in range(1, max(1, max(volumes)) + 1))


def refresh_sierra_tocs(args):
    games = json.loads(args.manifest.read_text())
    with tempfile.TemporaryDirectory() as temporary:
        temporary = Path(temporary)
        for game in games:
            if not game['sierra']:
                continue
            toc = temporary / 'tOC.txt'
            toc.write_text(sierra_toc(game))
            prefix = f'GAMES/{game["game"]}'
            run('python3', INSTALLER, '--disk', args.disk, '--source', temporary,
                '--prefix', prefix, '--existing-dir', prefix, '--existing-dir', prefix + '/CMDS',
                '--sys-exists', '--toc', toc)


def refresh_launchers(args):
    # Repair terminal redirects without reinstalling game assets or saved data.
    games = json.loads(args.manifest.read_text())
    with tempfile.TemporaryDirectory() as temporary:
        temporary = Path(temporary)
        for game in games:
            if game['cols'] != 32 and game['game'] != 'rogue':
                continue
            directory = f'GAMES/{game["game"]}'
            for name in ('play', 'launch'):
                host = temporary / name
                if host.exists():
                    host.unlink()
                run('os9', 'copy', f'{args.disk},{directory}/{name}', host)
                original = host.read_bytes()
                updated = re.sub(rb'/v1(?=\s|$)', b'/g40', original, flags=re.IGNORECASE)
                if game['game'] == 'rogue' and name == 'play':
                    updated = re.sub(rb'(\brogue[ \t]+)</g40(?=\s|$)',
                                     rb'\1<>>>/g40', updated, flags=re.IGNORECASE)
                if game['game'] == 'subsim' and name == 'play':
                    updated = re.sub(rb'\bpresub[ \t]+</g40(?=\s|$)',
                                     b'chd /dd\rsub <>>>/g40', updated, flags=re.IGNORECASE)
                if updated != original:
                    host.write_bytes(updated)
                    run('python3', INSTALLER, '--disk', args.disk, '--source', temporary,
                        '--root', name, '--data-dir', directory, '--existing-dir', directory)


def link_boot(args):
    """Link OS9Boot using LSN0's normal or segmented boot convention."""
    expected = args.bootfile.read_bytes()
    if not expected or len(expected) > 65535:
        raise SystemExit('Bootfile must contain between 1 and 65535 bytes')

    def locate():
        # Offsets are DD.DIR, FD.SIZ, FD.SEG and DIR.FD from defs/rbf.d.
        with args.disk.open('rb') as image:
            def sector(lsn):
                image.seek(lsn * 256)
                data = image.read(256)
                if len(data) != 256:
                    raise SystemExit('Boot descriptor points outside the image')
                return data

            def contents(fd):
                size = int.from_bytes(fd[9:13], 'big')
                segments, data = [], bytearray()
                for offset in range(16, 256, 5):
                    lsn = int.from_bytes(fd[offset:offset+3], 'big')
                    count = int.from_bytes(fd[offset+3:offset+5], 'big')
                    if not count:
                        break
                    segments.append((lsn, count))
                    image.seek(lsn * 256)
                    data.extend(image.read(count * 256))
                if len(data) < size:
                    raise SystemExit('Incomplete file segment list')
                return segments, bytes(data[:size])

            header = sector(0)
            root = sector(int.from_bytes(header[8:11], 'big'))
            _, directory = contents(root)
            for offset in range(0, len(directory), 32):
                entry = directory[offset:offset+32]
                if len(entry) != 32 or not entry[0]:
                    continue
                name = ''
                for char in entry[:29]:
                    name += chr(char & 127)
                    if char & 128:
                        break
                if name.lower() == 'os9boot':
                    fd_lsn = int.from_bytes(entry[29:32], 'big')
                    segments, data = contents(sector(fd_lsn))
                    return fd_lsn, segments, data
            return None

    current = locate()
    if current is None or current[2] != expected:
        with tempfile.TemporaryDirectory() as temporary:
            source = Path(temporary)
            (source / 'OS9Boot').write_bytes(expected)
            run('python3', INSTALLER, '--disk', args.disk, '--source', source, '--root', 'OS9Boot')
        current = locate()
    if current is None or current[2] != expected:
        raise SystemExit('OS9Boot verification failed; boot link was not changed')
    fd_lsn, segments, _ = current
    # DD.BSZ=0 tells boot_common.asm to read the FD and follow its segment list.
    pointer, size = (segments[0][0], len(expected)) if len(segments) == 1 else (fd_lsn, 0)
    with args.disk.open('r+b') as image:
        image.seek(0x15)  # DD.BT (3 bytes), followed by DD.BSZ (2 bytes).
        image.write(pointer.to_bytes(3, 'big') + size.to_bytes(2, 'big'))
    print(f'OS9Boot linked: {len(segments)} segment(s), ' + ('segmented boot' if size == 0 else 'contiguous boot'))


def install(args):
    games = json.loads(args.manifest.read_text())
    disk = args.disk.resolve()
    run('os9', 'makdir', f'{disk},GAMES')
    global_sys = {}
    with tempfile.TemporaryDirectory() as temp:
        temp = Path(temp)
        def copy_script(text, path):
            directory, name = path.rsplit('/', 1)
            named = temp / name
            named.write_bytes(text.replace('\n', '\r').encode('ascii'))
            run('python3', INSTALLER, '--disk', disk, '--source', temp, '--root', name,
                '--data-dir', directory, '--existing-dir', directory, '--sys-exists')
            run('os9', 'attr', '-ne', '-npe', '-r', '-pr', f'{disk},{path}')

        for game in games:
            name, source = game['game'], Path(game['source'])
            prefix = f'GAMES/{name}'
            command = ['python3', str(INSTALLER), '--disk', str(disk), '--source', str(source),
                       '--prefix', prefix, '--sys-exists', '--existing-dir', 'GAMES',
                       '--programs', *game['programs'], '--root', *game['root'],
                       '--sys', *game['sys'], '--screens', *game['screens'],
                       '--data-programs', *game['data_programs']]
            if game['sierra']:
                toc = temp / 'tOC.txt'
                toc.write_text(sierra_toc(game))
                command += ['--toc', str(toc)]
            run(*command)
            # Preserve absolute data paths used by the original games.
            if game['data_dir'] != '.':
                run('python3', INSTALLER, '--disk', disk, '--source', source, '--existing-dir', 'GAMES',
                    '--data-dir', game['data_dir'], '--root', *game['root'], '--data-programs', *game['data_programs'])
            for file in game['sys']:
                basename = Path(file).name
                payload = (source / file).read_bytes()
                if basename in global_sys and global_sys[basename] != payload:
                    raise SystemExit(f'Conflicting shared SYS file: {basename}')
                if basename not in global_sys:
                    run('python3', INSTALLER, '--disk', disk, '--source', source,
                        '--sys-exists', '--sys', file)
                    global_sys[basename] = payload
            device = {32: 'g40', 40: 'g40', 80: 'term'}[game['cols']]
            if game['startup']:
                body = Path(game['startup']).read_text().replace('<>>>/term', f'<>>>/{device}').replace('</term', f'</{device}').replace('</1', f'</{device}').replace('load utilpak1', 'load /dd/cmds/utilpak1')
            else:
                body = game['command'] + f' </{device}\n'
            if name == 'arcadepak':
                body += f'shell </{device}\n'
            copy_script(f'chd /dd/{prefix}\nchx /dd/{prefix}/CMDS\ndisplay 1b21\n' + body,
                        f'{prefix}/play')
            copy_script(f'shell -p </dd/{prefix}/play >/{device} >>/{device}\n', f'{prefix}/launch')
        copy_script(''.join(f'echo {i+1}. {game["game"]}\n' for i, game in enumerate(games)), 'CMDS/catalog')
    print(f'Installed {len(games)} games in {disk}')


def check(args):
    games = json.loads(args.manifest.read_text())
    chosen = next((i for i, g in enumerate(games) if g['game'] == args.game), None)
    if chosen is None:
        raise SystemExit(f'VHD_TEST_GAME={args.game} is not installed in this collection')
    game = games[chosen]
    base = args.manifest.resolve().parent
    visual = ['--min-screen-change', '0.2', '--require-animation'] if args.game == 'walk' else []
    if args.game == 'subsim':
        visual += ['--min-screen-colors', '3']
    if args.game in ('koronis', 'kingsquest3'):
        visual += ['--min-screen-colors', '8']
    if args.game == 'rogue':
        visual += ['--replay', str(Path(__file__).with_name('rogue-replay.lua')),
                   '--min-frames', '7200', '--seconds', '140']
    if args.game == 'koronis':
        visual += ['--replay', str(Path(__file__).with_name('koronis-replay.lua')),
                   '--min-frames', '10800', '--seconds', '200']
    if game['sierra']:
        visual += ['--scan-mapped-modules', '--error-byte', '0x9f', '--replay',
                   str(Path(__file__).with_name('sierra-replay.lua')),
                   '--min-frames', '7200', '--seconds', '140']
    program = 'mnln' if game['sierra'] else game['programs'][0]
    run('python3', Path(__file__).with_name('game-mame-smoke.py'),
        '--disk', base / 'games-boot.dsk', '--hard1', base / 'games.vhd',
        '--cpu', args.cpu, '--game', 'vhd-' + args.game,
        '--program', Path(game['source']) / program,
        '--command', str(chosen+1), '--mame', args.mame, '--rompath', args.rompath,
        '--ram', args.ram, '--output', base / 'verification', *visual)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    actions = parser.add_subparsers(dest='action', required=True)
    p = actions.add_parser('available')
    p.add_argument('--recipe', type=Path, required=True)
    p.add_argument('--source', type=Path, required=True)
    p = actions.add_parser('manifest')
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--game', required=True)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--cols', type=int, required=True)
    p.add_argument('--data-dir', default='.')
    p.add_argument('--startup', type=Path)
    p.add_argument('--command', default='')
    p.add_argument('--sierra', action='store_true')
    for field in ('programs', 'root', 'sys', 'screens', 'data-programs'):
        p.add_argument('--' + field, nargs='*', default=[])
    p = actions.add_parser('prepare')
    p.add_argument('--recipe', type=Path, required=True)
    p.add_argument('--cpu', required=True)
    p.add_argument('--games', nargs='+', required=True)
    p.add_argument('--output', type=Path, required=True)
    p = actions.add_parser('descriptor')
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--number', type=int, required=True)
    p.add_argument('--name', required=True)
    p = actions.add_parser('menu')
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p = actions.add_parser('refresh-sierra-tocs')
    p.add_argument('--disk', type=Path, required=True)
    p.add_argument('--manifest', type=Path, required=True)
    p = actions.add_parser('refresh-launchers')
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--disk', type=Path, required=True)
    p = actions.add_parser('link-boot')
    p.add_argument('--disk', type=Path, required=True)
    p.add_argument('--bootfile', type=Path, required=True)
    p = actions.add_parser('install')
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--disk', type=Path, required=True)
    p = actions.add_parser('check')
    p.add_argument('--manifest', type=Path, required=True)
    p.add_argument('--cpu', required=True)
    p.add_argument('--game', required=True)
    p.add_argument('--mame', required=True)
    p.add_argument('--rompath', required=True)
    p.add_argument('--ram', default='2048K')
    args = parser.parse_args()
    globals()[args.action.replace('-', '_')](args)


if __name__ == '__main__':
    main()
