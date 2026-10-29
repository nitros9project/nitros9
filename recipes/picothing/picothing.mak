# Pico-Thing shared build recipe (Level 1 and Level 2, 6809 and 6309).
#
# The Pico-Thing boots the way the Wildbits does: a small raw REL loader
# (rel_picothing, in the Pico's firmware) finds OS9Boot by name, loads it
# so that it ends at Bt.End, and jumps to krn with the bootfile's start in
# X and its size in Y.  The kernel adopts the bootfile in place, so there
# is no boot module, no F$Boot, no OS9Kernel file and no OS9Gen.  The two
# levels compose OS9Boot differently:
#
#   Level 2  OS9Boot = krnp2 krnp3_perr init ioman + drivers + shell, padded
#                      at the start so they end at $E000, then a gap to
#                      Bt.Start and krn padded to Bt.End-Bt.Start
#   Level 1  OS9Boot = krn krnp2 init ioman sysgo + drivers + shell
#
# Leaf recipes (l1/, l2/, l1dw/, l2dw/, *_6309/) set LEVEL, CPU and any
# recipe.mak overrides.  PORT stays "picothing" for every variant so all
# sources and the port defsfile (which sets Level) resolve to the shared
# level1/picothing and level2/picothing trees.  See README.md.

PORT ?= picothing
RECIPE ?= picothing
CPU ?= 6809
MACHINE ?= Pico-Thing
MODDIR = .mods
include ../../rules.mak
-include recipe.mak

ifeq ($(strip $(LEVEL)),)
  $(error LEVEL not set — build from a leaf recipe such as l2/)
endif

# Assembler search: the port module/command dirs (which also supply the
# port defsfile that sets "Level"), then the generic level trees and the
# kernel dirs.
AFLAGS += -I.
ifeq ($(LEVEL),2)
AFLAGS += -I$(L2PD) -I$(L2PMD) -I$(L2MD) -I$(L2MD)/kernel
endif
AFLAGS += -I$(L1PD) -I$(L1PMD) -I$(L1MD) -I$(L1MD)/kernel
ifeq ($(LEVEL),1)
# The Pico-Thing has no port-specific Level 1 modules directory — every
# Level 1 module is shared, either generic (level1/modules) or a
# Pico-Thing source in the Level 2 port tree.  Reach the latter by vpath
# (NOT by -I, which would make the level1/cmds/defsfile "use ../defsfile"
# chain resolve to the Level 2 port defsfile).  Add the port defs dir so
# that chain instead resolves to level1/picothing/defsfile (Level 1);
# rel_picothing's own "use dwinit/..." includes resolve relative to their
# source file, so no -I into the Level 2 module tree is needed.
AFLAGS += -I$(L1PD)/defs
vpath %.asm $(L2PMD)
endif
AFLAGS += $(AFLAGS_EXTRA)

# Libraries.  Level 2 links the level system library (6809 or 6309); level
# 1 links libcoco.  All levels also link libnet and libalib.
ifeq ($(LEVEL),2)
  ifeq ($(CPU),6309)
    NOS9_LIB = libnos96309l2.a
    LINK_LIB = -lnos96309l2
  else
    NOS9_LIB = libnos96809l2.a
    LINK_LIB = -lnos96809l2
  endif
  LIB_NAMES = $(NOS9_LIB) libnet.a libalib.a
  LFLAGS += -L$(LIBDIR) $(LINK_LIB) -lnet -lalib
else
  LIB_NAMES = libcoco.a libnet.a libalib.a
  LFLAGS += -L$(LIBDIR) -lnet -lcoco -lalib
endif
LFLAGS += $(LFLAGS_EXTRA)

DISTRONAME = NOS9_$(CPU)_L$(LEVEL)
DISTROVER  = $(DISTRONAME)_$(NITROS9VER)_$(RECIPE)

# ---------------------------------------------------------------------------
# Module groups (bare names, built into $(MODDIR))
# ---------------------------------------------------------------------------

