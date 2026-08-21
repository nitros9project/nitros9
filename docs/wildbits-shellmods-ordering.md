# Why the SHELLMODS merge order decides whether the K2 boots

*A report for anyone staring at `wildbits.mak` line "SHELLMODS = ..." and
refusing to believe a concatenation order can hang a computer. It can.
Here is everything we know, how we know it, and what we still don't.*

## Background: what CMDS/shell actually is

On the Wildbits recipes, `CMDS/shell` is not one program. The makefile
rule

```
$(MODDIR)/shell: $(addprefix $(MODDIR)/,$(SHELLMODS))
	$(MERGE) ... >$@
```

concatenates nine separately-assembled OS-9 modules into a single file:
`shellplus` (the shell itself, ~7000 bytes) followed by a set of small
built-in commands (`echo`, `iniz`, `link`, `load`, `save`, `unlink`, and
in the newer recipes also `date` and `deiniz`, ~34-241 bytes each).

Merged module files are normal OS-9 practice: when the kernel loads the
file (at boot, when `sysgo` forks the shell), it walks the `$87CD` module
headers, and *every* module in the file enters the module directory at
whatever offset it occupies. Consequence: **the SHELLMODS list order is
the physical memory layout** of those nine modules in the loaded block.
`shellplus` is always first; the list decides whose module header sits
at byte 6999, immediately after `shellplus` ends.

## The symptom

With the recipe's original order —

```
SHELLMODS = shellplus date deiniz echo iniz link load save unlink
```

— the K2 dies at or before reaching the shell prompt (early testing also
saw it as freezes at the first keystrokes). With `date`/`deiniz` moved to
the end —

```
SHELLMODS = shellplus echo iniz link load save unlink date deiniz
```

— the same system boots and runs. Nothing else changed.

## The evidence (why we're sure it's really the order)

This was established by direct A/B on hardware, using surgically edited
disk images rather than rebuilds, so that *only* the variable under test
changed:

1. **Order-only, byte-identical test.** Two disks were prepared whose
   `CMDS/shell` files contained the *same nine modules with
   byte-identical content and identical total size (7650 bytes)* — the
   only difference being whether `date`+`deiniz` sat immediately after
   `shellplus` or at the end of the file. (In the second layout, the
   classic seven-module pack is an exact byte prefix of the file.) The
   first disk froze; the second ran. Same day, same hardware, same
   everything else. There is no content difference to blame — only
   position.

2. **Every shared submodule compared byte-identical** between the two
   layouts before the test, so no "different build of date" explanation
   survives.

3. **Duplicate modules were ruled out.** `date`, `deiniz`, and `unlink`
   also exist inside `utilpak1` (loaded by `startup`). The copies are
   byte-identical, so OS-9's duplicate handling keeps one cleanly — and
   `unlink` is duplicated even on known-good disks, proving duplication
   per se is harmless here.

4. **The other suspect of that debugging era was absent.** These A/B
   disks were DriveWire images carrying **no WizFi driver at all**, so
   the (since-fixed) WizFi interrupt-init bug that caused several other
   freezes cannot explain these verdicts.

5. **Independently re-confirmed later** on an SD image and a fresh
   branch: original order = dead before shell; reordered = boots.

## When it strikes

The death window coincides with first contact: `sysgo` forks the shell,
the kernel loads the merged file (all nine modules enter the module
directory), the shell starts and processes `startup`. On the poison
layout the machine never gets a usable prompt.

## What we do NOT know: the mechanism

This is the honest part. The observable is that **a byte-identical
`shellplus` behaves differently depending on which module's bytes follow
it in memory** — `Date`'s header versus `Echo`'s header at offset 6999.
That can only happen if something reads or walks **past a module
boundary**. Candidate mechanisms, none yet proven:

- `shellplus` itself overrunning its own end — a table scan, string
  search, or indexed access that runs past the module and behaves
  differently depending on the bytes found there;
- the kernel's module-directory builder or `F$Fork`'s module search
  mis-stepping through the loaded block under some header arrangement;
- a Level-2 quirk where a module's offset within its 8K block feeds some
  mapping or size calculation incorrectly.

Related circumstantial history: months before this was isolated, adding
5 bytes of debug code to `sysgo` visibly changed freeze behavior —
consistent with a layout-sensitive defect existing somewhere in this
system for a long time.

**The reorder is therefore a dodge, not a fix.** A real bug still exists
in `shellplus` or the kernel; the current SHELLMODS order simply arranges
the furniture so it isn't triggered. Treat the ordering as load-bearing
until the underlying bug is found and fixed.

## The Jr2 datapoint: same poison, different verdict

The Jr2 boots fine with the poison order. This was checked properly:
`shellplus`, `date`, `deiniz`, and `echo` assemble **byte-identical**
under `-Djr2` and `-Dk2` (platform-neutral sources), so the Jr2 is
running the *exact same merged file* the K2 dies on. Conclusion: the
boundary overrun presumably happens on both machines and reads the same
garbage - what differs is **what the resulting misbehavior lands on**.
The K2's system map and hardware put live targets in the blast radius
(a larger, differently-composed bootfile shifts where the pack's block
sits; vtio maps video/CLUT blocks into the CPU map; the 4-LUT $FFA0 MMU
and I/O decode differ), while the Jr2's arrangement leaves the same
stray access harmless. The trigger is platform-independent; the
lethality is platform-dependent - which also means the Jr2 is a control
machine for the hunt below: probe both with the same poison disk and
the point where their execution diverges names the guilty consumer.

## How to hunt the real bug (when someone has the appetite)

- **Minimal reproducer:** two otherwise-identical disks differing only in
  a `Date` <-> `Echo` position swap after `shellplus`. (Archived copies
  from the original investigation exist as the HYBRID5/HYBRID6 test
  disks.)
- **Localization technique:** the K2's RGB LEDs make excellent state
  probes — write saturated color values (`lda #$FF` / `sta`, never
  read-modify-write: some registers don't read back) to the caps-lock
  LED color registers ($FE0D-0F, gates: $FE00 bit 5 + $FE06 bit 0) at
  suspect points: shellplus entry, its command-table scan, the kernel's
  module walk. Boot the failing layout; the lamp color at death names
  the last checkpoint passed.
- **What would count as the real fix:** finding the overrun (a bounds
  bug in shellplus's scan, or in the kernel walker), fixing it, and then
  demonstrating that *both* SHELLMODS orders boot clean.

## Practical guidance

Until then: do not "tidy" the SHELLMODS line back to alphabetical or
historical order, and if you add a module to the pack, add it *after*
the classic seven (`shellplus echo iniz link load save unlink`) and
re-verify with several boots — single-boot verdicts have burned us
before on this platform.
