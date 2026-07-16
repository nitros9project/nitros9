PORT ?= coco3
CPU ?= 6809
MACHINE ?= Tandy Color Computer 3
include $(NITROS9DIR)/recipes/rules.mak
RECIPE ?= coco3
-include recipe.mak
vpath %.asm $(LEVEL1)/coco1/modules
vpath %.asm $(LANGUAGES)/basic09

ifeq ($(CPU),6309)
AFLAGS += -DH6309=1
COCO3_LIB = libcoco3_6309.a
NOS9_LIB = libnos96309l2.a
COCO3_LFLAG = -lcoco3_6309
else ifeq ($(CPU),6809)
AFLAGS += -DH6309=0
COCO3_LIB = libcoco3.a
NOS9_LIB = libnos96809l2.a
COCO3_LFLAG = -lcoco3
else
$(error Unsupported CPU "$(CPU)"; use CPU=6809 or CPU=6309)
endif

# Set TERM_COLS to 32, 40, or 80 to select the /TERM display width (default: 80).
#   32 uses the VDG chip via covdg.io + term_vdg.dt (32x16, CoCo 1/2-style).
#   40 and 80 use the CoCo 3 window system via cowin.io + term_win{40,80}.dt.
# Set TERM_ALTCOLOR=1 for black/white colors instead of the default black/green
# (applies to 40- and 80-column window modes only).
TERM_COLS ?= 80
TERM_ALTCOLOR ?= 0
REL = rel_$(TERM_COLS)
ifeq ($(TERM_COLS),32)
TERM_WIN_DT = term_vdg.dt
TERM_IO = covdg.io
else
TERM_WIN_DT = term_win$(TERM_COLS).dt
TERM_IO = cowin.io
endif
ifeq ($(TERM_ALTCOLOR),1)
TERM_ALTCOLOR_FLAGS = -DALTCOLOR=1
else
TERM_ALTCOLOR_FLAGS =
endif

DSKIMAGE ?= l$(LEVEL)_$(RECIPE).dsk
CLEAN_EXTRA ?=
CLEAN_DIRS ?=
TRACKS ?= 40
ifeq ($(TRACKS),40)
OS9FORMAT_CMD ?= $(OS9FORMAT_DS40)
else ifeq ($(TRACKS),80)
OS9FORMAT_CMD ?= $(OS9FORMAT_DS80)
else
$(error Unsupported TRACKS "$(TRACKS)"; use TRACKS=40 or TRACKS=80)
endif

AFLAGS += -I.
AFLAGS += -I$(LANGUAGES)/basic09
AFLAGS += -I$(L2PD)/defs
AFLAGS += -I$(L2MD)/kernel -I$(L2PMD)
AFLAGS += -I$(L1MD)/kernel -I$(L1MD)
AFLAGS += $(AFLAGS_EXTRA)
LFLAGS += -L $(LIBDIR) $(COCO3_LFLAG) -lnet -lalib
LFLAGS += $(LFLAGS_EXTRA)

DSDD40 = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1
DSDD80 = -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1

RBF ?= rbf.mn rb1773.dr ddd0_$(TRACKS)d.dd d0_$(TRACKS)d.dd d1_$(TRACKS)d.dd d2_$(TRACKS)d.dd
SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) \
	$(TERM_WIN_DT) w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw \
	w8.dw w9.dw w10.dw w11.dw w12.dw w13.dw w14.dw w15.dw
PIPE ?= pipeman.mn piper.dr pipe.dd
CLOCK ?= clock_60hz clock2_soft
KERNEL_TRACK ?= $(REL) boot_1773_6ms krn
KERNELFILE = kerneltrack
STARTUP ?= $(NITROS9DIR)/level2/$(PORT)/startup

SYSDIR      ?= $(L2PD)/sys
SYSBIN      ?= $(shell make -C $(SYSDIR) --no-print-directory showbinobjs)
SYSTEXT     ?= $(shell make -C $(SYSDIR) --no-print-directory showtextobjs)
PORTDEFSDIR ?= $(L2PD)/defs
PORTDEFS    ?= $(shell make -C $(PORTDEFSDIR) --no-print-directory showobjs)

BOOTMODS ?= krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA)

SHELLMODS = shellplus date deiniz echo iniz link load save unlink
UTILPAK1 = attr build copy del deldir dir display list makdir mdir merge mfree procs rename tmode

CMDS_BASE ?= $(STDCMDS) grfdrv shell utilpak1
CMDS += $(CMDS_BASE) \
	$(CMDS_EXTRA)
BASIC09_SAMPLES ?=
RECIPE_DEPS ?=

