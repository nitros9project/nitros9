---
name: annotate-6809-6309-assembly
description: Annotate Motorola 6809 and Hitachi 6309 assembly source by adding clear comments to each code line and introducing sensible labels when labels are missing or weak. Use when Codex needs to explain, clean up, or reverse-engineer 6809/6309 assembly listings, ROM disassemblies, monitor source, game code, firmware, macros, data tables, or mixed code/data files without changing program behavior.
---

# Annotate 6809 6309 Assembly

Annotate 6809 or 6309 assembly in-place so the result is easier for a human to read, review, and continue editing. Preserve behavior, preserve the assembler dialect as much as possible, and default to comment-only edits unless the user explicitly asks for label changes.

## Workflow

1. Scan the file before editing anything.
2. Identify the assembler style already in use:
   - comment delimiter, which should be `;`
   - label column and indentation style
   - exported entry labels, which should be written with a trailing colon only when the same symbol has an `EXPORT` declaration
   - opcode casing, but normalize opcodes and register-like operand tokens to lowercase in the final output
   - directives such as `ORG`, `EQU`, `FCB`, `FDB`, `RMB`, `FCC`
   - local-label conventions, if any, including `@`-suffixed locals
3. Inspect the source header before code/data annotation:
   - preserve any existing meaningful title, copyright/license, author, usage, platform, and module-purpose text
   - if there is no OS-9-style edit history, add an `Edt/Rev  YYYY/MM/DD  Modified by` history block in the opening comment header
   - if a history block exists but uses weak labels such as only `History`, `Changes`, or loose dated notes, normalize it into the OS-9-style `Edt/Rev` format while preserving the information
   - use today's date only for a new annotation/update entry; do not invent historical dates, revision numbers, or author names
   - if the author/modifier is unknown, use `Codex` for the new annotation/update entry rather than guessing
   - keep the header in the file's existing block-comment style; for OS-9 assembly this is usually `*` comment lines with separator rows of `*` or `-`
4. Build a quick map of:
   - entry points
   - subroutines
   - branch and jump targets
   - loops
   - data tables
   - memory-mapped I/O or hardware-related constants
5. When disassembling or reverse-engineering function code, identify each function's stack usage:
   - parameters
   - return address area
   - saved registers
   - local variables
   - temporary stack slots
6. For each identified function, define assembler-friendly labels or symbols for stack offsets and use those names in comments and any requested label work instead of hard-coded stack numbers.
   - declare stack-offset equates immediately under the function label and above the code they describe
   - use the naming form `stk_...`
   - keep those stack-offset equate names all lowercase
   - make each stable stack-shape block start at offset `0`, meaning the current top of stack for that frame state
   - treat stack-offset equates as valid only for the current stack shape
   - after any stack manipulation such as `pshs`, `puls`, `leas`, `bsr`, `lbsr`, `jsr`, interrupt-frame setup, or local-frame allocation/removal, recompute the offset math before using `stk_...` names again
   - if a routine uses multiple truly different stable stack shapes, define a fresh set of `stk_...` equates for each stable state instead of reusing stale offsets
   - for short-lived stack changes that only shift an existing frame, do not repeat the same `stk_...` names in a second block; keep the original names and use exact byte math such as `stk_name+2,s`
   - when adjusting a stack-relative reference through a temporary push/pop window, account for the full byte width of the saved or restored registers, for example `pshs y` shifts later arguments by 2 bytes, `pshs d,x` shifts them by 4 bytes, and `pshs cc` shifts them by 1 byte
7. Document each identified function's stack frame clearly, including what lives at each named offset and how the routine uses it.
8. Identify raw numeric constants that correspond to known symbolic definitions:
   - OS calls and service codes
   - GetStat and SetStat selectors
   - OS error codes
   - module-header type and language fields
   - file mode, access, and attribute bits
   - any other project-wide assembler definitions already available through existing include files
9. Replace those raw constants with the proper symbols when doing annotation work, as long as the replacement preserves the exact numeric value and meaning.
   - prefer an existing project symbol over introducing a new local `equ`
   - if the correct shared symbol is missing, add it to the appropriate shared definition include instead of leaving a magic number behind
   - do not replace ordinary algorithmic constants, loop bounds, ASCII literals, bit masks, or scratch values unless they clearly correspond to an established symbolic definition
10. Add comments to each executable code line, except pseudo-ops that must remain uncommented.
    - Do not append comments to conditional pseudo-op lines such as `IFNE`, `IFEQ`, `IFGT`, `IFLT`, `IFGE`, `IFLE`, `IFP1`, `IFP2`, `ELSE`, or `ENDC`.
    - Apply this exception to equivalent `IF*` conditional directives in the assembler dialect.
    - Do not append comments to `use`, `nam`, `ttl`, or `pag` pseudo-op lines.
11. Add or improve labels only if the user explicitly asks for label work, except for stack-offset symbols defined as part of function-frame documentation.
    - when an exported symbol is also a label definition, write it with a trailing colon, for example `_foo:`, not `_foo`
    - do not add colons to internal/local labels unless they are explicitly exported
12. After annotating a file, run the pretty-printer:
   - `python3 /Users/boisy/Projects/coco-shelf/nitros9/scripts/asmprettyprint.py <annotated-file>`
13. Replace the file contents with the pretty-printed output.
14. Do not build, assemble, link, run tests, regenerate archives, or update disk images as part of this skill unless the user explicitly asks for that separate verification step.
15. Return the annotated assembly, and briefly note any uncertain interpretations.

## Required Output Rules

- Add a meaningful comment to every executable instruction line.
- Leave designated pseudo-op lines uncommented. Never append comments to `IFNE`, `IFEQ`, `IFGT`, `IFLT`, `IFGE`, `IFLE`, `IFP1`, `IFP2`, `ELSE`, `ENDC`, equivalent `IF*` directives, `use`, `nam`, `ttl`, or `pag`.
- Add comments to data and directive lines when their purpose is inferable.
- Preserve existing comments when they are useful. Refine them only when needed for clarity.
- Ensure the opening source header is in OS-9 assembly style. If no `Edt/Rev` history exists, add one in the opening comment block.
- A new or normalized OS-9 history block should use this shape:
  ```asm
  * Edt/Rev  YYYY/MM/DD  Modified by
  * Comment
  * ------------------------------------------------------------------
  *          YYYY/MM/DD  Codex
  * Annotated source and normalized comments.
  ```
- Do not invent module history. Preserve known history lines, and add only the current annotation/update line when adding a missing history block.
- Write every exported label definition with a trailing colon, for example `_foo:`, `ccdiv:`, or `Table_Name:`.
- Only apply the colon rule to symbols that have a matching `EXPORT` declaration in the same file.
- Do not add colons to internal helper labels, branch targets, loop labels, local data labels, or private subroutines unless they are exported.
- Do not add colons to `EXPORT`, `EXTERNAL`, `equ`, `rmb`, `fcb`, `fdb`, or other directive-only symbol declarations.
- Normalize opcodes to lowercase.
- Normalize register names and register-like operand tokens to lowercase, such as `a`, `b`, `d`, `x`, `y`, `u`, `s`, `pc`, `cc`, `dp`, `e`, `f`, `w`, `q`, and `md`.
- When disassembling function code, identify stack frames and define named stack-offset symbols for parameters, return-address area, saved registers, locals, and temporary stack slots.
- Use those named stack-offset symbols in comments and any requested label work instead of repeating raw stack-relative numbers.
- Declare those stack-offset symbols immediately under the function label, above the code they describe.
- Name stack-offset symbols in the form `stk_...`, using lowercase names.
- Start each stable `stk_...` block at offset `0`, representing the current top of stack for that frame state.
- Make each function's stack frame documentation explicit and easy to scan.
- Do not reuse a `stk_...` offset after the stack depth changes unless the offset math is recomputed for the new stack state.
- When a function has multiple stable stack states, define separate `stk_...` equates only when the frame is genuinely different; for temporary push/pop windows, keep the original names and use adjusted forms like `stk_name+N,s`.
- When using an adjusted form like `stk_name+N,s`, make `N` match the real byte count pushed or pulled, not the number of registers involved.
- Replace raw numeric constants with the correct shared symbols when those symbols already exist or should clearly exist in a shared definition include.
- If a shared symbol is missing but the meaning is clear, add it to the appropriate include and then use it instead of leaving the raw constant in the assembly source.
- Do not change instruction order, opcodes, addressing modes, numeric values, directives, branch targets, or code/data layout unless the user explicitly asks for something beyond comment annotation. Replacing a raw constant with an equivalent symbol is allowed and expected when it preserves the exact value.
- Default to comment-only edits.
- After completing annotation of a file, run `python3 /Users/boisy/Projects/coco-shelf/nitros9/scripts/asmprettyprint.py <file>` and use its output as the final file contents.
- Do not run `make`, `lwasm`, `lwlink`, `cmoc`, unit tests, archive rebuilds, disk-image updates, or any other build/verification command unless the user explicitly asks for a build or test after annotation.
- Do not rename labels, introduce labels, replace raw targets with labels, or change local-label style unless the user explicitly requests label work.
- If label work is explicitly requested, keep labels assembler-friendly: letters, digits, and underscores unless the source clearly uses another convention.
- If label work is explicitly requested and the code already has a coherent naming scheme, follow it.
- If label work is explicitly requested and the source already uses local labels ending in `@`, keep using them while they remain in scope.
- If label work is explicitly requested, treat `@` local labels as out of scope after a blank line; do not reference them past that boundary.
- If intent is uncertain, say what the instruction appears to do instead of pretending certainty.

## Labeling Guidance

Apply this section only when the user explicitly asks for label work.

Create labels only when they improve readability. Good candidates:

- subroutine entry points
- loop headers
- conditional branch destinations
- shared fallthrough targets
- dispatch tables
- string or byte tables
- hardware service routines

If the active assembler style supports local labels ending in `@`, prefer those for short in-scope branch targets instead of inventing a longer global label. Only do this while the target remains in scope; after a blank line, switch to a non-local label.

Use concise, descriptive names based on observed behavior. Prefer names like:

- `InitVideo`
- `CopySpriteLoop`
- `CheckKeyboard`
- `WaitVBlank`
- `PrintChar`
- `Table_Sine`
- `Ptr_ScreenBuffer`
- `ReturnIfBusy`

Avoid vague names like:

- `Label1`
- `Loop1`
- `Sub1`
- `AddrC123`

If you truly do not know the intent, use structured neutral names that still convey role:

- `Subroutine_C123`
- `BranchTarget_C1A0`
- `Loop_CopyBytes`
- `Table_BytePairs_C400`

See `references/annotation-patterns.md` for naming patterns and examples.

## Commenting Guidance

Write comments that explain purpose, not just syntax. Good comment styles include:

- effect on registers or flags when that matters
- why a branch happens
- what a memory location likely represents
- what a loop is copying, scanning, clearing, or counting
- what a data block is used for

Prefer:

- `LDA   ,X+          ; load next byte from source and advance pointer`
- `BEQ   Done         ; stop when terminator was reached`
- `STD   <$10         ; save 16-bit result in temporary work buffer`

Avoid restating the mnemonic in empty words:

- `LDA   ,X+          ; load A`
- `BEQ   Done         ; branch if equal`

When flags are the real story, mention them:

- `CMPA  #$0D         ; set Z when character is carriage return`
- `BNE   ReadNext     ; continue until CR is found`

When annotating functions that use the stack heavily:

- define stack-offset names near the function entry
- place stack-offset equates directly under the function label
- use lowercase `stk_...` names for stack offsets
- start each stable stack-layout block at `0` for the current top of stack, then count upward by bytes
- describe which offsets are parameters, saved registers, locals, or temporaries
- prefer comments like `load parameter pointer` or `store local byte count` over `load 6,s`
- if the source already has equivalent stack symbols, preserve and improve them instead of inventing a second scheme
- when the routine changes stack depth, stop and recompute the stack math before reusing any `stk_...` name
- if needed, create a second or third block of `stk_...` equates only when a genuinely new stable stack layout begins
- for short-lived temporary pushes, prefer `stk_name+N,s` instead of a second `stk_...` block, and make `N` reflect the exact number of bytes added to the stack

When a numeric literal looks like a known platform or project definition:

- prefer `F_*`, `I_*`, `SS_*`, `E_*`, mode, attribute, or other shared symbols over raw hex or decimal literals
- add the missing shared definition in the proper include file when the meaning is clear and reused
- keep literals only when they are genuinely local algorithmic values rather than externally defined semantics

## Mixed Code And Data

Disassemblies often mix instructions and tables. Before labeling a region as code:

- check whether branch or jump targets enter it
- check for impossible opcode flow
- check for repeating structured bytes
- check for pointer tables or string data

If a region appears to be data, annotate it as data rather than inventing executable behavior.

## 6309-Specific Notes

- Treat 6309 as a superset of 6809.
- Recognize 6309-only registers and operations such as `E`, `F`, `W`, `Q`, `MD`, `TFM`, `DIVD`, `DIVQ`, `MULD`, and bit-manipulation instructions.
- Comment 6309-only instructions in terms of their higher-level effect, especially for block transfer or 32-bit math.

## Response Shape

When the user asks for direct annotation work:

1. Return the edited assembly block.
2. Keep the code unchanged unless the user explicitly requested label work.
3. Call out uncertain areas such as guessed hardware registers, possible jump tables, or ambiguous data/code boundaries.

When the user asks for guidance instead of a rewrite:

1. Explain the likely control flow.
2. Suggest label names and comment wording.
3. Identify any ambiguous targets or data regions.