# PATA IDE partition descriptors: master /I0-/I7 are always present; the
# slave /J0-/J7 descriptors are wired in only on the mega images (MEGA=1,
# set in mega.mak).  Slave IDE is untested on hardware, so the base images
# leave the eight slave descriptors out of the bootfile.
IDE_PARTS = i0_pt.dd i1_pt.dd i2_pt.dd i3_pt.dd \
            i4_pt.dd i5_pt.dd i6_pt.dd i7_pt.dd
ifeq ($(MEGA),1)
IDE_PARTS += j0_pt.dd j1_pt.dd j2_pt.dd j3_pt.dd \
             j4_pt.dd j5_pt.dd j6_pt.dd j7_pt.dd
endif

# /DD follows the boot transport: DriveWire drive 0 (ddx0.dd, driver rbdw)
# for DriveWire builds, the PATA master otherwise (ddi0_pt.dd, llide_pt).
# A DriveWire board with no PATA drive would otherwise hang on the first
# /DD access (chd /DD at coldstart, chx /dd/cmds in startup) spinning in
# the IDE driver.  The IDE partition descriptors /I0-/I7 stay in the boot
# file either way, dormant until an HD is attached.
ifeq ($(BOOTDEV),dw)
DEFAULT_DD = ddx0.dd
else
DEFAULT_DD = ddi0_pt.dd
endif
RBF_CORE = rbf.mn rbsuper.dr llide_pt.dr $(DEFAULT_DD)
SCF      = scf.mn sc6850.dr term_pt.dd nil.dr nil.dd zero.dr zero.dd
PIPE     = pipeman.mn piper.dr pipe.dd
# DriveWire: virtual disks /X0-/X3 and the /P printer.  /P is in the
# bootfile rather than /Modules because attaching a runtime-loaded SCF
# device fails with E$NoRAM on Level 2 (F$SLink into the tight system map
# at I$Attach).
DW       = rbdw.dr dwio.sb x0.dd x1.dd x2.dd x3.dd scdwp.dr p_scdwp.dd
SYSGO    = sysgo

# Graphical console (loadable, not in the bootfile)
GFX      = vtio_picothing.dr copico term_gfx.dd
# Video console (M5 multi-window), one driver VConW serving /W0 (window 0
# = root/panel, the base console) and the overlays /W1../W7.  In the
# bootfile, not loadable: attaching a runtime-loaded SCF device here fails
# with E$NoRAM (F$SLink into the tight 64K L2 system map at I$Attach).  One
# driver keeps a single owner of the pico's one keyboard stream.
WIN      = vconw.dr w0_pt.dd \
           w1_pt.dd w2_pt.dd w3_pt.dd w4_pt.dd w5_pt.dd w6_pt.dd w7_pt.dd
# Extra DriveWire descriptors (loadable).  The mega images instead build
# every DriveWire virtual channel into the bootfile, where it can be
# attached: the wildcard /N, /N1-/N13, /MIDI and the virtual windows
# /Z1-/Z7.  The DriveWire /Term stays loadable, as it would clash with
# the console's /Term.
ifeq ($(MEGA),1)
DW_EXTRA = ddx0.dd term_scdwv.dt clock2_dw
DW      += scdwv.dr n_scdwv.dd \
           n1_scdwv.dd n2_scdwv.dd n3_scdwv.dd n4_scdwv.dd \
           n5_scdwv.dd n6_scdwv.dd n7_scdwv.dd n8_scdwv.dd \
           n9_scdwv.dd n10_scdwv.dd n11_scdwv.dd n12_scdwv.dd \
           n13_scdwv.dd midi_scdwv.dd \
           z1_scdwv.dd z2_scdwv.dd z3_scdwv.dd z4_scdwv.dd \
           z5_scdwv.dd z6_scdwv.dd z7_scdwv.dd
else
DW_EXTRA = ddx0.dd scdwv.dr term_scdwv.dt n_scdwv.dd \
           n1_scdwv.dd n2_scdwv.dd n3_scdwv.dd n4_scdwv.dd clock2_dw
endif

ifeq ($(LEVEL),2)
CLOCK    = clock clock2_ds12885
RAMDISK  = rammer.dr r0.dd
SHELLBOOT = shell
# OS9Boot: everything essential to reach the shell.  krnp3_perr installs
# the full-text F$PErr; krnp2 runs it at boot.
BOOTFILE = krnp2 krnp3_perr init ioman $(RBF_CORE) $(IDE_PARTS) $(SCF) \
           $(WIN) $(CLOCK) $(PIPE) $(RAMDISK) $(DW) $(SYSGO) $(SHELLBOOT) \
           $(BOOTMODS_EXTRA)
else
CLOCK    = clock clock2_ds12885
SHELLBOOT = shell_21
BOOTFILE = krn krnp2 init ioman $(SYSGO) $(CLOCK) $(SCF) $(RBF_CORE) \
           $(IDE_PARTS) $(DW) $(PIPE) $(SHELLBOOT) $(BOOTMODS_EXTRA)
endif

# Loadable modules placed in /Modules.  The Level 2 base image carries the
# graphical console and the extra DriveWire descriptors; the Level 1 base
# floppy has no /Modules directory.
ifeq ($(LEVEL),2)
LOADMODS = $(GFX) $(DW_EXTRA)
else
LOADMODS =
endif

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

ifeq ($(LEVEL),2)
CMDS = asm attr backup bawk binex build cmp copy \
       date dcheck debug ded deiniz del deldir devs dir dirsort disasm \
       display dmem dmode dsave dump dw echo edit error exbin \
       format free gfxtest grep help httpd ident inetd iniz irqs link list load login \
       makdir mdir megaread merge mfree minted mmap modpatch more padrom park \
       pmap proc procs printerr prompt pwd pxd rename save setime \
       sleep smap tee telnet tmode touch tsmon unlink verify vidbusy vidload vlink \
       wdemo wintest wtest wshow wroute wgfx gemtest keytest xmode \
       $(CMDS_EXTRA)
# Merged command packs added to /CMDS alongside the plain commands
CMDS_MERGED = shell utilpak1
else
CMDS = asm attr backup bawk binex build cmp copy cputype \
       date dcheck debug ded deiniz del deldir devs dir dirsort disasm \
       display dmode dsave dump dw echo edit error exbin format \
       free grep help httpd ident inetd iniz irqs link list load login makdir \
       megaread mdir merge mfree minted more padrom park printerr procs prompt \
       pwd pxd rename save setime shellplus shell_21 sleep \
       tee telnet tmode touch tsmon unlink verify xmode \
       $(CMDS_EXTRA)
CMDS_MERGED = utilpak1
endif

CMDS_DISK = $(CMDS) $(CMDS_MERGED)

SHELLMODS = shellplus echo iniz link load save unlink
UTILPAK1  = attr copy date del deldir dir display list makdir mdir \
            merge mfree procs rename tmode unlink

# ---------------------------------------------------------------------------
# Build products
# ---------------------------------------------------------------------------

REL       = rel_picothing
OS9FORMAT_CMD ?= $(OS9FORMAT_DS80)
STARTUP ?= $(NITROS9DIR)/level$(LEVEL)/$(PORT)/startup
DSKIMAGE ?= $(DISTROVER).dsk

# Optional expanded-image hooks (used by the mega recipes).  A recipe.mak
# may add extra build prerequisites, BASIC09 sample files, and a
# RECIPE_INSTALL macro that installs additional software onto the disk.
# All default empty, so the base recipes build unchanged.
RECIPE_DEPS ?=
BASIC09_SAMPLES ?=

all: libs $(DSKIMAGE)

include ../../libs.mak

