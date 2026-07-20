# Pico-Thing shared build recipe (Level 1 and Level 2, 6809 and 6309).
#
# The Pico-Thing boots differently from the CoCo ports: a small raw REL
# loader (rel_picothing) runs at Bt.Start, loads OS9Kernel, then F$Boot
# pulls in OS9Boot (the merged bootfile).  The disk therefore carries
# OS9Kernel and OS9Boot as two separate files rather than a single
# OS9Boot.  The two levels compose those files differently:
#
#   Level 2  OS9Kernel = boot module padded to 1024 bytes, then krn
#            OS9Boot   = krnp2 krnp3_perr init ioman + drivers + shell
#   Level 1  OS9Kernel = krn krnp2 init boot   (plain merge, no pad)
#            OS9Boot   = ioman sysgo + drivers + shell
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

# PATA IDE partition descriptors: master /I0-/I7, slave /J0-/J7
IDE_PARTS = i0_pt.dd i1_pt.dd i2_pt.dd i3_pt.dd \
            i4_pt.dd i5_pt.dd i6_pt.dd i7_pt.dd \
            j0_pt.dd j1_pt.dd j2_pt.dd j3_pt.dd \
            j4_pt.dd j5_pt.dd j6_pt.dd j7_pt.dd

RBF_CORE = rbf.mn rbsuper.dr llide_pt.dr ddi0_pt.dd
SCF      = scf.mn sc6850.dr term_pt.dd nil.dr nil.dd zero.dr zero.dd
PIPE     = pipeman.mn piper.dr pipe.dd
DW       = rbdw.dr dwio.sb x0.dd x1.dd x2.dd x3.dd
SYSGO    = sysgo

# Graphical console (loadable, not in the bootfile)
GFX      = vtio_picothing.dr copico term_gfx.dd
# Extra DriveWire descriptors (loadable)
DW_EXTRA = ddx0.dd scdwv.dr term_scdwv.dt n_scdwv.dd \
           n1_scdwv.dd n2_scdwv.dd n3_scdwv.dd n4_scdwv.dd clock2_dw

KERNEL = krn

ifeq ($(LEVEL),2)
CLOCK    = clock clock2_soft
RAMDISK  = rammer.dr r0.dd
SHELLBOOT = shell
# OS9Boot: everything essential to reach the shell.  krnp3_perr installs
# the full-text F$PErr; krnp2 runs it at boot.
BOOTFILE = krnp2 krnp3_perr init ioman $(RBF_CORE) $(IDE_PARTS) $(SCF) \
           $(CLOCK) $(PIPE) $(RAMDISK) $(DW) $(SYSGO) $(SHELLBOOT) \
           $(BOOTMODS_EXTRA)
else
CLOCK    = clock clock2_soft
SHELLBOOT = shell_21
BOOTFILE = ioman $(SYSGO) $(CLOCK) $(SCF) $(RBF_CORE) $(IDE_PARTS) \
           $(DW) $(PIPE) $(SHELLBOOT) $(BOOTMODS_EXTRA)
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
       format free grep help httpd ident inetd iniz irqs link list load login \
       makdir mdir megaread merge mfree minted mmap modpatch more padrom park \
       pmap proc procs printerr prompt pwd pxd rename save setime \
       sleep smap tee telnet tmode touch tsmon unlink verify xmode \
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
BOOT_PAD  = 1024
OS9KERNEL ?= os9kernel
OS9FORMAT_CMD ?= $(OS9FORMAT_DS80)
STARTUP ?= $(NITROS9DIR)/level$(LEVEL)/$(PORT)/startup
DSKIMAGE ?= $(DISTROVER).dsk

all: libs $(DSKIMAGE)

include ../../libs.mak

# ---- module build rules that need non-default flags ----------------------

# rbsuper + llide share a static drive table sized by DrvCount; both must
# agree.  16 slots = 8 master (/I0-7) + 8 slave (/J0-7) partitions.
$(MODDIR)/rbsuper.dr: rbsuper.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DDrvCount=16 $< $(ASOUT)$@

$(MODDIR)/llide_pt.dr: llide.asm | $(MODDIR)
	$(AS) $(AFLAGS) -DDrvCount=16 $(ASOUT)$@ $<

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

# DriveWire boot module and I/O subroutine use the auxiliary-ACIA transport
$(MODDIR)/dwio.sb: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) -Dpicothing=1 $(ASOUT)$@ $<
# DriveWire boot module: shared with the CoCo1 boot_dw.asm; the Pico-Thing
# aux-ACIA transport is selected inside the shared dwinit/dwread/dwwrite
# includes and a -Dpicothing=1 island in boot_dw.asm.
$(MODDIR)/boot_dw_pt: $(L1D)/coco1/modules/boot_dw.asm | $(MODDIR)
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

# ---- REL loader, bootfile, OS9Kernel -------------------------------------

# REL: raw binary loaded at Bt.Start.  Also emitted as an SREC for
# usim09pt / firmware loading.
$(REL): rel_picothing.asm
	$(ASROM) $(AFLAGS) $(ASOUT)$@ $<
$(REL).srec: rel_picothing.asm
	$(AS) --format=srec $(AFLAGS) $(ASOUT)$@ $<

bootfile: $(addprefix $(MODDIR)/,$(BOOTFILE))
	$(MERGE) $(addprefix $(MODDIR)/,$(BOOTFILE)) >$@

ifeq ($(LEVEL),2)
# Level 2: OS9Kernel = boot module padded to $(BOOT_PAD) bytes, then krn.
os9kernel: $(MODDIR)/boot_picothing $(MODDIR)/$(KERNEL)
	dd if=$(MODDIR)/boot_picothing of=$@ bs=$(BOOT_PAD) conv=sync 2>/dev/null
	cat $(MODDIR)/$(KERNEL) >>$@
os9kernel_dw: $(MODDIR)/boot_dw_pt $(MODDIR)/$(KERNEL)
	dd if=$(MODDIR)/boot_dw_pt of=$@ bs=$(BOOT_PAD) conv=sync 2>/dev/null
	cat $(MODDIR)/$(KERNEL) >>$@
else
# Level 1: OS9Kernel = krn krnp2 init boot, merged (the cold-start scans
# this blob and F$Links Init and krnp2 before F$Boot runs).
os9kernel: $(MODDIR)/$(KERNEL) $(MODDIR)/krnp2 $(MODDIR)/init $(MODDIR)/boot_picothing
	$(MERGE) $(MODDIR)/$(KERNEL) $(MODDIR)/krnp2 $(MODDIR)/init $(MODDIR)/boot_picothing >$@
os9kernel_dw: $(MODDIR)/$(KERNEL) $(MODDIR)/krnp2 $(MODDIR)/init $(MODDIR)/boot_dw_pt
	$(MERGE) $(MODDIR)/$(KERNEL) $(MODDIR)/krnp2 $(MODDIR)/init $(MODDIR)/boot_dw_pt >$@
endif

# ---- disk image ----------------------------------------------------------

DSK_PREREQS = bootfile $(OS9KERNEL) $(REL) helpmsg \
              $(addprefix $(MODDIR)/,$(SYSGO) $(CMDS_DISK) $(LOADMODS))

ifeq ($(LEVEL),2)
$(DSKIMAGE): $(DSK_PREREQS)
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=bootfile
	$(OS9COPY) $(OS9KERNEL) $@,OS9Kernel
	$(OS9ATTR_EXEC) $@,OS9Kernel
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
	$(MAKDIR) $@,Modules
	$(OS9COPY) $(addprefix $(MODDIR)/,$(LOADMODS)) $@,Modules
	$(OS9ATTR_EXEC) $(foreach m,$(LOADMODS),$@,Modules/$(m))
else
$(DSKIMAGE): $(DSK_PREREQS)
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=bootfile
	$(OS9COPY) $(OS9KERNEL) $@,OS9Kernel
	$(OS9ATTR_EXEC) $@,OS9Kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS_DISK)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach f,$(CMDS_DISK),$@,CMDS/$(f))
	$(OS9RENAME) $@,CMDS/shell_21 shell
	$(MAKDIR) $@,SYS
	$(CPL) $(SYS_TEXT_FILES) $@,SYS
	$(OS9ATTR_TEXT) $(foreach f,$(notdir $(SYS_TEXT_FILES)),$@,SYS/$(f))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
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
	$(RM) *.list *.map bootfile os9kernel os9kernel_dw $(REL) $(REL).srec
	$(RM) *.dsk buildinfo helpmsg
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)

.PHONY: all clean libs bootfile
