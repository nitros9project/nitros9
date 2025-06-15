include ../port.mak

# Module directory
LFLAGS          += -L $(NITROS9DIR)/lib -lnet -lf256 -lalib
MD		= ../modules
FNT             = ../sys/fonts
# Commands directory
CMDSDIR		= ../cmds

DEPENDS		= ./makefile

# Kernel
KERNEL	= $(MD)/krn $(MD)/krnp2 $(MD)/init $(MD)/ioman

# Select one of the dwio modules below based on your desired configuration:
#DWIO 	= $(MD)/dwio_wizfi.sb
DWIO 	= $(MD)/dwio_serial.sb

# PIPE
PIPE	= $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd

# RBF
RBF		= $(MD)/rbf.mn

# RBF DriveWire driver
RBFDW     = $(MD)/rbdw.dr $(MD)/x0.dd $(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

# RBF Foenix Flash/RAM disk driver
RBMEM = $(MD)/rbmem.dr $(MD)/f0.dd $(MD)/c0.dd $(MD)/f1.dd $(MD)/c1.dd

# RBF RBSuper driver
RBSUPER   = $(MD)/rbsuper.dr

# RBF Foenix SD card low level driver
RBFNXSD	= $(MD)/llfnxsd.sb $(MD)/s0.dd $(MD)/s1.dd

# RBF Dummy low level driver
RBFDUMMY	= $(MD)/lldummy.sb $(MD)/s0_v.dd

# SCF
SCF		 = $(MD)/scf.mn

# SCF video terminal
SCVT_F256K  = $(MD)/vtio.dr $(MD)/keydrv_f256k.sb $(MD)/term.dt
SCVT_F256JR = $(MD)/vtio.dr $(MD)/keydrv_ps2.sb $(MD)/term.dt

# SCF 16550 serial driver
SC16550  = $(MD)/sc16550.dr $(MD)/t0_sc16550.dd

# Font & palette
FONT		 = $(FNT)/bannerfont.sb
PALETTE	 = $(MD)/palette.sb

# SCF DriveWire virtual networking/window driver
SCDWV = 	$(MD)/scdwv.dr $(SCDWV_NET) $(SCDWV_WIN)

SC16550 =   $(MD)/sc16550.dr $(MD)/t0_sc16550.dd

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

# NOTE!!!
# VTIO must be near the top of the bootlist so that it can safely map
# the F256's text and CLUT blocks into $E000-$FFFF.
BOOTFILE_SD_F256K = $(KERNEL) \
		$(SCF) $(SCVT_F256K) $(FONT) $(PALETTE) \
		$(PIPE) \
		$(RBF) $(RBFDW) $(DWIO) \
		$(RBSUPER) $(RBFNXSD) $(RBMEM) \
		$(MD)/dds0.dd \
		$(SC16550) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(CMDSDIR)/shell_21

# NOTE!!!
# VTIO must be near the top of the bootlist so that it can safely map
# the F256's text and CLUT blocks into $E000-$FFFF.
BOOTFILE_SD_F256JR = $(KERNEL) \
		$(SCF) $(SCVT_F256JR) $(FONT) $(PALETTE) \
		$(PIPE) \
		$(RBF) $(RBFDW) $(DWIO) \
		$(RBSUPER) $(RBFNXSD) $(RBMEM) \
		$(MD)/dds0.dd \
		$(SC16550) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(CMDSDIR)/shell_21

# NOTE!!!
# VTIO must be near the top of the bootlist so that it can safely map
# the F256's text and CLUT blocks into $E000-$FFFF.
BOOTFILE_DW_F256K = $(KERNEL) \
		$(SCF) $(SCVT_F256K) $(FONT) $(PALETTE) \
		$(PIPE) \
		$(RBF) $(RBFDW) $(DWIO) \
		$(RBSUPER) $(RBFNXSD) $(RBMEM) \
		$(MD)/ddx0.dd \
		$(SC16550) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(CMDSDIR)/shell_21
		
# NOTE!!!
# VTIO must be near the top of the bootlist so that it can safely map
# the F256's text and CLUT blocks into $E000-$FFFF.
BOOTFILE_DW_F256JR = $(KERNEL) \
		$(SCF) $(SCVT_F256JR) $(FONT) $(PALETTE) \
		$(PIPE) \
		$(RBF) $(RBFDW) $(DWIO) \
		$(RBSUPER) $(RBFNXSD) $(RBMEM) \
		$(MD)/ddx0.dd \
		$(SC16550) \
		$(CLOCK) \
		$(MD)/sysgo \
		$(CMDSDIR)/shell_21
		
ALLOBJS		= bootfile_sd_f256k bootfile_sd_f256jr \
			 bootfile_dw_f256k bootfile_dw_f256jr
		
all: $(ALLOBJS)

# Level 1 bootfiles require that krn be the first module in the bootfile. 
# It also requires that the bootfile be padded out to a multiple of 256
# bytes. Finally, the trampoline code is borrowed from Level 2 but is only
# necessary to fill the areas between $FD00-$FFFF.
bootfile_sd_f256k: $(BOOTFILE_SD_F256K) $(DEPENDS)
	$(MERGE) $(BOOTFILE_SD_F256K)>$@

bootfile_sd_f256jr: $(BOOTFILE_SD_F256JR) $(DEPENDS)
	$(MERGE) $(BOOTFILE_SD_F256JR)>$@

bootfile_dw_f256k: $(BOOTFILE_DW_F256K) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DW_F256K)>$@

bootfile_dw_f256jr: $(BOOTFILE_DW_F256JR) $(DEPENDS)
	$(MERGE) $(BOOTFILE_DW_F256JR)>$@

clean:
	$(RM) $(ALLOBJS)
