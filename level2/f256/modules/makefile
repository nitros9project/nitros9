include ../port.mak

vpath %.as $(LEVEL1)/$(PORT)/modules
vpath %.asm kernel:$(LEVEL1)/$(PORT)/modules:$(LEVEL2)/modules:$(LEVEL1)/modules

# Select one of the dwio modules below based on your desired configuration:
#DWIO	= dwio_wizfi.sb
DWIO	= dwio_serial.sb

AFLAGS		+= -I$(LEVEL2)/$(PORT)
AFLAGS		+= -I$(LEVEL1)/$(PORT)/modules
AFLAGS		+= -I$(LEVEL1)/modules
LFLAGS	    += -L $(NITROS9DIR)/lib -L $(LEVEL2)/$(PORT)/libs -lnet -lf256 -lalib -lfnxsnd

DEPENDS		= ./makefile
TPB		= $(3RDPARTY)/booters

KERNEL		= krn krnp2
SYSMODS		= ioman init sysgo
CLOCKS		= clock clock2_f256

RBF		= rbf.mn rbdw.dr $(DWIO) ddx0.dd x0.dd x1.dd x2.dd x3.dd \
		rbmem.dr ddc0.dd c0.dd c1.dd f0.dd f1.dd \
		rbsuper.dr \
		llfnxsd.sb dds0.dd s0.dd s1.dd

SCF		= scf.mn \
		vrn.dr nil.dd \
		vtio.dr keydrv_f256k2.sb keydrv_f256k.sb keydrv_ps2.sb mousedrv_ps2.sb term.dt \
		SOLdrv.sb fSOL.dd \
		sc16550.dr t0_sc16550.dd \
		scdwp.dr p_scdwp.dd \
		scdwv.dr term_scdwv.dt n_scdwv.dd \
		n0_scdwv.dd n1_scdwv.dd n2_scdwv.dd \
		n3_scdwv.dd n4_scdwv.dd n5_scdwv.dd n6_scdwv.dd n7_scdwv.dd \
		n8_scdwv.dd n9_scdwv.dd n10_scdwv.dd n11_scdwv.dd n12_scdwv.dd \
		n13_scdwv.dd midi_scdwv.dd \
		z1_scdwv.dd z2_scdwv.dd z3_scdwv.dd z4_scdwv.dd z5_scdwv.dd \
		z6_scdwv.dd z7_scdwv.dd z8_scdwv.dd z9_scdwv.dd z10_scdwv.dd \
		z11_scdwv.dd z12_scdwv.dd z13_scdwv.dd z14_scdwv.dd \
		wizfi.dr wz.dd n0.dd n1.dd n2.dd n3.dd

PIPE		= pipeman.mn pipeman_named.mn piper.dr pipe.dd

FONTS	= #applefont.sb bannerfont.sb jessefont.sb phoenixegafont.sb msxfont.sb msxbannerfont.sb quadrotextfont.sb
PALETTES  = palette.sb

ALLOBJS		=  $(KERNEL) $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(PIPE) $(RFM) $(FONTS) $(PALETTES)

all:	$(ALLOBJS)

sysgo: sysgo.o

rbmem.dr: rbmem.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS)

# WizFi360 chip
wizfi.dr: wizfi.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS)
wz.dd: wz.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS)
n0.dd: n0.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS)
n1.dd: n1.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS)
n2.dd: n2.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS)
n3.dd: n3.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS)

# Kernel
krn: $(LEVEL2)/modules/kernel/krn.asm
	$(CD) kernel; make $@
	$(CP) kernel/$@ .

krnp2: $(LEVEL2)/modules/kernel/krnp2.asm
	$(CD) kernel; make $@
	$(CP) kernel/$@ .

# SD card descriptors
dds0.dd: rbfnxsddesc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< $(FNXSDFLAGS) -DSD=0 -DDD=1

s0.dd: rbfnxsddesc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< $(FNXSDFLAGS) -DSD=0

s1.dd: rbfnxsddesc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< $(FNXSDFLAGS) -DSD=1

# rbmem descriptors
f0.dd: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

f1.dd: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1 -DF1=1

c0.dd: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2 -DC0=1

c1.dd: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3 -DC1=1

ddc0.dd: rbmemdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2 -DDD=1 -DC0=1

# 16550 descriptors
t0_sc16550.dd: sc16550desc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS)

# DriveWire SCF descriptors
term_scdwv.dt: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=0

n_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=255

n0_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=0

n1_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=1

n2_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=2

n3_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=3

n4_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=4

n5_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=5

n6_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=6

n7_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=7

n8_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=8

n9_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=9

n10_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=10

n11_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=11

n12_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=12

n13_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=13

midi_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=14

term_z_scdwv.dt: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=16

z1_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=17

z2_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=18

z3_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=19

z4_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=20

z5_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=21

z6_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=22

z7_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=23

z8_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=24

z9_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=25

z10_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=26

z11_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=27

z12_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=28

z13_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=29

z14_scdwv.dd: scdwvdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DAddr=30

# DriveWire dwio modules
dwio_wizfi.sb: dwio.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDWIO_WIZFI

dwio_serial.sb: dwio.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDWIO_SERIAL

# DriveWire RBF descriptors
ddx0.dd: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1 -DDNum=0

x0.dd: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

x1.dd: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1

x2.dd: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2

x3.dd: dwdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3

# RFM descriptors
ddy0.dd: rfmdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDD=1 -DDNum=0

y0.dd: rfmdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=0

y1.dd: rfmdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=1

y2.dd: rfmdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=2

y3.dd: rfmdesc.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(AFLAGS) -DDNum=3

# Clocks
clock: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DPwrLnFrq=60

clean:
	$(CD) kernel; make $@
	$(RM) $(ALLOBJS) *.o *.list *.map

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
