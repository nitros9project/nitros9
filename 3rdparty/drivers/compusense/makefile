include ../../../rules.mak

vpath %.asm $(LEVEL1)/modules

DEPENDS		= ./makefile
DRVRS		= vinit.dr vdisk.dr
RAMDISKDESCS	= v0.dd
DESCS		= $(RAMDISKDESCS) 
ALLOBJS		= $(DRVRS) $(DESCS) 

all:	$(ALLOBJS) $(DEPENDS)

vinit.dr: VInit.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

vdisk.dr: VDisk.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

v0.dd: v0.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

clean:
	$(RM) $(ALLOBJS)

dsk:
dskcopy:
dskclean:

