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

# 0a) padup256 has CRLF line endings; cygwin sh chokes on it unless
#     igncr is in effect. wildbits.mak's "PADUP ?=" honors this.
PADUP = bash -o igncr ./padup256 bootfile

# 0b) BASIC09 binaries build from the sibling nitros9-languages repo
#     (LANGUAGES above). Its build invokes python3, which on this box
#     needs the /usr/local/bin/python3 shim (else the bare name hits
#     the Windows Store alias stub) - installed 2026-08-29, spare
#     copy: wildbits-buildkit\pyshim-python3. runb is integrity-pinned
#     by RUNB_SHA256 in wildbits.mak.

# 1) DriveWire in the boot: dwio_serial + pipes + rbdw/x0-x3.
#    sc16550/t0 deliberately NOT included: OS9Boot must stay under
#    32,256 bytes (the booter loads it at $FE00-minus-size; below
#    $8000 it wedges at "Loading sector.") and /t0 shares the DW
#    UART at $FE60 anyway.
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

# 2) SHELLMODS merge order: with the stock alphabetical order (date
#    directly after shellplus) the toolshed-2.6-merged shell module
#    freezes before the prompt on Windows/cygwin64 build hosts.
#    Merging date/deiniz LAST is the proven clean ordering. Root
#    cause (suspected read past module end in shellplus) still open;
#    drop this override once fixed upstream.
override SHELLMODS = shellplus echo iniz link load save unlink date deiniz
