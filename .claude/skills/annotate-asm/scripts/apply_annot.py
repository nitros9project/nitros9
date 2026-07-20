#!/usr/bin/env python3
"""Apply the parallel-annotation JSON maps to a disassembled .asm file.

Two phases (run separately, byte-checkpoint between):
  --phase renames : apply all label renames (word-boundary global replace)
  --phase comments: reformat+comment bare instruction lines (line numbers > SKIP)

Line numbers are 1-based and STABLE (renames/comments never add or remove lines),
so the comment map keyed by line number stays valid across both phases.
"""
import sys, os, re, json, glob

FILE = sys.argv[sys.argv.index('--file') + 1]
OUT  = sys.argv[sys.argv.index('--out') + 1]
PHASE = sys.argv[sys.argv.index('--phase') + 1]
SKIP = int(sys.argv[sys.argv.index('--skip')+1]) if '--skip' in sys.argv else 0

def load_maps():
    renames = {}   # old -> new (raw, pre-dedup)
    comments = {}  # int lineno -> comment
    for p in sorted(glob.glob(os.path.join(OUT, '*.json'))):
        try:
            d = json.load(open(p))
        except Exception as e:
            print(f"  WARN: bad json {p}: {e}", file=sys.stderr); continue
        for r in d.get('renames', []):
            old, new = r.get('old'), r.get('new')
            if old and new and re.fullmatch(r'[uL][0-9A-Fa-f]{4}', old):
                renames[old] = new
        for k, v in (d.get('comments') or {}).items():
            try:
                ln = int(k)
            except: continue
            if v and ln > SKIP:
                comments[ln] = v.strip()
    return renames, comments

def existing_labels(text):
    return set(re.findall(r'(?m)^([A-Za-z_][A-Za-z0-9_.$@]*)', text))

def do_renames(text):
    renames, _ = load_maps()
    # only rename labels actually defined in the file
    defs = set(re.findall(r'(?m)^([uL][0-9A-Fa-f]{4})', text))
    renames = {o: n for o, n in renames.items() if o in defs}
    used = existing_labels(text) - set(renames.keys())
    # lwasm here runs with --pragma=nosymbolcase, so symbols are case-INSENSITIVE:
    # dedup on lowercased names or e.g. StrlenLoop and StrLenLoop collide at assembly.
    taken = {u.lower() for u in used}
    final = {}
    for old in sorted(renames, key=lambda o: (-len(o), o)):
        new = re.sub(r'[^A-Za-z0-9_]', '', renames[old]) or ('Lbl' + old)
        if not re.match(r'[A-Za-z_]', new):
            new = 'L' + new
        base, i = new, 2
        while new.lower() in taken:
            new = f"{base}{i}"; i += 1
        taken.add(new.lower()); final[old] = new
    # single pass: replace each old token (word boundary) — olds are unique 5-char tokens, no overlap
    def repl(m):
        return final.get(m.group(0), m.group(0))
    text = re.sub(r'(?<![A-Za-z0-9_.$@])([uL][0-9A-Fa-f]{4})(?![A-Za-z0-9_.$@])', repl, text)
    print(f"  applied {len(final)} renames")
    return text

def field(s, w):
    return s.ljust(w) if len(s) < w else s + ' '

def do_comments(text):
    _, comments = load_maps()
    lines = text.split('\n')
    n = 0
    for i, line in enumerate(lines, 1):
        if i <= SKIP or i not in comments:
            continue
        # only touch BARE instruction lines: no existing inline comment risk because
        # disasm instruction lines carry no comment. Parse trivially.
        if not line.strip() or line.lstrip().startswith('*'):
            continue
        has_label = line[:1] not in (' ', '\t')
        toks = line.split()
        if not toks:
            continue
        label = toks[0] if has_label else ''
        rest = toks[1:] if has_label else toks
        if not rest:
            continue
        opcode = rest[0]
        # pseudo-ops: skip (shouldn't be in comment map, but guard)
        if opcode.lower() in ('rmb','equ','fcb','fdb','fcc','fcs','mod','emod','end','use','set','ifp1','ifp2','endc','org','nam','ttl','align'):
            continue
        operand = rest[1] if len(rest) > 1 else ''
        # guard: if there were >2 rest tokens, the line already had a comment -> skip to avoid mangling
        if len(rest) > 2:
            continue
        new = (field(label if label else '', 20) + field(opcode, 10) +
               field(operand, 10) + comments[i]).rstrip()
        lines[i-1] = new
        n += 1
    print(f"  commented+realigned {n} lines")
    return '\n'.join(lines)

text = open(FILE).read()
if PHASE == 'renames':
    text = do_renames(text)
elif PHASE == 'comments':
    text = do_comments(text)
else:
    sys.exit("unknown phase")
open(FILE, 'w').write(text)
