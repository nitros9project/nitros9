include ../port.mak

# Module directory
MD          = ../modules

DEPENDS     = ./makefile

# Kernel
# krnp3_perr installs the F$PErr replacement that prints full error text
# from /dd/sys/errmsg; krnp2 links and runs "krnp3" at boot if present.
KERNEL      = $(MD)/krn
KERNELP2    = $(MD)/krnp2 $(MD)/krnp3_perr $(MD)/init $(MD)/ioman

# Boot modules
BOOT_IDE    = $(MD)/boot_picothing
BOOT_DW     = $(MD)/boot_dw_pt

# --- Essential modules (in bootfile, needed to boot) ---

# RBF core + /DD descriptor (minimum to read the boot disk)
RBF_CORE    = $(MD)/rbf.mn $(MD)/rbsuper.dr $(MD)/llide_pt.dr $(MD)/ddi0_pt.dd

# SCF stack (serial console)
SCF         = $(MD)/scf.mn $(MD)/sc6850.dr $(MD)/term_pt.dd

# Clock
CLOCK       = $(MD)/clock_picothing $(MD)/clock2_null

# PIPE
PIPE        = $(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd

# RAM disk
RAMDISK     = $(MD)/rammer.dr $(MD)/r0.dd

# DriveWire (RBF driver + I/O subroutine + descriptors)
DW          = $(MD)/rbdw.dr $(MD)/dwio.sb $(MD)/x0.dd $(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd

# Sysgo
SYSGO       = $(MD)/sysgo

# Shell (merged module file built in cmds/)
SHELLMOD    = ../cmds/shell

# --- Loadable modules (on disk in /Modules, load as needed) ---

# IDE partition descriptors (master /I0../I7 and slave /J0../J7)
IDE_PARTS   = $(MD)/i0_pt.dd $(MD)/i1_pt.dd $(MD)/i2_pt.dd $(MD)/i3_pt.dd \
              $(MD)/i4_pt.dd $(MD)/i5_pt.dd $(MD)/i6_pt.dd $(MD)/i7_pt.dd \
              $(MD)/j0_pt.dd $(MD)/j1_pt.dd $(MD)/j2_pt.dd $(MD)/j3_pt.dd \
              $(MD)/j4_pt.dd $(MD)/j5_pt.dd $(MD)/j6_pt.dd $(MD)/j7_pt.dd

# Graphics console (CoPico)
GFX         = $(MD)/vtio_picothing.dr $(MD)/copico $(MD)/term_gfx.dd

# Additional DriveWire descriptors (SCF channels, clock2)
DW_EXTRA    = $(MD)/ddx0.dd \
              $(MD)/scdwv.dr $(MD)/term_scdwv.dt $(MD)/n_scdwv.dd \
              $(MD)/n1_scdwv.dd $(MD)/n2_scdwv.dd \
              $(MD)/n3_scdwv.dd $(MD)/n4_scdwv.dd \
              $(MD)/clock2_dw

# All loadable modules (on disk in /Modules, not in bootfile)
LOADMODS    = $(IDE_PARTS) $(GFX) $(DW_EXTRA)

# OS9Kernel: boot module (padded to 1024 bytes) + krn, loaded by REL at
# Bt.Start ($E800).  Boot sits at $E800, krn at $EC00 (= Where).
# Two variants: IDE (for PATA disks) and DW (for DriveWire server).
BOOT_PAD      = 1024

# OS9Boot: essential modules only.  Everything else is in /Modules
# on disk for load/unload experimentation.
BOOTFILE_PT = $(KERNELP2) \
              $(RBF_CORE) \
              $(SCF) \
              $(CLOCK) \
              $(PIPE) \
              $(RAMDISK) \
              $(DW) \
              $(SYSGO) \
              $(SHELLMOD)

REL         = rel_picothing

ALLOBJS     = bootfile_pt os9kernel os9kernel_dw $(REL)

all:    $(ALLOBJS)

bootfile_pt: $(BOOTFILE_PT) $(DEPENDS)
	$(MERGE) $(BOOTFILE_PT) >$@

os9kernel: $(BOOT_IDE) $(KERNEL) $(DEPENDS)
	dd if=$(BOOT_IDE) of=$@ bs=$(BOOT_PAD) conv=sync 2>/dev/null
	cat $(KERNEL) >>$@

os9kernel_dw: $(BOOT_DW) $(KERNEL) $(DEPENDS)
	dd if=$(BOOT_DW) of=$@ bs=$(BOOT_PAD) conv=sync 2>/dev/null
	cat $(KERNEL) >>$@

# REL boot loader (raw binary, copied from modules/)
$(REL): $(MD)/$(REL) $(DEPENDS)
	$(CP) $(MD)/$(REL) $@

clean:
	$(RM) $(ALLOBJS)

showloadmods:
	@$(ECHO) $(LOADMODS)

