#!/usr/bin/env python3
# Definitive DP-globals fix.
#  - direct-page-encoded data refs (from the listing) carry the equate Name.
#  - a label that is ALSO a code target (branch/call/leax-pcr OR the mod-directive
#    exec entry / a pseudo-op operand) is DUAL: keep the code label, add a SEPARATE
#    equate, repoint only the direct-page data refs.
#  - a pure global's colliding startup label is blanked.
#  - ANY non-direct-page, non-code reference the disassembler symbolized to the label
#    (indexed-indirect [L,y], indexed L,y, extended) becomes the NUMERIC LITERAL $00NN
#    -- Name belongs only in direct-page operands.
# Usage: python3 dpfix2.py <file.asm> <listing.lst> [--apply]
import re, sys
from collections import defaultdict
F=sys.argv[1]; LST=sys.argv[2]; APPLY='--apply' in sys.argv

DIRECT1={0x00,0x03,0x04,0x06,0x07,0x08,0x09,0x0A,0x0C,0x0D,0x0E,0x0F}|set(range(0x90,0xA0))|set(range(0xD0,0xE0))
PFX={0x10:{0x93,0x9C,0x9E,0x9F,0xDE,0xDF},0x11:{0x93,0x9C}}
DATAOPS={'ldd','std','ldx','stx','ldu','stu','ldy','sty','lda','sta','ldb','stb',
 'cmpd','cmpx','cmpu','cmpy','cmpa','cmpb','addd','subd','adca','adcb','sbca','sbcb',
 'anda','andb','ora','orb','eora','eorb','adda','addb','subb','bita','bitb'}
INHERENT={'rts','rti','nop','clra','clrb','coma','comb','deca','decb','inca','incb',
 'asla','aslb','lsra','lsrb','rora','rorb','asra','asrb','rola','rolb','nega','negb',
 'tsta','tstb','mul','sex','abx','daa','sync','swi','swi2','swi3','sexw','pshsw','pulsw'}
BR={'lbsr','bsr','jsr','jmp','lbra','bra','lbeq','beq','lbne','bne','lbcs','bcs','lbcc','bcc',
 'lbhi','bhi','lblo','blo','lbls','bls','lbge','bge','lblt','blt','lbgt','bgt','lble','ble',
 'lbmi','bmi','lbpl','bpl','lbvs','bvs','lbvc','bvc','lbsr'}
PSEUDO={'mod','fdb','fcc','fcs','fcb','equ','rmb','os9'}

src=open(F).read().split('\n')

# direct-page data refs: offset -> [srcnum]
refs=defaultdict(list)
for l in open(LST).read().split('\n'):
    m=re.match(r'([0-9A-Fa-f]{4}) ([0-9A-Fa-f]{2,})\s+\(\s*\S+\):(\d+)\s{2,}(.*)$',l)
    if not m: continue
    byts=m.group(2); srcnum=int(m.group(3))
    b=[int(byts[i:i+2],16) for i in range(0,len(byts),2)]
    if len(b)==2 and b[0] in DIRECT1: off=b[1]
    elif len(b)==3 and b[0] in PFX and b[1] in PFX[b[0]]: off=b[2]
    else: continue
    sl=src[srcnum-1]; has=not sl[:1].isspace(); toks=sl.split()
    if len(toks)<(3 if has else 2): continue
    opcode=(toks[1] if has else toks[0]).lower()
    operand=toks[2] if has else toks[1]
    if opcode not in DATAOPS or ',' in operand or operand.startswith('#'): continue
    refs[off].append(srcnum)

cur_label={}
for off,lns in refs.items():
    sl=src[lns[0]-1]; has=not sl[:1].isspace(); toks=sl.split()
    operand=toks[2] if has else toks[1]
    if not operand.startswith('$'): cur_label[off]=operand

def line_mnemonic(line):
    if not line.strip() or line.lstrip().startswith('*'): return None
    t=line.split()
    return (t[1] if not line[:1].isspace() and len(t)>1 else t[0]).lower() if t else None

