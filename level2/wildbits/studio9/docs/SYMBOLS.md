# UME symbols and storage ownership

S9ModuleDir owns 48 bytes appended after MidiInPath; S9ModuleLeaf owns the next
two bytes and points to the filename portion within that buffer. Startup captures
the inherited execution device, forming `/device/s9/`. Overlay loads and the GUI
fork append their module names there. The GUI constructs its font pathname in a
temporary 48-byte stack buffer. Neither process changes its execution directory.
F$Link/F$UnLoad still use module names; this changes no unload-list membership.

The assembler's master definitions file is **`../cmds/equates.asm`**. All 20
executable UME modules and the `/dwm` descriptor select their section of that
file. The generated `s9_d0` module contains image data, not shared variables.
The source artwork's labels remain with their emitted image bytes.

This consolidation preserves the previous module bytes. It does not relocate
existing data, change the Fran protocol, or change playback.

## What `$10FE` means

`KeepGind` owns two bytes at `$10FE–$10FF` in the UMusE3 process. s9s saves the
last full score redraw's event index there. It is **not a callback slot**.
The drive-menu pointer `pDriveMenu` owns `$112D–$112E`; its 83-byte hit-table,
drive-name and count payload is dynamically allocated above the static area.
`pConfigCache` owns `$112F�$1130`; its heap buffer retains path changes until exit.
`AuditionSavedFlags` owns **two bytes**, `$1131�$1132`. Its former one-byte
allocation at `$10AF` let `std` overwrite `PianoSym` at `$10B0` and left the
piano using that wrong source block after audition. `$10AF` remains reserved.
`MidiInPath` owns `$1133`: the interrupt-captured `/mi` path plus one (zero closed).
`UmeStaticEnd` is `$1134`, the first byte available to the C heap.
Fran owns two new bytes after its appended arrow glyphs: `FrMidiPath` (its
status-only `/mi` path plus one) and `FrMidiShown` (last drawn IRQ activity).
`MIDrv` owns its own system-state fields and a separately allocated 2 KB RX ring;
these do not alias either application process.

The original callback table occupies `$0351–$03B6`: 51 two-byte routine pointers.
`uinit` installs the callbacks that the current program uses. The older C source
does not contain the later `pbeep` slot at `$0377`, so blindly copying its offsets
would shift subsequent pointers by two bytes. `UmeData_pputchar` at `$0383` is
the `charput` callback. The table must be initialized before calling overlays
that use it. These are synchronous indirect subroutine calls.

## Address spaces and names

| Group | Meaning |
|---|---|
| Shared editor definitions | UMusE3 and s9b–s9y share one process data area. |
| `UmeData_*` | Canonical legacy editor data addresses; local C names alias these. |
| `FrData_*`, s9gui section | Fran is a separate OS-9 process with its own data area. Equal numeric addresses do not alias the editor. |
| `*_reserved_XXXX` | Existing address whose full purpose or extent is unresolved. Reserved, never available for new storage. |
| Importer/configuration frame fields | Offsets from a temporary stack frame, usually addressed through U. Not absolute memory allocations. |
| Hardware constants | Device registers, masks and layout constants; not process RAM. |
| `equ *` and emitted code/image labels | Remain beside their code/data; they are module-relative, not fixed shared RAM addresses. |

The scoped sections also preserve local aliases and constants. They are selected
with `UME_SCOPE_<MODULE>` before including `equates.asm`; identical field names
in two importers need not have identical stack offsets.
Every named stack field is marked `STACK OFFSET` in its definition comment.
Track-record fields say `STACK-BACKED TRACK RECORD OFFSET`; frame sizes and
buffer/record capacities have separate explicit labels and are not addresses.

## Inventories

These CSV files are generated from the current source, not manually maintained:

- `symbols.csv`: every master definition, numeric value, scope, expression,
  original comment, C-source clue and master-file line.
- `symbol-references.csv`: every memory-instruction operand, including direct,
  extended, indirect, indexed and immediate forms. An immediate number is not
  automatically a pointer. Access width describes the instruction, not an
  inferred array allocation.
- `routine-labels.csv`: code/data labels across all port assembly and includes,
  with source locations. A label is not assumed to be a callable routine.
- `storage.csv`: owned/reserved process ranges, their sizes and purposes.
- `callbacks.csv`: the 51 original pointer slots and the routines actually
  assigned by the current `uinit`; unassigned slots are explicitly marked.

Regenerate after source changes with:

```text
python tools/check_symbols.py --write
```

`make verify-symbols` runs before module assembly. It rejects overlapping owned
regions, unresolved master definitions, unregistered absolute data symbols,
new raw absolute process-data operands, and numeric definitions that escape into
individual modules. It also checks the heap boundary and rejects direct word accesses crossing an allocation boundary. The five intentional paired clears are explicitly registered with `@word`. The development self-test
deliberately puts `pDriveMenu` back at `$10FE` and requires rejection.

## Allocation procedure

1. Consult the master file and references for **all** modules, not only the caller.
2. Identify the process and lifetime. Keep temporary state in an explicitly sized
   stack frame where appropriate; preserve the existing C stack/register ABI.
3. For new persistent editor storage, append a named range at the end of the
   existing static allocation, register its exact byte size with `@alloc`, and
   advance `UmeStaticEnd`. Review remaining heap/stack space before adding it.
4. For Fran, separately review its data/arena/heap boundaries. Do not use the
   editor's addresses or route drawing outside Fran's owned rows through it.
5. An alias needs an explicit `@alias` owner and a reviewed lifetime contract.
   Adding an alias declaration is not proof that two uses can safely coexist.
6. Run the symbol guard during development and keep every consumer dependent on
   `equates.asm`. Do not invent free space from gaps in grep results.

## Original C evidence and limits

Original source used for this audit:

`E:/cygwin64/home/taylo/CocoRepo/OS-9/APPS/C_RMA/ULTIMUSE3/UMUSE/`

- `bdp.c`: main direct-page declarations, preference bytes, event state and
  playback state. Its own header requires centralization for fragmented routines.
- `bglob.c`: global arrays, instrument values/names, score filename, parts and
  staves; includes `fcnptrs.h` for routine pointers.
- `fcnptrs.h` and `bin.c`: callback declarations and initialization.
- `FRANS/fran.c`, `fglob.c`, `fgraf.c`, `fcurse.c`, `fterm.c`, `fprint.c`:
  the renderer's independent state and original ownership.

The C snapshot predates the 10.11 executable and the WildBits port. C matches
recorded alongside definitions are **clues**, not permission to infer offsets or
sizes from declaration order. Current assembly operands and existing proven
layout mappings remain the address authority.

Existing overlapping lifetimes are recorded, not silently rewritten:

- The editor reuses old mouse/playback DP fields for context menus and controls.
- Playback borrows `MenuStates` for the piano queue while menus are inactive.
- Browser page state occupies **stack offsets** `$0760–$0767` within
  `FilePickMenu`'s `$078A`-byte frame. It does **not** occupy absolute RAM
  `$0760–$0767` and does not overlap the instrument table at `$075F`.
  The original audit incorrectly compared these separate address spaces.
- Fran reuses retired fields for its port statics, and `FrFocusMask` and
  `FrNoDirty` intentionally name the same byte.

All legacy space and unknown gaps are reserved. The static scanner cannot prove
the bounds of every runtime-computed pointer, establish every lifetime, or decode
instruction bytes still stored in legacy FCB blobs. This inventory is not a claim
that every historical alias is safe. It prevents those uncertainties from being
treated as unused storage.

## Browser C stack frames

