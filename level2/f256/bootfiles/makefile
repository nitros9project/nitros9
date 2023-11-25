include ../port.mak

# Module directory
MD		= ../modules
# Commands directory
CMDSDIR		= ../cmds

DEPENDS		= ./makefile

# Kernel
KERNEL	= $(MD)/krn
KERNELP2	= $(MD)/krnp2 $(MD)/init $(MD)/ioman

# DriveWire support
DWIO		= $(MD)/dwio.sb

# RBF
RBF		= $(MD)/rbf.mn

# RBF DriveWire driver
RBDW      = $(MD)/rbdw.dr $(MD)/x0.dd $(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

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

# Clock driver
CLOCK	= $(MD)/clock $(MD)/clock2_f256

BOOTFILE_SD = $(KERNELP2) \
		$(SCF) $(SCVT) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBFNXCART) $(RBFNXSD) \
		$(MD)/dds0.dd \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

BOOTFILE_DW = $(KERNELP2) \
		$(SCF) $(SCVT) \
		$(FONT) $(PALETTE) \
		$(DWIO) \
		$(RBF) $(RBDW) $(RBSUPER) $(RBFNXCART) $(RBFNXSD) \
		$(MD)/ddx0.dd \
		$(CLOCK) \
		$(MD)/sysgo \
		$(MD)/kernel/krn

ALLOBJS		= bootfile_sd bootfile_dw

all:	$(ALLOBJS)

bootfile_sd: $(BOOTFILE_SD) $(DEPENDS)
	$(MERGE) $(BOOTFILE_SD)>$@
	./padup256 $@

bootfile_dw: $(BOOTFILE_DW) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DW)>$@
	./padup256 $@

upload: bootfile_dw
	upload bootfile 8000

trace:
	@dump 0 20
	@echo "            CCAABBDPXXXX YYYYUUUUSSSSPCPC"
	@echo

clean:
	$(RM) $(ALLOBJS)