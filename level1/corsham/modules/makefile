include ../port.mak

vpath %.asm $(LEVEL1)/modules

AFLAGS		+= -I$(LEVEL1)/$(PORT)
AFLAGS		+= -I$(LEVEL1)/modules

CLOCKSOFT       = -DRTCSoft=1

DEPENDS		= ./makefile
TPB		= $(3RDPARTY)/booters

BOOTERS		= rel boot_cshsd
KERNEL		= krn krnp2
SYSMODS		= ioman init sysgo sysgo_rom pio.sb
CLOCKS	        = clock clock2_cshsd

RBF		= rbf.mn rbcshsd.dr ddh0.dd h0.dd h1.dd h2.dd h3.dd

SCF		= scf.mn \
		vrn.dr \
		nil.dd \
		sc6850.dr term_sc6850.dt

PIPE		= pipeman.mn \
		piper.dr \
		pipe.dd


ALLOBJS		= $(BOOTERS) $(KERNEL) $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(PIPE) $(DW)

all:	$(ALLOBJS)

# Kernel
krn krnp2:
	$(CD) kernel; make $@
	$(CP) kernel/$@ .


sysgo_rom: sysgo.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DROM=1

# DriveWire 3 RBF descriptors
ddh0.dd: rbdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1 -DDNum=0

h0.dd: rbdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

h1.dd: rbdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1

h2.dd: rbdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2

h3.dd: rbdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3

# 6850 terminal
term_sc6850.dt: term_sc6850.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DHwBASE=0xE010

# Clocks
clock: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

clean:
	$(CD) kernel; make $@
	$(RM) $(ALLOBJS)

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


