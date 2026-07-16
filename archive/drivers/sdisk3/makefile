include ../../../rules.mak

DEPENDS		= ./makefile

L2DRIVERS	= sdisk3_dpj.dr sdisk3_dmc.dr
NITROSDRIVERS	= sdisk3_dpj_63.dr sdisk3_dmc_63.dr
DESCS		= ddd0_35s.dd d0_35s.dd d1_35s.dd \
		ddd0_40d.dd d0_40d.dd d1_40d.dd \
		ddd0_80d.dd d0_80d.dd d1_80d.dd
ALLOBJS		= $(L2DRIVERS) $(NITROSDRIVERS) $(DESCS)

# Device Descriptor Macros
SSDD35          = -DCyls=35 -DSides=1 -DSectTrk=18 -DSectTrk0=18 \
                -DInterlv=3 -DSAS=8 -DDensity=1
DSDD40          = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 \
                -DInterlv=3 -DSAS=8 -DDensity=1
DSDD80          = -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 \
                -DInterlv=3 -DSAS=8 -DDensity=3

all:	$(ALLOBJS) $(DEPENDS)

# Device Drivers
sdisk3_dpj_63.dr: sdisk3_dpj.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DNitrOS9=1

sdisk3_dmc_63.dr: sdisk3_dmc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DNitrOS9=1

# Device Descriptors
# 35 Track Single-Sided
ddd0_35s.dd: sdisk3desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(SSDD35) -DDD=1

d0_35s.dd: sdisk3desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(SSDD35)

d1_35s.dd: sdisk3desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(SSDD35) -DDNum=1

# 40 Track Double-Sided
ddd0_40d.dd: sdisk3desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD40) -DDD=1

d0_40d.dd: sdisk3desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD40)

d1_40d.dd: sdisk3desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD40) -DDNum=1

# 80 Track Double-Sided
ddd0_80d.dd: sdisk3desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD80) -DDD=1

d0_80d.dd: sdisk3desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD80)

d1_80d.dd: sdisk3desc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) $(DSDD80) -DDNum=1

clean:
	$(RM) $(ALLOBJS) *.list *.map

dsk:
dskcopy:
dskclean:

