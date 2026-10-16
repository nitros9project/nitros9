# NitrOS-9 Level 2 for the Color Computer 2 with an i-MMU-nity MMU board.
#
# The i-MMU-nity provides a CoCo 3 compatible MMU ($FF90/$FF91, $FFA0-$FFAF)
# but no GIME, so the console is the VDG (covdg.io, 32x16) and the clock runs
# from the PIA0 VSYNC interrupt. Port-specific sources live in
# level2/immunity/modules (including all the video modules except VTIO);
# everything else is shared with the CoCo 3 port.
#
# MEDIA selects the boot device:
#   floppy  WD1773 floppy (rb1773), 40 or 80 tracks (TRACKS=40|80)
#   sdc     CoCo SDC (rbsuper + llcocosdc), with the floppy driver as well

PORT := immunity
CPU := 6809
LEVEL := 2
MACHINE := Color Computer 2 with i-MMU-nity
include $(NITROS9DIR)/recipes/rules.mak
RECIPE ?= immunity
-include recipe.mak

# Shared CoCo sources. vpath directories from rules.mak (this port's own
# modules first, then level2/modules, level1/modules, ...) are searched before
# these, so files that exist in more than one place get explicit rules below.
vpath %.asm $(LEVEL2)/coco3/modules $(LEVEL1)/coco1/modules

AFLAGS += -DH6309=0
NOS9_LIB = libnos96809l2.a
COCO3_LIB = libcoco3.a

MEDIA ?= floppy
# VDG_T1=1 for a 6847T1 VDG (true lower case, e.g. some CoCo 2B models);
# the default 0 suits the plain MC6847 in most CoCo 1/2s. Software can't
# tell them apart.
# UPPERCASE=1 makes covdg show lower case letters as normal capitals
# (display only; typed input is unchanged).
VDG_T1 ?= 0
UPPERCASE ?= 0
# HIRES=42 or HIRES=51: the console is 42x24 (Co42) or 51x24 (CoHR) text
# drawn on PMODE 4 graphics screens instead of CoVDG's 32x16. Green on
# black; HIRES_BUFF=1 for buff on black; HIRES_INVERSE=1 for black text on
# green (or buff). On an NTSC TV, 42 columns reads
# better (51 is best on a monochrome monitor or a CoCoDV).
# HIRES_CODV=1 with a CoCoDV: monochrome (no artifact colours), green text
# on a dark green background.
HIRES ?= 0
HIRES_BUFF ?= 0
HIRES_INVERSE ?= 0
HIRES_CODV ?= 0
# VDG_WINDOWS=n adds /V1../Vn, extra screens (CLEAR/SHIFT-CLEAR switch
# between them; start a shell with "shell i=/v1&"). 32x16, 0 to 7; with
# HIRES, 0 to 4 (each takes one of the 5 VDG pool blocks).
ifeq ($(HIRES),51)
VDGCO = cohr.io
AFLAGS_VDG = -DUSECOHR=1
else ifeq ($(HIRES),42)
VDGCO = co42.io
AFLAGS_VDG = -DUSECO42=1
else ifeq ($(HIRES),0)
VDGCO = covdg.io
AFLAGS_VDG =
else
$(error Unsupported HIRES "$(HIRES)"; use HIRES=0, 42 or 51)
endif
ifeq ($(HIRES),0)
VDG_WINDOWS ?= 7
else
VDG_WINDOWS ?= 4
ifneq ($(filter-out 0 1 2 3 4,$(VDG_WINDOWS)),)
$(error VDG_WINDOWS=$(VDG_WINDOWS): HIRES allows 0 to 4)
endif
endif
TRACKS ?= 40
PwrLnFrq ?= 60

DSKIMAGE ?= l$(LEVEL)_$(RECIPE).dsk
CLEAN_EXTRA ?=
CLEAN_DIRS ?=

AFLAGS += -I.
AFLAGS += -I$(L2PMD) -I$(LEVEL2)/coco3/modules -I$(LEVEL1)/coco1/modules
AFLAGS += -I$(L2MD)/kernel -I$(L1MD)/kernel -I$(L1MD)
AFLAGS += $(AFLAGS_EXTRA)
LFLAGS += -L $(LIBDIR) -lcoco3 -lnet -lalib
LFLAGS += $(LFLAGS_EXTRA)

DSDD40 = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1
DSDD80 = -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1
SDFLAGS = -DCOCOSDC=1 -DITTYP=128

# ---------------------------------------------------------------------------
# Boot media
FLOPPY ?= rb1773.dr d0_$(TRACKS)d.dd d1_$(TRACKS)d.dd d2_$(TRACKS)d.dd
ifeq ($(MEDIA),floppy)
BOOTER ?= boot_1773_6ms
RBF ?= rbf.mn ddd0_$(TRACKS)d.dd $(FLOPPY)
ifeq ($(TRACKS),40)
OS9FORMAT_CMD ?= $(OS9FORMAT_DS40)
else ifeq ($(TRACKS),80)
OS9FORMAT_CMD ?= $(OS9FORMAT_DS80)
else
$(error Unsupported TRACKS "$(TRACKS)"; use TRACKS=40 or TRACKS=80)
endif
else ifeq ($(MEDIA),sdc)
BOOTER ?= boot_sdc
RBF ?= rbf.mn rbsuper.dr llcocosdc.dr ddsd0_cocosdc.dd sd0_cocosdc.dd \
	sd1_cocosdc.dd $(FLOPPY)
# 1024 tracks x 18 sectors x 256 bytes = 4.5MB, the size used on the SDC so far
OS9FORMAT_CMD ?= $(OS9FORMAT) -t1024 -ss -dd
else ifeq ($(MEDIA),dragon)
# Dragon 64: DragonDOS controller (ddisk), Dragon keyboard rows in VTIO,
# stage-0 loader in the DragonDOS boot area (LSN 2-17) that loads the
# normal kernel track from track 34.
AFLAGS += -Dd64=1
vpath %.asm $(LEVEL1)/d64/modules
BOOTER ?= boot_d64
RBF ?= rbf.mn ddisk.dr ddd0_dg$(TRACKS).dd d0_dg$(TRACKS).dd \
	d1_dg$(TRACKS).dd d2_dg$(TRACKS).dd
ifeq ($(TRACKS),40)
OS9FORMAT_CMD ?= $(OS9FORMAT_DS40) -dr
else ifeq ($(TRACKS),80)
OS9FORMAT_CMD ?= $(OS9FORMAT_DS80) -dr
else
$(error Unsupported TRACKS "$(TRACKS)"; use TRACKS=40 or TRACKS=80)
endif
GEN_DEPS = $(MODDIR)/stage0_d64
GEN_PRE = $(OS9GEN) $@ -d -t=$(MODDIR)/stage0_d64
XROAR_RUN = -machine dragon64 -machine-opt immunity -cart dragondos \
	-load-fd0 $(DSKIMAGE) -type 'BOOT\r'
else
$(error Unsupported MEDIA "$(MEDIA)"; use MEDIA=floppy, sdc or dragon)
endif

# ---------------------------------------------------------------------------
# Boot modules
REL ?= rel_32
KERNEL_TRACK ?= $(REL) $(BOOTER) krn
KERNELFILE = kerneltrack

VDGWINS = $(foreach n,$(wordlist 1,$(VDG_WINDOWS),1 2 3 4 5 6 7),v$(n).dw)
SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb $(VDGCO) term_vdg.dt $(VDGWINS)
PIPE ?= pipeman.mn piper.dr pipe.dd
CLOCK ?= clock_$(PwrLnFrq)hz clock2_soft

BOOTMODS ?= krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA)

$(addprefix $(MODDIR)/,vtio.dr covdg.io cohr.io co42.io): $(DEFSDIR)/cocovtio.d

