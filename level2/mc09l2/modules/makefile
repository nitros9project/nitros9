PORT = mc09
include $(NITROS9DIR)/rules.mak

vpath %.asm kernel:$(LEVEL2)/modules:$(LEVEL1)/modules

AFLAGS		+= -I$(LEVEL1)/modules

CLOCKSOFT       = -DRTCSoft=1
TC3FLAGS        = $(AFLAGS) -DTC3=1 $(FLAGS)
IDEFLAGS        = $(AFLAGS) -DIDE=1 $(FLAGS)
SDFLAGS         = $(AFLAGS) -DCOCOSDC=1 -DITTYP=128 $(FLAGS)

DEPENDS		= ./makefile
BOOTERS		= boot_sdc
BOOTTRACK	= rel_80 $(BOOTERS) mc09krn

KERNEL		= krnp2 krnp3_perr krnp4_regdump
SYSMODS		= ioman init sysgo_dd
CLOCKS		= clock2_soft clock2_dw mc09clock_50hz mc09clock_91hz

RBF		= rbf.mn \
		rbdw.dr dwio.sb \
		mc09sdc.dr \
		rammer.dr r0_8k.dd r0_96k.dd r0_128k.dd r0_192k.dd \
		dds0_80d.dd s0_80d.dd s1_80d.dd s2_80d.dd s3_80d.dd \
		myram.dr mr0.dd \
		ddx0.dd x0.dd x1.dd x2.dd x3.dd

SCF		= scf.mn \
		mc6850.dr \
		term_mc6850.dt term_mc6850_t0.dt term_mc6850_t1.dt \
		nil.dd \
		scdwv.dr term_scdwv.dt n_scdwv.dd \
		n1_scdwv.dd n2_scdwv.dd n3_scdwv.dd \
		n4_scdwv.dd n5_scdwv.dd n6_scdwv.dd n7_scdwv.dd \
		n8_scdwv.dd n9_scdwv.dd n10_scdwv.dd n11_scdwv.dd \
		n12_scdwv.dd n13_scdwv.dd midi_scdwv.dd \
		term_z_scdwv.dt z1_scdwv.dd z2_scdwv.dd z3_scdwv.dd \
		z4_scdwv.dd z5_scdwv.dd z6_scdwv.dd z7_scdwv.dd \

PIPE		= pipeman.mn pipeman_named.mn \
		piper.dr \
		pipe.dd

RFM		= rfm.mn rfmdrv.dr ddy0.dd y0.dd y1.dd y2.dd y3.dd

# The following macros represent a collection of modules for various
# kernel tracks and bootfile configurations.
#
KERNEL_MC09SD	= rel_80 boot_sdc mc09krn

ALLOBJS		=  $(BOOTTRACK) $(KERNEL) $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(PIPE) $(RFM)

all:	$(ALLOBJS)

# Kernel
mc09krn krn krnp2:
	$(CD) kernel; make $@
	$(OS9COPY) kernel/$@ .

# Special cases

# CoCo/MC09 SDC Booter
boot_sdc: boot_sdc.asm
	$(AS) $(ASOUT)$@ $< $(SDFLAGS)

# REL Modules
rel_80: rel.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DWidth=80

# SysGo Modules
sysgo_dd: sysgo.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1

# Serial ports for mc09
term_mc6850_t0.dt: term_mc6850.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DTNum=0        -DHwBASE=0xFFD2

term_mc6850_t1.dt: term_mc6850.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DTNum=1        -DHwBASE=0xFFD4

# SDOFFSET is the high 16 bits of the 24-bit block address at
# which the disk image starts on the SDcard. It must match
# the value used in the create_sd_image script.
dds0_80d.dd: mc09sdcdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=0 -DSDOFFSET=0x0280 -DDD=1

s0_80d.dd: mc09sdcdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=0 -DSDOFFSET=0x0280

s1_80d.dd: mc09sdcdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=1 -DSDOFFSET=0x0290

s2_80d.dd: mc09sdcdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=2 -DSDOFFSET=0x02A0

s3_80d.dd: mc09sdcdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=3 -DSDOFFSET=0x02B0

# RAM Disk descriptors
r0_8k.dd: r0.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DRAMSize=8

ddr0_8k.dd: r0.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DRAMSize=8 -DDD=1

r0_96k.dd: r0.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DRAMSize=96

ddr0_96k.dd: r0.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DRAMSize=96 -DDD=1

r0_128k.dd: r0.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DRAMSize=128

ddr0_128k.dd: r0.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DRAMSize=128 -DDD=1

r0_192k.dd: r0.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DRAMSize=192

ddr0_192k.dd: r0.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DRAMSize=192 -DDD=1

# DriveWire SCF descriptors
term_scdwv.dt: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=0

n_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=255

n1_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=1

n2_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=2

n3_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=3

n4_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=4

n5_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=5

n6_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=6

n7_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=7

n8_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=8

n9_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=9

n10_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=10

n11_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=11

n12_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=12

n13_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=13

midi_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=14

term_z_scdwv.dt: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=16

z1_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=17

z2_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=18

z3_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=19

z4_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=20

z5_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=21

z6_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=22

z7_scdwv.dd: scdwvdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=23

# DriveWire RBF descriptors
ddx0.dd: dwdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1 -DDNum=0

x0.dd: dwdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

x1.dd: dwdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1

x2.dd: dwdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2

x3.dd: dwdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3

# RFM descriptors
ddy0.dd: rfmdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1 -DDNum=0

y0.dd: rfmdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

y1.dd: rfmdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1

y2.dd: rfmdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2

y3.dd: rfmdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3

# Clocks
mc09clock_50hz: mc09clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DTkPerSec=50

mc09clock_91hz: mc09clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DTkPerSec=91

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
