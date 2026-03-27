LEVEL = 1
PORT = wildbits
vpath %.asm $(NITROS9DIR)/level1/$(PORT)/feu
vpath %.as $(NITROS9DIR)/level1/$(PORT)/feu
include ../../rules.mak

# Bare target rule for this recipe's in-directory build style
%: %.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@

init: buildinfo

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

sysgo: $(OBJDIR)/sysgo.o
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

include ../../libs.mak

bootfile: $(BOOTMODS)
	$(MERGE) $(BOOTMODS)>$@

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

f0.dsk: startup $(F0_CMDS)
	$(OS9FORMAT) -q -t10 -st16 $@ -n"FEU"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(F0_CMDS) $@,CMDS
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

$(DSKIMAGE): bootfile $(CMDS)
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfile $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
#	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
#	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
#	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
#	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
#	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
#	$(CPL) $(STARTUP) $@,startup
#	$(OS9ATTR_TEXT) $@,startup
#	$(MAKDIR) $@,BASIC09
#	$(CPL) $(BASIC09_FILES) $@,BASIC09
#	$(MAKDIR) $@,BF
#	$(CPL) $(BF_FILES) $@,BF
#	$(MAKDIR) $@,SOUNDS
#	$(OS9COPY) $(SOUND_FILES) $@,SOUNDS
#	$(MAKDIR) $@,SCRIPTS
#	$(CD) scripts; $(CPL) $(SCRIPTS) ../$@,SCRIPTS
#	$(MAKDIR) $@,TESTS
#	$(CD) tests; $(CPL) $(TESTS) ../$@,TESTS

# Command rules
pwd:    pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

pxd:    pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

xmode:  xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1
                
tmode:  xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

# Descriptor rules
# SD card descriptors
dds0: rbwbsddesc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< $(WBSDFLAGS) -DSD=0 -DDD=1

s0: rbwbsddesc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< $(WBSDFLAGS) -DSD=0

s1: rbwbsddesc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< $(WBSDFLAGS) -DSD=1

# rbmem descriptors
f0: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

f1: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1 -DF1=1

c0: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2 -DC0=1

c1: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3 -DC1=1

ddc0: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2 -DDD=1 -DC0=1

# DriveWire dwio modules
dwio_wizfi: dwio.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDWIO_WIZFI

dwio_serial: dwio.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDWIO_SERIAL

# DriveWire 3 RBF descriptors
ddx0: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1 -DDNum=0

x0: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

x1: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1

x2: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2

x3: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3

# 16550 descriptors
t0_sc16550: sc16550desc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS)

# DriveWire 3 SCF descriptors
term_n.dt: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=0

n: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=255

n0: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=0

n1: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=1

n2: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=2

n3: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=3

n4: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=4

n5: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=5

n6: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=6

n7: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=7

n8: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=8

n9: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=9

n10: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=10

n11: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=11

n12: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=12

n13: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=13

midi: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=14

term_z.dt: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=16

z1: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=17

z2: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=18

z3: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=19

z4: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=20

z5: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=21

z6: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=22

z7: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=23

z8: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=24

z9: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=25

z10: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=26

z11: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=27

z12: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=28

z13: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=29

z14: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=30

clean:
	$(RM) $(BOOTMODS) $(F0_CMDS) *.list *.map bootfile *.dsk booter* *.zip *.csv f0_? sysgo startup
	-rm -rf $(OBJDIR) $(LIBDIR)

help:
	@echo "Make scenarios:"
	@echo "  make flash_booter PLATFORM=jr2: flash booter for Jr2"
	@echo "  make flash_booter PLATFORM=k2: flash booter for K2"
	@echo "  make flash PLATFORM=jr2: flash booter for Jr2"
	@echo "  make flash PLATFORM=k2: flash booter for K2"
	@echo "  make flash_f0 PLATFORM=jr2: flash /f0 for Jr2"
	@echo "  make flash_f0 PLATFORM=k2: flash /f0 for K2"

.PHONY: all clean upload flash flash_booter flash_f0 libs
