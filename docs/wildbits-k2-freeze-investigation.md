# Wildbits K2: OS-9 Level 2 keystroke-freeze investigation

**Date:** 2026-08-19/20
**Hardware:** Wildbits K2 (Foenix F256 family), 6809 soft CPU (both Core1X
and Core2X FPGA cores reproduce), NitrOS-9 Level 2, DriveWire and SD boot.
**Symptom:** system freezes during or shortly after `sysgo`, on the first
keystrokes at the shell prompt, or when running `mdir`. Video stays alive;
the CPU stops responding. At its worst the machine could not reach a shell
for days.

This document summarizes the root-cause hunt for reviewers of the fix.
The raw experiment log (every build, disk, and hardware verdict, in order)
is in [wildbits-k2-freeze-ledger.txt](wildbits-k2-freeze-ledger.txt).
Every verdict was obtained by booting a staged disk on real K2 hardware.
Final state: **two code defects fixed, one recipe defect fixed, one
command bug confirmed but not fixed, and two loader/layout invariants
documented.** Both DriveWire and SD images, with the full module set
including WizFi, verified freeze-free.

## Bug 1: DoPoll/DoToggle must exit carry-SET on Wildbits

**Culprit:** mainline commit `4cdea53a8` ("Fix DoPoll returning carry set,
causing DoneIRQ to mask IRQs after non-clock IRQ", 2026-05-28), which
changed the shared `DoPoll`/`DoToggle` exit in `level2/modules/clock.asm`
to `clrb` (carry clear).

A git bisect landed exactly on this commit: parent `cba089576` boots
clean, `4cdea53a8` freezes on keystroke. Instruction-level A/B on
hardware at that commit, all else byte-identical:

| exit instruction          | Carry | Result  |
|---------------------------|-------|---------|
| (parent, no change)       | set   | clean   |
| `clrb`                    | clear | freezes |
| `andcc #$FE` (carry only) | clear | freezes |
| `orcc #$01`               | set   | clean   |
| parent + 1 `nop` pad      | set   | clean   |

Carry state is the entire story: same-size instructions differing only in
the carry bit flip the machine between clean and frozen.

**Why the K2 needs carry set:** the kernel's `DoneIRQ` masks interrupts
when carry is set. On the Wildbits this mask-on-carry pacing is
load-bearing; with carry clear the machine livelocks. The mainline change
is presumably correct for CoCo hardware, so the fix is `ifne wildbits`
guarded: `orcc #$01` at the `DoToggle` exit (the fall-through end of
`DoPoll`).

**The fix must live at the active `DoToggle`/`DoPoll` exit.** An earlier
attempt placed it after a `bsr DoPoll` that sits inside the `ifne
picothing` block of clock.asm — dead code on wildbits builds. That
mistake was invisible on DriveWire disks (see bug 1b) and cost a second
investigation.

The same change also writes `INT_MASK_0` absolutely (SOF-only) at clock
init instead of read-modify-write, so stale unmasked interrupt sources
cannot survive a soft reboot.

## Bug 1b: the same defect via the non-clock IRQ path (the "WizFi freeze")

With the fix accidentally dead at HEAD, DriveWire images ran clean but
any image carrying WizFi froze. WizFi looked guilty for a day; it is
innocent. The mechanism:

- On a clock (SOF) interrupt, execution continues past `DoPoll` and the
  exit carry comes from later code — benign either way. Hence DriveWire
  disks (no device IRQ sources) never exposed the dead fix.
- On a **non-clock** interrupt, `SvcIRQ` takes `NoClock`, which points
  `D.SvcIRQ` directly at `DoPoll`; its return carry goes **straight to
  DoneIRQ**. With the `clrb` ending, that path livelocks.
- WizFi is the K2's only non-SOF interrupt source, so "disks with WizFi
  freeze" was a perfect — and perfectly misleading — correlation.

Proven by module-transplant A/B on SD images: HEAD kernel + Jul-15 clock
(carry-set exit) runs clean; Jul-15 kernel + HEAD clock (carry-clear
exit) freezes; binary diff of the two clocks shows the exit instruction
as the only semantic difference. Driver-side workarounds (interrupt
throttling, forcing carry state in the driver's ISR) were tested and are
unnecessary: the kernel's mask-on-carry pacing is itself the flow
control.

## Bug 2: shell merge order (position-sensitive freeze)

The recipes flow merges `date` and `deiniz` into `CMDS/shell`
(`SHELLMODS`). With `date`'s module placed immediately after `shellplus`
in the file, the K2 freezes at keystrokes; the identical nine modules
with `date`/`deiniz` moved to the end run clean (hardware A/B, order-only
change, same bytes). All submodules common to the two layouts are
byte-identical, and duplicated modules (`date`, `deiniz`, `unlink` also
live in `utilpak1`) are byte-identical copies, so no version conflict
exists.

Fix: `SHELLMODS = shellplus echo iniz link load save unlink date deiniz`
— the classic pack becomes an exact byte prefix of the merged file.

**Open question:** why a byte-identical `shellplus` behaves differently
depending on which module's bytes follow it (suspected read past the
module's own end, unproven). Minimal reproducer: swap `Date`'s and
`Echo`'s positions after `Shell` in `CMDS/shell`.

## Fix 3: WizFi interrupt mode on K2 (`f7a2703ce` revert)

`f7a2703ce` ("Set WizFi to use timer interrupt on K2") replaced two
`beq InstallTimer0` machine-ID tests with unconditional `bra`, forcing
Timer0 polling on all machines. Restoring the conditionals returns the
K2 to its hardware WizFi interrupt, which runs clean once bug 1b is
fixed. (During the investigation both modes froze — because of bug 1b,
not the mode choice.)

## Bug 4 (confirmed, not fixed here): `modem` crashes on a missing device

Typing `modem /wz` on a system whose bootfile contains no WizFi driver
or `/wz` descriptor hard-crashes the K2 (confirmed live on hardware).
The command's missing-device error path needs its own audit. Until then,
`modem /wz` must not appear in `startup` on disks without WizFi.

## Boot-loader invariants discovered (SD path)

Documented because violating either produces "can't locate the kernel in
the bootfile", and nothing in the build checks them:

1. **`Krn` must be the final module in OS9Boot**, and
2. **`Krn` must start exactly 4096 bytes before end-of-file** (equivalently
   on a 256-byte boundary with the standard 4061-byte kernel + 35 pad).

The recipe's `krn`-last convention plus `padup256` satisfies both today
by construction; any change to the kernel's size or the bootfile tail
can silently break them.

## What was ruled out

- **FPGA/hardware:** both CPU cores reproduce identically; a fully
  timing-clean build plus temporarily disabling DMA and debug CPU-halt
  paths changed nothing.
- **The WizFi driver:** byte-for-byte the Jul-15 module runs clean on a
  fixed clock; ISR flow-control and carry-contract patches were tested
  and reverted as unnecessary.
- **SOLdrv/fSOL**, bootfile composition, missing modules, `Init`
  contents, `sysgo`, `utilpak1`, startup contents, kernel (`Krn`)
  changes, and pure module-position shifts of the kernel — all
  exonerated by transplant/inert-padding A/B disks.
