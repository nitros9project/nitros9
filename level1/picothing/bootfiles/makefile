include ../port.mak

# Module directory
MD		= ../modules
# Commands directory
CMDSDIR		= ../cmds

DEPENDS		= ./makefile

# Boot modules
BOOT_IDE	= $(MD)/boot_picothing
BOOT_DW		= $(MD)/boot_dw_pt

# OS9Kernel: krn + boot module, loaded by REL before the kernel runs.
# Two variants: IDE (for PATA disks) and DW (for DriveWire server).
OS9KERNEL_IDE	= $(MD)/krn $(BOOT_IDE)
OS9KERNEL_DW	= $(MD)/krn $(BOOT_DW)

# OS9Boot: remaining essential modules loaded by F$Boot
BOOTFILE = $(MD)/ioman $(MD)/sysgo \
		$(MD)/clock $(MD)/clock2_null \
		$(MD)/scf.mn \
		$(MD)/sc6850.dr $(MD)/term_pt.dd \
		$(MD)/rbf.mn \
		$(MD)/rbsuper.dr $(MD)/llide_pt.dr $(MD)/ddi0_pt.dd \
		$(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd \
		$(CMDSDIR)/shell_21

BOOTFILES	= bootfile os9kernel os9kernel_dw

ALLOBJS		= $(BOOTFILES)

all:	$(ALLOBJS)

bootfile: $(BOOTFILE) $(DEPENDS)
	$(MERGE) $(BOOTFILE)>$@

os9kernel: $(OS9KERNEL_IDE) $(DEPENDS)
	$(MERGE) $(OS9KERNEL_IDE)>$@

os9kernel_dw: $(OS9KERNEL_DW) $(DEPENDS)
	$(MERGE) $(OS9KERNEL_DW)>$@

clean:
	$(RM) $(ALLOBJS)
