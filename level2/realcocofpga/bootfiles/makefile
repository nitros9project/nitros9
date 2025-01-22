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
KERNELP2	= $(MD)/krnp2 $(MD)/krnp3_perr $(MD)/krnp4_regdump $(MD)/init $(MD)/ioman

# DriveWire support
DWIO		= $(MD)/dwio.sb

# RBF
RBF		= $(MD)/rbf.mn

# RBF DriveWire driver
RBDW      = $(MD)/rbdw.dr $(MD)/x0.dd $(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

# RBF Foenix Flash/RAM disk driver
RBMEM = $(MD)/rbmem.dr $(MD)/c0.dd $(MD)/f0.dd

# RBF RBSuper driver
RBSUPER   = $(MD)/rbsuper.dr

# RBF Foenix SD card low level driver
RBFNXSD	= $(MD)/llfnxsd.sb $(MD)/s0.dd

# SCF
SCF		 = $(MD)/scf.mn

# SCF 16550
SC16550	 = $(MD)/sc16550.dr $(MD)/t0_sc16550.dd

# SCF video terminal
SCVT_F256K	 = $(MD)/vtio.dr $(MD)/keydrv_f256k.sb $(MD)/mousedrv_ps2.sb $(MD)/term.dt
SCVT_F256JR  = $(MD)/vtio.dr $(MD)/keydrv_ps2.sb $(MD)/mousedrv_ps2.sb $(MD)/term.dt

# Font & palette
FONT		 = $(FNT)/bannerfont.sb
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
CLOCK60HZ  = $(MD)/clock_60hz $(MD)/clock2_soft


# The _80 in rel_80 refers to 80-column screen
KERNEL_REALCOCOFPGA	= $(MD)/rel_80 $(MD)/bootmodule_realcocofpga $(MD)/krn

REALCOCOFPGA_SDC_DRIVERS = $(MD)/realcocofpga_sdc.dr \
	$(MD)/realcocofpga_sdc_dds0.dd \
	$(MD)/realcocofpga_sdc_s0.dd \
	$(MD)/realcocofpga_sdc_s1.dd \

VTIO_COWIN_80 = $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cowin.io \
		$(MD)/term_win80.dt \
		$(MD)/w.dw $(MD)/w1.dw $(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw \
		$(MD)/w5.dw $(MD)/w6.dw $(MD)/w7.dw

PIPE       = $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd

BOOTFILEMODULES_REALCOCOFPGA = $(MD)/krnp2 $(MD)/krnp3_perr $(MD)/krnp4_regdump $(MD)/ioman $(MD)/init \
		$(RBF) \
        $(REALCOCOFPGA_SDC_DRIVERS) \
		$(SCF) \
		$(VTIO_COWIN_80) \
		$(PIPE) \
		$(CLOCK60HZ) \
		$(MD)/sysgo_dd

# BOOTFILE_REALCOCOFPGA	= $(MD)/krnp2 $(MD)/krnp3_perr $(MD)/krnp4_regdump $(MD)/ioman $(MD)/init \
# 		$(MD)/rbf.mn \
#         $(REALCOCOFPGA_SDC_DRIVERS) \
# 		$(MD)/scf.mn \
# 		$(VTIO_COWIN_80) \
# 		$(PIPE) \
# 		$(CLOCK60HZ)

BOOTFILES	= boot_realcocofpga
KERNELS		= kernel_realcocofpga

ALLOBJS		= $(BOOTFILES) $(KERNELS)


all:	$(ALLOBJS)


boot_realcocofpga: $(BOOTFILEMODULES_REALCOCOFPGA) $(DEPENDS)
	$(MERGE) $(BOOTFILEMODULES_REALCOCOFPGA)>$@
#	./padup256 $@

kernel_realcocofpga: $(KERNEL_REALCOCOFPGA) $(DEPENDS)
	$(MERGE) $(KERNEL_REALCOCOFPGA)>$@
#	./padup256 $@



#trace:
#	@dump 0 20
#	@echo "            CCAABBDPXXXX YYYYUUUUSSSSPCPC"
#	@echo


clean:
	$(RM) $(ALLOBJS)
