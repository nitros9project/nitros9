include ../port.mak

vpath %.asm kernel:$(LEVEL2)/picothing/modules:$(LEVEL2)/modules:$(LEVEL1)/modules
vpath %.asm $(LEVEL1)/modules/kernel

AFLAGS      += -I$(LEVEL2)/$(PORT)
AFLAGS      += -I$(LEVEL1)/modules
AFLAGS      += -I$(LEVEL2)/modules

DEPENDS     = ./makefile

IDEFLAGS    = $(AFLAGS) -DIDE=1 $(FLAGS)

KERNEL      = krn krnp2
SYSMODS     = ioman init sysgo boot_picothing
CLOCKS      = clock_picothing clock2_null
RBF         = rbf.mn rbsuper.dr llide_pt.dr ddi0_pt.dd i0_pt.dd
SCF         = scf.mn sc6850.dr term_pt.dd
PIPE        = pipeman.mn piper.dr pipe.dd

ALLOBJS     = $(KERNEL) $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(PIPE)

all:    $(ALLOBJS)

# Kernel (built in kernel/ subdirectory)
krn krnp2:
	$(CD) kernel; make $@
	$(CP) kernel/$@ .

# Pico-Thing PATA IDE low-level driver
llide_pt.dr: llide_pt.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Pico-Thing PATA disk descriptors (default drive)
ddi0_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDD=1

i0_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

# Pico-Thing boot module (PATA IDE boot)
boot_picothing: boot_picothing.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Clock module
clock_picothing: clock_picothing.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Minimal Clock2 stub (no RTC on base Pico-Thing)
clock2_null: clock2_null.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Console terminal descriptor
term_pt.dd: term_pt.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

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
