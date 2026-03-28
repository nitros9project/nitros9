PORT ?= coco3
CPU ?= 6809
MACHINE ?= Tandy Color Computer 3
include ../../rules.mak
RECIPE ?= coco3
-include recipe.mak
vpath %.asm $(LEVEL1)/coco1/modules

DSKIMAGE ?= l$(LEVEL)_$(RECIPE).dsk
OS9FORMAT_CMD ?= $(OS9FORMAT_DS40)

AFLAGS += -I.
AFLAGS += -I$(L2MD)/kernel -I$(L2PMD)
AFLAGS += -I$(L1MD)/kernel -I$(L1MD)
AFLAGS += $(AFLAGS_EXTRA)
LFLAGS += -L $(LIBDIR) -lcoco3 -lnet -lalib
LFLAGS += $(LFLAGS_EXTRA)

DSDD40 = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1

RBF ?= rbf.mn rb1773.dr ddd0_40d.dd d0_40d.dd d1_40d.dd d2_40d.dd
SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb cowin.io \
	term_win80.dt w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw \
	w8.dw w9.dw w10.dw w11.dw w12.dw w13.dw w14.dw w15.dw
PIPE ?= pipeman.mn piper.dr pipe.dd
CLOCK ?= clock_60hz clock2_soft
KERNEL_TRACK ?= rel_80 boot_1773_6ms krn
KERNELFILE = kerneltrack
STARTUP ?= $(NITROS9DIR)/level2/$(PORT)/startup

BOOTMODS ?= krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	sysgo_dd shell_21 \
	$(BOOTMODS_EXTRA)

SHELLMODS = shellplus date deiniz echo iniz link load save unlink
UTILPAK1 = attr build copy del deldir dir display list makdir mdir merge mfree procs rename tmode

CMDS_BASE ?= $(STDCMDS) grfdrv shell utilpak1
CMDS += $(CMDS_BASE) \
	$(CMDS_EXTRA)

all: libs $(DSKIMAGE)

LIB_NAMES = libnos96809l2.a libnet.a libalib.a libcoco3.a
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

# Command rules
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

# CoCo 3 kernel/booter variants
$(MODDIR)/boot_1773_6ms: boot_1773.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DSTEP=0

$(MODDIR)/sysgo_dd: sysgo.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1

$(MODDIR)/clock_60hz: clock.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPwrLnFrq=60

$(MODDIR)/clock_50hz: clock.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPwrLnFrq=50

# CoCo 3 rel variant
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

# DriveWire RBF descriptors
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
	$(RM) *.list *.map bootfile $(KERNELFILE) *.dsk buildinfo
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)

.PHONY: all clean libs