# ---- module build rules that need non-default flags ----------------------

# rbsuper + llide share a static drive table sized by DrvCount; both must
# agree.  16 slots = 8 master (/I0-7) + 8 slave (/J0-7) partitions.
$(MODDIR)/rbsuper.dr: rbsuper.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DDrvCount=16 $< $(ASOUT)$@

$(MODDIR)/llide_pt.dr: llide.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DDrvCount=16 $(ASOUT)$@ $<

# Console terminal descriptor: the shared TNum-parameterized sc6850
# descriptor.  No TNum gives /Term; HwBASE is the console ACIA ($FFC4);
# Pauses=0 keeps the no-end-of-page-pause behaviour.  A second port is a
# one-line rule away: -DTNum=0 for /T0 (this same $FFC4), or -DTNum=1
# with -DHwBASE=0xFFC6 for /T1 on the auxiliary ACIA.
$(MODDIR)/term_pt.dd: term_sc6850.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DHwBASE=0xFFC4 -DPauses=0 $< $(ASOUT)$@

# Video window descriptors from one shared source (w_pt.asm), one per
# window with -DWINNUM=n (IT.WND=n).  WINNUM 0 is the root/panel, named
# /W0 (the base console); 1..7 are the overlays /W1../W7.
$(MODDIR)/w0_pt.dd: w_pt.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DWINNUM=0 $< $(ASOUT)$@
$(MODDIR)/w1_pt.dd: w_pt.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DWINNUM=1 $< $(ASOUT)$@
$(MODDIR)/w2_pt.dd: w_pt.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DWINNUM=2 $< $(ASOUT)$@
$(MODDIR)/w3_pt.dd: w_pt.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DWINNUM=3 $< $(ASOUT)$@
$(MODDIR)/w4_pt.dd: w_pt.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DWINNUM=4 $< $(ASOUT)$@
$(MODDIR)/w5_pt.dd: w_pt.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DWINNUM=5 $< $(ASOUT)$@
$(MODDIR)/w6_pt.dd: w_pt.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DWINNUM=6 $< $(ASOUT)$@
$(MODDIR)/w7_pt.dd: w_pt.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DWINNUM=7 $< $(ASOUT)$@

# wgfx and gemtest include tables generated by scripts/mkvidgfx.py (the
# outputs are committed); rebuild them when a table changes.
$(MODDIR)/wgfx: wgfxdat.asm
$(MODDIR)/gemtest: gemtestdat.asm

# PATA IDE descriptors: DD = default drive, I0-I7 = master partitions
# (SOFF1 steps by $20), J0-J7 = slave partitions (DRVID=1).
$(MODDIR)/ddi0_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDD=1
$(MODDIR)/i0_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x00
$(MODDIR)/i1_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x20
$(MODDIR)/i2_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x40
$(MODDIR)/i3_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x60
$(MODDIR)/i4_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x80
$(MODDIR)/i5_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0xA0
$(MODDIR)/i6_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0xC0
$(MODDIR)/i7_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0xE0
$(MODDIR)/j0_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0x00
$(MODDIR)/j1_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0x20
$(MODDIR)/j2_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0x40
$(MODDIR)/j3_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0x60
$(MODDIR)/j4_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0x80
$(MODDIR)/j5_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0xA0
$(MODDIR)/j6_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0xC0
$(MODDIR)/j7_pt.dd: ptidedesc.asm | $(MODDIR)
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0xE0

# RAM disk (shared from the CoCo 3 tree)
$(MODDIR)/rammer.dr: $(L2D)/coco3/modules/rammer.asm | $(MODDIR)
	$(AS) $(AFLAGS) $(ASOUT)$@ $<
$(MODDIR)/r0.dd: $(L2D)/coco3/modules/r0.asm | $(MODDIR)
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Lean /Nil and /Zero pseudo-devices (NIL selects /Nil over the /Zero default)
$(MODDIR)/nil.dr: nzdrv.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DNIL=1 $(ASOUT)$@ $<
$(MODDIR)/nil.dd: nzdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DNIL=1 $(ASOUT)$@ $<
$(MODDIR)/zero.dr: nzdrv.asm | $(MODDIR)
	$(AS) $(AFLAGS) $(ASOUT)$@ $<
$(MODDIR)/zero.dd: nzdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# The DriveWire I/O subroutine uses the auxiliary-ACIA transport
$(MODDIR)/dwio.sb: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) -Dpicothing=1 $(ASOUT)$@ $<

# DriveWire RBF descriptors
$(MODDIR)/ddx0.dd: dwdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1 -DDNum=0
$(MODDIR)/x0.dd: dwdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0
$(MODDIR)/x1.dd: dwdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1
$(MODDIR)/x2.dd: dwdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2
$(MODDIR)/x3.dd: dwdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3

# DriveWire SCF virtual channels
$(MODDIR)/term_scdwv.dt: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=0
$(MODDIR)/n_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=255
$(MODDIR)/n1_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=1
$(MODDIR)/n2_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=2
$(MODDIR)/n3_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=3
$(MODDIR)/n4_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=4
$(MODDIR)/n5_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=5
$(MODDIR)/n6_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=6
$(MODDIR)/n7_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=7
$(MODDIR)/n8_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=8
$(MODDIR)/n9_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=9
$(MODDIR)/n10_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=10
$(MODDIR)/n11_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=11
$(MODDIR)/n12_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=12
$(MODDIR)/n13_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=13
$(MODDIR)/midi_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=14
# The virtual windows /Z1-/Z7 are channels 17-23
$(MODDIR)/z1_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=17
$(MODDIR)/z2_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=18
$(MODDIR)/z3_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=19
$(MODDIR)/z4_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=20
$(MODDIR)/z5_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=21
$(MODDIR)/z6_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=22
$(MODDIR)/z7_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=23

# ---- command build rules that need non-default flags ---------------------

$(MODDIR)/tmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1
$(MODDIR)/xmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1
$(MODDIR)/pwd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1
$(MODDIR)/pxd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

# Level 2 shell is a merged shellplus pack; Level 1 boots the standalone
# shell_21 module (renamed to "shell" on disk).
$(MODDIR)/shell: $(addprefix $(MODDIR)/,$(SHELLMODS)) | $(MODDIR)
	$(MERGE) $(addprefix $(MODDIR)/,$(SHELLMODS)) >$@
$(MODDIR)/utilpak1: $(addprefix $(MODDIR)/,$(UTILPAK1)) | $(MODDIR)
	$(MERGE) $(addprefix $(MODDIR)/,$(UTILPAK1)) >$@

# ---- REL loader and bootfile ---------------------------------------------

# REL: raw binary the Pico's firmware loads at $0130.  Also emitted as an
# SREC for usim09pt / firmware loading.
$(REL): rel_picothing.asm
	$(ASROM) $(AFLAGS) $(ASOUT)$@ $<
$(REL).srec: rel_picothing.asm
	$(AS) --format=srec $(AFLAGS) $(ASOUT)$@ $<

# REL loads OS9Boot so that it ends at Bt.End ($FC00, below the Pico's
# debug monitor), and the kernel needs it to start at or above $4000: the
# page at $2000 carries REL's hand-over and the kernel's adoption of the
# bootfile cannot start in block 1.  So it can be at most $BC00 bytes.
BT_END    = 0xFC00
BT_MAX    = 0xBC00

ifeq ($(LEVEL),2)
# Level 2: krn is the last module and must sit at Bt.Start ($EC00), so pad
# it to exactly Bt.End-Bt.Start.  Every other module must sit below $E000:
# $E000-$FFFF is the fixed window, one page shared by every task, and a
# program module there cannot be mapped into a user task (in slots 0-6
# page $FF means "no RAM").  So pad the other modules at their start to a
# whole number of pages (as the Wildbits padup256 does) and follow them
# with a gap that fills the window up to krn.
KRN_SLOT  = 0x1000
WIN_GAP   = 0xC00

krnslot: $(MODDIR)/krn
	@KRN=$$(wc -c <$<) ; \
	if [ $$KRN -gt $$(($(KRN_SLOT))) ] ; then \
		echo "krn is $$KRN bytes; it must fit $$(($(KRN_SLOT))) (Bt.Start to Bt.End)" ; \
		exit 1 ; \
	fi
	cp $< $@
	$(PADROM) $$(($(KRN_SLOT))) $@

bootfile: $(addprefix $(MODDIR)/,$(BOOTFILE)) krnslot
	$(MERGE) $(addprefix $(MODDIR)/,$(BOOTFILE)) >$@
	$(PADROM) -b $$(( ($$(wc -c <$@) + 255) / 256 * 256 )) $@
	$(PADROM) $$(( $$(wc -c <$@) + $(WIN_GAP) )) $@
	cat krnslot >>$@
	@SIZE=$$(wc -c <$@) ; \
	if [ $$SIZE -gt $$(($(BT_MAX))) ] ; then \
		echo "bootfile is $$SIZE bytes; it must be at most $$(($(BT_MAX)))" ; \
		rm -f $@ ; exit 1 ; \
	fi
else
# Level 1: krn is the first module; REL rounds the start down to a page.
bootfile: $(addprefix $(MODDIR)/,$(BOOTFILE))
	$(MERGE) $(addprefix $(MODDIR)/,$(BOOTFILE)) >$@
	@SIZE=$$(wc -c <$@) ; \
	if [ $$SIZE -gt $$(($(BT_MAX))) ] ; then \
		echo "bootfile is $$SIZE bytes; it must be at most $$(($(BT_MAX)))" ; \
		rm -f $@ ; exit 1 ; \
	fi
endif

# ---- play directory --------------------------------------------------------

# /DD/PLAY on every image: some text to experiment on, a K&R C program
# (wstat) to build, run and modify, and a BASIC09 graphics demo (vgfx).
# Only the mega images carry the C compiler and BASIC09; on the others the
# files are there to read and edit.
PLAY_DIR   = $(NITROS9DIR)/level1/$(PORT)/play
PLAY_FILES = $(PLAY_DIR)/readme $(PLAY_DIR)/sample.txt $(PLAY_DIR)/wstat.c \
             $(PLAY_DIR)/vgfx.b09

# ---- disk image ----------------------------------------------------------

DSK_PREREQS = bootfile $(REL) helpmsg $(RECIPE_DEPS) $(PLAY_FILES) \
              $(addprefix $(MODDIR)/,$(SYSGO) $(CMDS_DISK) $(LOADMODS))

ifeq ($(LEVEL),2)
$(DSKIMAGE): $(DSK_PREREQS)
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfile $@,OS9Boot
	$(OS9COPY) $(MODDIR)/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS_DISK)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach f,$(CMDS_DISK),$@,CMDS/$(f))
	$(MAKDIR) $@,SYS
	$(CPL) $(SYS_TEXT_FILES) $@,SYS
	$(OS9ATTR_TEXT) $(foreach f,$(notdir $(SYS_TEXT_FILES)),$@,SYS/$(f))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,PLAY
	$(CPL) $(PLAY_FILES) $@,PLAY
	$(OS9ATTR_TEXT) $(foreach f,$(notdir $(PLAY_FILES)),$@,PLAY/$(f))
	$(MAKDIR) $@,Modules
	$(OS9COPY) $(addprefix $(MODDIR)/,$(LOADMODS)) $@,Modules
	$(OS9ATTR_EXEC) $(foreach m,$(LOADMODS),$@,Modules/$(m))
ifneq ($(strip $(BASIC09_SAMPLES)),)
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_SAMPLES) $@,BASIC09
	$(OS9ATTR_TEXT) $(foreach f,$(notdir $(BASIC09_SAMPLES)),$@,BASIC09/$(f))
endif
	$(call RECIPE_INSTALL,$@)
else
$(DSKIMAGE): $(DSK_PREREQS)
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfile $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS_DISK)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach f,$(CMDS_DISK),$@,CMDS/$(f))
	$(OS9RENAME) $@,CMDS/shell_21 shell
	$(MAKDIR) $@,SYS
	$(CPL) $(SYS_TEXT_FILES) $@,SYS
	$(OS9ATTR_TEXT) $(foreach f,$(notdir $(SYS_TEXT_FILES)),$@,SYS/$(f))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,PLAY
	$(CPL) $(PLAY_FILES) $@,PLAY
	$(OS9ATTR_TEXT) $(foreach f,$(notdir $(PLAY_FILES)),$@,PLAY/$(f))
endif

# ---- system support files ------------------------------------------------

ifeq ($(LEVEL),2)
HELPFILES = asm.hp attr.hp backup.hp binex.hp build.hp chd.hp chx.hp cmp.hp \
            copy.hp date.hp dcheck.hp debug.hp ded.hp deiniz.hp del.hp \
            deldir.hp devs.hp dir.hp dirsort.hp disasm.hp display.hp dmem.hp \
            dmode.hp dsave.hp dump.hp echo.hp edit.hp error.hp ex.hp exbin.hp \
            format.hp free.hp help.hp ident.hp iniz.hp irqs.hp link.hp list.hp \
            load.hp login.hp makdir.hp mdir.hp megaread.hp merge.hp mfree.hp \
            minted.hp mmap.hp modpatch.hp padrom.hp park.hp pmap.hp proc.hp \
            procs.hp prompt.hp pwd.hp pxd.hp rename.hp save.hp setime.hp \
            setpr.hp shell.hp sleep.hp smap.hp tee.hp tmode.hp touch.hp \
            tsmon.hp unlink.hp verify.hp xmode.hp
SYS_TEXT_FILES = $(L2D)/sys/motd helpmsg $(L1D)/sys/errmsg \
                 $(L1D)/sys/inetd.conf $(L1D)/sys/password
vpath %.hp $(L2D)/sys:$(L1D)/sys
else
HELPFILES = asm.hp attr.hp backup.hp binex.hp build.hp chd.hp chx.hp cmp.hp \
            cobbler.hp config.hp copy.hp cputype.hp date.hp dcheck.hp debug.hp \
            ded.hp deiniz.hp del.hp deldir.hp devs.hp dir.hp dirsort.hp \
            disasm.hp display.hp dmode.hp dsave.hp dump.hp echo.hp edit.hp \
            error.hp ex.hp exbin.hp format.hp free.hp gfx.hp help.hp ident.hp \
            iniz.hp inkey.hp irqs.hp kill.hp link.hp list.hp load.hp login.hp \
            makdir.hp mdir.hp megaread.hp merge.hp minted.hp mpi.hp mfree.hp \
            os9gen.hp padrom.hp park.hp procs.hp prompt.hp pwd.hp pxd.hp \
            rename.hp save.hp setime.hp setpr.hp shell.hp sleep.hp tee.hp \
            tmode.hp touch.hp tsmon.hp tuneport.hp unlink.hp verify.hp xmode.hp
SYS_TEXT_FILES = $(L1D)/sys/errmsg $(L1D)/sys/motd $(L1D)/sys/password \
                 $(L1D)/sys/inetd.conf helpmsg
vpath %.hp $(L1D)/sys
endif

helpmsg: $(HELPFILES)
	$(MERGE) $^ > $@

clean:
	$(RM) *.list *.map bootfile krnslot $(REL) $(REL).srec
	$(RM) *.dsk buildinfo helpmsg
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)

.PHONY: all clean libs bootfile
