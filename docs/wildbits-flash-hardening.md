# WildBits Flash Driver and Core Hardening (/f0, /f1)

**Dates:** 2026-08-29 / 2026-08-30
**Changes:**
- `level1/wildbits/modules/rbmem.asm` (erase completion polling,
  program-verify timeout, Init cleanup)
- FPGA cores: Jr2 `v8_rc5` (frame-timed flash write strobe;
  `TyVKy2K2turbo_MMU_FNX6809.v` + `CFP95139AJR2_Top.v`)

## Background

Formatting and writing the onboard flash drives had decayed into a
grab-bag of symptoms: the K2 formatted `/f1` *sometimes*, failing other
runs with error #243 right after the disk-name prompt; the Jr2 failed
`format /f1` every time with #211 ("bad sector") when physical verify
was requested, froze when it wasn't, and later — after partial fixes —
produced the strangest symptom of all: formats and copies that
"succeeded" instantly with no error while writing nothing at all.
Flash *reads* worked throughout on both machines (both boot from
flash), which is what made the failures look mysterious.

The investigation found three independent defects — two in the driver,
one in the FPGA core — stacked on top of each other. Each machine and
speed mode exposed a different combination.

## Defect 1 (driver): erase "wait" was a clock-calibrated guess

The SST39 sector-erase command takes **18ms typical, 25ms maximum**.
The driver's post-erase wait was a CPU spin loop whose iteration count
had been hand-calibrated to ~19ms at the stock 6.29MHz clock — *between*
the chip's typical and maximum. Any erase slower than ~19ms was still
running internally when the driver began programming bytes into it;
those programs failed verify and surfaced as **random #243 during
format** — random because erase time genuinely varies erase-to-erase,
and because only *dirty* sectors need erasing at all (a freshly-erased
chip formatted fine, deepening the mystery). Any CPU-speed change
(the turbo cores) shrank the wait further.

**Fix:** the wait is replaced by **DQ6 toggle polling** — the chip
alternates DQ6 on every read while an erase is in progress, so two
consecutive equal reads mean the erase is *actually* complete. This is
chip-reported truth, correct at any CPU speed; a generous poll bound
(~200ms) only guards against hangs. The same technique was already
used (correctly) by the byte-program verify loop.

## Defect 2 (driver): program-verify timeout seeded with garbage

The byte-program verify loop counted down an 8-bit timeout register
that was initialized from **an arbitrary pre-program flash read**. Over
erased flash that read $FF (255 polls — fine); over dirty content it
could be 1 or 2, timing the verify out after a couple of polls and
throwing spurious #243 *independent of any real timing problem*.
**Fix:** deterministic 256-poll bound (`clrb`). Also removed in the
same pass: a leftover debug screen-poke in the Init-time cache
allocation that ran unconditionally (corrupting one byte of whatever
memory block was mapped at the time) and masked `F$AllRAM` errors.

## Defect 3 (FPGA core, Jr2): flash write strobe missed chip timing in turbo

With the driver fixed, the K2 formatted reliably at both speeds and
the Jr2 at stock speed — but the Jr2 in **turbo** produced the
silent-no-op signature: `format` completed without errors while
writing nothing, `copy` returned instantly with no file landing.

