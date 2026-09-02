# WildBits MMU Slot Safety — the "one character, then freeze" fork crash

**Date:** 2026-09-02
**Platforms:** F256 WildBits K2 and Jr2 (shared Level 2 sources)
**Status:** root cause proven from RAM dumps, fix field-verified on the K2
(`l2_wildbitsk2_wc4u`); the Jr2 carries the same sources and needs a rebuild
**Branch:** `wb/fixes_bundle` (vtio.asm, defs/wildbits_vtio.d, krn.asm, clock.asm; see also `wildbits-interrupt-hygiene.md`)

---

## Symptom

With four WizFi listeners running (`tsmon /wz0&` … `/wz3&`), the next fork
from a script — the trailing `echo` in `wiz4up`, or `proc`/`wbinfo` typed
on the console once remote shells were connected — printed exactly **one
character** and the machine froze. Three listeners were always "rock
solid". The same signature appeared on both machines, at stock speed and
in turbo, on every driver and kernel variant tried over August. Earlier
investigations chased the scheduler (a "cleared process descriptor on the
active queue at $5F00"), fork linkage, the tick VIRQ, the DAT refresh path
and a stale-PID reap; none of those was the cause.

Separately, the K2 had twice "lost" its flash drives to error 241
(E$Sect) under load. Same fault, different driver (see below).

## How it was found

The K2's FPGA debug port reads RAM independently of the halted CPU. A
healthy snapshot (four tsmons up) and a frozen one were dumped and
compared; the boot is deterministic, so the two 512K images differed in
only 25 bytes. Those bytes told the story:

- The process queues were intact and the kernel had **finished** the
  script — no echo process, no sub-shell, the shell back asleep on its
  keyboard read. The *console* had died, not the scheduler.
- Kernel page 0 had 13 scattered single-byte writes (the wizfi stat-page
  pointer, D.SysDAT's high byte, D.BlkMap's high byte among them) plus five
  random 2-byte stores elsewhere: the signature of a CPU executing garbage.
- The old "$5F00 corpse" was not a freed descriptor at all: it was a
  different block showing through system slot 2 when the dispatcher looked.

Tools: `Wildbits\FoenixMgrWin\k2dump.py` (whole-RAM dump; 64-byte
transfers, resets the machine on exit) and `k2post.py` (queue walker).
Two hard limits of the debug engine: never request more than $64 bytes
per transfer, and never read above the 512K RAM — either one desyncs the
engine until the board is **power-cycled** (resets do not clear it).

## Root cause

Every wildbits driver that needs to touch VKY, flash or RAM-disk memory
uses **system slot 2 ($4000–$5FFF)** as a temporary map window:

| driver | constant | what it maps |
|---|---|---|
| vtio | `MAPSLOT equ MMU_SLOT_2` (Level 2) | text $C2, attributes $C3, LUT $C0, font $C1, sound $C4 |
| mousedrv | `MAPSLOT equ MMU_SLOT_2` | $C0 for the pointer sprite |
| rbmem | `MMU_SLOT equ 2` | flash / RAM-disk sector blocks |
| wizfi | `WORK_SLOT equ MMU_SLOT_2` | (debug only, commented out) |

Each window masks IRQs, saves the slot's current block, maps its block,
does its work and restores the saved value. That is safe only while
nothing the kernel needs lives in slot 2.

But the Level 2 kernel's `F$SRqMem` allocates system pages **from the top
of the map downward**, and on wildbits the bootfile occupies $71–$FE, so
the free system pool is $20–$70. After about 17 pages of use (four tsmons
is enough) allocations cross into $40–$5F — slot 2 — and **process
descriptors land there**. A descriptor's second page is that process's
**system stack**.

vtio's character-write path did this:

```
    ldb   MAPSLOT          save the slot
    pshs  b                ... on the stack
    ldb   #$C2 / stb MAPSLOT / sta ,x        text block mapped, char written
    ldb   #$C3 / stb MAPSLOT / sta ,x        attribute block mapped
    lda   ,s+              <-- stack is in slot 2: this reads the ATTRIBUTE BLOCK
    sta   MAPSLOT          <-- restores junk into system slot 2
    puls  cc / rts         <-- pops garbage from the wrong block: CPU wanders
```

The first character is already on screen when the restore goes wrong,
hence exactly one character. The scroll, erase-line, palette, bitmap and
bell windows had the same pattern. Why script speed mattered: while the
sub-shell running `wiz4up` is alive it holds the $6F00 gap, so the echo
child's descriptor is allocated at $5700 (slot 2); a human-paced fork
after the script exits gets $6F00 (slot 3) and survives. Three listeners
never pushed the map into slot 2 at all.

rbmem's flash command path pushes return addresses **inside** a window
with a flash block mapped; with a slot-2 stack those pushes vanish into
the flash chip. That is the error-241 loss of /f0 and /f1.

## The fix (two layers)

1. **vtio.asm** — no window uses the stack for the saved slot any more.
   The value is parked in a new statics byte, `V.MapSav`
   (`defs/wildbits_vtio.d`), and no stack traffic crosses a block change
   inside a window (BellTone's and SetBitmap's temporaries moved to the
   IRQ-masked DP scratch `D.IRQTmp`). This works at Level 1 (the FEU build,
   window in slot 7) and Level 2 alike.
2. **krn.asm** (`IFNE wildbits`, 12 bytes paid from the CrashDump fill,
   module size unchanged) — after the kernel marks its global memory used,
   it also marks pages $40–$5F used, so the kernel **never allocates in
   slot 2 again**. Cost: 8K of system RAM. Benefit: every driver's window,
   including rbmem's and mousedrv's untouched inside-window pushes, is
   safe by construction.

Verify in a bootfile: krn contains `9E 4E 30 88 40 C6 20 6C 80 5A 26 FB`;
vtio no longer contains `35 04 F7 FF AA` (`puls b / stb MAPSLOT`) — the
two occurrences left in a bootfile belong to mousedrv and vtio's boot-time
InitDisplay, both harmless once slot 2 is reserved.

## Field verification (K2, 2026-09-02, `l2_wildbitsk2_wc4u`)

| test | result |
|---|---|
| `wizi` → `wiz4up` with its trailing `echo` (the deterministic repro) | completes, prompt returns |
| four remote clients connected, four shells | all alive |
| console `proc` and `wbinfo` with all shells up (the Jr2's classic crash) | clean |
| `dir` in each remote shell | separate clean streams |
| client disconnect → reconnect on the same channel | hangup emulation re-arms |
| `dir /f0`, `dir /f1` with everything up (rbmem window) | clean |

## Rules for driver authors (wildbits)

- Slot 2 is the drivers' window and the kernel stays out of it. Do not
  map anything into slots 0, 1 or 3–7 from a driver.
- Never park the saved slot value on the stack; use statics (or the DP
  scratch with IRQs masked). Assume the caller's stack can be anywhere.
- Inside a window, avoid `pshs`/`puls`/`bsr` while the mapped block is
  not plain RAM — flash swallows pushes, VKY blocks return them but from
  the wrong place if the block changes between push and pull.
- Windows stay IRQ-masked and short. The tick path (cursor, sound) opens
  the same window from interrupt context.

## How this relates to the WizCon4 work and the "keyboard freezes"

Three different faults were tangled together during the August/September
WizFi campaign, and they were routinely mistaken for one another. For the
record:

| what people saw | actual fault | where it is fixed |
|---|---|---|
| K2: first keystroke after starting a `tsmon` on a WizFi channel wedges the machine (cursor keeps blinking, keyboard dead) | The WizFi driver kept its shared stat-page pointer in `D.SWPage` (DP $03), which on the K2 sits inside the keyboard driver's row-state bytes ($00–$08); every keystroke zeroed the pointer and the driver then used the kernel's page 0 as its queue page | WizFi driver (`D.DbgMem`), on the WizCon4 branch — **not** part of this bundle |
| Both machines: with four WizFi listeners up, the next fork that writes to the console prints one character and freezes | **This document**: vtio's map window in system slot 2 vs. the kernel growing the system map into slot 2 | vtio + krn, this bundle |
| K2: /f0 and /f1 "lost" with error 241 under load | Same slot-2 fault through rbmem's flash window | krn reservation, this bundle |

Two points worth stating plainly:

- **tsmon plays no part in the mechanism.** A tsmon never writes to the
  console, so it never enters a vtio window; the tsmons survived with their
  own descriptors sitting inside slot 2. Four listeners simply cost enough
  system memory (a two-page descriptor plus path descriptors each) to push
  the kernel's page allocations down into slot 2 for the first time. Any
  other load that consumes ~17 system pages would do the same, and the
  victim is whichever process next writes to the screen from a slot-2
  stack.
- **Why script speed mattered.** While the `wiz4up` sub-shell is alive it
  holds the free gap at $6F00 (slot 3), so a fork launched from the script
  gets its descriptor at $5700 (slot 2) and dies; a fork typed by hand after
  the script has exited gets $6F00 and survives. That is the whole
  "human-paced works, script-speed dies" mystery.

The WizCon4 driver itself (four packet-mode channels, link gating, hangup
emulation, the first-connection fixes) is independent of this bundle and
ships on its own branch; it was the *test load* that finally made the
slot-2 fault reproducible on demand, which is how the root cause was found.

## Still open

- `dmem <block> …` on a non-zero block freezes the machine: F$CpyMem
  builds a temporary DAT image and copies through slots 5–6 with F$Move;
  same family as the known user-mode F$MapBlk problem. Not caused by the
  reservation (no slot-2 use in that path); not yet investigated.
- rbmem's `TfrSect`/`SendCmd` and mousedrv's `MakeMSPointer` still push
  inside their windows. Harmless while slot 2 is reserved; worth cleaning
  up for the same discipline as vtio.
- The Jr2 needs its disk and FEU blocks rebuilt from these sources and the
  same ladder run.
