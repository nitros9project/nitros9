include ../port.mak

DEPENDS		= ./makefile $(NOSLIB)/net.o

# Module directory
LFLAGS          += -L $(NITROS9DIR)/lib -lnet -lf256 -lalib
MD		= ../modules
FNT	        = ../sys/fonts
# Commands directory
CMDSDIR		= ../cmds

# Kernel
KERNEL	= $(MD)/krn $(MD)/krnp2 init $(MD)/ioman

# DriveWire support
DWIO		= $(MD)/dwio.sb

# RBF
RBF		= $(MD)/rbf.mn

# RBF DriveWire driver
RBFDW     = $(MD)/rbdw.dr $(MD)/x0.dd $(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

# RBF Foenix Cartridge/RAM disk driver
RBMEM = $(MD)/rbmem.dr $(MD)/c0.dd $(MD)/f0.dd

# RBF RBSuper driver
RBSUPER   = $(MD)/rbsuper.dr

# RBF Foenix SD card low level driver
RBFNXSD	= $(MD)/llfnxsd.sb $(MD)/s0.dd

# SCF
SCF		 = $(MD)/scf.mn

# Font & palette
FONT		 = $(FNT)/bannerfont.sb
PALETTE	 = $(MD)/palette.sb

# SCF video terminal
SCVT_F256JR  = $(MD)/vtio.dr $(MD)/keydrv_ps2.sb $(MD)/term.dt
SCVT_F256K   = $(MD)/vtio.dr $(MD)/keydrv_f256k.sb $(MD)/term.dt

# SCF DriveWire virtual networking/window driver
SCDWV = 	$(MD)/scdwv.dr $(SCDWV_NET) $(SCDWV_WIN)

# SCF DriveWire virtual networking descriptors
SCDWV_NET  = $(MD)/n_scdwv.dd $(MD)/n1_scdwv.dd \
		$(MD)/n2_scdwv.dd $(MD)/n3_scdwv.dd $(MD)/n4_scdwv.dd \
		$(MD)/n5_scdwv.dd $(MD)/n6_scdwv.dd $(MD)/n7_scdwv.dd \

# SCF DriveWire virtual window descriptors
SCDWV_WIN  = $(MD)/z1_scdwv.dd $(MD)/z2_scdwv.dd $(MD)/z3_scdwv.dd \
		$(MD)/z4_scdwv.dd $(MD)/z5_scdwv.dd $(MD)/z6_scdwv.dd \
		$(MD)/z7_scdwv.dd $(MD)/z8_scdwv.dd $(MD)/z9_scdwv.dd \
		$(MD)/z10_scdwv.dd $(MD)/z11_scdwv.dd $(MD)/z12_scdwv.dd \
		$(MD)/z13_scdwv.dd $(MD)/z14_scdwv.dd

# SCF DriveWire virtual printer driver
SCDWP     = $(MD)/scdwp.dr $(MD)/p_scdwp.dd

# Pipe
PIPE	= $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd

# Clock driver
CLOCK	= $(MD)/clock $(MD)/clock2_f256

# NOTE!!!
# VTIO must be near the top of the bootlist so that it can safely map
# the F256's text and CLUT blocks into $E000-$FFFF.
BOOTFILE_F256K = $(KERNEL) \
		$(SCF) $(SCVT_F256K) $(FONT) $(PALETTE) \
		$(RBF) $(RBFDW) $(DWIO) \
		$(RBSUPER) $(RBFNXSD) $(RBMEM) \
		$(PIPE) \
		$(CLOCK) \
		sysgo $(CMDSDIR)/shell_21 \
		$(CMDSDIR)/display \
		$(CMDSDIR)/echo $(CMDSDIR)/fnxreset \
		$(CMDSDIR)/iniz $(CMDSDIR)/deiniz \
		$(CMDSDIR)/load $(CMDSDIR)/link $(CMDSDIR)/unlink \
		$(CMDSDIR)/bootos9

# NOTE!!!
# VTIO must be near the top of the bootlist so that it can safely map
# the F256's text and CLUT blocks into $E000-$FFFF.
BOOTFILE_F256JR = $(KERNEL) \
		$(SCF) $(SCVT_F256JR) $(FONT) $(PALETTE) \
		$(RBF) $(RBFDW) $(DWIO) \
		$(RBSUPER) $(RBFNXSD) $(RBMEM) \
		$(PIPE) \
		$(CLOCK) \
		sysgo $(CMDSDIR)/shell_21 \
		$(CMDSDIR)/display \
		$(CMDSDIR)/echo $(CMDSDIR)/fnxreset \
		$(CMDSDIR)/iniz $(CMDSDIR)/deiniz \
		$(CMDSDIR)/load $(CMDSDIR)/link $(CMDSDIR)/unlink \
		$(CMDSDIR)/bootos9

F0_CMDS = $(CMDSDIR)/attr \
		$(CMDSDIR)/build \
		$(CMDSDIR)/copy \
		$(CMDSDIR)/date \
		$(CMDSDIR)/debug $(CMDSDIR)/del $(CMDSDIR)/deldir \
		$(CMDSDIR)/devs $(CMDSDIR)/dir $(CMDSDIR)/dump \
		$(CMDSDIR)/edit \
		$(CMDSDIR)/fnxinfo \
		$(CMDSDIR)/ident $(CMDSDIR)/irqs \
		$(CMDSDIR)/list \
		$(CMDSDIR)/makdir $(CMDSDIR)/mfree $(CMDSDIR)/mdir \
	    $(CMDSDIR)/pick \
 		$(CMDSDIR)/procs $(CMDSDIR)/pwd $(CMDSDIR)/pxd \
		$(CMDSDIR)/setime $(CMDSDIR)/sleep \
		$(CMDSDIR)/tmode

ALLOBJS		= init sysgo bootfile_f256k bootfile_f256jr booter_ram_f256k booter_flash_f256k \
				booter_ram_f256jr booter_flash_f256jr

all: $(DEPENDS) $(ALLOBJS) f0.dsk
	
# Some commands depend on net.o
$(NOSLIB)/net.o:
	cd $(NOSLIB); make
	
bootfile_f256k: sysgo $(BOOTFILE_F256K) $(DEPENDS)
	$(MERGE) $(BOOTFILE_F256K)>$@

bootfile_f256jr: sysgo $(BOOTFILE_F256JR) $(DEPENDS)
	$(MERGE) $(BOOTFILE_F256JR)>$@

booter_ram_f256k: bootfile_f256k
	$(MERGE) $(BOOTFILE_F256K)>bootfile_f256k
	$(PADROM) 23552 bootfile_f256k
	$(AS) -DFLASH=0 --output=raw trampoline.asm -otrampoline
	cat bootfile_f256k trampoline > $@
	$(RM) trampoline

booter_ram_f256jr: bootfile_f256jr
	$(MERGE) $(BOOTFILE_F256JR)>bootfile_f256jr
	$(PADROM) 23552 bootfile_f256jr
	$(AS) -DFLASH=0 --output=raw trampoline.asm -otrampoline
	cat bootfile_f256jr trampoline > $@
	$(RM) trampoline

booter_flash_f256k: bootfile_f256k
	$(MERGE) $(BOOTFILE_F256K)>bootfile_f256k
	$(PADROM) 23552 bootfile_f256k
	$(AS) -DFLASH=1 --output=raw trampoline.asm -otrampoline
	cat bootfile_f256k trampoline > $@
	$(RM) trampoline

booter_flash_f256jr: bootfile_f256jr
	$(MERGE) $(BOOTFILE_F256JR)>bootfile_f256jr
	$(PADROM) 23552 bootfile_f256jr
	$(AS) -DFLASH=1 --output=raw trampoline.asm -otrampoline
	cat bootfile_f256jr trampoline > $@
	$(RM) trampoline

upload_f256k: booter_ram_f256k
	upload $^ 8000

upload_f256jr: booter_ram_f256jr
	upload $^ 8000

f256k.zip: booter_flash_f256k
	-rm booter_? bulk.csv
	dd status=none bs=8k skip=0 count=1 if=$^ of=booter_0
	dd status=none bs=8k skip=1 count=1 if=$^ of=booter_1
	dd status=none bs=8k skip=2 count=1 if=$^ of=booter_2
	echo "3d,booter_0" > bulk.csv
	echo "3e,booter_1" >> bulk.csv
	echo "3f,booter_2" >> bulk.csv
	-rm -rf mapfiles
	mkdir mapfiles
	os9 ident -s $^ > mapfiles/bootlist
	cp ../modules/kernel/*.map ../modules/kernel/*.list ../modules/*.map ../modules/*.list mapfiles
	zip $@ bulk.csv booter_0 booter_1 booter_2 mapfiles/*

flash_f256k: f256k.zip
	bulk_flash bulk.csv

f256jr.zip: booter_flash_f256jr
	-rm booter_? bulk.csv
	dd status=none bs=8k skip=0 count=1 if=$^ of=booter_0
	dd status=none bs=8k skip=1 count=1 if=$^ of=booter_1
	dd status=none bs=8k skip=2 count=1 if=$^ of=booter_2
	echo "3d,booter_0" > bulk.csv
	echo "3e,booter_1" >> bulk.csv
	echo "3f,booter_2" >> bulk.csv
	-rm -rf mapfiles
	mkdir mapfiles
	os9 ident -s $^ > mapfiles/bootlist
	cp ../modules/kernel/*.map ../modules/kernel/*.list ../modules/*.map ../modules/*.list mapfiles
	zip $@ bulk.csv booter_0 booter_1 booter_2 mapfiles/*

flash_f256jr: f256jr.zip
	bulk_flash bulk.csv

f0.zip: f0.dsk
	-rm f0_? bulk.csv
	dd status=none bs=8k skip=0 count=1 if=$^ of=f0_0
	dd status=none bs=8k skip=1 count=1 if=$^ of=f0_1
	dd status=none bs=8k skip=2 count=1 if=$^ of=f0_2
	dd status=none bs=8k skip=3 count=1 if=$^ of=f0_3
	dd status=none bs=8k skip=4 count=1 if=$^ of=f0_4
	echo "38,f0_0" > bulk.csv
	echo "39,f0_1" >> bulk.csv
	echo "3a,f0_2" >> bulk.csv
	echo "3b,f0_3" >> bulk.csv
	echo "3c,f0_4" >> bulk.csv
	zip $@ bulk.csv f0_0 f0_1 f0_2 f0_3 f0_4

flash_f0: f0.zip
	bulk_flash bulk.csv

FEU_FILES = $(foreach file,feu/*,$(file))

f0.dsk: feu/startup
	$(OS9FORMAT) -q -t10 -st16 $@ -n"FEU"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(F0_CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(F0_CMDS),$@,CMDS/$(file))
	$(MAKDIR) $@,FEU
	$(foreach file,$(FEU_FILES),$(OS9COPY) -l $(file) $@,FEU)
	
feu/startup: FORCE
	echo "display 1b 60 0 ff ff 20 ff 1b 61 1 ff 0 0 ff 5 22 f0 1b 20 2 0 0 50 18 0 1 0" > $@
	echo "echo FEU - Foenix Executive Utility" >> $@
	echo "echo Build date:" `date` >> $@
	echo "fnxinfo" >> $@
	echo "chd .../feu" >> $@
	echo "pick -pFEU: main.pick</1" >> $@

FORCE: ;

clean:
	$(RM) $(ALLOBJS) *.o *.tmp vectors trampoline *.list *.map *.dsk bulk.csv f0_? booter_? *.zip feu/startup

feu: feu.o
	$(LINKER) $(LFLAGS) $^ -o$@
