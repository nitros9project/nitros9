#!/usr/bin/env python3
"""Build a single EmuDsk game library from the shared game recipe manifests."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

INSTALLER = Path(__file__).with_name('install-game.py')


def run(*args, **kwargs):
    return subprocess.run(list(map(str, args)), check=True, **kwargs)


GAME_TITLES = {
    'adventure': 'Adventure', 'arcadepak': 'Arcade Pak',
    'blackcauldron': 'The Black Cauldron', 'christmas86': 'Christmas 1986',
    'cocothello': 'Cocothello', 'flightsim2': 'Flight Simulator II',
    'goldrush': 'Gold Rush!', 'hordes': 'Hordes & Holes', 'kalah': 'Kalah',
    'kingsquest1': "King's Quest I", 'kingsquest2': "King's Quest II",
    'kingsquest3': "King's Quest III", 'kingsquest4': "King's Quest IV",
    'koronis': 'Koronis Rift', 'kyumgai': 'Kyum-Gai: To Be Ninja',
    'leisuresuitlarry': 'Leisure Suit Larry', 'manhunter1': 'Manhunter: New York',
    'manhunter2': 'Manhunter 2: San Francisco', 'mmission': 'Microscopic Mission',
    'pacos9': 'Pac-OS9', 'policequest1': 'Police Quest',
    'rescueof': 'Rescue on Fractalus!', 'reversi': 'Reversi', 'rogue': 'Rogue',
    'sokoban': 'Sokoban', 'solitaire': 'Pyramid Solitaire',
    'spacequest0': 'Space Quest 0', 'spacequest1': 'Space Quest I',
    'spacequest2': 'Space Quest II', 'subsim': 'Sub Battle Simulator', 'walk': 'Walk',
}


def game_title(game):
    return GAME_TITLES[game['game']]


def game_directory(game):
    name = re.sub(r'[^A-Z0-9]', '', game_title(game).upper())
    if not 1 <= len(name) <= 29:
        raise SystemExit(f'Invalid OS-9 directory name: {name}')
    return 'GAMES/' + name


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
        cells = [f'{i+1:2d}. {game_title(games[i]):<34}' for i in range(index, min(index+2, len(games)))]
        text += ''.join(cells) + '\r'
    text += '\rSelection: '
    raw = list(text.replace('\r', '\r\n').encode('ascii'))
    lines = ['        fcb ' + ','.join(f'${b:02x}' for b in raw[i:i+16]) for i in range(0, len(raw), 16)]
    labels = '\n'.join(f'path{i} fcc "/DD/{game_directory(g)}/launch"\n        fcb 13' for i, g in enumerate(games))
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
            prefix = game_directory(game)
            run('python3', INSTALLER, '--disk', args.disk, '--source', temporary,
                '--prefix', prefix, '--existing-dir', prefix, '--existing-dir', prefix + '/CMDS',
                '--sys-exists', '--toc', toc)


def copy_script(disk, temporary, text, path):
    directory, name = path.rsplit('/', 1)
    host = temporary / name
    host.write_bytes(text.replace('\n', '\r').encode('ascii'))
    run('python3', INSTALLER, '--disk', disk, '--source', temporary, '--root', name,
        '--data-dir', directory, '--existing-dir', directory, '--sys-exists')
    run('os9', 'attr', '-ne', '-npe', '-r', '-pr', f'{disk},{path}')


def game_scripts(game):
    prefix = game_directory(game)
    device = {32: 'G40', 40: 'G40', 80: 'TERM'}[game['cols']]
    if game['game'] in ('rogue', 'mmission'):
        command = 'rogue' if game['game'] == 'rogue' else 'mm'
        body = f'link shell\n{command} <>>>/{device}\n'
    elif game['game'] == 'subsim':
        body = f'link shell\nsub <>>>/{device}\n'
    elif game['startup']:
        body = Path(game['startup']).read_text().replace('<>>>/term', f'<>>>/{device}').replace('</term', f'</{device}').replace('</1', f'</{device}').replace('load utilpak1', 'load /DD/CMDS/utilpak1')
        body = body.replace('/dd/sys/', '/DD/SYS/')
    else:
        body = game['command'] + f' </{device}\n'
    if game['game'] == 'arcadepak':
        body += f'shell </{device}\n'
    play = f'chd /DD/{prefix}\nchx /DD/{prefix}/CMDS\ndisplay 1b21\n' + body
    launch = f'shell -p </DD/{prefix}/play >/{device} >>/{device}\n'
    return play, launch


def migrate_layout(args):
    games = json.loads(args.manifest.read_text())
    moves = [{'source': 'GAMES/' + game['game'], 'destination': game_directory(game)}
             for game in games]
    adventure = next((g for g in games if g['game'] == 'adventure'), None)
    if adventure:
        moves.append({'source': 'GAMES/ADVENT', 'destination': game_directory(adventure),
                      'baseline': {Path(name).name.casefold(): str(Path(adventure['source']) / name)
                                   for name in adventure['root']}})
    for legacy, selector in [('ROGUE', 'rogue'), ('SUB', 'subsim')]:
        game = next((g for g in games if g['game'] == selector), None)
        if game:
            baseline = {Path(name).name.casefold(): str(Path(game['source']) / name)
                        for name in game['root'] + game['data_programs']}
            moves.append({'source': legacy, 'destination': game_directory(game), 'baseline': baseline})
    # Compile the path fixes before touching an existing image. Publishing the
    # matching games sources is required; an old checkout fails safely here.
    updates = {'rogue': ['rogue'], 'subsim': ['sub', 'sub1', 'sub2', 'sub5'],
               'adventure': ['build/adventure'], 'mmission': ['mm']}
    programs = []
    nitros9 = Path(__file__).resolve().parents[1]
    c3root = Path(os.environ.get('LANGUAGES', nitros9.parent / 'nitros9-languages')) / 'c3'
    for game in games:
        selector = game['game']
        if selector not in updates:
            continue
        source = Path(game['source'])
        if selector == 'adventure':
            run('make', '-C', c3root, 'runtime')
        run('make', '-C', source, f'NITROS9DIR={nitros9}', f'C3ROOT={c3root}',
            'PORT=coco3', *updates[selector])
        for name in updates[selector]:
            host = source / name
            data = host.read_bytes()
            obsolete = (selector == 'rogue' and b'...../rogue' in data.lower()
                        or selector == 'subsim' and b'sub/' in data.lower()
                        or selector == 'adventure' and b'/DD/GAMES/ADVENT\0' in data.upper()
                        or selector == 'mmission' and data[0x21:0x23] != b'\x86\x01')
            if obsolete:
                raise SystemExit(f'Update the games checkout before migrating: {host}')
            programs.append({'source': str(host),
                             'destination': game_directory(game) + '/CMDS/' + host.name})
    run('python3', Path(__file__).with_name('game-layout.py'), '--disk', args.disk,
        '--moves', json.dumps(moves), '--install', json.dumps(programs))


def refresh_launchers(args):
    games = json.loads(args.manifest.read_text())
    with tempfile.TemporaryDirectory() as folder:
        temporary = Path(folder)
        for game in games:
            play, launch = game_scripts(game)
            for name, body in [('play', play), ('launch', launch)]:
                copy_script(args.disk, temporary, body, game_directory(game) + '/' + name)


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

        for game in games:
            name, source = game['game'], Path(game['source'])
            prefix = game_directory(game)
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
            if game['data_dir'] != '.' and game['data_dir'].upper() != prefix:
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
            play, launch = game_scripts(game)
            copy_script(disk, temp, play, prefix + '/play')
            copy_script(disk, temp, launch, prefix + '/launch')
        copy_script(disk, temp, ''.join(f'echo "{i+1}. {game_title(game)}"\n'
                                      for i, game in enumerate(games)), 'CMDS/catalog')
    print(f'Installed {len(games)} games in {disk}')


def check(args):
    games = json.loads(args.manifest.read_text())
    chosen = next((i for i, g in enumerate(games) if g['game'] == args.game), None)
    if chosen is None:
        raise SystemExit(f'VHD_TEST_GAME={args.game} is not installed in this collection')
    game = games[chosen]
    base = args.manifest.resolve().parent
    visual = ['--min-screen-change', '0.2', '--require-animation'] if args.game == 'walk' else []
    if args.game == 'mmission':
        visual += ['--replay', str(Path(__file__).with_name('mmission-replay.lua')),
                   '--min-frames', '7200', '--seconds', '140', '--min-screen-colors', '4']
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
    p = actions.add_parser('migrate-layout')
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