# ---------------------------------------------------------------------------
# Disk contents
STARTUP ?= $(NITROS9DIR)/level2/$(PORT)/startup

SYSDIR      ?= .sys
SYS_RECIPE  ?= $(NITROS9DIR)/recipes/support/coco3-system.mak
SYSTEXT     ?= helpmsg errmsg password motd
PORTDEFSDIR ?= $(LEVEL2)/coco3/defs
PORTDEFS_RECIPE ?= $(NITROS9DIR)/recipes/support/coco3-defs.mak
PORTDEFS    ?= os9.d rbf.d scf.d coco.d coco3vtio.d Defsfile

ifneq ($(SYSDIR),)
CLEAN_DIRS += $(SYSDIR)
$(SYSDIR):
	mkdir -p $@
endif

SHELLMODS = shellplus date deiniz echo iniz link load save unlink
UTILPAK1 = attr build copy del deldir dir display list makdir mdir merge mfree procs rename tmode

CMDS_BASE ?= $(STDCMDS) shell utilpak1 mmap pmap reboot
CMDS += $(CMDS_BASE) $(CMDS_EXTRA)

all: libs $(DSKIMAGE)

LIB_NAMES = $(NOS9_LIB) libnet.a libalib.a $(COCO3_LIB)
include $(NITROS9DIR)/recipes/libs.mak

kernelfile: $(addprefix $(MODDIR)/,$(KERNEL_TRACK))
	$(MERGE) $(addprefix $(MODDIR)/,$(KERNEL_TRACK))>$(KERNELFILE)

bootfile: $(addprefix $(MODDIR)/,$(BOOTMODS))
	$(MERGE) $(addprefix $(MODDIR)/,$(BOOTMODS))>$@

$(DSKIMAGE): libs kernelfile bootfile $(MODDIR)/sysgo_dd $(GEN_DEPS) $(addprefix $(MODDIR)/,$(CMDS)) $(STARTUP) | $(SYSDIR)
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(GEN_PRE)
	$(OS9GEN) $@ -b=bootfile -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
ifneq ($(SYSDIR),)
	$(MAKDIR) $@,SYS
	$(MAKE) -C $(SYSDIR) -f $(SYS_RECIPE) --no-print-directory $(SYSTEXT)
	$(CD) $(SYSDIR); $(CPL) $(SYSTEXT) $(CURDIR)/$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
endif
ifneq ($(PORTDEFSDIR),)
	$(MAKDIR) $@,DEFS
	$(MAKE) -C $(PORTDEFSDIR) -f $(PORTDEFS_RECIPE) --no-print-directory
	$(CD) $(PORTDEFSDIR); $(CPL) $(PORTDEFS) $(CURDIR)/$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(PORTDEFS),$@,DEFS/$(file))
endif
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9COPY) $(MODDIR)/sysgo_dd $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(call RECIPE_INSTALL,$@)

# Run the image in the locally built XRoar with the i-MMU-nity MMU.
# XRoar has no CoCo SDC emulation, so this only makes sense for MEDIA=floppy.
XROAR ?= $(NITROS9DIR)/../xroar/run-memjr.sh
XROAR_RUN ?= -load-fd0 $(DSKIMAGE) -type 'DOS\r'
run: $(DSKIMAGE)
	$(XROAR) $(XROAR_RUN)

# ---------------------------------------------------------------------------
# Rules for sources that exist in more than one vpath directory

