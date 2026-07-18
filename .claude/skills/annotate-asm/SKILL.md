---
name: 6809-annotate
description: Turn a raw disassembled 6809/6309 OS-9 module into legible, byte-identical source. Renames generic labels (L0047, u0100) to meaningful names, adds an inline comment to every instruction, fixes the disassembler's failures (code left as fcb data, data decoded as code, per-instruction address labels, direct-page globals resolved to code labels, addresses symbolized as immediates), and formats to the project style. Scales to huge modules by fanning out reader agents. Every step is verified byte-identical to the original binary. Invoke with a file path argument.
argument-hint: <path/to/file.asm>
allowed-tools: [Read, Edit, Write, Bash, Grep, Workflow]
---

# 6809 / OS-9 Disassembly Annotator

You are an expert in Motorola 6809 / Hitachi 6309 assembly and the NitrOS-9 / Microware OS-9 operating system. Your job: take a raw disassembly (RML Disasm, os9dis, etc.) and make it read like hand-written source — **without changing a single assembled byte**.

The user invoked this skill with: `$ARGUMENTS` (a path to a `.asm` file). If none was given, ask for one.

## The one rule that governs everything: the byte-oracle

Every change you make is cosmetic and MUST re-assemble to the exact same module. Before touching anything, capture a baseline binary + CRC; after every batch of edits, re-assemble and compare. If the bytes differ, stop and fix/revert before continuing. This is what lets you refactor aggressively with confidence.

## Pipeline overview

Run these phases in order. Small modules (< ~1500 lines) can do Phase 1 by hand; large ones fan out agents (Phase 1, parallel path).

| Phase | What |
|-------|------|
| 0 | Byte-oracle baseline (assemble command, CRC) |
| 1 | Rename labels + comment every instruction |
| 2 | Whitespace / project formatting + block separation |
| 3 | Fix failed disassembly (code-as-fcb, data-as-code) |
| 4 | Remove unreferenced per-instruction labels |
| 5 | Fix DP-global / immediate mislabels |
| 6 | Final verify + header note + report |

Worked examples: `c.prep.asm` (4.7k lines, mostly sequential) and `c.comp.asm` (20k lines, parallelized across 44 agents) in `3rdparty/packages/ccompiler/`.

---

## Phase 0 — Byte-oracle baseline (ALWAYS FIRST)

1. **Find the assemble command.** Look for a `Makefile`/`makefile` in the file's dir; `make -n <target>` (target = basename without `.asm`) prints the exact `lwasm` line. NitrOS-9 modules typically use:
   ```
   lwasm --no-warn=ifp1 --6309 --format=os9 \
     --pragma=pcaspcr,nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax \
     --includedir=$NITROS9DIR/defs -DNOS9VER= -DNOS9MAJ= -DNOS9MIN= <file>.asm -o<file>
   ```
2. **Assemble the unmodified source** to `$SP/<name>.baseline` (use a scratch dir, e.g. `$CLAUDE_JOB_DIR/tmp` or the session scratchpad). If it fails, stop and report — do not annotate a source that doesn't assemble.
3. **Record the CRC:** `os9 ident $SP/<name>.baseline | grep CRC` (e.g. `Module CRC : $4B70BB (Good)`).
4. **Define the checkpoint** you will run after every phase:
   ```bash
   lwasm <flags> <file>.asm -o$SP/chk 2>&1 | head
   cmp -s $SP/chk $SP/<name>.baseline && echo "✓ BYTE-IDENTICAL" || echo "✗ DIFFERS"
   ```
   Never advance past a `✗`.

> lwasm on a 20k-line file can take >1 min; run big assemblies in their own Bash call so the 2-minute limit doesn't cut off a checkpoint.

---

## Phase 1 — Rename labels + comment every instruction

### Label patterns to rename
Disassemblers emit generic labels in these forms — rename **all** of them:

| Pattern | Meaning |
|---------|---------|
| `L` + 4 hex (`L0047`, `L01B5`) | Code label (branch target, subroutine entry) |
| `u` / `U` + 4 hex (`u000C`, `U0053`) | Direct-page / U-register-relative data variable |
| `Y` + 4 hex (`Y0106`, `Y0116`) | Y-register-relative data variable (a module's static-data base is often in Y) |
| `D` + 4 hex | Data label |

The `U####` / `Y####` **data globals are the ones most easily left behind** — they sit in an `rmb` block and look like they might be constants, so a rename pass focused on `L####` code labels skips them (this happened on `c_asm.asm`). Rename them too, using the same intent your comments record. If a data global's purpose is genuinely ambiguous — or it is mis-disassembled filler — keep it by address rather than invent a misleading name. Leave already-meaningful names alone. Never rename OS-9 system constants (`I$Open`, `F$Exit`, `C$CR`, `E$EOF`, …).

### Naming heuristics (UpperCamelCase, 2–4 words)
- **Subroutine** (target of `bsr`/`jsr`/`lbsr`): verb phrase — `ParseExpr`, `SkipSpaces`, `EmitByte`, `LookupSym`.
- **Loop top** (branched back to): suffix `Loop`. **Error/exit**: suffix `Err`/`Fail` / `Ok`/`Done`.
- **Condition target** (after `cmpa #C$CR` etc.): name the condition — `GotCR`, `IsDelim`, `NotFound`.
- **Variable** (`u`/`U`/`Y` prefix): infer type from `rmb` size (1=flag/char, 2=pointer/word, N=buffer) and use — `CurChar`, `LineNum`, `InPtr`, `MacroTbl`.
- Recognize OS-9 idioms: `I$Open`→`OpenFailed` on the `bcs`; `I$Read`/`I$Write`→read/write helpers; `F$Exit`→exit point; `F$Mem`→alloc; `cmpa #C$CR`→CR check; `tfr s,u`/`leau ,s`→frame pointer.
- Distinguish repeats with qualifiers (`ReadLoop1`/`ReadLoop2`); never reuse a name already in the file.

### Comment rules
One short phrase (≤8 words) on **every instruction line**, explaining WHY not the mechanics (a 6809 reader knows what `lda ,x+` does; they want to know why). Exception: note a genuinely tricky idiom briefly (`puls pc,b` combined restore+return, `coma` to make $FF, `tfr s,u` frame pointer). Match the file's comment column (scan the file; usually 41). Don't comment pseudo-ops (`rmb equ fcb fdb fcc fcs mod emod end use set ifp1 endc org`), blank lines, `*` comment lines, or `os9 XXX` lines (self-documenting unless context needs it).

### Small modules — do it inline
Read the whole file, build the rename map, apply renames one at a time with `replace_all: true` (checkpoint every ~5), then add comments in batches (checkpoint after each batch). A fast batch-rename is a word-boundary sub:
```python
s = re.sub(r'(?<![A-Za-z0-9_.$@])'+re.escape(old)+r'(?![A-Za-z0-9_.$@])', new, s)
```

### Large modules — fan out reader agents (the scalable path)
Do the analysis in parallel, apply centrally. Agents are **read-only**; only the main loop mutates the file, so no agent can change a byte without a checkpoint catching it.

1. **Partition** lines `[codeStart..end]` into ~330–460-line chunks.
2. **`Workflow`**: one agent per chunk. Each agent:
   - Reads ONLY its slice (`Read` with offset/limit) and uses `grep -n <label> <file>` for cross-references — do NOT have every agent read the whole 20k-line file.
   - Returns `renames` for labels **defined in its range only** (each label is defined once, so its owner names it) and `comments` (`{lineNo: text}` for instruction lines).
   - **Writes a JSON file** `chunk_<i>.json` and returns the path.
   - **Hardcode the output dir in the workflow script** — passing it via `args` has bound to `undefined` in practice, scattering files into a literal `undefined/` dir.
   - JSON shape: `{ "renames":[{"old":"L1A7C","new":"ParseExpr","why":"..."}], "comments":{"461":"..."} }`
   - Add one whole-file "variables" agent when there are many `u`/`U`/`Y` labels — DP and Y-relative globals are referenced everywhere, so a single owner names them coherently.
3. **Apply centrally** with `scripts/apply_annot.py` (in this skill dir), byte-checkpointing between phases:
   ```bash
   python3 scripts/apply_annot.py --file <f>.asm --out <jsonDir> --phase renames   # then checkpoint
   python3 scripts/apply_annot.py --file <f>.asm --out <jsonDir> --phase comments  # then checkpoint
   ```
   It dedups rename collisions, only renames labels actually defined in the file, keys comments by **line number** (stable — renames and comments never add or remove lines), reformats + comments only *bare* instruction lines (so operand/comment splitting is unambiguous), and skips lines ≤ `--skip` (default 0; use it to protect a hand-done section).
4. **Clean up** afterwards:
   - **Stragglers**: labels at chunk boundaries no agent owned — find remaining `^[uUYL][0-9A-F]{4}` defs, name by context (dedup against existing names).
   - **Stale comment refs**: comments are applied *after* renames, so an agent's comment may still cite an old `Lxxxx` name — re-apply the rename map over the whole file (only comment mentions remain as `[uUYL]XXXX` tokens; they get updated).

Agent inference quality is high: on ccompiler they correctly identified macro tables, if/else compilation, free lists, and frame layouts.

---

## Phase 2 — Whitespace / project formatting (byte-neutral)

1. **Run the project formatter** — the same one the pre-commit hook uses:
   ```bash
   python3 $NITROS9DIR/scripts/asmprettyprint.py <f>.asm > $SP/fmt && mv $SP/fmt <f>.asm   # then checkpoint
   ```
   It aligns label/opcode/operand/comment columns. Confirm it's the upstream version (a local edit once had it lowercasing opcodes — that would still be byte-identical but is not the house style).
2. **Blank line after every unconditional branch** (`bra`/`lbra`/`jmp`) — NOT after calls (`bsr`/`lbsr`/`jsr`/`swi`), so subroutines read as delimited blocks. Insert only where not already blank; checkpoint.
3. **Blank line after `puls pc[,...]`** returns (same idea). Checkpoint.

Detect the opcode as the first token, or the 2nd if the line has a leading label; for `puls`, check `pc` is in the register list.

---

## Phase 3 — Fix failed disassembly

Disassemblers get code/data boundaries wrong in both directions. Run all detectors, then fix.

### Detectors
1. **Data labels reached by control flow** — a label on an `fcb`/`fdb`/`fcc` line that is a `bsr`/`jsr`/branch/`jmp` target. That "data" is really code. (`CopyStr` in c.prep: `fcb $A6,$A0,$A7,$C0,$30,$1F,$26,$F8,$39` = `lda ,y+ / sta ,u+ / leax -1,x / bne / rts`.)
2. **`fcb` blocks reached by fall-through** — the instruction before an `fcb` run is not a terminator (`rts`/`rti`/`bra`/`lbra`/`jmp`/`puls pc`). Code-as-data — UNLESS it's the legit **inline-data-after-`bsr`** idiom (routine reads params after its own call; usually flagged "call past inline data").
3. **Short `fcb` runs ending in `$39`/`$3B`** (rts/rti) that decode as a valid instruction stream.
4. **Strings/tables decoded as instructions** — the reverse, with no `fcb` to warn you, so run it every pass. Signals: (a) an agent names a label `Msg…`/`…Banner` but it sits on an *instruction* line; (b) an **ASCII-as-code cluster** — `$2A`(`*`)→`bpl`, `$20`(space)→`bra` — a run of `bpl`/`lsrb`/`coma`/`rorb`/`clra` with stray `fcb $4x`/`$5x`; (c) the region is reached **only** by `leax LABEL,pcr` feeding `I$Write`/`I$WritLn` (a string pointer — not a code callback, which gets `jsr ,x`). Find clusters: `grep -nE "^\s+(lsrb|lsra|coma|comb|rorb|rora|asrb|rolb)\s*$" f.asm`. (`MsgStackOverflow` in c.link.)

### Fix
Get the bytes from a listing (`lwasm <flags> --list=$SP/x.lst <f>.asm -o/dev/null`); replace code-left-as-`fcb` with instructions, or a decoded string with `fcc /.../` + `fcb` control bytes (`MsgStackOverflow fcc /**** STACK OVERFLOW ****/` + `fcb $0D`) — the reconstructed span must end exactly where the next real label's address begins. **Checkpoint** — lwasm must re-emit identical bytes. Then **re-run Phase 4**: deleting the fake instructions orphans any label whose only reference was one of them (`WriteBanner`/`StackUsed`/… in c.link).

---

## Phase 4 — Remove unreferenced per-instruction labels

Disassemblers often put an address label on **every** instruction (especially relocation/init preambles). A label that appears **exactly once** (only at its own definition) is unreferenced clutter. Remove it — blank the leading label token, keep the instruction and its column. Byte-neutral; checkpoint.

```python
toks = Counter(re.findall(r'(?<![A-Za-z0-9_.$@])([A-Za-z_][A-Za-z0-9_]*)(?![A-Za-z0-9_.$@])', src))
unref = {lbl for lbl in code_defs if toks[lbl] == 1}   # code_defs = labels defined on instruction lines
# for each match at column 0: line = ' '*len(lbl) + line[len(lbl):]
```

---

## Phase 5 — Fix direct-page-global & immediate mislabels

**Root cause:** the disassembler assumes the direct page is at page `$00`. So a DP global reference `ldd <$1F` (bytes `DC 1F`) gets resolved to the *code* label at the colliding low address `$001F`; and a symbol whose address doubles as a constant (e.g. `_start` = mod exec offset `$001D`) shows up as `#_start`. This bites when DP globals live in an undeclared `rmb` blob. If the disassembly already declared each DP var as its own `rmb` (as c.prep did), it never happens — c.prep was clean; c.comp needed the fix.

### Detect
- **DP globals:** code-line labels referenced **only** by data ops (`ldd`/`std`/`cmpd`/`lda`/`sta`/…), never by a branch/call/`leax`. Confirm via the listing that the reference bytes are direct-page (`DC 1F`, etc.).
- **Immediates:** defined labels used as `#Label`.

### Fix (byte-identical because you keep the exact value)
- **DP globals:** define each as `Name equ <exact value>` in a DP-globals block near the top (comment it, noting the DP=$00 collision), repoint the direct-page references to `Name`, blank the colliding code label, and add the equate. Name from the dominant use in the agents' per-site comments — a general-purpose global may serve more than one role.
  - Detect the globals and repoint them **by their direct-page encoding in the listing** (`DC 1F`, `9E 1F`, …) — only those operands are true direct-page global accesses that should carry the `Name` symbol.
  - **After blanking a labeled global, its label is now undefined for any *other*-mode reference** that the disassembler happened to symbolize (indexed-indirect `[L001B,y]`, indexed `L001B,y`, extended). Turn those into the **numeric literal** `$00NN`, NOT `Name` — the code base writes Y-relative/indexed accesses as bare numbers (and since `Y` is often the globals base, `[$1B,y]` already reaches the same global), so `Name` belongs only in direct-page operands. Putting the equate name inside `[Name,y]` reads wrong.
  - A **dual-use** offset (also a real branch/call target — e.g. `copybytes`, a startup convergence label) is the exception: keep its code label and add a *separate* equate, repointing only the direct-page data references so the code references keep resolving to the code label. Note the module's **exec entry `_start`** can be one of these (its address collides with a low global) — it's referenced by the **`mod` directive**, not a branch, so your dual-use test must count a `mod`/pseudo-op operand as a code reference or you'll rename `_start` in the header.
  - Bare `$00NN` references (never resolved to a label) are already valid numbers — repoint the direct-page ones for legibility; a missed one is harmless.
- **Immediates:** replace `#Label` with `#$value`.

Checkpoint.

---

## Phase 6 — Final verification, header note, report

1. **Final checkpoint:** assemble, `cmp` to baseline, confirm the CRC is unchanged. Report `✓ BINARY IDENTICAL`.
2. **Header note** — add to the `*` banner (today's date):
   ```
   * Annotated YYYY-MM-DD (Claude Code):
   *   - renamed disassembled labels to meaningful names
   *   - added inline comments to every instruction
   *   - re-disassembled <any code-as-data fixed, if any>
   *   - verified byte-identical to the original assembly (module CRC $XXXXXX)
   ```
3. **Report**: counts (labels renamed, comments added, unreferenced labels dropped, disassembly fixes), the CRC match, and any judgement calls (e.g. a global named for its dominant use). Note the file is uncommitted unless the user asks to commit.

## What NOT to do
- Don't add, remove, or reorder instructions (Phase 3 re-disassembly is the sole exception, and it must re-emit identical bytes).
- Don't rename OS-9 system calls / constants — they're not disassembled labels.
- Don't guess a name when context is truly ambiguous — use a descriptive placeholder and flag it in the report.
- Don't skip a checkpoint. A `✗` means revert and diagnose before continuing.
- Don't commit unless explicitly asked.

## Supporting files
- `scripts/apply_annot.py` — central rename/comment applier for the parallel path (`--phase renames|comments`, `--file`, `--out`, `--skip`).
- `scripts/dp_globals.py` — Phase 5 DP-globals fix (`<file.asm> <listing.lst> [--apply]`): finds direct-page globals from the listing encoding, builds the equate block, repoints direct-page refs, keeps dual-use code labels (incl. the `mod` exec entry) with a separate equate, and turns non-direct-page symbolized refs into numeric literals. Dry-run first (no `--apply`) to review the DUAL set, then apply and checkpoint.
