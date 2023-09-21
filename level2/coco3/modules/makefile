include ../port.mak

vpath %.asm kernel:$(LEVEL2)/modules:$(LEVEL1)/modules

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
CLOCKCOCO3FPGA  = -DRTCCoco3CPGA=1
TC3FLAGS        = $(AFLAGS) -DTC3=1 $(FLAGS)
IDEFLAGS        = $(AFLAGS) -DIDE=1 $(FLAGS)
SDFLAGS         = $(AFLAGS) -DCOCOSDC=1 -DITTYP=128 $(FLAGS)
CC3FPGAFLAGS    = $(AFLAGS) -DCC3FPGA=1 $(FLAGS)

DEPENDS		= ./makefile
TPB		= $(3RDPARTY)/booters

BOOTERS		= boot_1773_6ms boot_1773_30ms \
		boot_burke boot_rampak boot_wd1002 boot_dw boot_dw_becker boot_dw_arduino \
		boot_tc3 boot_dide boot_ide boot_sdc boot_rom boot_dw_rs232pak boot_dw_directmodempak \
		boot_dw_cocolink
BOOTTRACK	= rel_32 rel_40 rel_80 rel_32_50hz rel_40_50hz rel_80_50hz $(BOOTERS) krn
KERNEL		= krnp2 krnp3_perr krnp4_regdump ccbkrn
SYSMODS		= ioman init sysgo_h0 sysgo_dd sysgo_rom sysgo_bd rominfo vectors
CLOCKS		= clock_60hz clock_50hz \
		clock2_elim clock2_disto2 clock2_disto4 clock2_bnb \
		clock2_smart clock2_harris clock2_cloud9 clock2_soft \
		clock2_jvemu clock2_messemu clock2_dw clock2_coco3fpga

RBF		= rbf.mn \
		rbdw.dr dwio.sb dwio_becker.sb dwio_arduino.sb \
		dwio_rs232pak.sb dwio_directmodempak.sb dwio_cocolink.sb \
		rb1773.dr rb1773_scii_ff74.dr rb1773_scii_ff58.dr \
		d0_35s.dd d1_35s.dd d2_35s.dd d3_35s.dd \
		d0_40d.dd d1_40d.dd d2_40d.dd d0_80d.dd \
		d1_80d.dd d2_80d.dd \
		ddd0_35s.dd ddd0_40d.dd ddd0_80d.dd \
		rammer.dr r0_8k.dd r0_96k.dd r0_128k.dd r0_192k.dd \
		ddr0_8k.dd ddr0_96k.dd ddr0_128k.dd ddr0_192k.dd md.dd \
		myram.dr mr0.dd \
		ddx0.dd x0.dd x1.dd x2.dd x3.dd \
		rbsuper.dr lltc3.dr llide.dr llcocosdc.dr \
		ddi0_ide.dd i0_ide.dd i1_ide.dd ih_ide.dd \
		dds0_tc3.dd s0_tc3.dd s1_tc3.dd s2_tc3.dd s3_tc3.dd s4_tc3.dd \
		s5_tc3.dd s6_tc3.dd sh_tc3.dd \
		ddsd0_cocosdc.dd sd0_cocosdc.dd sd1_cocosdc.dd \
		llcoco3fpga.dr ddsd0_coco3fpga.dd sd0_coco3fpga.dd sd1_coco3fpga.dd \
		ramd_coco3fpga.dr r0_ramd_coco3fpga.dd \
		emudsk.dr ddh0_emudsk.dd h0_emudsk.dd h1_emudsk.dd

SCF		= scf.mn \
		vtio.dr vrn.dr scbbp.dr scbbt.dr scdwp.dr sspak.dr sc6551.dr \
		cowin.io cogrf.io covdg.io covdg_small.io \
		keydrv_cc3.sb snddrv_cc3.sb \
		joydrv_joy.sb joydrv_6551L.sb joydrv_6552L.sb \
		joydrv_6551M.sb joydrv_6552M.sb \
		nil.dd p_scbbp.dd p_scdwp.dd \
		t1_scbbt.dd t2_sc6551.dd t3_sc6551.dd \
		ftdd.dd vi.dd ssp.dd term_scbbt.dt term_sc6551.dt \
		term_vdg.dt term_win40.dt term_win80.dt w.dw w1.dw w2.dw \
		w3.dw w4.dw w5.dw w6.dw w7.dw \
		w8.dw w9.dw w10.dw w11.dw w12.dw w13.dw w14.dw w15.dw \
		v1.dw v2.dw v3.dw v4.dw v5.dw \
		v6.dw v7.dw \
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

ALLOBJS		=  $(BOOTTRACK) $(KERNEL) $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(PIPE) $(RFM)

all:	$(ALLOBJS)

# Kernel
ccbkrn krn krnp2:
	$(CD) kernel; make $@
	$(CP) kernel/$@ .

# Special cases

# TC^3 SCSI Booter
boot_tc3: boot_scsi.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS)

# SuperIDE/Glenside IDE Booter
boot_ide: boot_ide.asm
	$(AS) $(ASOUT)$@ $< $(IDEFLAGS)

