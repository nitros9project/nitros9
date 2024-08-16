include ../port.mak

# Module directory
MD		= ../modules
CMDS		= ../cmds

DEPENDS		= ./makefile

KERNEL_ROM	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init $(MD)/boot_rom

KERNEL_ROM_1773	= $(MD)/rel $(MD)/krn $(MD)/krnp2 $(MD)/init $(MD)/boot_1773_6ms

BOOTFILE_ROM	= $(MD)/rominfo $(MD)/ioman \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/covdg.io \
		$(MD)/term_vdg.dt \
		$(MD)/sysgo_rom \
		$(CMDS)/shell_21 \
		$(MD)/clock_60hz $(MD)/clock2_soft

BOOTFILE_ROM_1773 = $(MD)/rominfo

BOOTFILE_ROMPAK	= $(MD)/rominfo_pak $(MD)/ioman \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/covdg.io \
		$(MD)/term_vdg.dt \
		$(MD)/sysgo_dd \
		$(CMDS)/shell_21 \
		$(MD)/clock_60hz $(MD)/clock2_soft

BOOTFILE_ROMPAK_1773 = $(MD)/rominfo

BOOTROMS	= nos96809l1.rom nos96809l1.rompak nos96809l1_1773.rom nos96809l1_1773.rompak
KERNELS		= kernel_rom

ALLROMS		= $(BOOTROMS)

all:	$(ALLROMS)

# Bootfiles
# Kernel file in ROM (no BASIC needed), but boot file on floppy
nos96809l1_1773.rom: $(BOOTFILE_ROM_1773) $(KERNEL_ROM_1773) $(DEPENDS)
	$(MERGE) $(BOOTFILE_ROM_1773)>$@.tmp
	$(PADROM) 11776 $@.tmp
	$(MERGE) $(KERNEL_ROM_1773)>kernel_rom
	$(PADROM) 4592 kernel_rom
	$(MERGE) $@.tmp kernel_rom>$@.tmp2
	$(MERGE) $@.tmp2 $(MD)/vectors>$@
	$(RM) $@.tmp $@.tmp2
	
nos96809l1.rom: $(BOOTFILE_ROM) $(KERNEL_ROM) $(DEPENDS)
	$(MERGE) $(BOOTFILE_ROM)>$@.tmp
	$(PADROM) 11776 $@.tmp
	$(MERGE) $(KERNEL_ROM)>kernel_rom
	$(PADROM) 4592 kernel_rom
	$(MERGE) $@.tmp kernel_rom>$@.tmp2
	$(MERGE) $@.tmp2 $(MD)/vectors>$@
	$(RM) $@.tmp $@.tmp2
	
nos96809l1_1773.rompak: $(BOOTFILE_ROMPAK_1773) $(KERNEL_ROM_1773) $(DEPENDS)
	$(MERGE) $(BOOTFILE_ROMPAK_1773)>$@.tmp
	$(PADROM) 11776 $@.tmp
	$(MERGE) $(KERNEL_ROM_1773)>kernel_rom
	$(PADROM) 4352 kernel_rom
	$(MERGE) $@.tmp kernel_rom>$@
	$(RM) $@.tmp

nos96809l1.rompak: $(BOOTFILE_ROMPAK) $(KERNEL_ROM) $(DEPENDS)
	$(MERGE) $(BOOTFILE_ROMPAK)>$@.tmp
	$(PADROM) 11776 $@.tmp
	$(MERGE) $(KERNEL_ROM)>kernel_rom
	$(PADROM) 4352 kernel_rom
	$(MERGE) $@.tmp kernel_rom>$@
	$(RM) $@.tmp
	

# Kernels
kernel_rom: $(KERNEL_ROM) $(DEPENDS)
	$(MERGE) $(KERNEL_ROM)>$@

clean:
	$(RM) $(ALLROMS) $(KERNELS)

