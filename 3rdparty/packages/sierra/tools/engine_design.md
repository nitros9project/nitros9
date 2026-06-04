# Phase 2 SID engine design notes

Status: **design only** — not yet implemented in `mnln.asm`.  This
document captures the decisions for the next implementation session so
work can resume in a known state.

## Goal

When the CoCo X-SID cartridge is present AND the currently-playing
sound has a SID stream in `sidSnd`, play the stream polyphonically
(3 SID voices, with voice 3 alternating between tone and noise as
encoded by the extractor).  When either condition is false, fall
through to the existing mono path (Phase 1 single-voice SID if X-SID
is present, original DAC bit-bang if not).

This is a strict superset of Phase 1 functionality.  All existing
fallback paths must continue to work.

## Memory layout (sidcar load)

* `sidDir` (404 bytes for SQ0:R) and `sidSnd` (~52 KiB) live as
  ordinary OS-9 files on the boot disk.  They are NOT loaded by
  `OS9Boot` and don't go through the AGI volume system at all — they
  are read by mnln directly via `I$Open` / `I$Read`.
* At first SID playback (or at engine init), mnln opens `sidDir` and
  reads its 404 bytes into a small static buffer.  Cost: negligible.
* For `sidSnd`, two options — pick at implementation time:
  1. **Pre-load everything at startup** into a dedicated bank.  Cost:
     52 KiB resident.  Benefit: no I/O during gameplay, no risk of
     "AGI fetched the FDC for a vol and now sidSnd can't be re-read".
  2. **Pre-load only the small SFX, load music on first use**.  Cost:
     a brief I/O hitch when a new music track starts (already happens
     for the existing AGI vol fetches).  Benefit: lower RAM usage.

   Recommend option 1 for simplicity.  The CoCo3 has 128 KiB minimum
   and the AGI engine itself already consumes most of the lower 64K
   bank — but a 52 KiB sidSnd fits in any spare bank.  Use OS-9
   `F$SRqMem` to allocate one 64 KiB system block; load sidSnd into
   it; map it on demand via the GIME MMU when reading SID notes.

   Cleanest realisation: load sidSnd into a contiguous range right
   after the AGI data area, store its 16-bit base pointer in
   `SidSndBase`.  Reads of the SID stream are then `ldd offset,x`
   relative to that base.

## Engine entry point

Insert into `PlaySound` (mnln.asm:9770) right after the SidProbe gate,
*before* the existing PlaySound mono loop:

```asm
PlaySound        pshs    y
                 clrb
                 ldu     $03,u           ; existing: U -> mono data buffer
                 ; XSID Phase 2 dispatch:
                 lda     >SidPresent,pcr ; tri-state
                 bne     PlaySoundProbed
                 lbsr    SidProbe
                 lda     >SidPresent,pcr
PlaySoundProbed  cmpa    #$01
                 bne     PlaySoundDAC    ; rename existing path
                 ; SID present - try the SidDir for this sound:
                 ldb     -1,u            ; (TBD how to recover sound num)
                 lbsr    SidLookup       ; returns C=1 if found, X=stream
                 bcc     PlaySoundPhase1 ; not in sidDir -> Phase 1 mono+SID
                 lbsr    SidPlayPoly     ; new polyphonic engine
                 ; return value semantics: see below
                 bra     PlaySoundFlush

PlaySoundPhase1  ; existing Phase 1 mono+SID path (unchanged)
                 lda     >$FF23
                 anda    #$F7
                 sta     >$FF23
                 lbsr    SidSetupVoice1
                 bra     PlaySoundLoop
```

**Sound number recovery**: at PlaySound entry, U was the sound node
pointer; cmd_sound did `ldu $01,s` then `lbsr PlaySound`.  Inside
PlaySound we did `ldu $03,u` to get the data buffer.  Before that line,
$02,u was the sound number.  Save it into B (or a static var) BEFORE
the `ldu $03,u` rewrite, then look it up in SidDir later.

## Timing source

Critical decision from rubber-duck critique: **do not use calibrated
busy-loops or interrupt-masked timing.**

Use NitrOS-9's 60 Hz system tick.  The kernel maintains a tick counter;
read it before and after each "wait for next tick" period.  The
authoritative tick variable in NitrOS-9 Level 2/CoCo3 is `D.Ticks`
(system DP, search the level2/coco3 defs for the exact location — it's
the byte incremented by the 60 Hz IRQ).  Read it via direct memory or
via `F$STime` /`F$Time` for an OS-level read.

Loop sketch:

```asm
                 pshs    cc              ; preserve I-bit
                 andcc   #$AF            ; ensure IRQ enabled
WaitTick         lda     >D.Ticks
NextTick         cmpa    >D.Ticks
                 beq     NextTick        ; spin until tick advances
                 ; tick advanced; service voices
                 lbsr    SidTickService
                 ; check end condition
                 bra     WaitTick
```

**IRQ rules**: enter the polyphonic engine with IRQs ENABLED so the
60 Hz tick keeps firing.  Only mask IRQs around the very short critical
section that pokes $FF7F=$30, writes a handful of SID registers, and
restores $FF7F=$FF.  Each per-voice write burst is ~6 instructions;
mask cost is negligible.

## Time accounting (`cmd_sound` interaction)

The current `cmd_sound` adds `PlaySound`'s D-register return to
`F$STime`'s seconds field, because the old DAC playback ran with
IRQs masked and the kernel clock didn't advance.

With IRQs enabled during SidPlayPoly, the kernel clock advances
naturally.  Therefore:

* `SidPlayPoly` MUST return `D = 0` so `cmd_sound`'s "add elapsed"
  catch-up code becomes a no-op.

Verify by looking at `cmd_sound` at line 9684 (`cmpd #$0000`) — that
check already short-circuits `D == 0`, so returning 0 is sufficient.

## SidTickService

Once per 60 Hz tick, for each of 3 voices:

```
1. Decrement countdown_v1.
2. If countdown_v1 != 0, skip to voice 2.
3. Else (note expired): advance v1_ptr by 5; read new note record.
   - If duration == FFFF: mark v1 done (gate off SID v1, freeze v1_ptr).
   - Else:
     - Critical section (orcc #IntMasks, MPI=$30):
       - Write FREQ_LO = note[2], FREQ_HI = note[3].
       - amp_wave = note[4].
       - If amp_wave low nibble == 0 (rest): write CR=0 (gate off),
         optionally write SR=0.
       - Else if low nibble == 1 (triangle): write SR = (amp_wave >> 4) << 4,
         write CR = $11 (triangle+gate).
       - Else if low nibble == 8 (noise): same but CR = $81.
     - End critical section.
     - countdown_v1 = duration.
4. Repeat for voice 2, voice 3 (with appropriate register addresses).
5. If all 3 voices are done, signal end-of-sound to outer loop.
```

Estimated cost: < 200 cycles per tick when no notes change, < 600
cycles when all 3 voices change.  Well within the budget (60 Hz tick =
14,924 cycles available at 0.89 MHz).

## Fall-back behaviour summary

| X-SID present | sound has SID stream | Path taken                  |
| ------------- | -------------------- | --------------------------- |
| no            | (don't care)         | original DAC bit-bang       |
| yes           | no                   | Phase 1 mono SID            |
| yes           | yes                  | Phase 2 polyphonic SID      |

In all cases the AGI script API is unchanged.

## Risk register

* **D.Ticks address**: needs verification in NitrOS-9 defs.  Plan B:
  use `F$Time` and a calibrated busy-loop hybrid.  Plan C: subscribe
  to the GIME timer IRQ with `F$IRQ` (heavier weight).

* **sidSnd memory residency**: 52 KiB is significant.  If OS-9 system
  block allocation pushes against game limits, fall back to load-on-
  demand per cmd_load_sound (the existing AGI path is exactly this
  pattern for vol resources).

* **Note alignment**: every voice stream is a strict run of 5-byte
  records.  No padding or alignment is required, but the engine must
  always advance U by exactly 5 — careless `leau 4,u` would corrupt
  the entire voice.

* **Big-endian assumption**: all duration / freq / amp_wave reads must
  go through BE accessors.  The 6809 `LDD` is BE-natural so this is
  effortless, but document it so future maintainers don't try to LE-
  swap.

* **mnln size**: each new code block grows mnln.  Prior pop/crackle
  fixes have already seen lwasm PCR-offset weirdness when storage was
  added near `SidPresent`.  Add new storage in a single block away from
  existing globals; use `lbsr` and `lbra` exclusively in the new
  routines.

## Out of scope (Phase 3+)

* Non-blocking music playback (currently the AGI script blocks on
  sound just like Phase 1).
* SID filter / pulse / sawtooth waveforms (extractor format already
  supports adding these by extending the waveform enum).
* Tracker-quality hand-authored SID music as opposed to PCjr-faithful
  reconstruction.
* Generalised NitrOS-9 `snddrv_xsid.sb` driver so non-AGI programs can
  use the SID.
