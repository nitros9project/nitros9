"""check_menus.py - build-time guard for every s9 condensed menu (menu3 / s9gui ctxma).

2026-10-08 (user: "in s9 you've repeatedly mashed up menus and caused them to scroll or crash the system, how do
we make sure it stops happening"). Run by `make verify` after the modules are built:

    check_menus.py "<lwasm command and flags>" <module dir>

Each descriptor (`descXxx fcb col, y, width, rows` in cmds/*.asm) is read from the ASSEMBLED module - the address
from lwasm's symbol dump, the bytes from .mods/CMDS - so every equate is already resolved. Checked:
  * the rows: as many rows as the header says (a short list makes ctxma read the NEXT output as rows - the junk
    and the scroll), a known kind on each, one key letter each;
  * the width: every row's text fits (ctxma drops what does not fit: a cut label);
  * the window: it fits on the screen as placed (winrest would move it, and the pointer rows would not follow);
  * the states (the menus listed in STATES): the caller's sprintf formats give every checkbox / radio row its
    character and every field row its CR-terminated text, inside MenuStates' 40 bytes at the worst case;
  * the keys (the menus listed in DISPATCH): every key letter has a case in the caller's dispatch chain;
  * pickers that must sit on their window (PICKERS): the same column and y expressions.
Any failure stops the build.
"""
import os, re, subprocess, sys, tempfile

CMDS = 'cmds'
TEXT_LINE_H = 7          # equates TextLineH
SCREEN_TOP = 191
MENUSTATES = 40          # equates MenuStates: 40 bytes
KINDS = {ord(' '), ord('b'), ord('r'), ord('q'), ord('f')}

# descriptor -> the formats the caller sprintf's into MenuStates before menu3: (module, symbol, MenuStates offset)
STATES = {
    'descMidiModes': [('s9m', 'fmtThreeFlags', 0), ('s9m', 'fmtSettingsVals', 3)],
    'descMidiDevices': [('s9r', 'fmtDmFlags', 0)],   # 2026-10-09: split from MIDI Modes
    'descOpts':      [('s9', 'fmtElevenInts', 0)],
}
# descriptor -> (source file, the label that starts the key dispatch chain)
DISPATCH = {
    'descMidiModes': ('s9m.asm', 'SettingsDispatch'),
    'descMidiDevices': ('s9r.asm', 'DevicesMenu'),
    'descOpts':      ('s9.asm', 'at78@'),
}
# a key string (not a descriptor) and its dispatch: (source, key-table label, keys to skip at the front, dispatch)
KEYTABLES = [
    ('s9m.asm', 'tblMidiPickKeys', 18, 'MidiCmdDispatch'),   # 16 part keys and the two blank cells first
]
# (window record source, its line pattern, picker source, picker label): the column and y expressions must agree
PICKERS = [
    ('s9gui.asm', r'menu 8 \(MIDI Levels', 's9m.asm', 'VolLevelsPick'),
    ('s9gui.asm', r'menu 6 \(Inst', 's9m.asm', 'InstrPickLoop'),
]

errors = []


def err(msg):
    errors.append(msg)


def symbols(asm_cmd, module, tmp):
    """Assemble cmds/<module>.asm with a symbol dump; return ({symbol: value}, module bytes)."""
    sym = os.path.join(tmp, module + '.sym')
    out = os.path.join(tmp, module + '.bin')
    cmd = asm_cmd + ['-I' + CMDS, '--symbol-dump=' + sym, os.path.join(CMDS, module + '.asm'), '-o' + out]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        sys.exit('check_menus: assembling %s for its symbols failed:\n%s' % (module, r.stdout + r.stderr))
    table = {}
    for line in open(sym):
        m = re.match(r'(\S+)\s+EQU\s+\$([0-9A-Fa-f]+)', line)
        if m:
            table[m.group(1)] = int(m.group(2), 16)
    return table, open(out, 'rb').read()


def cstring(data, at):
    end = data.index(0, at)
    return data[at:end], end + 1


