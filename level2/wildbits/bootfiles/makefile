include ../port.mak

# Module directory
MD		= ../modules
# Commands directory
CMDSDIR		= ../cmds
# Font directory
FNT		= ../sys/fonts

DEPENDS		= ./makefile

# Kernel
KERNEL	= $(MD)/krn
KERNELP2	= $(MD)/krnp2 $(MD)/init $(MD)/ioman

# Classic OS-9 PIPE
PIPE = $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd

# Select one of the dwio modules below based on your desired configuration:
#DWIO	= $(MD)/dwio_wizfi.sb
DWIO	= $(MD)/dwio_serial.sb

# RBF
RBF		= $(MD)/rbf.mn

# RBF DriveWire driver
RBDW	  = $(MD)/rbdw.dr $(MD)/x0.dd $(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

# RBF Wildbits Flash/RAM disk driver
RBMEM = $(MD)/rbmem.dr $(MD)/f0.dd $(MD)/c0.dd $(MD)/f1.dd $(MD)/c1.dd

# RBF RBSuper driver
RBSUPER	  = $(MD)/rbsuper.dr

# RBF Wildbits SD card low level driver
RBWBSD = $(MD)/llwbsd.sb $(MD)/s0.dd $(MD)/s1.dd

# SCF
SCF		 = $(MD)/scf.mn

# SCF 16550
SC16550	 = $(MD)/sc16550.dr $(MD)/t0_sc16550.dd

# WizFi360 drivers
WIZFI = $(MD)/wizfi.dr $(MD)/wz.dd $(MD)/wz0.dd $(MD)/wz1.dd $(MD)/wz2.dd $(MD)/wz3.dd

# SCF video terminal
SCVT_K2  = $(MD)/vtio.dr $(MD)/keydrv_k2.sb $(MD)/mousedrv_ps2.sb $(MD)/term.dt
SCVT_K   = $(MD)/vtio.dr $(MD)/keydrv_k.sb $(MD)/mousedrv_ps2.sb $(MD)/term.dt
SCVT_JR  = $(MD)/vtio.dr $(MD)/keydrv_ps2.sb $(MD)/mousedrv_ps2.sb $(MD)/term.dt

# Font & palette
#FONT		 = $(FNT)/bannerfont.sb
#PALETTE	 = $(MD)/palette.sb

#SOL
SOL = $(MD)/SOLdrv.sb $(MD)/fSOL.dd 

# SCF DriveWire virtual networking/window driver
SCDWV =		$(MD)/scdwv.dr $(SCDWV_NET) $(SCDWV_WIN)

# SCF DriveWire virtual networking descriptors
SCDWV_NET  = $(MD)/n_scdwv.dd $(MD)/n1_scdwv.dd \
		$(MD)/n2_scdwv.dd $(MD)/n3_scdwv.dd $(MD)/n4_scdwv.dd \
		$(MD)/n5_scdwv.dd $(MD)/n6_scdwv.dd $(MD)/n7_scdwv.dd \

# SCF DriveWire virtual window descriptors
SCDWV_WIN  = $(MD)/z1_scdwv.dd $(MD)/z2_scdwv.dd $(MD)/z3_scdwv.dd \
		$(MD)/z4_scdwv.dd $(MD)/z5_scdwv.dd $(MD)/z6_scdwv.dd \
		$(MD)/z7_scdwv.dd

# SCF DriveWire virtual printer driver
SCDWP	  = $(MD)/scdwp.dr $(MD)/p_scdwp.dd

# Clock driver
CLOCK	= $(MD)/clock $(MD)/clock2_wildbits

BOOTFILE_SD_K2 = $(KERNELP2) \
		$(SCF) $(SCVT_K2) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBWBSD) \
		$(MD)/dds0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_DW_K2 = $(KERNELP2) \
		$(SCF) $(SCVT_K2) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBWBSD) \
		$(MD)/ddx0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_SD_K = $(KERNELP2) \
		$(SCF) $(SCVT_K) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBWBSD) \
		$(MD)/dds0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_DW_K = $(KERNELP2) \
		$(SCF) $(SCVT_K) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBWBSD) \
		$(MD)/ddx0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_SD_JR = $(KERNELP2) \
		$(SCF) $(SCVT_JR) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBWBSD) \
		$(MD)/dds0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_DW_JR = $(KERNELP2) \
		$(SCF) $(SCVT_JR) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBWBSD) \
		$(MD)/ddx0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_CART_JR = $(KERNELP2) \
		$(SCF) $(SCVT_JR) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBWBSD) \
		$(MD)/ddc0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

ALLOBJS		= bootfile_sd_k2 bootfile_dw_k2 bootfile_sd_k bootfile_dw_k \
		  bootfile_sd_jr bootfile_dw_jr bootfile_cart_jr

all:	$(ALLOBJS)

bootfile_sd_k2: $(BOOTFILE_SD_K2) $(DEPENDS)
	$(MERGE) $(BOOTFILE_SD_K2)>$@
	./padup256 $@

bootfile_dw_k2: $(BOOTFILE_DW_K2) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DW_K2)>$@
	./padup256 $@

upload_k2: bootfile_dw_k2
	upload bootfile_k2 8000

bootfile_sd_k: $(BOOTFILE_SD_K) $(DEPENDS)
	$(MERGE) $(BOOTFILE_SD_K)>$@
	./padup256 $@

bootfile_dw_k: $(BOOTFILE_DW_K) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DW_K)>$@
	./padup256 $@

upload_k: bootfile_dw_k
	upload bootfile_k 8000

bootfile_sd_jr: $(BOOTFILE_SD_JR) $(DEPENDS)
	$(MERGE) $(BOOTFILE_SD_JR)>$@
	./padup256 $@

bootfile_dw_jr: $(BOOTFILE_DW_JR) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DW_JR)>$@
	./padup256 $@

upload_jr: bootfile_dw_jr
	upload bootfile_jr 8000

bootfile_cart_jr: $(BOOTFILE_CART_JR) $(DEPENDS)
	$(MERGE) $(BOOTFILE_CART_JR)>$@
	./padup256 $@

trace:
	@dump 0 20
	@echo "		   CCAABBDPXXXX YYYYUUUUSSSSPCPC"
	@echo

clean:
	$(RM) $(ALLOBJS)
