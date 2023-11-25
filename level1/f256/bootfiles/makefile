include ../port.mak

# Module directory
LFLAGS          += -L $(NITROS9DIR)/lib -lnet -lf256 -lalib
MD		= ../modules
# Commands directory
CMDSDIR		= ../cmds

DEPENDS		= ./makefile

# Kernel
KERNEL	= $(MD)/krn $(MD)/krnp2 $(MD)/init $(MD)/ioman

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
RBFNXSD	= $(MD)/llfnxsd.sb $(MD)/dds0.dd $(MD)/s0.dd

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

BOOTFILE = $(KERNEL) $(DWIO) \
		$(RBF) $(RBFDW) \
		$(RBSUPER) $(RBFNXSD) $(RBFNXCART) \
		$(SCF) $(SCVT) $(FONT) $(PALETTE) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(CMDSDIR)/shell_21

ALLOBJS		= bootfile

all: $(ALLOBJS)

# Level 1 bootfiles require that krn be the first module in the bootfile. 
# It also requires that the bootfile be padded out to a multiple of 256
# bytes. Finally, the trampoline code is borrowed from Level 2 but is only
# necessary to fill the areas between $FD00-$FFFF.
bootfile: $(BOOTFILE) $(DEPENDS)
	$(MERGE) $(BOOTFILE)>$@

clean:
	$(RM) $(ALLOBJS) bootfile