def read_descriptor(data, at, name):
    col, y, width, rows = data[at:at + 4]
    keys = data[at + 4:at + 4 + rows]
    p = at + 4 + rows
    items = []
    while data[p]:
        kind = data[p]
        label, p = cstring(data, p + 1)
        items.append((kind, label))
        if len(items) > 64:
            err('%s: no end to its rows (no zero kind)' % name)
            break
    return col, y, width, rows, keys, items


def render(fmt):
    """A printf format -> (layout text with each conversion at its nominal width, worst-case length)."""
    out, worst, i = [], 0, 0
    while i < len(fmt):
        c = fmt[i]
        if c == ord('%'):
            m = re.match(rb'%(\d*)([dcs%])', fmt[i:])
            if not m:
                err('format %r: a conversion this checker does not know' % fmt)
                return b'', 0
            n = int(m.group(1) or 0)
            conv = m.group(2)
            if conv == b'd':
                text = b'0' * max(n, 1)
                worst += max(n, 4) if n else 1        # a %Nd field may carry '-127'; a bare %d is a 0/1 flag
            elif conv == b'c':
                text, worst = b'0', worst + 1
            elif conv == b'%':
                text, worst = b'%', worst + 1
            else:
                err('format %r: %%s in a states format - its length cannot be checked' % fmt)
                return b'', 0
            out.append(text)
            i += len(m.group(0))
        else:
            out.append(bytes([c]))
            worst += 1
            i += 1
    return b''.join(out), worst


def check_states(name, items, fmts):
    buf = bytearray(MENUSTATES + 64)
    worst_end = 0
    for (data, at, off) in fmts:
        fmt, _ = cstring(data, at)
        text, worst = render(fmt)
        buf[off:off + len(text) + 1] = text + b'\0'
        worst_end = max(worst_end, off + worst + 1)
    if worst_end > MENUSTATES:
        err('%s: its states need %d bytes at the worst case - MenuStates holds %d' % (name, worst_end, MENUSTATES))
    cur = 0
    for kind, label in items:
        k = chr(kind)
        if k in 'br':
            if buf[cur] in (0, 13):
                err('%s: the row %r has no state character (the states run out)' % (name, label.decode('latin-1')))
                return
            cur += 1
        elif k == 'f':
            end = cur
            while buf[end] not in (0, 13):
                end += 1
            if buf[end] != 13:
                err('%s: the field %r has no CR-terminated text in the states' % (name, label.decode('latin-1')))
                return
            cur = end + 1


def dispatch_keys(src, label):
    """The key letters a compare chain tests, from its label to its first unconditional branch."""
    lines = open(os.path.join(CMDS, src), encoding='latin-1').read().splitlines()
    start = next((i for i, l in enumerate(lines) if re.match(re.escape(label) + r'(\s|$)', l)), None)
    if start is None:
        err('%s: no label %s for a key dispatch' % (src, label))
        return set()
    keys = set()
    for l in lines[start:start + 120]:
        code = l.split('*')[0] if l.startswith('*') else l
        m = re.search(r'\bcmp[xb]\s+#(?:\'(.)|\$00([0-9A-Fa-f]{2})\b|\$([0-9A-Fa-f]{2})\b)', code)
        if m:
            keys.add(ord(m.group(1)) if m.group(1) else int(m.group(2) or m.group(3), 16))
        elif re.search(r'^\S*\s+l?bra\s', code) and keys:
            break
    return keys


def check_window(name, col, y, width, rows):
    left = col - 1
    right = left + width + 2 - 1
    bottom = y - 10 - TEXT_LINE_H * rows
    if rows > 26:
        err('%s: %d rows - a window holds 26' % (name, rows))
    if left < 1 or right > 78:
        err('%s: columns %d..%d - off the screen (winrest would move it, and its pointer rows with it)' % (name, left, right))
    if y > SCREEN_TOP or bottom < 0:
        err('%s: rows y %d down to %d - off the screen (winrest would move it)' % (name, y, bottom))


def check_widths(name, width, items):
    room = width + 1                      # ctxma: FrCtxLeft = width + 1, the box takes one
    for kind, label in items:
        k = chr(kind)
        text = label.decode('latin-1').lstrip('\x10')
        need = len(text) + (1 if k in 'brq' else 0)
        if k == 'f':
            need += 4                     # the value: up to four characters ('-127')
        if need > room:
            err('%s: the row %r needs %d columns, the menu is %d wide' % (name, text, need, width))


def main():
    asm_cmd = sys.argv[1].split()
    descs = []
    for f in sorted(os.listdir(CMDS)):
        if not f.endswith('.asm'):
            continue
        for line in open(os.path.join(CMDS, f), encoding='latin-1'):
            m = re.match(r'(desc[A-Z]\w*)\s+fcb\s', line)
            if m:
                descs.append((f[:-4], m.group(1)))
    mods = {}
    with tempfile.TemporaryDirectory() as tmp:
        need = {m for m, _ in descs} | {m for v in STATES.values() for m, _, _ in v}
        for m in sorted(need):
            mods[m] = symbols(asm_cmd, m, tmp)
    for module, name in descs:
        table, data = mods[module]
        if name not in table:
            err('%s: %s not in its symbol dump' % (module, name))
            continue
        col, y, width, rows, keys, items = read_descriptor(data, table[name], name)
        if len(items) != rows:
            err('%s: the header says %d rows, the list has %d' % (name, rows, len(items)))
        for kind, label in items:
            if kind not in KINDS:
                err('%s: the row %r has an unknown kind %r' % (name, label, chr(kind)))
        if any(k < 0x20 and k != 13 for k in keys):     # a CR key: a title row that closes the menu
            err('%s: its key string is shorter than its %d rows' % (name, rows))
        check_widths(name, width, items)
        check_window(name, col, y, width, rows)
        if name in STATES:
            fmts = []
            for m, sym, off in STATES[name]:
                t, d = mods[m]
                if sym not in t:
                    err('%s: the states format %s is not in %s' % (name, sym, m))
                    break
                fmts.append((d, t[sym], off))
            else:
                check_states(name, items, fmts)
        if name in DISPATCH:
            have = dispatch_keys(*DISPATCH[name])
            for k, (kind, label) in zip(keys, items):
                if k in (ord(' '), ord('-'), 13):
                    continue
                # 2026-10-09: a lower-case key whose sub-menu opens over the menu is cased in upper case ('Q', 'P',
                # 'I', 'S': the menu is still up and closes after the sub-menu)
                if k not in have and not (0x61 <= k <= 0x7A and k - 0x20 in have):
                    err('%s: the key %r (row %r) has no case in %s' % (name, chr(k), label.decode('latin-1'), DISPATCH[name][1]))
    for src, label, skip, disp in KEYTABLES:
        text = open(os.path.join(CMDS, src), encoding='latin-1').read()
        m = re.search(re.escape(label) + r'\s+fcb\s+\$0D\s*\n\s+fcc\s+/([^/]*)/', text)
        if not m:
            err('%s: no key table %s' % (src, label))
            continue
        have = dispatch_keys(src, disp)
        for ch in m.group(1)[skip:]:
            if ch != ' ' and ord(ch) not in have:
                err('%s: the key %r has no case in %s' % (label, ch, disp))
    for rsrc, rpat, psrc, plabel in PICKERS:
        rec = next((l for l in open(os.path.join(CMDS, rsrc), encoding='latin-1') if re.search(rpat, l)), None)
        if not rec:
            err('%s: no window record matching %r' % (rsrc, rpat))
            continue
        fields = rec.split()[1].split(',')
        rcol, ry = fields[1], fields[2]
        plines = open(os.path.join(CMDS, psrc), encoding='latin-1').read().splitlines()
        start = next((i for i, l in enumerate(plines) if l.startswith(plabel)), None)
        imms = []
        for l in plines[start:start + 60] if start is not None else []:
            m = re.match(r'\s+ldd\s+#(\S+)', l)
            if m:
                imms.append(m.group(1))
            if 'ptextmen' in l:
                break
        if rcol not in imms or ry not in imms:
            err('%s: its picker (%s) does not use the window\'s column %s and y %s (it pushes %s)'
                % (rpat.replace('\\', ''), plabel, rcol, ry, ', '.join(imms[-2:])))
    if errors:
        sys.exit('STOP: menu check failed\n  ' + '\n  '.join(errors))
    print('menus: %d descriptors checked, all consistent' % len(descs))


if __name__ == '__main__':
    main()
