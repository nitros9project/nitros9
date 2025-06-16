include ../port.mak

# Module directory
MD		= ../modules
# Commands directory
CMDSDIR		= ../cmds
# Font directory
FNT 	        = ../sys/fonts

DEPENDS		= ./makefile

# Kernel
KERNEL	= $(MD)/krn
KERNELP2	= $(MD)/krnp2 $(MD)/init $(MD)/ioman

# Classic OS-9 PIPE
PIPE = $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd

# Select one of the dwio modules below based on your desired configuration:
#DWIO 	= $(MD)/dwio_wizfi.sb
DWIO 	= $(MD)/dwio_serial.sb

# RBF
RBF		= $(MD)/rbf.mn

# RBF DriveWire driver
RBDW      = $(MD)/rbdw.dr $(MD)/x0.dd $(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

# RBF Foenix Flash/RAM disk driver
RBMEM = $(MD)/rbmem.dr $(MD)/f0.dd $(MD)/c0.dd $(MD)/f1.dd $(MD)/c1.dd

# RBF RBSuper driver
RBSUPER   = $(MD)/rbsuper.dr

# RBF Foenix SD card low level driver
RBFNXSD	= $(MD)/llfnxsd.sb $(MD)/s0.dd $(MD)/s1.dd

# SCF
SCF		 = $(MD)/scf.mn

# SCF 16550
SC16550	 = $(MD)/sc16550.dr $(MD)/t0_sc16550.dd

# WizFi360 drivers
WIZFI = $(MD)/wizfi.dr $(MD)/wz.dd $(MD)/n0.dd $(MD)/n1.dd $(MD)/n2.dd $(MD)/n3.dd

# SCF video terminal
SCVT_F256K	 = $(MD)/vtio.dr $(MD)/keydrv_f256k.sb $(MD)/mousedrv_ps2.sb $(MD)/term.dt
SCVT_F256JR  = $(MD)/vtio.dr $(MD)/keydrv_ps2.sb $(MD)/mousedrv_ps2.sb $(MD)/term.dt

# Font & palette
#FONT		 = $(FNT)/bannerfont.sb
#PALETTE	 = $(MD)/palette.sb

#SOL
SOL = $(MD)/SOLdrv.sb $(MD)/fSOL.dd 

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

# Clock driver
CLOCK	= $(MD)/clock $(MD)/clock2_f256

BOOTFILE_SD_F256K = $(KERNELP2) \
		$(SCF) $(SCVT_F256K) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBFNXSD) \
		$(MD)/dds0.dd \
		$(SOL) \
        	$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_DW_F256K = $(KERNELP2) \
		$(SCF) $(SCVT_F256K) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBFNXSD) \
		$(MD)/ddx0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_SD_F256JR = $(KERNELP2) \
		$(SCF) $(SCVT_F256JR) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBFNXSD) \
		$(MD)/dds0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_DW_F256JR = $(KERNELP2) \
		$(SCF) $(SCVT_F256JR) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBFNXSD) \
		$(MD)/ddx0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_CART_F256JR = $(KERNELP2) \
		$(SCF) $(SCVT_F256JR) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBMEM) $(RBFNXSD) \
		$(MD)/ddc0.dd \
		$(SOL) \
		$(WIZFI) \
		$(PIPE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

ALLOBJS		= bootfile_sd_f256k bootfile_dw_f256k bootfile_sd_f256jr bootfile_dw_f256jr bootfile_cart_f256jr

all:	$(ALLOBJS)

bootfile_sd_f256k: $(BOOTFILE_SD_F256K) $(DEPENDS)
	$(MERGE) $(BOOTFILE_SD_F256K)>$@
	./padup256 $@

bootfile_dw_f256k: $(BOOTFILE_DW_F256K) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DW_F256K)>$@
	./padup256 $@

upload_f256jr: bootfile_dw_f256jr
	upload bootfile_f256kr 8000

bootfile_sd_f256jr: $(BOOTFILE_SD_F256JR) $(DEPENDS)
	$(MERGE) $(BOOTFILE_SD_F256JR)>$@
	./padup256 $@

bootfile_dw_f256jr: $(BOOTFILE_DW_F256JR) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DW_F256JR)>$@
	./padup256 $@

upload_f256jr: bootfile_dw_f256jr
	upload bootfile_f256jr 8000

bootfile_cart_f256jr: $(BOOTFILE_CART_F256JR) $(DEPENDS)
	$(MERGE) $(BOOTFILE_CART_F256JR)>$@
	./padup256 $@

trace:
	@dump 0 20
	@echo "            CCAABBDPXXXX YYYYUUUUSSSSPCPC"
	@echo

clean:
	$(RM) $(ALLOBJS)