def is_code_target(name):
    # branch/call/leax-pcr target, or referenced by a pseudo-op (mod exec entry, fdb, ...)
    leapcr=re.compile(r'lea[xyus]\s+'+re.escape(name)+r',pcr')
    tok=re.compile(r'(?<![A-Za-z0-9_.$@])'+re.escape(name)+r'(?![A-Za-z0-9_.$@])')
    for l in src:
        mn=line_mnemonic(l)
        if mn in BR and tok.search(l): return True
        if leapcr.search(l): return True
        if mn in PSEUDO and tok.search(l) and not re.match(re.escape(name)+r'\b',l): return True
    return False

DUAL={off for off,lbl in cur_label.items() if lbl and is_code_target(lbl)}

def cname(off):
    lbl=cur_label.get(off)
    if off not in DUAL and lbl and lbl.startswith('Glb'): return lbl
    return f'GlbVar{off:04X}'

def parse(line):
    has=not line[:1].isspace(); toks=line.split()
    if has: label,rest=toks[0],toks[1:]
    else: label,rest=None,toks
    opcode=rest[0] if rest else ''
    if opcode.lower() in INHERENT:
        operand=''; comment=' '.join(rest[1:]) if len(rest)>1 else ''
    else:
        operand=rest[1] if len(rest)>1 else ''
        comment=' '.join(rest[2:]) if len(rest)>2 else ''
    return label,opcode,operand,comment
def fld(s,w): return s.ljust(w) if len(s)<w else s+' '
def build(label,opcode,operand,comment):
    return (fld(label or '',20)+fld(opcode,10)+(fld(operand,10) if comment else operand)+comment).rstrip()

n_rep=0; n_lit=0; n_blank=0; literals=[]
for off in sorted(refs):
    cn=cname(off); lbl=cur_label.get(off); NN=f'${off:04X}'
    dp_lines=set(refs[off])
    # 1) repoint direct-page data refs -> cname
    for ln in refs[off]:
        label,opcode,operand,comment=parse(src[ln-1])
        if operand!=cn:
            src[ln-1]=build(label,opcode,cn,comment); n_rep+=1
    if lbl is None:
        continue   # bare $00NN global: nothing else to do
    tok=re.compile(r'(?<![A-Za-z0-9_.$@])'+re.escape(lbl)+r'(?![A-Za-z0-9_.$@])')
    # 2) walk remaining lines that still reference lbl
    for i,l in enumerate(src):
        if i+1 in dp_lines: continue
        if not tok.search(l): continue
        is_def = re.match(re.escape(lbl)+r'(?![A-Za-z0-9_.$@])', l) is not None
        if is_def:
            if off in DUAL:
                continue   # keep the code label
            label,opcode,operand,comment=parse(l)
            src[i]=build(None,opcode,operand,comment); n_blank+=1
            continue
        mn=line_mnemonic(l)
        if mn in BR or mn in PSEUDO:
            continue   # genuine code reference (branch / mod exec entry) -> keep
        # otherwise a non-direct-page DATA reference (indexed/indirect/extended) -> literal
        src[i]=tok.sub(NN,l); n_lit+=1; literals.append((i+1,off))

# equate block
eq=['* --------------------------------------------------------------------',
 '* Direct-page global variables.',
 '* The C runtime keeps its globals in the direct page (DP = data base).',
 '* The disassembler assumed DP=$00, so these direct-page references had',
 '* resolved onto the startup code at the same low addresses; they are',
 '* defined here as equates and the references repointed, byte-identically.',
 '* --------------------------------------------------------------------']
for off in sorted(refs):
    eq.append(f"{cname(off):<20}{'equ':<10}${off:04X}")
eq.append('')

print(f"direct-page repoints: {n_rep}   non-dp refs -> literal: {n_lit}   defs blanked: {n_blank}")
print(f"DUAL (kept code label + separate equate): {[(hex(o),cur_label[o]) for o in sorted(DUAL)]}")
print(f"equates: {len(refs)}   literal lines: {literals[:8]}")

if APPLY:
    out=[]; inserted=False
    for l in src:
        out.append(l)
        if not inserted and re.match(r'size\s+equ\s+\.',l):
            out.append(''); out.extend(eq); inserted=True
    assert inserted
    open(F,'w').write('\n'.join(out)); print("APPLIED")
