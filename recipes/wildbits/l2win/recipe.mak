# ===================================================================
# l2win - Level 2 disk recipe for Windows / cygwin64 / toolshed 2.6
# build hosts. Identical to ../l2 except for the two overrides below,
# which wildbits.mak picks up via its "-include recipe.mak" hook.
# The `override` directives win over wildbits.mak's own definitions,
# so wildbits.mak needs no changes and l2 stays stock.
# ===================================================================

# 0) GnuWin32 make 3.81 cannot parse drive-letter paths in rules
#    (broken $(abspath) + the ":" read as a target separator ->
#    "multiple target patterns" at the $(MODDIR)/basic09 rule when
#    NITROS9DIR comes from the Windows env as e:/...). Force
#    colon-free drive-relative paths; native tools resolve them
#    against the current drive (E:) and the E:\cygwin64\cygwin64
#    junction makes them work for cygwin coreutils too.
override NITROS9DIR := /cygwin64/home/taylo/nitros9
override LANGUAGES := /cygwin64/home/taylo/nitros9-languages
# export so recursive sub-makes (sys-assets/fonts/backgrounds) see the
# corrected paths instead of re-reading e:/... from the environment
export NITROS9DIR LANGUAGES

# 0a0) ALWAYS format with -e (extend to full image size): rules.mak's
#      OS9FORMAT_SD is the one variant defined WITHOUT -e, and only
#      the disk rule's own command line has been adding it. Pin it
#      here so every branch's build gets a full-size image even if
#      that rule changes. (A duplicated -e is harmless.)
OS9FORMAT_CMD = $(OS9FORMAT_SD) -e

# 0a) The bootfile padder (2026-10-04): smartpad256 pads at the BEGINNING
#     to whole pages like padup256, then past the page counts the kernel
#     cannot reserve (31-32, 63-64, 95-96, 127-128 pages: Krn's F$SRqMem
#     reservation sits two pages above the bootfile and, when the bootfile
#     starts in the last two pages of an 8K block, F$AllImg maps every slot
#     above one block low). Ceiling 40,448 bytes ($6000-$FDFF; slot 2 is the
#     drivers' reserved window). Bootfiles over 32,768 also need the
#     unsigned copy loop in bootos9/os9boot (same date). igncr: CRLF-safe.
PADUP = bash -o igncr ./smartpad256 bootfile
override MAX_BOOTFILE_SIZE = 40448

# 0b) BASIC09 binaries build from the sibling nitros9-languages repo
#     (LANGUAGES above). Its build invokes python3, which on this box
#     needs the /usr/local/bin/python3 shim (else the bare name hits
#     the Windows Store alias stub) - installed 2026-08-29, spare
#     copy: wildbits-buildkit\pyshim-python3. runb is integrity-pinned
#     by RUNB_SHA256 in wildbits.mak.

# 1) DriveWire in the boot: dwio_serial + pipes + rbdw/x0-x3.
#    sc16550/t0 deliberately NOT included: OS9Boot had to stay under
#    32,256 bytes (the booter loads it at $FE00-minus-size; below
#    $8000 it wedged at "Loading sector." - the copy loop's signed
#    BGT, fixed 2026-10-04; see 0a for the new limits) and /t0 shares
#    the DW UART at $FE60 anyway.
ifeq ($(LEVEL),2)
override BOOTMODS = krnp2 ioman init \
	$(SCF) \
	$(RBF) \
	dwio_serial $(PIPE) $(DRIVEWIRE_RBF) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA) \
	krn
else
override BOOTMODS = krn krnp2 ioman init \
	$(SCF) \
	$(RBF) \
	dwio_serial $(PIPE) $(DRIVEWIRE_RBF) \
	$(CLOCK) \
	sysgo shell_21 \
	$(BOOTMODS_EXTRA)
endif

# 1b) "make clean" here also cleans the font/background outputs that
#     wildbits-sys-assets generates INTO the source tree
#     (level1/wildbits/sys/{fonts,backgrounds}) - the stock recipe
#     never recurses there, leaving them behind as untracked files.
#     Added as a prerequisite of clean, so wildbits.mak's own clean
#     recipe is untouched. "-" keeps clean going if a sub-clean fails.
#     NOTE: this file is included before wildbits.mak's "all" target,
#     and make's default goal is the FIRST target seen - declare all
#     first (bare; wildbits.mak adds its prerequisites later) so a
#     plain "make" still builds instead of cleaning.
all:
clean: clean-sys-assets
.PHONY: clean-sys-assets
clean-sys-assets:
	-$(MAKE) -C $(FONT_DIR) -f $(NITROS9DIR)/recipes/support/wildbits-fonts.mak clean
	-$(MAKE) -C $(BACKGROUND_DIR) -f $(NITROS9DIR)/recipes/support/wildbits-backgrounds.mak clean