`UMUSE/diskio.c` supplies the original `fnamenu` and `diread` local/argument
names. The current assembly, including every push/pop and the C math helpers
that consume their stacked operand, establishes the actual offsets. Register
variable `cp` resides in U; it is not an invented stack slot.

| Routine | Stack fields at the allocated frame base |
| --- | --- |
| `FilePickMenu` / C `fnamenu` | `rec` +0, `nlines` +2, `nrecs` +4, `fnames` +6 |
| `ReadDirList` / C `diread` | `chan` +0, `count` +2, `name[30]` +4, `buff[32]` +$22 |

The first 72 filename slots end at offset `$0755`; only 64 entries are displayed
per page. The C array reserved two additional slots, whose otherwise unused
tail now holds the eight paging bytes. The frame still ends at `$078A`.
Saved registers, return addresses and caller arguments are named separately.
For example `DirNameOff+2,s` accounts for a two-byte argument already pushed.
Released compiler scratch below S is marked `STACK TEMP`, not called a local.

`@frame` / `@field` records let the build-time guard reject fields outside their
frame or overlapping other fields in that same frame. Stack fields are never
compared with absolute process allocations. The naming pass traces stack depth
through both routines, including branch joins, and preserves every numerical
operand value. The definitions-only assembly guard requires unchanged module
bytes; no new runtime storage or instructions are needed.

The generated `stack-uses.csv` inventories S-relative operands throughout the
app, including still-numeric operands. A numeric displacement is not a proven
C variable name: each routine's pushes and register usage must be traced before
naming it. This pass does not claim every legacy stack operand has been named.

Toolbox overlay owns FrToolY (two bytes) and FrToolUp (one byte), appended
to GUI storage before FrDataEnd. FrToolSave=$4000 is a virtual rectangle-save
token, not a process address: it uses bytes 56856..61271 of the existing 64 KB
FrSave allocation. Existing window-save tokens stop below 50148. The saved
rectangle is columns 16..63, 23 rows, including the brush box. No new RAM blocks
or modules are allocated; unloading is unchanged. The old background is restored
before moving the toolbox or repainting staves; a screen fill invalidates it.

The captured rendered toolbox uses FrToolImage=$3A00, a virtual save token
for arena bytes 50712..55127. It does not overlap the window-save ceiling
50148 or the background save at 56856..61271. Drag start captures it once;
each move restores the old background, saves the new background and pastes
this image through the existing DMA rectangle path. No modules, process
storage or allocated RAM blocks were added; unloading is unchanged.

Movable toolbox origin (2026-10-05): ToolX owns two appended editor bytes;
FrToolX owns two appended GUI bytes. Both initialize to column 16. Dragging
clamps the left column to 0..32, so the 48-column rectangle always fits the
80-column screen. Main-frame hit testing, icon picking, brush-box placement,
icon rendering and pixel-line decorations all derive X from this origin.
The four-byte drag frame holds Y and X-column grab deltas; each is documented
as a STACK OFFSET. ToolHide restores the background before FrToolX changes.
The $99 drag protocol carries Y, phase ($80 capture/$81 move), and X column.
No RAM blocks or modules were added; allocation/unloading remains unchanged.

2026-10-05 MIDI opening-measure notation: ifirstnote is a two-byte field
appended to S9I's private U-based stack frame. Validation finds the earliest
sounding note. At the first measure boundary, a fully silent opening measure
gets native notation-only rests for every imported part, inserted in timestamp
order. Its silence and all later MIDI timestamps remain unchanged. Bar-number
packets carry distinct high/low bytes and the opening marker is rendered.
No modules or persistent allocations were added; unloading is unchanged.

2026-10-05 MIDI opening-silence completion: irestend is a two-byte STACK OFFSET
after ifirstnote in S9I's private U frame. It prevents duplicate opening rests
while covering multiple empty measures and the partial measure before the first
note. MIDI timestamps and playback messages remain unchanged. No module or
allocation arrangement changed; unloading remains unchanged.