# CoCo 3 Level 2 VTIO (level1/modules/vtio.asm would win on the vpath)
$(MODDIR)/vtio.dr: $(LEVEL2)/coco3/modules/vtio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Level 2 CoHR and Co42, from one source (level1/coco1/modules has the
# Level 1 ones)
HIRES_FLAGS = -DUSEBUFF=$(HIRES_BUFF) -DUSEINV=$(HIRES_INVERSE) \
	-DUSECODV=$(HIRES_CODV)
$(MODDIR)/cohr.io: $(L2PMD)/cohr.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(HIRES_FLAGS)
$(MODDIR)/co42.io: $(L2PMD)/cohr.asm $(L2PMD)/co42font.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(HIRES_FLAGS) -DUSECO42=1

# ---------------------------------------------------------------------------
# Module variants

$(MODDIR)/covdg.io: covdg.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DALLCAPS=$(UPPERCASE)

# /term: default VDG character set (descriptor parity byte, see term_vdg.asm)
ifeq ($(VDG_T1),1)
TERM_VDG_FLAGS =
else
TERM_VDG_FLAGS = -DPLAIN6847=1
endif
$(MODDIR)/term_vdg.dt: term_vdg.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(TERM_VDG_FLAGS) $(AFLAGS_VDG)

# /V1-/V7 from one source (level2/immunity/modules/vdgwin.asm)
$(MODDIR)/v%.dw: vdgwin.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(TERM_VDG_FLAGS) $(AFLAGS_VDG) -DWNUM=$*

$(MODDIR)/rel_32: rel.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DWidth=32

$(MODDIR)/boot_1773_6ms: boot_1773.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DSTEP=0

$(MODDIR)/boot_sdc: boot_sdc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(SDFLAGS)

# Dragon 64 (MEDIA=dragon)
$(MODDIR)/boot_d64: boot_d64.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0 -DSTEP=0

$(MODDIR)/stage0_d64: stage0_d64.asm | $(MODDIR)
	$(ASROM) $< $(ASOUT)$@

DGDS40 = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=2 -DSAS=8 -DDensity=1
DGDS80 = -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=2 -DSAS=8 -DDensity=1 -DD35

$(MODDIR)/ddd0_dg%.dd: ddiskdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DGDS$*) -DDNum=0 -DDD=1

$(MODDIR)/d0_dg%.dd: ddiskdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DGDS$*) -DDNum=0

$(MODDIR)/d1_dg%.dd: ddiskdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DGDS$*) -DDNum=1

$(MODDIR)/d2_dg%.dd: ddiskdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DGDS$*) -DDNum=2

$(MODDIR)/sysgo_dd: sysgo.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1

$(MODDIR)/clock_60hz: clock.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPwrLnFrq=60

$(MODDIR)/clock_50hz: clock.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPwrLnFrq=50

# Floppy descriptors
$(MODDIR)/ddd0_40d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=0 -DDD=1

$(MODDIR)/d0_40d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=0

$(MODDIR)/d1_40d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=1

$(MODDIR)/d2_40d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=2

$(MODDIR)/ddd0_80d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=0 -DDD=1

$(MODDIR)/d0_80d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=0

$(MODDIR)/d1_80d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=1

$(MODDIR)/d2_80d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=2

# CoCo SDC driver and descriptors
$(MODDIR)/llcocosdc.dr: llcocosdc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(SDFLAGS)

$(MODDIR)/ddsd0_cocosdc.dd: superdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(SDFLAGS) -DDD=1

$(MODDIR)/sd0_cocosdc.dd: superdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(SDFLAGS) -DITDRV=0

$(MODDIR)/sd1_cocosdc.dd: superdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(SDFLAGS) -DITDRV=1

# Command variants
$(MODDIR)/pwd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

$(MODDIR)/pxd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

$(MODDIR)/xmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

$(MODDIR)/tmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

$(MODDIR)/shell: $(addprefix $(MODDIR)/,$(SHELLMODS)) | $(MODDIR)
	$(MERGE) $(addprefix $(MODDIR)/,$(SHELLMODS)) >$@

$(MODDIR)/utilpak1: $(addprefix $(MODDIR)/,$(UTILPAK1)) | $(MODDIR)
	$(MERGE) $(addprefix $(MODDIR)/,$(UTILPAK1)) >$@

clean:
	$(RM) *.list *.map bootfile $(KERNELFILE) *.dsk buildinfo $(CLEAN_EXTRA)
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR) $(CLEAN_DIRS)

.PHONY: all clean libs run
