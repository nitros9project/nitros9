LEVEL = 1
PORT = wildbits
MODDIR = .mods
vpath %.asm $(NITROS9DIR)/level1/$(PORT)/feu
vpath %.as $(NITROS9DIR)/level1/$(PORT)/feu
include ../../rules.mak

ifeq ($(PLATFORM), jr2)
  KEYSUB = keydrv_ps2
else
  KEYSUB = keydrv_k2
  PLATFORM = k2
endif

DSKIMAGE = feu_wildbits$(PLATFORM).dsk

AFLAGS += -I.
AFLAGS += -I$(L1MD)/kernel -I$(L1PMD)
LFLAGS += -L $(LIBDIR) -lwildbitsl$(LEVEL) -lnet -lalib

KERNEL = krn krnp2 ioman init
RBF = rbf rbsuper llwbsd rbmem dds0 s0 s1 f0 f1
SCF = scf vtio $(KEYSUB) term bannerfont palette
DRIVEWIRE_RBF = rbdw x0 x1 x2 x3
DRIVEWIRE_SCF = scdwv n1 n2 n3 n4 n5
DRIVEWIRE = dwio_serial $(DRIVEWIRE_RBF) $(DRIVEWIRE_SCF)
PIPE = pipeman piper pipe
SC16550 = sc16550 t0_sc16550
CLOCK = clock clock2_wildbits

$(MODDIR)/sysgo: $(OBJDIR)/sysgo.o | $(MODDIR)
	$(LINKER) $(LFLAGS) $^ -o$@

$(OBJDIR)/sysgo.o: sysgo.as

# NOTE!!!
# VTIO must be near the top of the bootlist so that it can safely map
# the text and CLUT blocks into $E000-$FFFF.
BOOTMODS = $(KERNEL) \
	$(SCF) \
	$(RBF) \
	$(CLOCK) \
	sysgo shell_21 \
	display echo wbreset \
	iniz deiniz \
	load link unlink \
	bootos9

F0_CMDS = attr \
		build \
		copy \
		date \
		debug del deldir \
		devs dir dump \
		edit \
		wbinfo \
		ident irqs \
		list \
		makdir mfree mdir \
	    pick \
		procs pwd pxd \
		setime sleep \
		tmode

all: libs bootfile booter

LIB_NAMES = libwildbitsl$(LEVEL).a libnet.a libalib.a
include ../../libs.mak

bootfile: $(addprefix $(MODDIR)/,$(BOOTMODS))
	$(MERGE) $(addprefix $(MODDIR)/,$(BOOTMODS))>$@

booter: bootfile
	$(PADROM) 23552 bootfile
	$(AS) -DFLASH=1 --output=raw $(LEVEL1)/$(PORT)/feu/trampoline.asm -o$@.tmp
	cat bootfile $@.tmp > $@
	$(RM) $@.tmp

flash: flash_booter flash_f0

flash_booter: all booter.zip
	bulk_flash bulk_booter.csv

flash_f0: all f0.zip
	bulk_flash bulk_f0.csv

f0.zip: f0.dsk
	-rm f0_? bulk_f0.csv
	dd status=none bs=8k skip=0 count=1 if=$^ of=f0_0
	dd status=none bs=8k skip=1 count=1 if=$^ of=f0_1
	dd status=none bs=8k skip=2 count=1 if=$^ of=f0_2
	dd status=none bs=8k skip=3 count=1 if=$^ of=f0_3
	dd status=none bs=8k skip=4 count=1 if=$^ of=f0_4
	echo "38,f0_0" > bulk_f0.csv
	echo "39,f0_1" >> bulk_f0.csv
	echo "3a,f0_2" >> bulk_f0.csv
	echo "3b,f0_3" >> bulk_f0.csv
	echo "3c,f0_4" >> bulk_f0.csv
	zip $@ bulk_f0.csv f0_0 f0_1 f0_2 f0_3 f0_4

booter.zip: booter
	-rm booter_? bulk_booter.csv
	dd status=none bs=8k skip=0 count=1 if=$^ of=booter_0
	dd status=none bs=8k skip=1 count=1 if=$^ of=booter_1
	dd status=none bs=8k skip=2 count=1 if=$^ of=booter_2
	echo "3d,booter_0" > bulk_booter.csv
	echo "3e,booter_1" >> bulk_booter.csv
	echo "3f,booter_2" >> bulk_booter.csv
	-rm -rf mapfiles
	mkdir mapfiles
	os9 ident -s $^ > mapfiles/bootlist
	zip $@ bulk_booter.csv booter_0 booter_1 booter_2 mapfiles/*
	-rm -rf mapfiles

FEU_FILES = $(foreach file,$(NITROS9DIR)/level1/$(PORT)/feu/feu/*,$(file))

f0.dsk: startup $(addprefix $(MODDIR)/,$(F0_CMDS))
	$(OS9FORMAT) -q -t10 -st16 $@ -n"FEU"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(addprefix $(MODDIR)/,$(F0_CMDS)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(F0_CMDS),$@,CMDS/$(file))
	$(MAKDIR) $@,FEU
	$(OS9COPY) -l startup $@,FEU
	$(foreach file,$(FEU_FILES),$(OS9COPY) -l $(file) $@,FEU)

startup:
	echo "display 1b 61 1 ff 0 0 ff 5 22 f0 1b 20 2 0 0 50 18 0 1 0 1b 32 7" > $@
	echo "echo FEU - First Execution Unit" >> $@
	echo "echo Build date:" `date` >> $@
	echo "wbinfo" >> $@
	echo "chd .../feu" >> $@
	echo "pick -pFEU: main.pick</1" >> $@

$(DSKIMAGE): bootfile $(addprefix $(MODDIR)/,$(CMDS))
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfile $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))

# Command rules
$(MODDIR)/pwd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

$(MODDIR)/pxd: pd.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

$(MODDIR)/xmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

$(MODDIR)/tmode: xmode.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

# Descriptor rules
# SD card descriptors
$(MODDIR)/dds0: rbwbsddesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(WBSDFLAGS) -DSD=0 -DDD=1

$(MODDIR)/s0: rbwbsddesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(WBSDFLAGS) -DSD=0

$(MODDIR)/s1: rbwbsddesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(WBSDFLAGS) -DSD=1

# rbmem descriptors
$(MODDIR)/f0: rbmemdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0

$(MODDIR)/f1: rbmemdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=1 -DF1=1

$(MODDIR)/c0: rbmemdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=2 -DC0=1

$(MODDIR)/c1: rbmemdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=3 -DC1=1

$(MODDIR)/ddc0: rbmemdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=2 -DDD=1 -DC0=1

# DriveWire dwio modules
$(MODDIR)/dwio_wizfi: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDWIO_WIZFI

$(MODDIR)/dwio_serial: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDWIO_SERIAL

# DriveWire 3 RBF descriptors
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

# 16550 descriptors
$(MODDIR)/t0_sc16550: sc16550desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# DriveWire 3 SCF descriptors
$(MODDIR)/term_n.dt: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=0

$(MODDIR)/n: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=255

$(MODDIR)/n0: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=0

$(MODDIR)/n1: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=1

$(MODDIR)/n2: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=2

$(MODDIR)/n3: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=3

$(MODDIR)/n4: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=4

$(MODDIR)/n5: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=5

$(MODDIR)/n6: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=6

$(MODDIR)/n7: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=7

$(MODDIR)/n8: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=8

$(MODDIR)/n9: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=9

$(MODDIR)/n10: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=10

$(MODDIR)/n11: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=11

$(MODDIR)/n12: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=12

$(MODDIR)/n13: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=13

$(MODDIR)/midi: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=14

$(MODDIR)/term_z.dt: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=16

$(MODDIR)/z1: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=17

$(MODDIR)/z2: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=18

$(MODDIR)/z3: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=19

$(MODDIR)/z4: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=20

$(MODDIR)/z5: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=21

$(MODDIR)/z6: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=22

$(MODDIR)/z7: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=23

$(MODDIR)/z8: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=24

$(MODDIR)/z9: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=25

$(MODDIR)/z10: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=26

$(MODDIR)/z11: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=27

$(MODDIR)/z12: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=28

$(MODDIR)/z13: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=29

$(MODDIR)/z14: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=30

clean:
	$(RM) *.list *.map bootfile *.dsk booter* *.zip *.csv f0_? sysgo startup
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)

help:
	@echo "Make scenarios:"
	@echo "  make flash_booter PLATFORM=jr2: flash booter for Jr2"
	@echo "  make flash_booter PLATFORM=k2: flash booter for K2"
	@echo "  make flash PLATFORM=jr2: flash booter for Jr2"
	@echo "  make flash PLATFORM=k2: flash booter for K2"
	@echo "  make flash_f0 PLATFORM=jr2: flash /f0 for Jr2"
	@echo "  make flash_f0 PLATFORM=k2: flash /f0 for K2"

.PHONY: all clean flash flash_booter flash_f0 libs
