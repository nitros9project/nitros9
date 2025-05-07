include ../port.mak

vpath %.asm $(LEVEL1)/modules

AFLAGS		+= -I$(LEVEL1)/modules

CLOCKSOFT       = -DRTCSoft=1

DEPENDS		= ./makefile
TPB		= $(3RDPARTY)/booters

BOOTERS		= 
KERNEL		= krn krnp2
SYSMODS		= ioman init sysgo sysgo_rom
CLOCKS      = clock_60hz clock_50hz clock2_soft clock2_dw

RBF		= rbf.mn rbdw.dr dwio.sb ddx0.dd x0.dd x1.dd x2.dd x3.dd

SCF		= scf.mn \
		vrn.dr vtio.dr \
		nil.dd \
		term.dt \
		scdwp.dr p_scdwp.dd \
		scdwv.dr term_scdwv.dt n_scdwv.dd n1_scdwv.dd n2_scdwv.dd \
		n3_scdwv.dd n4_scdwv.dd n5_scdwv.dd n6_scdwv.dd n7_scdwv.dd \
		n8_scdwv.dd n9_scdwv.dd n10_scdwv.dd n11_scdwv.dd n12_scdwv.dd \
		n13_scdwv.dd midi_scdwv.dd \
		z1_scdwv.dd z2_scdwv.dd z3_scdwv.dd z4_scdwv.dd z5_scdwv.dd \
		z6_scdwv.dd z7_scdwv.dd

PIPE		= pipeman.mn \
		piper.dr \
		pipe.dd


ALLOBJS		= $(KERNEL) $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(PIPE) $(DW)

all:	$(ALLOBJS)

# Kernel
krn krnp2:
	$(CD) kernel; make $@
	$(CP) kernel/$@ .


sysgo_rom: sysgo.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DROM=1

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

# Clocks
clock_60hz: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DPwrLnFrq=60

clock_50hz: clock.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DPwrLnFrq=50

clean:
	$(CD) kernel; make $@
	$(RM) $(ALLOBJS) *.list *.map

showobjs:
	@$(ECHO) $(ALLOBJS)

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


