# Jim Hathaway's MultiMediaCard NitrOS-9 driver

include ../../../rules.mak

DEPENDS		= ./makefile
DRVRS		= mmcdrv_l1.dr mmcdrv_l2.dr mmcdrv_l1s.dr mmcdrv_l2s.dr 
DESCS		= h0_mmc_l1.dd h0_mmc_l2.dd h1_mmc_l1.dd h1_mmc_l2.dd dd_mmc_l1.dd dd_mmc_l2.dd
ALLOBJS		= $(DRVRS) $(DESCS)
MMCL1FLAGS	= $(AFLAGS) -DLevel=1
MMCL2FLAGS	= $(AFLAGS) -DLevel=2

all:	$(ALLOBJS) $(DEPENDS)

# Drivers - optimized for speed over size
mmcdrv_l1.dr: mmcdrv.asm
	$(AS) $(ASOUT)$@ $< $(MMCL1FLAGS)

mmcdrv_l2.dr: mmcdrv.asm
	$(AS) $(ASOUT)$@ $< $(MMCL2FLAGS)

# Drivers - optimized for size over speed

mmcdrv_l1s.dr: mmcdrv.asm
	$(AS) $(ASOUT)$@ $< $(MMCL1FLAGS) -DSMALLC=1

mmcdrv_l2s.dr: mmcdrv.asm
	$(AS) $(ASOUT)$@ $< $(MMCL2FLAGS) -DSMALLC=1

# Descriptors
# ITDRV is the Drive 0 or 1 switch for device descriptors
h0_mmc_l1.dd: mmcdesc.asm
	$(AS) $(ASOUT)$@ $< $(MMCL1FLAGS) -DITDRV=0

h0_mmc_l2.dd: mmcdesc.asm
	$(AS) $(ASOUT)$@ $< $(MMCL2FLAGS) -DITDRV=0

h1_mmc_l1.dd: mmcdesc.asm
	$(AS) $(ASOUT)$@ $< $(MMCL1FLAGS) -DITDRV=1

h1_mmc_l2.dd: mmcdesc.asm
	$(AS) $(ASOUT)$@ $< $(MMCL2FLAGS) -DITDRV=1

dd_mmc_l1.dd: mmcdesc.asm
	$(AS) $(ASOUT)$@ $< $(MMCL1FLAGS) -DITDRV=0 -DDD=1

dd_mmc_l2.dd: mmcdesc.asm
	$(AS) $(ASOUT)$@ $< $(MMCL2FLAGS) -DITDRV=0 -DDD=1

clean:
	$(RM) $(ALLOBJS) *.list *.map

dsk:
dskcopy:
dskclean:

