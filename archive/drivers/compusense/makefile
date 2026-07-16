include ../../../rules.mak

vpath %.asm $(LEVEL1)/modules

DEPENDS		= ./makefile
DRVRS		= vinit.dr vdisk.dr
RAMDISKDESCS	= v0.dd
DESCS		= $(RAMDISKDESCS) 
ALLOBJS		= $(DRVRS) $(DESCS) 

all:	$(ALLOBJS) $(DEPENDS)

vinit.dr: vinit.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

vdisk.dr: vdisk.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

v0.dd: v0.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

clean:
	$(RM) $(ALLOBJS)

dsk:
dskcopy:
dskclean:

