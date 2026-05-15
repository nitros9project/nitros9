---
name: 6809-annotate
description: Annotate disassembled 6809/6309 source: rename generic labels (L0047, u0100) to meaningful names and add inline comments explaining each instruction's purpose. Invoke with a file path argument.
argument-hint: <path/to/file.asm>
allowed-tools: [Read, Edit, Bash, Grep]
---

# 6809 Assembly Annotator

You are an expert in Motorola 6809/Hitachi 6309 assembly language and the NitrOS-9 real-time operating system for the TRS-80 Color Computer. Your task is to replace generic disassembled labels with meaningful, descriptive names, and to add a short inline comment to every instruction line explaining its purpose.

## Invocation

The user invoked this skill with: $ARGUMENTS

If no file path was given, ask the user to provide one. If a path was given, operate on that file.

## Label Patterns to Rename

Disassemblers produce labels in these forms — rename ALL of them:

| Pattern | Meaning |
|---------|---------|
| `L` followed by 4 hex digits (e.g. `L0047`, `L01B5`) | Code label (branch target, subroutine entry) |
| `u` followed by 4 hex digits (e.g. `u0100`, `u000C`) | Direct page / U-register relative data variable |
| `D` followed by 4 hex digits | Data label |

Labels that are already meaningful (e.g. `Exit`, `MainLoop`, `skipspc`) must NOT be renamed.

## Procedure

### Step 1 — Read the file

Read the entire assembly source file provided.

### Step 2 — Map every disassembled label

Produce an internal table (do not show it to the user unless asked). For each label record:
- Where it is defined (the line it appears as a label)
- Every place it is referenced (branches, calls, loads, stores)
- The instruction(s) immediately at or after its definition
- The context: what operation surrounds its use

### Step 3 — Name each label

Apply these naming heuristics in priority order:

#### U-relative / direct-page data labels (`u` prefix)

These are memory offsets from the U (or direct page) register — they are data fields, not code.

- Look at how the location is used: `lda`, `sta`, `ldb`, `stb`, `clr`, `inc`, `dec`, `tst`, `leax ...,u` → it's a variable.
- Look at what value is stored/tested and in what context.
- Use `rmb` size to infer type: 1 byte = flag/char/byte value; 2 bytes = pointer/word; N bytes = buffer/array.
- Examples of good names: `pathDesc`, `retryCount`, `inputBuf`, `errorCode`, `devNum`, `curPos`, `screenRow`, `byteCount`.

#### Code labels (`L` prefix)

These are branch targets or subroutine entry points.

- If the label is the target of a `bsr` or `jsr` → it's a subroutine. Name it as a verb phrase: `readByte`, `skipSpaces`, `parseArg`, `writeOutput`, `openPath`.
- If the label immediately follows a `bcs`, `bne`, `beq`, `bhi`, `blo`, `blt`, etc. error branch → it's likely an error handler or exit point: `errorExit`, `notFound`, `eofReached`.
- If the label is jumped to from multiple places and leads to `os9 F$Exit` or `rts` → `exitOk`, `exitErr`, `returnOk`.
- If the label is the top of a loop (branched back to) → `loopTop`, `retryLoop`, `scanLoop`, `mainLoop` (qualified by context).
- If the label is at a conditional test or comparison → `checkXxx` where Xxx describes what is being tested.
- If the label is jumped to on a specific condition (e.g. after `cmpa #C$CR`) → name it for that condition: `gotCR`, `isCR`, `notDelim`.

#### NitrOS-9 / OS-9 specific patterns

Recognize these OS9/NitrOS-9 idioms and name accordingly:

- `os9 I$Open` followed by a `bcs` branch → the `bcs` target is `openFailed` or `openError`.
- `os9 I$Read` / `I$ReadLn` → nearby labels relate to `read`, `readLine`, `readData`.
- `os9 I$Write` / `I$WritLn` → `writeMsg`, `writeLine`, `printStr`.
- `os9 I$Close` → `closePath`, `closeFile`.
- `os9 F$Exit` → the enclosing label is the exit point; name it `exitOk` or `exitErr`.
- `os9 F$Mem` → memory allocation/deallocation context.
- `os9 F$Fork` / `F$Chain` → process management.
- `os9 F$STime` / `F$GTime` → time-related labels.
- `os9 I$GetStt` / `I$SetStt` → status/option operations; context determines name.
- `os9 SS$ComSt` / `SS$Opt` → comm-status or option set; `setComStat`, `setOpts`.
- After `ldd #size` + `os9 F$Mem` → `allocMem`, `getMemBlock`.
- `tfr s,u` or `leau ,s` at the start of a subroutine → this is frame-pointer setup; the label is the subroutine entry.

#### Module header labels

NitrOS-9 modules begin with a fixed header. If labels appear in the header region:
- First `fdb` → `modSize` or part of the module preamble.
- `fcb edition` → edition byte.
- Labels at `mod` macro or early `fdb`/`fcb` sequences → leave alone if they look intentional, otherwise name for their structural role.

#### Naming style rules

- Use **UpperCamelCase** (PascalCase) for all new names — every word starts with a capital letter, including the first.
- Keep names short but descriptive (2–4 words max).
- Prefix loop-top labels with `Loop` and subroutine labels with a capitalized verb.
- Suffix error-path labels with `Err` or `Fail`.
- Suffix success-path / clean-exit labels with `Ok` or `Done`.
- When the same logical concept appears multiple times (e.g. two different read loops), distinguish with a qualifier: `ReadLoop1` / `ReadLoop2` or context-specific names.
- Never use a name already present in the file as a different label.

### Step 4 — Establish assembly baseline

Before making any edits, confirm the source assembles cleanly and record the reference binary output. This baseline is used to verify every subsequent edit preserves the exact machine code.

#### 4a — Locate the original binary

The assembled binary typically lives adjacent to the source or in an `OBJS/` subdirectory. Search:

```bash
# Common NitrOS-9 output locations relative to the source
find "$(dirname <source>)" -maxdepth 3 \( -name "$(basename <source> .asm)" -o -name "*.dr" -o -name "*.dd" -o -name "*.mn" \) 2>/dev/null
```

If a binary is found, record its path as `ORIG_BIN`.

#### 4b — Capture baseline ident output

Run `os9 ident` on the original binary and save the output:

```bash
os9 ident "$ORIG_BIN"
```

Save this as `BASELINE_IDENT`. It will be compared against every assembled output.

#### 4c — Discover assembly command

NitrOS-9 uses `lwasm` from lwtools. Find the include paths and defines the file needs by:

1. Looking for a `Makefile` or `*.mak` in the source directory or its parents — grep for `LWASM`, `lwasm`, `--format`, `-I`, `-D` flags near references to this source file.
2. If a make target exists for this file, run `make -n <target>` (dry run) to capture the exact command.
3. As a fallback, construct the command manually:

```bash
lwasm --format=os9 \
      -I/path/to/nitros9/defs \
      -I/path/to/nitros9/level1/defs   \   # or level2/defs as appropriate
      --output=/tmp/wizard_test.bin \
      <source_file>
```

Save this command as `ASM_CMD`.

#### 4d — Test assembly of original source

Run `ASM_CMD` on the unmodified source. If it fails, report the error to the user and stop — do not proceed with renaming until the source assembles cleanly.

If it succeeds, run `os9 ident /tmp/wizard_test.bin` and confirm the output matches `BASELINE_IDENT`. If they differ, warn the user before proceeding.

### Step 5 — Plan inline comments

Before editing, build a second internal table mapping every instruction line to a short comment. Do not show this table unless asked.

#### Comment rules

- Write comments in plain English, one short phrase (5–10 words max).
- Explain the **purpose** of the instruction, not its mechanics — a reader who knows 6809 already knows what `lda ,x+` does; they want to know *why*.
- Exception: for non-obvious addressing modes or tricky idioms (e.g. `puls pc,b` as a combined return+restore, `coma` to produce $FF, `tfr s,u` for frame pointer), a brief mechanical note is welcome.
- Do not repeat what the label name already says. If the label is `readLineLoop` and the first instruction is `clra`, write `clear A before I$ReadLn` not `top of read line loop`.
- If a comment already exists and is good, leave it alone. If it is generic or wrong, replace it.
- Do not comment pseudo-ops (`rmb`, `equ`, `fdb`, `fcb`, `fcs`, `mod`, `emod`, `end`, `use`, `ifp1`, `endc`, `set`), blank lines, or comment-only lines.
- Do not comment `os9 XXX` lines — the system call name is self-documenting; only comment if the surrounding context needs explanation.
- Align all new comments to the same column as existing comments in the file (scan the file for the prevailing comment column; typically column 41 or 49).

#### NitrOS-9 / 6809 idiom glossary for comment writing

Use these translations when you see these patterns:

| Instruction / pattern | What to write |
|-----------------------|---------------|
| `coma` then `sta <var>` | `initialize <var> to $FF (invalid/unset)` |
| `clrb` | `clear error code` or `clear B` depending on context |
| `pshs u,x,a` | `save registers across system call` |
| `puls u,x,a` | `restore registers after system call` |
| `puls pc,b` | `restore B and return` |
| `lbsr label` | `call <label>` |
| `bsr label` | `call <label>` |
| `os9 F$Exit` | (skip — self-documenting) |
| `leax N,x` | `advance X by N` or `back up X by N` |
| `leax label,pcr` | `load PC-relative address of <label>` |
| `leay N,y` | `advance Y by N` |
| `tfr s,u` | `set U as frame pointer` |
| `leau ,s` | `set U as frame pointer` |
| `ldd #size` + `os9 F$Mem` | surrounding context → `allocate N bytes` |
| `cmpb #E$EOF` | `check for end-of-file error` |
| `cmpa #PDELIM` | `check for path delimiter (/)` |
| `cmpa #C$CR` | `check for carriage return` |
| `cmpa #C$SPAC` | `check for space character` |
| `cmpa #'-` | `check for option flag (-)` |
| `bcs label` | `branch if error (carry set)` |
| `bvs label` | `branch if overflow` |
| `bmi label` | `branch if negative (high bit set)` |
| `bpl label` | `branch if non-negative (high bit clear)` |
| `mul` | `multiply A×B → D` |

### Step 6 — Apply changes with checkpoint verification

Use the Edit tool to rename labels. Rename one label at a time using `replace_all: true` to catch all occurrences in a single pass. Work through the label list from Step 2 in order.

After all label renames are complete and a checkpoint has passed, add inline comments. Work through the file top to bottom, adding or replacing comments on instruction lines. Because comments never affect assembled output, you may add comments in larger batches (up to 20 lines at a time) using multi-line Edit blocks, then run a checkpoint after each batch to confirm the binary is still identical.

#### Checkpoint cadence — labels

After every 5 label renames (or when a logically related group is complete), run a verification checkpoint:

```bash
# Assemble modified source
<ASM_CMD substituting source path>

# Compare ident output
os9 ident /tmp/wizard_test.bin
```

Compare the `os9 ident` output against `BASELINE_IDENT`:
- Module name, size, type, language, attributes, and parity/CRC must all match exactly.
- If ANY field differs, stop immediately, report which label rename caused the mismatch, revert that rename with another `replace_all` Edit, and re-run the checkpoint to confirm recovery before continuing.

For an extra-precise check, also compare the binaries byte-for-byte:

```bash
cmp "$ORIG_BIN" /tmp/wizard_test.bin && echo "IDENTICAL" || echo "MISMATCH"
```

A `MISMATCH` here with a passing `os9 ident` is unusual — report it to the user but it is not necessarily a blocker (the module CRC is the authoritative check in NitrOS-9).

### Step 7 — Final verification

After all labels have been renamed and all comments have been added, run one final checkpoint:

```bash
<ASM_CMD>
os9 ident /tmp/wizard_test.bin
cmp "$ORIG_BIN" /tmp/wizard_test.bin && echo "BINARY IDENTICAL" || echo "BINARY DIFFERS"
```

Report the result to the user. If the binary is identical, the changes were purely cosmetic as expected. If it differs, investigate before reporting success.

### Step 8 — Add annotation header

After the final verification passes, insert a short annotation notice into the file's header comment block (the `*`-prefixed block at the top of the file, below the module description and history). Add it as the last item before the blank line that ends the banner:

```
* Annotated by /6809-annotate (Claude Code) YYYY-MM-DD:
*   - Renamed disassembled labels to meaningful names
*   - Added inline comments to every instruction
```

Use today's date for `YYYY-MM-DD`. This note is cosmetic and requires no further assembly verification.

### Step 9 — Report

Present the summary table to the user:

| Old Name | New Name | Rationale |
|----------|----------|-----------|
| L0047 | ParseArg | Entry point of `bsr` called during argument parsing |
| u000C | ZeroFlag | Single byte tested/cleared as a boolean flag |
| ... | ... | ... |

Keep rationale brief (one short phrase). List every renamed label. End with the final assembly verification result.

## What NOT to do

- Do not reformat or reorder code — only rename labels and add/replace comments.
- Do not add or remove instructions.
- Do not rename OS9 system call names (`I$Open`, `F$Exit`, etc.) — those are constants, not disassembled labels.
- Do not guess a label name if context is truly ambiguous — use a descriptive placeholder like `branch_L0047` and note it in the summary table as "ambiguous".
- Do not skip the baseline assembly step even if the original binary cannot be found — assemble the source first and use that as the reference.
- Do not add comments to pseudo-ops (`rmb`, `equ`, `fcb`, `fdb`, `fcs`, `mod`, `emod`, `end`, `use`, `set`), blank lines, or lines that are already comment-only.
