include $(NITROS9DIR)/rules.mak

# Module and cmds directories
MD		= ../modules
CM		= ../cmds

DEPENDS		= ./makefile

# The _80 in rel_80 refers to 80-column screen
KERNEL_REALCOCOFPGA	= $(MD)/rel_80 $(MD)/boot_realcocofpga $(MD)/krn

REALCOCOFPGA_SDC_DRIVERS = $(MD)/realcocofpga_sdc.dr \
	$(MD)/realcocofpga_sdc_dds0.dd \
	$(MD)/realcocofpga_sdc_s0.dd \
	$(MD)/realcocofpga_sdc_s1.dd \
	$(MD)/realcocofpga_sdc_s2.dd \
	$(MD)/realcocofpga_sdc_s3.dd

VTIO_COWIN_80 = $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cowin.io \
		$(MD)/term_win80.dt \
		$(MD)/w.dw $(MD)/w1.dw $(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw \
		$(MD)/w5.dw $(MD)/w6.dw $(MD)/w7.dw

PIPE       = $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd
CLOCK60HZ  = $(MD)/clock_60hz $(MD)/clock2_soft

BOOTFILE_REALCOCOFPGA	= $(MD)/krnp2 $(MD)/krnp3_perr $(MD)/krnp4_regdump $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
        $(REALCOCOFPGA_SDC_DRIVERS) \
		$(MD)/scf.mn \
		$(VTIO_COWIN_80) \
		$(PIPE) \
		$(CLOCK60HZ)

BOOTFILES	= bootfile_realcocofpga
KERNELS		= kernel_realcocofpga

ALLOBJS		= $(BOOTFILES) $(KERNELS)

all:	$(ALLOBJS)

bootfile_realcocofpga: $(BOOTFILE_REALCOCOFPGA) $(DEPENDS)
	$(MERGE) $(BOOTFILE_REALCOCOFPGA)>$@

kernel_realcocofpga: $(KERNEL_REALCOCOFPGA) $(DEPENDS)
	$(MERGE) $(KERNEL_REALCOCOFPGA)>$@

clean:
	$(RM) $(ALLOBJS)
