include ../port.mak

vpath %.asm $(LEVEL1)/modules $(LEVEL1)/coco1/modules

AFLAGS		+= -I$(LEVEL1)/$(PORT)
AFLAGS		+= -I$(LEVEL1)/modules

CLOCKSOFT       = -DRTCSoft=1

SDFLAGS		= $(AFLAGS) -DCOCOSDC=1 -DITTYP=128 $(FLAGS)

DEPENDS		= ./makefile
TPB		= $(3RDPARTY)/booters

BOOTERS		= boot_sdc
BOOTTRACK	= rel $(BOOTERS)
KERNEL		= krn krnp2 wbug
SYSMODS		= ioman init sysgo_dd sysgo_h0
CLOCKS          = mc09clock_soft_50hz\
		mc09clock_dw_50hz

RBF		= rbf.mn \
		rbdw.dr \
		mc09sdc.dr \
		dds0_80d.dd s0_80d.dd s1_80d.dd s2_80d.dd s3_80d.dd \
		ddx0.dd x0.dd x1.dd x2.dd x3.dd \
		dds0_tc3.dd s0_tc3.dd s1_tc3.dd s2_tc3.dd s3_tc3.dd s4_tc3.dd \
                s5_tc3.dd s6_tc3.dd sh_tc3.dd

SCF		= scf.mn \
		nil.dd p_scbbp.dd p_scdwp.dd pipe.dd ssp.dd \
		mc6850.dr term_mc6850.dt term_mc6850_t0.dt term_mc6850_t1.dt \
		scdwv.dr term_scdwv.dt n_scdwv.dd n1_scdwv.dd n2_scdwv.dd \
		n3_scdwv.dd n4_scdwv.dd n5_scdwv.dd n6_scdwv.dd n7_scdwv.dd \
		n8_scdwv.dd n9_scdwv.dd n10_scdwv.dd n11_scdwv.dd n12_scdwv.dd \
		n13_scdwv.dd midi_scdwv.dd \
		term_z_scdwv.dt z1_scdwv.dd z2_scdwv.dd z3_scdwv.dd z4_scdwv.dd z5_scdwv.dd \
		z6_scdwv.dd z7_scdwv.dd

PIPE		= pipeman.mn \
		piper.dr \
		pipe.dd

RFM		= rfm.mn rfmdrv.dr ddy0.dd y0.dd y1.dd y2.dd y3.dd

ALLOBJS		= $(BOOTTRACK) $(KERNEL) $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(PIPE) $(RFM)

all:	$(ALLOBJS)

# Kernel
krn krnp2:
	$(CD) kernel; make $@
	$(OS9COPY) kernel/$@ .

# Special cases

# CoCo SDC Booter
boot_sdc: boot_sdc.asm
	$(AS) $(ASOUT)$@ $< $(SDFLAGS)

# DriveWire CoCo1 Booter
boot_dw_coco1:	boot_dw.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DBAUD38400=1

# DriveWire CoCo1 Submodule
dwio_coco1.sb:	dwio.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DBAUD38400=1

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

# Serial ports for mc09
term_mc6850_t0.dt: term_mc6850.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DTNum=0        -DHwBASE=0xFFD2

term_mc6850_t1.dt: term_mc6850.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DTNum=1        -DHwBASE=0xFFD4




# DriveWire 3 SCF descriptors
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

# DriveWire 3 RBF descriptors
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

# TC^3 SCSI Descriptors
dds0_tc3.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS) $(ID0) -DDD=1

s0_tc3.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS) $(ID0) $(SCSI_HD)

s1_tc3.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS) $(ID1) $(SCSI_HD)

s2_tc3.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS) $(ID2) $(SCSI_HD)

s3_tc3.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS) $(ID3) $(SCSI_HD)

s4_tc3.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS) $(ID4) $(SCSI_HD)

s5_tc3.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS) $(ID5) $(SCSI_HD)

s6_tc3.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS) $(ID6) $(SCSI_HD)

sh_tc3.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS) $(HDBDOS)

# IDE Descriptors
ddi0_ide.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(IDEFLAGS) $(MASTER) -DDD=1

i0_ide.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(IDEFLAGS) $(MASTER)

i1_ide.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(IDEFLAGS) $(SLAVE)

ih_ide.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(IDEFLAGS) $(HDBDOS)

# CoCo SDC Descriptors
ddsd0_cocosdc.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(SDFLAGS) -DDD=1

sd0_cocosdc.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(SDFLAGS) -DITDRV=0

sd1_cocosdc.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(SDFLAGS) -DITDRV=1

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

rel: rel.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

sysgo_dd: sysgo.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DDD=1

sysgo_h0: sysgo.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Clocks
mc09clock_soft_50hz: mc09clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ -DSOFT $< -DPwrLnFrq=50

mc09clock_dw_50hz: mc09clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ -DDW $< -DPwrLnFrq=50

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


