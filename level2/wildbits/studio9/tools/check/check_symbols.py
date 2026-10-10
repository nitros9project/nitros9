"""UME master-definition inventory and allocation guard. No guest or disk access.

Absolute data, frame-relative offsets, constants and code labels are different
namespaces. Dynamic indexing cannot prove an array's extent; never call a gap free.
"""
from pathlib import Path
import argparse, ast, csv, re, sys

ROOT=Path(__file__).resolve().parents[2]
DEFS=ROOT/'cmds/equates.asm'
EQ=re.compile(r'^(\w[\w.]*)\s+equ\s+(\S+)(.*)$',re.I)
MEMOPS=set('lda ldb ldd ldx ldy ldu lds sta stb std stx sty stu sts cmpa cmpb cmpd cmpx cmpy cmpu cmps adda addb addd suba subb subd anda andb ora orb eora eorb adca adcb sbca sbcb bita bitb tst clr inc dec neg com lsl lsr asl asr rol ror jmp jsr'.split())
WORD=set('ldd ldx ldy ldu lds std stx sty stu sts cmpd cmpx cmpy cmpu cmps addd subd'.split())
FRAME_SCOPES={'S9C','S9F','S9G','S9I','S9O','S9R','S9Y'}

def evaluate(expr,values):
    expr=re.sub(r'\$([0-9A-Fa-f]+)',r'0x\1',expr)
    expr=re.sub(r'%([01]+)',r'0b\1',expr)
    expr=re.sub(r"'(.)",lambda m:str(ord(m[1])),expr)
    def walk(n):
        if isinstance(n,ast.Constant) and isinstance(n.value,int):return n.value
        if isinstance(n,ast.Name):return values[n.id.lower()]
        if isinstance(n,ast.UnaryOp):
            v=walk(n.operand)
            if isinstance(n.op,ast.USub):return -v
            if isinstance(n.op,ast.UAdd):return v
        if isinstance(n,ast.BinOp):
            a,b=walk(n.left),walk(n.right)
            if isinstance(n.op,ast.Add):return a+b
            if isinstance(n.op,ast.Sub):return a-b
            if isinstance(n.op,ast.Mult):return a*b
            if isinstance(n.op,(ast.Div,ast.FloorDiv)):return a//b
            if isinstance(n.op,ast.BitOr):return a|b
            if isinstance(n.op,ast.BitAnd):return a&b
            if isinstance(n.op,ast.BitXor):return a^b
        raise ValueError(expr)
    return walk(ast.parse(expr,mode='eval').body)

def definitions(text):
    rows=[];scope='shared';evidence=''
    for no,line in enumerate(text.splitlines(),1):
        m=re.search(r'ifdef\s+UME_SCOPE_(\w+)',line,re.I)
        if m:scope=m[1].upper();evidence=''
        if re.match(r'\s*endc',line,re.I):scope='shared';evidence=''
        if line.startswith('* From '):evidence=line[2:]
        m=EQ.match(line)
        if m:rows.append(dict(scope=scope,name=m[1],expression=m[2],comment=m[3].strip(),line=no,evidence=evidence))
    scopes={r['scope'] for r in rows};tables={}
    for scope in scopes:
        wanted=[r for r in rows if r['scope'] in ('shared',scope)]
        vals={}
        for _ in range(len(wanted)+1):
            change=False
            for r in wanted:
                if r['name'].lower() in vals:continue
                try:v=evaluate(r['expression'],vals)
                except (KeyError,ValueError,SyntaxError):continue
                vals[r['name'].lower()]=v;change=True
            if not change:break
        tables[scope]=vals
    for r in rows:r['value']=tables[r['scope']].get(r['name'].lower())
    return rows,tables

def instructions(text):
    for no,line in enumerate(text.splitlines(),1):
        if not line.strip() or line.lstrip().startswith(('*',';')):continue
        tokens=line.split()
        if not line[0].isspace():tokens=tokens[1:]
        if len(tokens)>=2 and tokens[0].lower() in MEMOPS:
            yield no,tokens[0].lower(),tokens[1]


def stack_uses():
    """Inventory S-indexed instructions without guessing local-variable names."""
    for p in sorted((ROOT/'cmds').glob('*')):
        if p.suffix not in ('.asm','.inc') or p.name=='equates.asm':continue
        for no,line in enumerate(p.read_text(encoding='latin1').splitlines(),1):
            if not line.strip() or line.lstrip().startswith(('*',';')):continue
            fields=line.split()
            if not line[0].isspace():fields=fields[1:]
            if len(fields)<2:continue
            op,operand=fields[:2]
            if not re.search(r',[-+]?s(?:\+\+?|\])?$',operand,re.I):continue
            expr=operand.split(',')[0].strip('[<>')
            if op.lower()=='leas':kind='stack-pointer adjustment'
            elif re.search(r',[-+]s|,s\+',operand,re.I):kind='stack push/pop operand'
            elif re.fullmatch(r'-?(?:\$[\da-f]+|\d+)?',expr,re.I):kind='numeric stack offset; routine analysis required'
            elif expr.lower() in ('a','b','d'):kind='register-indexed stack access'
            else:kind='named stack offset/expression'
            yield [p.name,no,op,operand,kind,' '.join(fields[2:])]

def allocations(text,tables):
    rows=[]
    for line in text.splitlines():
        m=re.match(r'\* @alloc (\S+) (\S+) (\S+) (\S+) (.+)',line)
        if not m:continue
        space,scope,name,size,why=m.groups();vals=tables[scope]
        rows.append(dict(space=space,scope=scope,name=name,start=evaluate(name,vals),size=evaluate(size,vals),why=why))
    return rows

def overlap_errors(rows):
    errors=[]
    for i,a in enumerate(rows):
        for b in rows[i+1:]:
            if a['space']==b['space'] and a['start']<b['start']+b['size'] and b['start']<a['start']+a['size']:
                errors.append(f"overlap: {a['name']} and {b['name']} in {a['space']} at ${max(a['start'],b['start']):04X}")
    return errors