The tell was the driver's debug flash-ID display: at stock speed the
probe read **$BFD7** (the SST39VF040's ID); in turbo it read **$C000**
— not a corrupted ID but *raw array data*, meaning the chip had never
entered ID mode: **the command-sequence writes themselves were being
ignored**. With no ID match the driver classified the device as plain
RAM, writes went to a path the flash ignores (reads still returned
the old array contents — hence error-free "successful" formats that
verified against the previous format's data).

Root cause: both machines drive the flash write-enable pin from the
**raw CPU R/W line**, so the WE edges that latch each command byte are
defined by whatever bus frames *surround* the write. Under the turbo
cores, the neighboring instruction fetches run shortened (24-tick)
frames, shifting those edge relationships. The K2's flash variant
tolerates the shifted geometry; the Jr2's SST39VF040 does not — its
write-cycle minimums were no longer met, and every command write
bounced. (Flash *reads* use a properly gated OE and full-length
frames in all modes, which is why reads never failed.)

**Fix (Jr2 core):** the MMU now generates a **frame-timed WE pulse**
for flash write frames — low from tick 19 to 27 of the 32-tick write
frame: 45ns pulse width (chip minimum 40ns), 65ns of address/CS
setup, data held to frame end. Flash writes never take shortened
frames, so the chip sees **byte-identical write geometry in turbo and
stock**. The change is wired only in the Jr2 top (under the turbo
build flag); the K2 keeps its proven raw strobe and its cores are
untouched.

## Defect 4 (FPGA core, Jr2): one write strobe, three chips

The first spin of the shaped strobe (v8_rc5) gated the pulse on the
flash chip-select alone — and immediately produced a new symptom: the
**cartridge** stopped accepting writes on the Jr2 (its ID probe read
$A811 — raw array bytes — while the same cart worked fine in the K2),
even though cart *reads* were perfect.

The Jr2's external bus turns out to have **one shared write strobe
serving three chips**: the onboard flash, the cartridge (which is
addressed through the *EXRAM* decode at MMU blocks $80+, not the
flash decode), and the RTC. Gating the shaped pulse on the flash
select starved the other two — the cart entirely, and the RTC's
writes would have followed (silently breaking hardware clock-setting).

**Fix (Jr2 core v8_rc6):** the shaped pulse fires for **flash and
EXRAM/cartridge** write frames — mirroring how the bus's read
output-enable already treats those selects symmetrically — while
**RTC selects pass the raw strobe through** unchanged: the RTC is a
slow device with RDY-inserted wait states whose accesses have always
worked on the raw strobe in both modes, and a fixed-width pulse would
not fit its stretched cycles. Each of the three clients now gets the
strobe its timing actually requires.

## Field verification (2026-08-30)

- **K2** (core v8_rc5): repeated `format /f1` passes at stock and
  turbo — the random #243 is gone regardless of how dirty the flash
  is. Cartridge writes via `/c0` confirmed working.
- **Jr2** (core v8_rc6, turbo on): ID probes read $BFD7 (onboard) and
  $BFD5 (cartridge); `format /f1`, file copies to `/f1` and `/c0`,
  and `setime` to the hardware RTC all succeed. Stock-speed operation
  unchanged.

## Notes for maintainers

- The erase and program waits are now **chip-reported** (DQ6 toggle),
  never clock-calibrated. Any future timing loop in this driver should
  follow the same rule: poll the device, bound the poll, never count
  cycles.
- The silent-no-op failure mode is worth remembering: when the ID
  probe fails, flash writes do not error — they quietly do nothing
  while reads keep returning stale data. A format that "succeeds"
  suspiciously fast, or a copy that lands nothing, means *check the
  probe first* (the `fDEBUG` build of rbmem paints the 4-character
  chip ID on screen on every Init/Write — expect $BFD6/$BFD7 on the
  Jr2, $BFC8/$BFC9 on the K2).
- **The Jr2 external bus has ONE write strobe and THREE clients**
  (onboard flash, cartridge via the EXRAM decode, RTC). Any change to
  that strobe must account for all three — the v8_rc5 spin proved the
  failure mode by fixing one client and silently breaking the other
  two. The cartridge is *not* behind the flash chip-select; it lives
  at MMU blocks $80+ in the EXRAM decode.
- Deployment pairing: the driver fixes are core-independent; turbo
  flash **and cartridge** capability on the Jr2 requires core
  **v8_rc6+** (v8_rc5 covers onboard flash only). **Recommended
  cores: `wildbits_jr2_6809_v8_rc6` and `wildbits_k2_6809_v8_rc6`**
  (the K2's flash behavior is unchanged since rc3; rc6 simply builds
  both machines from the same source level).
