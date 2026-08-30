# l2win — WildBits Level 2 disk recipe for Windows build hosts

`l2win` builds the same Level 2 SD disk as `../l2`, but works out of
the box on a Windows / cygwin64 / GnuWin32-make-3.81 / toolshed 2.6
host. All differences live in `recipe.mak`, picked up through
`wildbits.mak`'s existing `-include recipe.mak` hook (the same
mechanism `l1dw` uses); `wildbits.mak` and `l2` are untouched.

Usage, from this directory:

    make clean PLATFORM=k2      (or jr2)
    make PLATFORM=k2

No environment setup is required — no NITROS9DIR/LANGUAGES arguments,
no SHELLOPTS, no PATH preparation.

## The SHELLMODS ordering bug (proven empirically)

The stock `SHELLMODS` merge order is alphabetical:

    shellplus date deiniz echo iniz link load save unlink

A `shell` module merged in that order **on this host** produces a
system that freezes before the shell prompt ever appears — proven
repeatedly during the 2026-08 DriveWire campaign: the same source
tree, same toolchain, same disk contents, differing only in merge
order, reproducibly freezes with `date` directly after `shellplus`
and reliably boots with:

    shellplus echo iniz link load save unlink date deiniz

(`date`/`deiniz` moved to the end). Multiple independent disks
confirmed both directions across many reboots.

The suspected root cause is shellplus reading past its own module end
into whatever the merge places next (interacting with how this
toolshed 2.6 build pads merged modules), but that has NOT been
confirmed at the code level — only the ordering fix is proven. A
related unexplained symptom, likely the same defect: a stray
high-bit character occasionally appears at the shell prompt when a
sub-shell exits (harmless, backspaces away). Once the real bug is
found and fixed upstream, the `override SHELLMODS` in `recipe.mak`
should be dropped.

## Extra cleaning of level1/wildbits/sys outputs

The `wildbits-sys-assets` target generates font and background
binaries **into the source tree** (`level1/wildbits/sys/fonts/`,
`level1/wildbits/sys/backgrounds/`). The stock recipes never clean
those, so they accumulate as untracked files in git status. `l2win`
adds a `clean-sys-assets` prerequisite to `clean` that runs those two
support makefiles' own `clean` targets. `wildbits.mak`'s clean recipe
itself is not modified.

(`recipe.mak` also declares a bare `all:` first — it is included
before `wildbits.mak` defines `all`, and make's default goal is the
first target seen; without this, a plain `make` would clean instead
of build.)

## BASIC09 inclusion

BASIC09 (`basic09 runb inkey syscall wild`) is on the disk. The
binaries build from the sibling **nitros9-languages** repo (post-2026
languages split), expected at `../nitros9-languages` next to this
repo. Its build invokes `python3`; on Windows the bare name resolves
to the Microsoft Store alias stub, so the build host carries a
`python3` shim in cygwin's `/usr/local/bin` pointing at the real
interpreter. `runb` is verified against the `RUNB_SHA256` pin in
`wildbits.mak` during every disk build.

## Everything else recipe.mak fixes (with the why)

- **Drive-letter paths**: GnuWin32 make 3.81 has a broken `$(abspath)`
  and reads the `:` of `e:/...` in a rule line as a second target
  separator (`multiple target patterns` at the basic09 rule).
  `NITROS9DIR`/`LANGUAGES` are forced to colon-free drive-relative
  forms and exported so recursive sub-makes inherit them.
- **Full-size images**: `OS9FORMAT_SD` is the one format variant in
  `rules.mak` defined *without* `-e`; `recipe.mak` pins
  `OS9FORMAT_CMD = $(OS9FORMAT_SD) -e` so images always come out
  full-size regardless of the disk rule's own flags.
- **padup256 CRLF**: the pad script has CRLF endings; it is run via
  `bash -o igncr` so the shell doesn't require SHELLOPTS from the
  environment.
- **DriveWire in the boot list**: `dwio_serial`, the pipe modules,
  and `rbdw`+`x0`-`x3` are merged into OS9Boot. `sc16550`/`t0` are
  deliberately excluded: the booter loads OS9Boot at `$FE00` minus
  its size, so past 32,256 bytes the load address drops below `$8000`
  and boot wedges at "Loading sector." — and `/t0` points at the same
  $FE60 UART DriveWire uses, so the two cannot run together anyway.
