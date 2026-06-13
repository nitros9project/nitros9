include ../port.mak

vpath %.asm kernel:$(LEVEL2)/picothing/modules:$(LEVEL2)/modules:$(LEVEL1)/modules
vpath %.asm $(LEVEL1)/modules/kernel

AFLAGS      += -I$(LEVEL2)/$(PORT)
AFLAGS      += -I$(LEVEL1)/modules
AFLAGS      += -I$(LEVEL2)/modules

DEPENDS     = ./makefile

IDEFLAGS    = $(AFLAGS) -DIDE=1 $(FLAGS)

KERNEL      = krn krnp2 krnp3_perr
SYSMODS     = ioman init sysgo boot_picothing boot_dw_pt rel_picothing
RELSREC     = rel_picothing.srec
CLOCKS      = clock_picothing clock2_null
RBF         = rbf.mn rbsuper.dr llide_pt.dr ddi0_pt.dd \
              i0_pt.dd i1_pt.dd i2_pt.dd i3_pt.dd \
              i4_pt.dd i5_pt.dd i6_pt.dd i7_pt.dd \
              j0_pt.dd j1_pt.dd j2_pt.dd j3_pt.dd \
              j4_pt.dd j5_pt.dd j6_pt.dd j7_pt.dd \
              rammer.dr r0.dd
SCF         = scf.mn sc6850.dr term_pt.dd
GFX         = vtio_picothing.dr copico term_gfx.dd
DW          = dwio.sb rbdw.dr ddx0.dd x0.dd x1.dd x2.dd x3.dd \
              scdwv.dr term_scdwv.dt n_scdwv.dd \
              n1_scdwv.dd n2_scdwv.dd n3_scdwv.dd n4_scdwv.dd \
              clock2_dw
PIPE        = pipeman.mn piper.dr pipe.dd

ALLOBJS     = $(KERNEL) $(SYSMODS) $(RELSREC) $(CLOCKS) $(RBF) $(SCF) $(GFX) $(DW) $(PIPE)

all:    $(ALLOBJS)

# Kernel (built in kernel/ subdirectory)
# Always recurse into kernel/ so its own makefile can check dependencies.
krn krnp2: FORCE
	$(CD) kernel; make $@
	$(CP) kernel/$@ .

FORCE:

# Pico-Thing PATA IDE low-level driver
llide_pt.dr: llide_pt.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Pico-Thing PATA disk descriptors
# DD = default drive (partition 0), I0-I7 = partitions 0-7
# Each partition is 512MB (2097152 sectors, SOFF1 steps by $20)
ddi0_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDD=1

i0_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x00

i1_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x20

i2_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x40

i3_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x60

i4_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0x80

i5_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0xA0

i6_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0xC0

i7_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DSOFF1=0xE0

# Slave-drive partitions (DRVID=1): same SOFF1 layout as the master,
# named /J0../J7, selected via the ATA DEV bit.
j0_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0x00

j1_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0x20

j2_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0x40

j3_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0x60

j4_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0x80

j5_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0xA0

j6_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0xC0

j7_pt.dd: ptidedesc.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DDRVID=1 -DSOFF1=0xE0

# RAM disk driver and descriptor (128KB default)
rammer.dr: $(LEVEL2)/coco3/modules/rammer.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

r0.dd: $(LEVEL2)/coco3/modules/r0.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Pico-Thing boot module (PATA IDE boot)
boot_picothing: boot_picothing.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Pico-Thing boot module (DriveWire boot via auxiliary ACIA)
boot_dw_pt: boot_dw_pt.asm
	$(AS) $(AFLAGS) -Dpicothing=1 $(ASOUT)$@ $<

# REL - early hardware init and relocation chunk (raw binary at Bt.Start)
rel_picothing: rel_picothing.asm
	$(AS) --format=raw $(AFLAGS) $(ASOUT)$@ $<

# Same REL source as a Motorola S-record (for usim09pt / firmware load)
rel_picothing.srec: rel_picothing.asm
	$(AS) --format=srec $(AFLAGS) $(ASOUT)$@ $<

# Clock module
clock_picothing: clock_picothing.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Minimal Clock2 stub (no RTC on base Pico-Thing)
clock2_null: clock2_null.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Console terminal descriptor (serial)
term_pt.dd: term_pt.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# VTIO driver for graphical console
vtio_picothing.dr: vtio_picothing.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# CoPico co-module (graphical console rendering)
copico: copico.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# Graphical console terminal descriptor
term_gfx.dd: term_gfx.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# DriveWire I/O subroutine module (auxiliary ACIA at $FFC5-$FFC6)
dwio.sb: dwio.asm
	$(AS) $(AFLAGS) -Dpicothing=1 $(ASOUT)$@ $<

# DriveWire RBF driver
rbdw.dr: rbdw.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

# DriveWire disk descriptors (virtual drives via DW server)
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

# DriveWire SCF virtual channel driver and descriptors
scdwv.dr: scdwv.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

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

# DriveWire clock2 module (time sync via DW server)
clock2_dw: clock2_dw.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $<

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

showgfx:
	@$(ECHO) $(GFX)

showdw:
	@$(ECHO) $(DW)

showpipe:
	@$(ECHO) $(PIPE)

identify:
	$(IDENT_SHORT) $(ALLOBJS)
