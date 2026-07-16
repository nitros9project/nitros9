include ../../../rules.mak

vpath %.asm $(LEVEL2)/modules:$(LEVEL1)/modules

AFLAGS += -I.

L1_256 = $(AFLAGS) -DLevel=1 -DRAMSize=1
L2_256 = $(AFLAGS) -DLevel=2 -DRAMSize=1
L1_512 = $(AFLAGS) -DLevel=1 -DRAMSize=2
L2_512 = $(AFLAGS) -DLevel=2 -DRAMSize=2

L2_DNHFC = $(AFLAGS) -DLevel=2

DEPENDS		= ./makefile
DRVRS		= rampak.dr parallel.dr
NHDRVRS		= cc3disk_sc2_irq.dr cc3disk_sc2_slp.dr
FLOPPYDESCS	= ddd0_35s.dd d0_35s.dd d1_35s.dd	\
		ddd0_40d.dd d0_40d.dd d1_40d.dd		\
		ddd0_80d.dd d0_80d.dd d1_80d.dd
RAMDISKDESCS	= r0_256_l1.dd r0_256_l2.dd r0_512_l1.dd r0_512_l2.dd
PRINTERDESCS	= pp.dd
DESCS		= $(FLOPPYDESCS) $(RAMDISKDESCS) $(PRINTERDESCS)
ALLOBJS		= $(DRVRS) $(DESCS) $(NHDRVRS)

# Device Descriptor Macros
SSDD35          = -DCyls=35 -DSides=1 -DSectTrk=18 -DSectTrk0=18 \
                -DInterlv=3 -DSAS=8 -DDensity=1
DSDD40          = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 \
                -DInterlv=3 -DSAS=8 -DDensity=1
DSDD80          = -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 \
                -DInterlv=3 -DSAS=8 -DDensity=3

all:	$(ALLOBJS) $(DEPENDS)

# Disto Super Controller II Drivers
cc3disk_sc2_irq.dr: cc3disk_sc2_irq.asm
	$(AS) $(ASOUT)$@ $< $(L2_DNHFC)
   
cc3disk_sc2_slp.dr: cc3disk_sc2_slp.asm
	$(AS) $(ASOUT)$@ $< $(L2_DNHFC)
   
# Disto Super Controller II Device Descriptors
# 35 Track Single-Sided
ddd0_35s.dd: rb1773desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(SSDD35) -DDD=1

d0_35s.dd: rb1773desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(SSDD35)

d1_35s.dd: rb1773desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(SSDD35) -DDNum=1

# 40 Track Double-Sided
ddd0_40d.dd: rb1773desc.asm  
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD40) -DDD=1

d0_40d.dd: rb1773desc.asm       
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD40)

d1_40d.dd: rb1773desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD40) -DDNum=1

# 80 Track Double-Sided
ddd0_80d.dd: rb1773desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD80) -DDD=1

d0_80d.dd: rb1773desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD80)

d1_80d.dd: rb1773desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD80) -DDNum=1

# RAM Disk Descriptors
r0_256_l1.dd: r0.asm
	$(AS) $(ASOUT)$@ $< $(L1_256)

r0_512_l1.dd: r0.asm
	$(AS) $(ASOUT)$@ $< $(L1_512)

r0_256_l2.dd: r0.asm
	$(AS) $(ASOUT)$@ $< $(L2_256)

r0_512_l2.dd: r0.asm
	$(AS) $(ASOUT)$@ $< $(L2_512)

clean:
	$(RM) $(ALLOBJS) *.list *.map

dsk:
dskcopy:
dskclean:

