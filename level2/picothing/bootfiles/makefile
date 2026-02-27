include ../port.mak

# Module directory
MD          = ../modules

DEPENDS     = ./makefile

# Kernel
KERNEL      = $(MD)/krn
KERNELP2    = $(MD)/krnp2 $(MD)/init $(MD)/ioman

# Boot module (PATA IDE boot)
BOOT        = $(MD)/boot_picothing

# RBF stack
RBF         = $(MD)/rbf.mn $(MD)/rbsuper.dr $(MD)/llide_pt.dr $(MD)/ddi0_pt.dd

# SCF stack
SCF         = $(MD)/scf.mn $(MD)/sc6850.dr $(MD)/term_pt.dd

# Clock
CLOCK       = $(MD)/clock_picothing $(MD)/clock2_null

# PIPE
PIPE        = $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd

# Sysgo
SYSGO       = $(MD)/sysgo

# Bootfile contents: krnp2 + init + ioman + boot + drivers + sysgo + krn
# krn must be last (it scans backward to find other modules)
BOOTFILE_PT = $(KERNELP2) \
              $(BOOT) \
              $(RBF) \
              $(SCF) \
              $(CLOCK) \
              $(PIPE) \
              $(SYSGO) \
              $(KERNEL)

ALLOBJS     = bootfile_pt

all:    $(ALLOBJS)

bootfile_pt: $(BOOTFILE_PT) $(DEPENDS)
	$(MERGE) $(BOOTFILE_PT) >$@

clean:
	$(RM) $(ALLOBJS)
