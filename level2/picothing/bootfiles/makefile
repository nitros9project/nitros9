include ../port.mak

# Module directory
MD          = ../modules

DEPENDS     = ./makefile

# Kernel
KERNEL      = $(MD)/krn
KERNELP2    = $(MD)/krnp2 $(MD)/init $(MD)/ioman

# Boot module (PATA IDE boot)
BOOT        = $(MD)/boot_picothing

# RBF stack (PATA IDE, 8 x 512MB partitions = 4GB)
RBF         = $(MD)/rbf.mn $(MD)/rbsuper.dr $(MD)/llide_pt.dr $(MD)/ddi0_pt.dd \
              $(MD)/i0_pt.dd $(MD)/i1_pt.dd $(MD)/i2_pt.dd $(MD)/i3_pt.dd \
              $(MD)/i4_pt.dd $(MD)/i5_pt.dd $(MD)/i6_pt.dd $(MD)/i7_pt.dd

# RBF DriveWire stack
RBDW        = $(MD)/rbdw.dr $(MD)/dwio.sb \
              $(MD)/ddx0.dd $(MD)/x0.dd $(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

# SCF stack (serial console)
SCF         = $(MD)/scf.mn $(MD)/sc6850.dr $(MD)/term_pt.dd

# SCF DriveWire virtual channels
SCDWV       = $(MD)/scdwv.dr $(MD)/term_scdwv.dt $(MD)/n_scdwv.dd \
              $(MD)/n1_scdwv.dd $(MD)/n2_scdwv.dd \
              $(MD)/n3_scdwv.dd $(MD)/n4_scdwv.dd

# Graphics console (CoPico)
GFX         = $(MD)/vtio_picothing.dr $(MD)/copico $(MD)/term_gfx.dd

# Clock
CLOCK       = $(MD)/clock_picothing $(MD)/clock2_dw

# PIPE
PIPE        = $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd

# Sysgo
SYSGO       = $(MD)/sysgo

# Shell (merged module file built in cmds/)
SHELLMOD    = ../cmds/shell

# OS9Kernel: krn + boot module, loaded by REL before the kernel runs.
# The kernel scans this block for modules, finding both.
OS9KERNEL   = $(KERNEL) $(BOOT)

# OS9Boot: all remaining modules for IDE + DriveWire + graphics.
# krn and boot_picothing are NOT included here — they arrive via
# OS9Kernel (loaded by REL) or via the SREC fallback path.
BOOTFILE_PT = $(KERNELP2) \
              $(RBF) \
              $(RBDW) \
              $(SCF) \
              $(SCDWV) \
              $(GFX) \
              $(CLOCK) \
              $(PIPE) \
              $(SYSGO) \
              $(SHELLMOD)

SREC        = boot_picothing.srec

ALLOBJS     = bootfile_pt os9kernel $(SREC)

all:    $(ALLOBJS)

bootfile_pt: $(BOOTFILE_PT) $(DEPENDS)
	$(MERGE) $(BOOTFILE_PT) >$@

os9kernel: $(OS9KERNEL) $(DEPENDS)
	$(MERGE) $(OS9KERNEL) >$@

DBGMON      = $(MD)/dbgmon

# SREC contains boot module, krn, and dbgmon — but also embeds SWIStack
# and interrupt stubs derived from krn.  Rebuild whenever any input changes.
$(SREC): $(BOOT) $(KERNEL) $(KERNELP2) $(DBGMON) $(DEPENDS)
	python3 $(NITROS9DIR)/scripts/mk_picothing_srec.py $(NITROS9DIR) >$@

clean:
	$(RM) $(ALLOBJS)

