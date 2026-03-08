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

# Shell (merged module file built in cmds/)
SHELLMOD    = ../cmds/shell

# OS9Boot disk image: all modules loaded from PATA by boot_picothing.
# boot_picothing and krn are already in RAM (loaded via SREC); including them
# here is harmless - I.VBlock will simply ignore duplicate module names.
BOOTFILE_PT = $(KERNELP2) \
              $(BOOT) \
              $(RBF) \
              $(SCF) \
              $(CLOCK) \
              $(PIPE) \
              $(SYSGO) \
              $(SHELLMOD) \
              $(KERNEL)

SREC        = boot_picothing.srec

ALLOBJS     = bootfile_pt $(SREC)

all:    $(ALLOBJS)

bootfile_pt: $(BOOTFILE_PT) $(DEPENDS)
	$(MERGE) $(BOOTFILE_PT) >$@

DBGMON      = $(MD)/dbgmon

# SREC contains boot module, krn, and dbgmon — but also embeds SWIStack
# and interrupt stubs derived from krn.  Rebuild whenever any input changes.
$(SREC): $(BOOT) $(KERNEL) $(KERNELP2) $(DBGMON) $(DEPENDS)
	python3 $(NITROS9DIR)/scripts/mk_picothing_srec.py $(NITROS9DIR) >$@

clean:
	$(RM) $(ALLOBJS)
