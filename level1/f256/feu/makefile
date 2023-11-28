include ../port.mak

DEPENDS		= ./makefile $(NOSLIB)/net.o

# Module directory
LFLAGS          += -L $(NITROS9DIR)/lib -lnet -lf256 -lalib
MD		= ../modules
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

# RBF Foenix Flash/RAM disk driver
RBFNXCART = $(MD)/rbfnxcart.dr $(MD)/c0.dd

# RBF RBSuper driver
RBSUPER   = $(MD)/rbsuper.dr

# RBF Foenix SD card low level driver
RBFNXSD	= $(MD)/llfnxsd.sb $(MD)/s0.dd

# SCF
SCF		 = $(MD)/scf.mn

# SCF video terminal
SCVT		 = $(MD)/vtio.dr $(MD)/term.dt

# Font & palette
FONT		 = $(MD)/phoenixegafont.sb
PALETTE	 = $(MD)/palette.sb

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

BOOTFILE = $(KERNEL) $(DWIO) \
		$(RBF) $(RBFDW) \
		$(RBSUPER) $(RBFNXSD) $(RBFNXCART) \
		$(SCF) $(SCVT) $(FONT) $(PALETTE) \
		$(PIPE) \
		$(CLOCK) \
		sysgo autoex \
		$(CMDSDIR)/shell_21 $(CMDSDIR)/debug \
		$(CMDSDIR)/date $(CMDSDIR)/devs \
		$(CMDSDIR)/irqs $(CMDSDIR)/procs \
		$(CMDSDIR)/mfree $(CMDSDIR)/mdir \
		$(CMDSDIR)/display $(CMDSDIR)/iniz \
		$(CMDSDIR)/deiniz $(CMDSDIR)/link \
		$(CMDSDIR)/unlink

ALLOBJS		= init sysgo autoex bootfile booter_ram booter_flash

all: $(DEPENDS) $(ALLOBJS)
	
# Some commands depend on net.o
$(NOSLIB)/net.o:
	cd $(NOSLIB); make
	
bootfile: sysgo autoex $(BOOTFILE) $(DEPENDS)
	$(MERGE) $(BOOTFILE)>$@

booter_ram: bootfile
	$(MERGE) $(BOOTFILE)>bootfile
	$(PADROM) 31744 bootfile
	$(AS) -DFLASH=0 --output=raw trampoline.asm -otrampoline
	cat bootfile trampoline > $@
	$(RM) trampoline

booter_flash: bootfile
	$(MERGE) $(BOOTFILE)>bootfile
	$(PADROM) 31744 bootfile
	$(AS) -DFLASH=1 --output=raw trampoline.asm -otrampoline
	cat bootfile trampoline > $@
	$(RM) trampoline

upload: booter_ram
	upload $^ 8000

flash: booter_flash
	dd status=none bs=8k skip=0 count=1 if=$^ of=booter_0
	dd status=none bs=8k skip=1 count=1 if=$^ of=booter_1
	dd status=none bs=8k skip=2 count=1 if=$^ of=booter_2
	dd status=none bs=8k skip=3 count=1 if=$^ of=booter_3
	echo "3c,booter_0" > bulk.csv
	echo "3d,booter_1" >> bulk.csv
	echo "3e,booter_2" >> bulk.csv
	echo "3f,booter_3" >> bulk.csv
	bulk_flash bulk.csv
	rm booter_? bulk.csv

clean:
	$(RM) $(ALLOBJS) *.o *.tmp vectors autoex trampoline

autoex: feu.o os9boot.o autoexec.o
	$(LINKER) $(LFLAGS) $^ -o$@