all: libs $(DSKIMAGE)

LIB_NAMES = $(NOS9_LIB) libnet.a libalib.a $(COCO3_LIB)
include $(NITROS9DIR)/recipes/libs.mak

kernelfile: $(addprefix $(MODDIR)/,$(KERNEL_TRACK))
	$(MERGE) $(addprefix $(MODDIR)/,$(KERNEL_TRACK))>$(KERNELFILE)

bootfile: $(addprefix $(MODDIR)/,$(BOOTMODS))
	$(MERGE) $(addprefix $(MODDIR)/,$(BOOTMODS))>$@

$(DSKIMAGE): libs kernelfile bootfile $(MODDIR)/sysgo_dd $(addprefix $(MODDIR)/,$(CMDS)) $(STARTUP) $(BASIC09_SAMPLES) $(RECIPE_DEPS)
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=bootfile -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
ifneq ($(SYSDIR),)
	$(MAKDIR) $@,SYS
	$(MAKE) -C $(SYSDIR) --no-print-directory
	$(CD) $(SYSDIR); $(OS9COPY) $(SYSBIN) $(CURDIR)/$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) $(SYSDIR); $(CPL) $(SYSTEXT) $(CURDIR)/$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
endif
ifneq ($(PORTDEFSDIR),)
	$(MAKDIR) $@,DEFS
	$(MAKE) -C $(PORTDEFSDIR) --no-print-directory
	$(CD) $(PORTDEFSDIR); $(CPL) $(PORTDEFS) $(CURDIR)/$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(PORTDEFS),$@,DEFS/$(file))
endif
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
ifneq ($(strip $(BASIC09_SAMPLES)),)
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_SAMPLES) $@,BASIC09
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(BASIC09_SAMPLES)),$@,BASIC09/$(file))
endif
	$(OS9COPY) $(MODDIR)/sysgo_dd $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(call RECIPE_INSTALL,$@)

# /TERM window descriptors — column count and colors controlled by TERM_COLS and TERM_ALTCOLOR
$(MODDIR)/term_win40.dt: term_win40.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(TERM_ALTCOLOR_FLAGS)

$(MODDIR)/term_win80.dt: term_win80.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(TERM_ALTCOLOR_FLAGS)

# VDG I/O module for 32-column mode (TERM_COLS=32)
$(MODDIR)/covdg.io: covdg.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DCOCO2=1

# Command rules
$(MODDIR)/pwd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

$(MODDIR)/pxd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

$(MODDIR)/xmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

$(MODDIR)/tmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

$(MODDIR)/runb: runb.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/shell: $(addprefix $(MODDIR)/,$(SHELLMODS)) | $(MODDIR)
	$(MERGE) $(addprefix $(MODDIR)/,$(SHELLMODS)) >$@

$(MODDIR)/utilpak1: $(addprefix $(MODDIR)/,$(UTILPAK1)) | $(MODDIR)
	$(MERGE) $(addprefix $(MODDIR)/,$(UTILPAK1)) >$@

# CoCo 3 kernel/booter variants
$(MODDIR)/boot_1773_6ms: boot_1773.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DSTEP=0

$(MODDIR)/boot_dw_becker: boot_dw.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DBECKER=1

$(MODDIR)/sysgo_dd: sysgo.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1

$(MODDIR)/clock_60hz: clock.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPwrLnFrq=60

$(MODDIR)/clock_50hz: clock.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPwrLnFrq=50

# CoCo 3 rel variants — width tracks TERM_COLS
$(MODDIR)/rel_32: rel.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DWidth=32

$(MODDIR)/rel_40: rel.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DWidth=40

$(MODDIR)/rel_80: rel.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DWidth=80

# CoCo 3 floppy descriptors
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

# DriveWire RBF descriptors
$(MODDIR)/dwio_becker.sb: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DBECKER=1

$(MODDIR)/ddx0.dd: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1 -DDNum=0

$(MODDIR)/x0.dd: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0

$(MODDIR)/x1.dd: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=1

$(MODDIR)/x2.dd: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=2

$(MODDIR)/x3.dd: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=3

# DriveWire SCF descriptors
$(MODDIR)/term_scdwv.dt: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=0

$(MODDIR)/n_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=255

$(MODDIR)/n1_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=1

$(MODDIR)/n2_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=2

$(MODDIR)/n3_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=3

$(MODDIR)/n4_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=4

$(MODDIR)/n5_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=5

clean:
	$(RM) *.list *.map bootfile $(KERNELFILE) *.dsk buildinfo $(CLEAN_EXTRA)
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR) $(CLEAN_DIRS)

FORCE:

.PHONY: all clean libs FORCE
