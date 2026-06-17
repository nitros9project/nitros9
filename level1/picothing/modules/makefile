include ../port.mak

vpath %.asm $(LEVEL1)/modules:$(LEVEL2)/picothing/modules

AFLAGS		+= -I$(LEVEL1)/$(PORT)
AFLAGS		+= -I$(LEVEL1)/modules
AFLAGS		+= -I$(LEVEL2)/picothing/modules

DEPENDS		= ./makefile

BOOTERS		= rel boot_picothing boot_dw_pt
KERNEL		= krn krnp2
SYSMODS		= ioman init sysgo
CLOCKS		= clock clock2_null

RBF		= rbf.mn rbsuper.dr llide_pt.dr ddi0_pt.dd i0_pt.dd

SCF		= scf.mn sc6850.dr term_pt.dd

PIPE		= pipeman.mn piper.dr pipe.dd

ALLOBJS		= $(BOOTERS) $(KERNEL) $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(PIPE)

all:	$(ALLOBJS)

init:	init.asm buildinfo

# Kernel
krn krnp2:
	$(CD) kernel; make $@
	$(CP) kernel/$@ .

# Pico-Thing PATA IDE low-level driver (from L2)
llide_pt.dr: llide_pt.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Pico-Thing PATA IDE boot module (shared with L2 via vpath)
boot_picothing: boot_picothing.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Pico-Thing DriveWire boot module (shared with L2 via vpath)
boot_dw_pt: boot_dw_pt.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# REL - early hardware init (shared with L2 via vpath, raw binary)
rel: rel_picothing.asm
	$(AS) --format=raw $(AFLAGS) $(ASOUT)$@ $<

# Clock module (L1 version with picothing conditionals)
clock: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Minimal Clock2 stub (no RTC, reuse from L2)
clock2_null: clock2_null.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Console terminal descriptor (reuse from L2)
term_pt.dd: term_pt.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Pico-Thing PATA disk descriptors
ddi0_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDD=1

i0_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x00

clean:
	$(CD) kernel; make $@
	$(RM) $(ALLOBJS) *.list *.map

showobjs:
	@$(ECHO) $(ALLOBJS)

showkernel:
	@$(ECHO) $(KERNEL)

showsysmods:
	@$(ECHO) $(SYSMODS)

showclocks:
	@$(ECHO) $(CLOCKS)

showrbf:
	@$(ECHO) $(RBF)

showscf:
	@$(ECHO) $(SCF)

showpipe:
	@$(ECHO) $(PIPE)

identify:
	$(IDENT_SHORT) $(ALLOBJS)
