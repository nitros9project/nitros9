include ../port.mak

# Module directory
MD		= ../modules
# Commands directory
CMDSDIR		= ../cmds

DEPENDS		= ./makefile

KERNEL_ROM	= $(MD)/rel_32 $(MD)/boot_rom $(MD)/krn

BOOTFILE_ROM	= $(MD)/rominfo $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg.io \
		$(MD)/term_vdg.dt \
		$(MD)/clock_60hz $(MD)/clock2_soft \
		$(MD)/sysgo_rom \
		$(CMDSDIR)/shell_21 \
		$(CMDSDIR)/mdir

BOOTROMS	= nos96809l2.rom
KERNELS		= kernel_rom

ALLROMS		= $(BOOTROMS)

all:	$(ALLROMS)

# Bootfiles
nos96809l2.rom: $(BOOTFILE_ROM) $(KERNEL_ROM) $(DEPENDS)
	$(MERGE) $(BOOTFILE_ROM)>$@.tmp
	$(PADROM) 27648 $@.tmp
	$(MERGE) $@.tmp $(KERNEL_ROM)>$@.tmp2
	$(PADROM) 32752 $@.tmp2
	$(MERGE) $@.tmp2 $(MD)/vectors>$@
	$(RM) $@.tmp $@.tmp2
	

# Kernels
kernel_rom: $(KERNEL_ROM) $(DEPENDS)
	$(MERGE) $(KERNEL_ROM)>$@

clean:
	$(RM) $(ALLROMS) $(KERNELS)

