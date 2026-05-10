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
KERNELS		= kernel_rom kernel_rom_1773

ALLROMS		= $(BOOTROMS)

all:	$(ALLROMS)

# Bootfiles
# Kernel file in ROM (no BASIC needed), but boot file on floppy
nos96809l1_1773.rom: $(BOOTFILE_ROM_1773) kernel_rom_1773 $(DEPENDS)
	$(MERGE) $(BOOTFILE_ROM_1773)>$@.tmp
	$(PADROM) 11776 $@.tmp
	$(CP) kernel_rom_1773 $@.tmp2
	$(PADROM) 4592 $@.tmp2
	$(MERGE) $@.tmp $@.tmp2>$@.tmp3
	$(MERGE) $@.tmp3 $(MD)/vectors>$@
	$(RM) $@.tmp $@.tmp2 $@.tmp3

nos96809l1.rom: $(BOOTFILE_ROM) kernel_rom $(DEPENDS)
	$(MERGE) $(BOOTFILE_ROM)>$@.tmp
	$(PADROM) 11776 $@.tmp
	$(CP) kernel_rom $@.tmp2
	$(PADROM) 4592 $@.tmp2
	$(MERGE) $@.tmp $@.tmp2>$@.tmp3
	$(MERGE) $@.tmp3 $(MD)/vectors>$@
	$(RM) $@.tmp $@.tmp2 $@.tmp3

nos96809l1_1773.rompak: $(BOOTFILE_ROMPAK_1773) kernel_rom_1773 $(DEPENDS)
	$(MERGE) $(BOOTFILE_ROMPAK_1773)>$@.tmp
	$(PADROM) 11776 $@.tmp
	$(CP) kernel_rom_1773 $@.tmp2
	$(PADROM) 4352 $@.tmp2
	$(MERGE) $@.tmp $@.tmp2>$@
	$(RM) $@.tmp $@.tmp2

nos96809l1.rompak: $(BOOTFILE_ROMPAK) kernel_rom $(DEPENDS)
	$(MERGE) $(BOOTFILE_ROMPAK)>$@.tmp
	$(PADROM) 11776 $@.tmp
	$(CP) kernel_rom $@.tmp2
	$(PADROM) 4352 $@.tmp2
	$(MERGE) $@.tmp $@.tmp2>$@
	$(RM) $@.tmp $@.tmp2


# Kernels
kernel_rom: $(KERNEL_ROM) $(DEPENDS)
	$(MERGE) $(KERNEL_ROM)>$@
kernel_rom_1773: $(KERNEL_ROM_1773) $(DEPENDS)
	$(MERGE) $(KERNEL_ROM_1773)>$@

clean:
	$(RM) $(ALLROMS) $(KERNELS)

