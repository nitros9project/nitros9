#
#modules/makefile for Dragon 64/Alpha/Tano
#
# 2005-04-24, P.Harvey-Smith, 
#	made descriptors for both 40 & 80 track drives for Dragon 64.
# 		
#
# 2005-05-31, P.Harvey-Smith,
# 	Steprate now passed in from ../makefile.dragon or ../makefile.dalpha
#
# 2005-12-31, P.Harvey-Smith,
#	Fixed up for renamed video drivers.
#
# 2006-01-08, P.Harvey-Smith.
#	Added descriptors for original Dragon Data single sided 5.25" drives.
#	Pass step rate to boot_d64, so that boot module steprate set correctly.
#
# 2006-01-18, P.Harvey-Smith,
#	Added ability to build for the Tano Dragon 64, using an RS-DOS
#	disk controler and a 60Hz clock.
#

ifeq ($(PORT),)
        PORT=d64
endif
include $(NITROS9DIR)/rules.mak

vpath %.asm $(LEVEL1)/modules

AFLAGS		+= -I$(LEVEL1)/modules

CLOCKELIM       = -DRTCElim=1
CLOCKDISTO2     = -DRTCDsto2=1
CLOCKDISTO4     = -DRTCDsto4=1
CLOCKBNB        = -DRTCBB=1
CLOCKSMART      = -DRTCSmart=1 -DMPIFlag=1
CLOCKHARRIS     = -DRTCHarrs=1
CLOCKCLOUD9     = -DRTCCloud9=1
CLOCKSOFT       = -DRTCSoft=1
CLOCKMESSEMU    = -DRTCMessEmu=1
CLOCKJVEMU      = -DRTCJVEmu=1

DEPENDS		= ./makefile
TPB		= $(3RDPARTY)/booters

BOOTERS		= boot_d64

BOOTTRACK	= rel $(BOOTERS)
KERNEL		= krn krnp2
SYSMODS		= ioman init sysgo_dd sysgo_h0

CLOCKS          = clock_60hz clock_50hz \
		clock2_elim clock2_disto2 clock2_disto4 clock2_bnb \
                clock2_smart clock2_harris clock2_cloud9 clock2_soft \
		clock2_messemu clock2_jvemu 

RBF		= rbf.mn \
		ddisk.dr \
		ddd0_80d.dd d0_80d.dd d1_80d.dd d2_80d.dd d3_80d.dd
ifeq ($(PORT),dalpha)
RBF +=		ddd0_80s.dd d0_80s.dd d1_80s.dd d2_80s.dd d3_80s.dd
else
RBF +=		ddd0_40d.dd d0_40d.dd d1_40d.dd d2_40d.dd d3_40d.dd \
		ddd0_40s.dd d0_40s.dd d1_40s.dd d2_40s.dd d3_40s.dd
endif

ifeq ($(PORT),dplus)
RBF +=		vinit.dr vdisk.dr v0.dd
endif

SCF		= scf.mn \
		vrn.dr scdpp.dr sspak.dr vtio.dr \
		covdg.io cohr.io co42.io\
		nil.dd p_dpp.dd pipe.dd ssp.dd \
		term_sc6551.dt t2_sc6551.dt t3_sc6551.dt \
		term_vdg.dt term_hr.dt term_42.dt term_80.dt p1_sc6551dragon.dd

ifeq ($(PORT),dplus)
SCF +=  codplus.io term_dplus.dt
endif

PIPE		= pipeman.mn \
		piper.dr \
		pipe.dd

ALLOBJS		= $(BOOTTRACK) $(KERNEL) $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(PIPE) 

all:	$(ALLOBJS)

# Special cases

# Kernel
krn krnp2:
	$(CD) kernel; make $@
	$(CP) kernel/$@ .

boot_d64:	boot_d64.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0 -DSTEP=$(STEP)

# Clocks
clock_60hz: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DPwrLnFrq=60

clock_50hz: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DPwrLnFrq=50

clock2_bnb: clock2_ds1315.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DBNB=1

clock2_cloud9: clock2_ds1315.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DCLOUD9=1


# Floppy descriptors
SSDD35		= -DCyls=35 -DSides=1 -DSectTrk=18 -DSectTrk0=18 \
		-DInterlv=2 -DSAS=8 -DDensity=1 -DSTEP=0
SSDD40		= -DCyls=40 -DSides=1 -DSectTrk=18 -DSectTrk0=18 \
		-DInterlv=2 -DSAS=8 -DDensity=1 -DSTEP=$(STEP)
DSDD40		= -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 \
		-DInterlv=2 -DSAS=8 -DDensity=1 -DSTEP=$(STEP)
SSDD80		= -DCyls=80 -DSides=1 -DSectTrk=18 -DSectTrk0=18 \
		-DInterlv=2 -DSAS=8 -DDensity=1 -DD35 -DSTEP=$(STEP)
DSDD80		= -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 \
		-DInterlv=2 -DSAS=8 -DDensity=1 -DD35 -DSTEP=$(STEP)

#Dragon 64 Drives can be double or single sided, but assume 
# that /d0 and /d1 are double sided 40 track.

ddd0_40d.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=0 -DDD=1

d0_40d.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=0

d1_40d.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=1

d2_40d.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=2

d3_40d.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=3

#Single sided 40 track drives.
ddd0_40s.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD40) -DDNum=0 -DDD=1

d0_40s.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD40) -DDNum=0

d1_40s.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD40) -DDNum=1

d2_40s.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD40) -DDNum=2

d3_40s.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD40) -DDNum=3

# Internal drives on Alpha are Single Sided 80 track.

ddd0_80s.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD80) -DDNum=0 -DDD=1

ddd0_80d.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=0 -DDD=1

d0_80s.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD80) -DDNum=0
	
d0_80d.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=0
	
d1_80s.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD80) -DDNum=1

d1_80d.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=1

d2_80s.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD80) -DDNum=2

d2_80d.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=2

d3_80s.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD80) -DDNum=3

d3_80d.dd: ddiskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=3


sysgo_dd: sysgo.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DDD=1

sysgo_h0: sysgo.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

ddisk.dr: ddisk.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ -DUPGRADED32=$(UPGRADED32) $< 


# compusense drivers
vinit.dr: $(3RDPARTY)/drivers/compusense/vinit.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) 

vdisk.dr: $(3RDPARTY)/drivers/compusense/vdisk.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) 

v0.dd: $(3RDPARTY)/drivers/compusense/v0.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS)


clean:
	$(CD) kernel; make $@
	$(RM) $(ALLOBJS)

showobjs:
	@$(ECHO) $(ALLOBJS)

showboottrack:
	@$(ECHO) $(BOOTTRACK)

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
