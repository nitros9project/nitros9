LEVEL = 2

# SY6551 RS-232 pak boot — matches MAME's -rs232 null_modem -bitbanger socket connection
KERNEL_TRACK ?= $(REL) boot_dw_rs232pak krn

# DriveWire RBF: rs232pak IO module + DW descriptors + floppy fallback
RBF ?= rbf.mn rbdw.dr dwio_rs232pak.sb ddx0.dd x0.dd x1.dd x2.dd x3.dd \
	ddd0_40d.dd d0_40d.dd d1_40d.dd d2_40d.dd

# SCF: scdwv driver and virtual channel descriptors
SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb cowin.io \
	term_win80.dt w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw \
	w8.dw w9.dw w10.dw w11.dw w12.dw w13.dw w14.dw w15.dw \
	scdwv.dr term_scdwv.dt n1_scdwv.dd n2_scdwv.dd n3_scdwv.dd \
	n4_scdwv.dd n5_scdwv.dd

# DriveWire clock
CLOCK ?= clock_60hz clock2_dw

# DriveWire disk image format
OS9FORMAT_CMD = $(OS9FORMAT_DW)

include ../coco3.mak

$(MODDIR)/boot_dw_rs232pak: boot_dw.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DSY6551N=1

$(MODDIR)/dwio_rs232pak.sb: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DSY6551N=1

DWDOS_SRC    = /Users/boisy/Projects/coco-shelf/toolshed/dwdos/dw3dos.asm
MAME_ROMPATH = /Users/boisy/Documents/Resources/Computing/mame/roms
MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -skip_gameinfo
DW_PORT      ?= 65400

coco3.rom: $(DWDOS_SRC) dw3dos_defs.asm
	lwasm.orig --format=raw --no-warn=ifp1 --pragma=condundefzero \
		-o/tmp/dw3dos_build.rom $< -DCoCo=3 -DSY6551N=1
	dd if=/tmp/dw3dos_build.rom of=$@ bs=32768 count=1
	$(RM) /tmp/dw3dos_build.rom

run: $(DSKIMAGE) coco3.rom
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) \
		-rompath "$(CURDIR):$(MAME_ROMPATH)" \
		-rs232 null_modem \
		-bitbanger socket.127.0.0.1:$(DW_PORT)

.PHONY: run coco3.rom
