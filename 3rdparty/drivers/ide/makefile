# Curtis Boyle's IDE Driver

include ../../../rules.mak

DEPENDS		= ./makefile
DRVRS		= ccide_l1.dr ccide_l2.dr
DESCS		= h0_ide_l1.dd h0_ide_l2.dd h1_ide_l1.dd h1_ide_l2.dd dd_ide_l1.dd dd_ide_l2.dd
ALLOBJS		= $(DRVRS) $(DESCS)
IDEL1FLAGS	= $(AFLAGS) -DLevel=1
IDEL2FLAGS	= $(AFLAGS) -DLevel=2

all:	$(ALLOBJS) $(DEPENDS)

# Drivers
ccide_l1.dr: ccide.asm
	$(AS) $(ASOUT)$@ $< $(IDEL1FLAGS)

ccide_l2.dr: ccide.asm
	$(AS) $(ASOUT)$@ $< $(IDEL2FLAGS)

# Descriptors
# ITDRV is the Master(0)/Slave(1) switch for device descriptors
h0_ide_l1.dd: idedesc.asm
	$(AS) $(ASOUT)$@ $< $(IDEL1FLAGS) -DITDRV=0

h0_ide_l2.dd: idedesc.asm
	$(AS) $(ASOUT)$@ $< $(IDEL2FLAGS) -DITDRV=0

h1_ide_l1.dd: idedesc.asm
	$(AS) $(ASOUT)$@ $< $(IDEL1FLAGS) -DITDRV=1

h1_ide_l2.dd: idedesc.asm
	$(AS) $(ASOUT)$@ $< $(IDEL2FLAGS) -DITDRV=1

dd_ide_l1.dd: idedesc.asm
	$(AS) $(ASOUT)$@ $< $(IDEL1FLAGS) -DITDRV=0 -DDD=1

dd_ide_l2.dd: idedesc.asm
	$(AS) $(ASOUT)$@ $< $(IDEL2FLAGS) -DITDRV=0 -DDD=1

clean:
	$(RM) $(ALLOBJS) *.list *.map

dsk:
dskcopy:
dskclean:

