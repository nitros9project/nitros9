# WildBits Interrupt-Controller Hygiene (krn + clock)

**Date:** 2026-09-01
**Platforms:** F256 WildBits K2 and Jr2
**Status:** field-verified on the K2 (rc8 typematic test matrix, 2026-09-01), shipped in `wb/fixes_bundle`

---

## The problem

The FPGA interrupt controller (`IRQ_Controller_Jr.v`) has four groups,
each with PENDING ($FE20+n), POLARITY, EDGE and MASK registers. Its reset
input is wired to the board's **physical** reset only. A software restart
(`bootos9`, a debugger restart, a crash path) therefore inherits whatever
the previous session left behind: masks opened by drivers that never got
to Term, and pending bits latched by hardware that kept running.

In practice: after a session in which `wizi` had unmasked the WiFi bits in
group 3, the next kernel came up with those bits already unmasked and
pending before any driver had installed a handler for them — an
interrupt with nobody to service it, i.e. a storm or a wander waiting for
the first tick. Every driver assumed "reset means everything masked", and
that assumption was false.

## The fix

**krn.asm (cold start, `IFNE wildbits`).** Before any driver installs,
the kernel writes $FF to all four INT_MASK registers and then $FF to all
four INT_PENDING registers (write-1-to-clear), with absolute stores. The
controller is now in its power-on state regardless of how the kernel was
entered. Drivers still unmask their own bits at Init as before.

**clock.asm (Init).** Clock Init used to write whole INT_PENDING/INT_MASK
registers. That was harmless when it ran first, but on wildbits clock Init
runs at the first `F$STime`, *after* vtio and mousedrv have armed their
interrupts, so the absolute writes silently wiped mousedrv's unmask. Init
now clears only its own stale SOF pending bit and unmasks SOF with a
read-modify-write; every other driver's bits are preserved. The comment
block in the source explains the ordering constraint.

## Why the scrub lives in krn and not in clock

Clock Init is too late (see above) and drivers are too early to know
about each other. The kernel's cold start is the one point that runs
before everything and after nothing, and it is the only place where a
blanket "mask and clear all four groups" cannot disturb a live driver.

## Cost and verification

- 24 bytes of krn, paid for out of the CrashDump padding (now computed at
  assembly time, see `wildbits-mmu-slot-safety.md`); krn image still
  exactly 4,096 bytes.
- Verified alongside the rc8 typematic work: `wizi` then the remote shell,
  mouse (the riskiest case: mousedrv arms before clock Init), `wbreset`
  cycles, held-key + WiFi traffic soak — all clean. `bootos9` from a
  running system refuses by design ("Can't boot in RAM mode"), so the
  inherited-state scenario cannot normally occur on wildbits any more; the
  scrub remains defence in depth for debug and crash restarts.

## Related

- `wildbits-mmu-slot-safety.md` — the other half of this bundle.
- `defs/wildbits.d` group-3 bit names (INT_OPT_KBD, INT_WIZNET, …) were
  added in the same campaign; note that `INT_SDC_INS` is still defined on
  the wrong bit there (collides with INT_VIA1; hardware uses bit 7) — an
  open defs fix.
