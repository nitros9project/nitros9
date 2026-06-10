LEVEL = 2

# Becker port kernel track and modules
KERNEL_TRACK ?= $(REL) boot_dw_becker krn

RBF ?= rbf.mn rbdw.dr dwio_becker.sb ddx0.dd x0.dd x1.dd x2.dd x3.dd \
	ddd0_40d.dd d0_40d.dd d1_40d.dd d2_40d.dd

SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb cowin.io \
	term_win80.dt w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw \
	w8.dw w9.dw w10.dw w11.dw w12.dw w13.dw w14.dw w15.dw \
	scdwv.dr term_scdwv.dt n1_scdwv.dd n2_scdwv.dd n3_scdwv.dd \
	n4_scdwv.dd n5_scdwv.dd

CLOCK ?= clock_60hz clock2_dw

OS9FORMAT_CMD = $(OS9FORMAT_DW)

# DWDOS Becker port cassette loader
DWDOS_SRC    = /Users/boisy/Projects/coco-shelf/toolshed/dwdos/dw3dos.asm
DWDOS_BIN    = dw3dosbck_cc3.bin
DWDOS_CAS    = dw3dosbck_cc3.cas
MAKEWAV      = makewav

MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -skip_gameinfo
DW_PORT      ?= 65504

include ../coco3.mak

all: libs $(DSKIMAGE) $(DWDOS_CAS)

$(MODDIR)/boot_dw_becker: boot_dw.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DBECKER=1

$(MODDIR)/dwio_becker.sb: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DBECKER=1

$(DWDOS_BIN): $(DWDOS_SRC)
	lwasm.orig --format=decb --no-warn=ifp1 --pragma=condundefzero \
		-o$@ $< -DCoCo=3 -DBIN=1 -DBECKER=1

$(DWDOS_CAS): $(DWDOS_BIN)
	$(MAKEWAV) -r -c -k -2 -n DWDOS -o$@ $<

# Start server with: drivewire-cli --tcp-port 65504 --disk0 $(DSKIMAGE)
# Becker port must be enabled in MAME's Tab -> Machine Configuration menu
# At BASIC prompt: CLOADM:EXEC  then  DOS
run: $(DSKIMAGE) $(DWDOS_CAS)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -cass $(DWDOS_CAS)

clean:
	$(RM) *.list *.map bootfile $(KERNELFILE) *.dsk buildinfo \
		$(DWDOS_BIN) $(DWDOS_CAS)
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)

.PHONY: all run clean