def inventory(text):
    rows,tables=definitions(text);alloc=allocations(text,tables);errors=overlap_errors(alloc)
    frames={};fields=[]
    for line in text.splitlines():
        m=re.match(r'\* @frame (\S+) (\S+) (\S+)$',line)
        if m:frames[(m[1],m[2])]=evaluate(m[3],tables[m[1]])
        m=re.match(r'\* @field (\S+) (\S+) (\S+) (\S+)$',line)
        if m:
            sc,owner,name,length=m.groups();v=tables[sc]
            field=dict(space=sc+':'+owner,name=name,start=evaluate(name,v),size=evaluate(length,v))
            fields.append(field)
            if field['start']<0 or field['start']+field['size']>frames.get((sc,owner),0):
                errors.append(f'{name}: outside stack frame {owner}')
    errors+=overlap_errors(fields)
    alias={}
    for line in text.splitlines():
        m=re.match(r'\* @alias (\S+) (\S+) (\S+) (\S+) (.+)',line)
        if m:
            space,scope,name,owner,why=m.groups();alias[(space,scope,name.lower())]=(owner,why)
            try:
                value=tables[scope][name.lower()]
                region=next(a for a in alloc if a['space']==space and a['name']==owner)
                if not region['start']<=value<region['start']+region['size']:
                    errors.append(f'{name}: alias is outside owner {owner}')
            except (KeyError,StopIteration):errors.append(f'{name}: unresolved alias owner {owner}')
    allowed_words={(m[1],evaluate(m[3],tables[m[2]])) for m in re.finditer(r'^\* @word (\S+) (\S+) (\S+) .+$',text,re.M)}
    alloc_names={(a['space'],a['scope'],a['name'].lower()) for a in alloc}
    defscope={(r['scope'],r['name'].lower()) for r in rows}
    end=tables['shared']['umestaticend']
    if max(a['start']+a['size'] for a in alloc if a['space']=='ume')!=end:
        errors.append('UmeStaticEnd does not match the last owned editor byte')
    for r in rows:
        if r['value'] is None:errors.append(f"unresolved master definition: {r['scope']} {r['name']}")
    refs=[];labels=[];scopes=set(tables)-{'shared'}
    for p in sorted((ROOT/'cmds').glob('*')):
        if p.suffix not in ('.asm','.inc') or p.name=='equates.asm':continue
        src=p.read_text(encoding='latin1');m=re.search(r'^UME_SCOPE_(\w+)\s+equ',src,re.M)
        scope=m[1].upper() if m else 'include/data'
        vals=tables.get(scope,tables['shared'])
        for no,line in enumerate(src.splitlines(),1):
            if re.match(r'^[A-Za-z_][\w.@]*\s',line):
                label=line.split()[0]
                labels.append([scope,p.name,no,label,'module-relative label' if not EQ.match(line) else 'local EQU'])
            em=EQ.match(line)
            if em and em[2]!='*' and em[1].lower()!='size' and not em[1].startswith('UME_SCOPE_'):
                # Dependent code-label differences remain with their code; numeric constants do not.
                try:evaluate(em[2],vals)
                except (KeyError,ValueError,SyntaxError):pass
                else:errors.append(f'{p.name}:{no}: definition {em[1]} belongs in equates.asm')
        for no,op,operand in instructions(src):
            addressing='immediate (not necessarily an address)' if operand.startswith('#') else 'indexed/dynamic' if ',' in operand else 'absolute'
            value_expr=operand.strip('[]<>#').split(',')[0].strip('<>')
            try:value=evaluate(value_expr,vals)
            except (KeyError,ValueError,SyntaxError):value=None
            space='fran' if scope=='S9GUI' else 'ume'
            refs.append([scope,p.name,no,op,operand,addressing,space,f'{value:04X}' if value is not None and value>=0 else '',2 if op in WORD else 1])
            if addressing=='absolute' and value is not None and 0<=value<(tables['S9GUI']['frdataend'] if space=='fran' else end):
                if op in WORD and '[' not in operand and (space,value) not in allowed_words:
                    owner=next((a for a in alloc if a['space']==space and a['start']<=value<a['start']+a['size']),None)
                    if owner and value+2>owner['start']+owner['size']:
                        errors.append(f'{p.name}:{no}: word access {operand} exceeds {owner["name"]} allocation')
                for sym in re.findall(r'[A-Za-z_][\w.]*',value_expr):
                    ds=scope if (scope,sym.lower()) in defscope else 'shared'
                    key=(space,ds,sym.lower())
                    if key not in alloc_names and key not in alias:
                        errors.append(f'{p.name}:{no}: unregistered data symbol {sym}; declare allocation or documented alias')
            if addressing=='absolute' and re.match(r'\[?[<>]?\$[0-9a-f]+\]?$',operand,re.I) and value is not None and value< (0x3a9d if space=='fran' else 0x1130) and scope in scopes:
                errors.append(f'{p.name}:{no}: raw process-data address {operand}; use master symbol')
    return rows,tables,alloc,refs,labels,errors

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--write',action='store_true');ap.add_argument('--self-test',action='store_true');args=ap.parse_args()
    text=DEFS.read_text(encoding='latin1');rows,tables,alloc,refs,labels,errors=inventory(text)
    if args.self_test:
        bad=[dict(r) for r in alloc]
        pointer=next(r for r in bad if r['name']=='pDriveMenu');pointer['start']=0x10fe
        assert any('pDriveMenu' in e and 'KeepGind' in e for e in overlap_errors(bad))
        print('PASS allocation guard rejects pDriveMenu/KeepGind overlap at $10FE')
        changed=re.sub(r'^(BrowserPagePosOff\s+equ\s+)\S+',r'\g<1>$0789',text,flags=re.M)
        assert any('outside stack frame' in e for e in inventory(changed)[-1])
        changed=re.sub(r'^(BrowserPagePosOff\s+equ\s+)\S+',r'\g<1>6',text,flags=re.M)
        assert any('overlap:' in e and 'BrowserListOff' in e for e in inventory(changed)[-1])
        print('PASS browser frame guard rejects overflow and filename-buffer overlap')
        changed=text.replace('@alloc ume shared AuditionSavedFlags 2','@alloc ume shared AuditionSavedFlags 1')
        assert any('word access >AuditionSavedFlags exceeds' in e for e in inventory(changed)[-1])
        print('PASS word-access guard rejects a one-byte allocation for two audition flags')
    if args.write:
        # the reports go to the build kit (2026-10-10, user: "regenerate and move to buildkit"); S9REPORTS overrides
        import os
        docs=Path(os.environ.get('S9REPORTS') or next((d for d in ('E:/cygwin64/home/taylo/wildbits-buildkit/tools/s9/reports',
            '/home/taylo/wildbits-buildkit/tools/s9/reports') if Path(d).parent.is_dir()), str(ROOT/'reports')))
        docs.mkdir(parents=True,exist_ok=True)
        def csvout(name,header,data):
            with (docs/name).open('w',newline='',encoding='utf8') as f:
                w=csv.writer(f);w.writerow(header);w.writerows(data)
        def kind(r):
            n,v,sc=r['name'],r['value'],r['scope']
            if 'STACK-BACKED TRACK RECORD OFFSET' in r['comment']:return 'stack-backed track-record offset'
            if 'STACK OFFSET' in r['comment']:return 'stack-frame offset'
            if 'STACK FRAME SIZE' in r['comment']:return 'stack-frame size'
            if 'STACK BUFFER/RECORD CAPACITY' in r['comment']:return 'stack buffer/record capacity'
            if n.startswith('UmeData_'):
                return 'editor callback slot' if v is not None and 0x351<=v<0x3b7 else 'editor legacy data (reserved)' if '_reserved_' in n else 'editor data'
            if n.startswith('FrData_'):return 'Fran legacy data (reserved)' if '_reserved_' in n else 'Fran data'
            if any(a['name']==n and a['scope']==sc for a in alloc):return 'owned storage'
            if re.search(r'\* @alias \S+ '+re.escape(sc)+' '+re.escape(n)+r' ',text):return 'documented storage alias'
            if sc in FRAME_SCOPES:return 'frame offset / constant (see operand base)'
            if v is not None and v>=0xfd00:return 'hardware/register constant'
            return 'constant / scoped alias (see expression and uses)'
        csvout('symbols.csv',['scope','symbol','value_hex','expression','kind','comment','evidence','master_line'],
          ([r['scope'],r['name'],f"{r['value']:04X}" if r['value'] is not None else '',r['expression'],
          kind(r),r['comment'],r['evidence'],r['line']] for r in rows))
        csvout('symbol-references.csv',['scope','file','line','opcode','operand','addressing','process','base_hex','access_bytes'],refs)
        csvout('routine-labels.csv',['scope','file','line','label','kind'],labels)
        csvout('stack-uses.csv',['file','line','opcode','operand','kind','comment'],stack_uses())
        csvout('storage.csv',['process','scope','symbol','start_hex','bytes','purpose'],([r['space'],r['scope'],r['name'],f"{r['start']:04X}",r['size'],r['why']] for r in alloc))
        src=(ROOT/'cmds/s9.asm').read_text(encoding='latin1');targets={};last=None;active=False
        for line in src.splitlines():
            if re.match(r'^uinit\s',line):active=True
            if re.match(r'^newscore\s',line):active=False
            if not active:continue
            m=re.search(r'\bleax\s+>?([\w.]+),pcr',line,re.I)
            if m:last=m[1]
            m=re.search(r'\bstx\s+>([\w.]+)',line,re.I)
            if m and last:
                v=tables['UMUSE3'].get(m[1].lower())
                if v is not None:targets[v]=last
        cb=sorted((r for r in rows if r['name'].startswith('UmeData_p') and r['value'] is not None and 0x351<=r['value']<0x3b7),key=lambda r:r['value'])
        csvout('callbacks.csv',['slot_hex','symbol','bytes','uinit_target'],([f"{r['value']:04X}",r['name'],2,targets.get(r['value'],'no uinit assignment found; do not call uninitialized')] for r in cb))
    if errors:
        print('\n'.join(errors[:60]));print(f'{len(errors)} definition/allocation errors');return 1
    print(f'PASS master symbols: {len(rows)} definitions, {len(alloc)} owned regions, {len(refs)} operand uses, {len(labels)} code/data labels')
    return 0
if __name__=='__main__':sys.exit(main())