boot_dide: boot_ide.asm
	$(AS) $(ASOUT)$@ $< $(IDEFLAGS) -DDEBLOCK

# CoCo SDC Booter
boot_sdc: boot_sdc.asm
	$(AS) $(ASOUT)$@ $< $(SDFLAGS)

# DriveWire Becker Booter
boot_dw_becker: boot_dw.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DBECKER=1

# DriveWire Deluxe RS232 Pak Booter
boot_dw_rs232pak: boot_dw.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSY6551N=1

# DriveWire CoCoLINK RS232 Pak Booter
boot_dw_cocolink: boot_dw.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSY6551N=1 -DSYCONSET=15

# DriveWire DirectModem Pak Booter
boot_dw_directmodempak: boot_dw.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSY6551N=1 -DSY6551B=65388

# DriveWire Becker Submodule
dwio_becker.sb: dwio.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DBECKER=1

# DriveWire Deluxe RS232 Pak Submodule
dwio_rs232pak.sb: dwio.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSY6551N=1

# DriveWire CoCoLINK RS232 Pak Submodule
dwio_cocolink.sb: dwio.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSY6551N=1 -DSYCONSET=15

# DriveWire Deluxe RS232 Pak Submodule
dwio_directmodempak.sb: dwio.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSY6551N=1 -DSY6551B=65388

# DriveWire Becker Booter
boot_dw_arduino: boot_dw.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DARDUINO=1

# DriveWire Arduino Submodule
dwio_arduino.sb: dwio.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DARDUINO=1

# CoGrf/CoVDG Modules
cogrf.io: cowin.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DCoGrf=1

covdg.io: covdg.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DCOCO2=1

covdg_small.io: covdg.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Disto SC-II Drivers
rb1773_scii_ff74.dr:    rb1773.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSCII=1

rb1773_scii_ff58.dr:    rb1773.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSCII=1 -DSCIIALT=1

emudsk.dr: emudsk.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS)

# REL Modules
rel_32: rel.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DWidth=32

rel_40: rel.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DWidth=40

rel_80: rel.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DWidth=80

rel_32_50hz: rel.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DWidth=32 -DTkPerSec=50

rel_40_50hz: rel.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DWidth=40 -DTkPerSec=50

rel_80_50hz: rel.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DWidth=80 -DTkPerSec=50

# Floppy Booters
boot_1773_6ms: boot_1773.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSTEP=0

boot_1773_30ms: boot_1773.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DSTEP=3

# SysGo Modules
sysgo_dd: sysgo.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1

sysgo_h0: sysgo.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS)

sysgo_rom: sysgo.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DROM=1

# TC^3 SCSI Driver
lltc3.dr: llscsi.asm
	$(AS) $(ASOUT)$@ $< $(TC3FLAGS)

# IDE Driver
llide.dr: llide.asm
	$(AS) $(ASOUT)$@ $< $(IDEFLAGS)

# Floppy descriptors
SSDD35	= -DCyls=35 -DSides=1 -DSectTrk=18 -DSectTrk0=18 \
	-DInterlv=3 -DSAS=8 -DDensity=1
DSDD40	= -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 \
	-DInterlv=3 -DSAS=8 -DDensity=1
DSDD80	= -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 \
	-DInterlv=3 -DSAS=8 -DDensity=1 -DD35

# HDB-DOS for SuperDriver
HDBDOS                  = -DHB $(SSDD35) $(ID0) -DITDNS=8

ddd0_35s.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD35) -DDNum=0 -DDD=1

d0_35s.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD35) -DDNum=0

d1_35s.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD35) -DDNum=1

d2_35s.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD35) -DDNum=2

d3_35s.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(SSDD35) -DDNum=3

ddd0_40d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=0 -DDD=1

d0_40d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=0

d1_40d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=1

d2_40d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD40) -DDNum=2

ddd0_80d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=0 -DDD=1

d0_80d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=0

d1_80d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=1

d2_80d.dd: rb1773desc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) $(DSDD80) -DDNum=2

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

# Coco3fpga ramd descriptors
r0_ramd_coco3fpga.dd: ramddesc_coco3fpga.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS)

# Emudsk descriptors
ddh0_emudsk.dd: emudskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0 -DDD=1

h0_emudsk.dd: emudskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

h1_emudsk.dd: emudskdesc.asm
	$(AS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1

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

# CoCo3FPGA SD Descriptors
ddsd0_coco3fpga.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(CC3FPGAFLAGS) -DDD=1

sd0_coco3fpga.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(CC3FPGAFLAGS) -DITDRV=0

sd1_coco3fpga.dd: superdesc.asm
	$(AS) $(ASOUT)$@ $< $(CC3FPGAFLAGS) -DITDRV=1

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
clock_60hz: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DPwrLnFrq=60

clock_50hz: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DPwrLnFrq=50

clock2_cloud9: clock2_ds1315.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DCLOUD9=1

clock2_bnb: clock2_ds1315.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DBNB=1

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
