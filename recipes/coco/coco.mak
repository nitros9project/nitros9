PORT ?= coco1
CPU ?= 6809
MACHINE ?= TRS-80 Color Computer 1/2
include ../../rules.mak
RECIPE ?= coco
-include recipe.mak

# Set VDG_T1=1 to enable true lowercase support for CoCo 2 boards
# equipped with the Motorola 6847T1 VDG chip.
VDG_T1 ?= 0
ifeq ($(VDG_T1),1)
VDG_T1_FLAGS = -Dcoco2b=1
else
VDG_T1_FLAGS =
endif

DSKIMAGE ?= l$(LEVEL)_$(RECIPE).dsk
OS9FORMAT_CMD ?= $(OS9FORMAT_DS40)
STARTUP ?= $(NITROS9DIR)/level1/$(PORT)/startup

AFLAGS += -I.
AFLAGS += -I$(L1MD)/kernel -I$(L1PMD)
AFLAGS += -I$(L1MD)
AFLAGS += $(AFLAGS_EXTRA)
LFLAGS += -L $(LIBDIR) -lcoco -lnet -lalib
LFLAGS += $(LFLAGS_EXTRA)

SSDD35 = -DCyls=35 -DSides=1 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1
DSDD40 = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1
DSDD80 = -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1 -DD35

RBF ?= rbf rb1773 ddd0_40d d0_40d d1_40d d2_40d
SCF ?= scf vtio covdg term_vdg
PIPE ?= pipeman piper pipe
CLOCK ?= clock_60hz clock2_soft
KERNEL_TRACK ?= rel krn krnp2 init boot_1773
KERNELFILE = kerneltrack

BOOTMODS ?= ioman \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	sysgo_dd shell_21 \
	$(BOOTMODS_EXTRA)

CMDS_BASE ?= $(STDCMDS)
CMDS += $(CMDS_BASE) \
	$(CMDS_EXTRA)

all: libs $(DSKIMAGE)

LIB_NAMES = libnos96809l1.a libnet.a libalib.a libcoco.a
include ../../libs.mak

kernelfile: $(addprefix $(MODDIR)/,$(KERNEL_TRACK))
	$(MERGE) $(addprefix $(MODDIR)/,$(KERNEL_TRACK))>$(KERNELFILE)

bootfile: $(addprefix $(MODDIR)/,$(BOOTMODS))
	$(MERGE) $(addprefix $(MODDIR)/,$(BOOTMODS))>$@

$(DSKIMAGE): kernelfile bootfile $(addprefix $(MODDIR)/,$(CMDS)) $(STARTUP)
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=bootfile -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup

# VDG terminal descriptor — conditionally enables 6847T1 true lowercase
$(MODDIR)/term_vdg: term_vdg.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(VDG_T1_FLAGS)

# Command rules
$(MODDIR)/pwd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

$(MODDIR)/pxd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

$(MODDIR)/xmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

$(MODDIR)/tmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

# CoCo 1 floppy descriptors
$(MODDIR)/boot_1773: boot_1773.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0 -DSTEP=0

$(MODDIR)/sysgo_dd: sysgo.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1

$(MODDIR)/clock_60hz: clock.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPwrLnFrq=60

$(MODDIR)/clock_50hz: clock.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPwrLnFrq=50

$(MODDIR)/ddd0_35s: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(SSDD35) -DDNum=0 -DDD=1

$(MODDIR)/d0_35s: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(SSDD35) -DDNum=0

$(MODDIR)/d1_35s: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(SSDD35) -DDNum=1

$(MODDIR)/d2_35s: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(SSDD35) -DDNum=2

$(MODDIR)/d3_35s: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(SSDD35) -DDNum=3

$(MODDIR)/ddd0_40d: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=0 -DDD=1

$(MODDIR)/d0_40d: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=0

$(MODDIR)/d1_40d: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=1

$(MODDIR)/d2_40d: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=2

$(MODDIR)/ddd0_80d: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=0 -DDD=1

$(MODDIR)/d0_80d: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=0

$(MODDIR)/d1_80d: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=1

$(MODDIR)/d2_80d: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=2

# DriveWire RBF descriptors
$(MODDIR)/ddx0: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1 -DDNum=0

$(MODDIR)/x0: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0

$(MODDIR)/x1: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=1

$(MODDIR)/x2: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=2

$(MODDIR)/x3: dwdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=3

clean:
	$(RM) *.list *.map bootfile $(KERNELFILE) *.dsk buildinfo
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)

.PHONY: all clean libs
