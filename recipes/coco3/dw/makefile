LEVEL = 2

# DriveWire kernel track uses boot_dw (bitbanger, 57600/115200 baud)
KERNEL_TRACK ?= $(REL) boot_dw krn

# DriveWire RBF: rbdw driver + dwio subroutine + DW descriptors + floppy fallback
RBF ?= rbf.mn rbdw.dr dwio.sb ddx0.dd x0.dd x1.dd x2.dd x3.dd \
	ddd0_40d.dd d0_40d.dd d1_40d.dd d2_40d.dd

# SCF: add scdwv driver and virtual channel descriptors
SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb cowin.io \
	term_win80.dt w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw \
	w8.dw w9.dw w10.dw w11.dw w12.dw w13.dw w14.dw w15.dw \
	scdwv.dr term_n.dt n1 n2 n3 n4 n5

# DriveWire clock module provides time via server
CLOCK ?= clock_60hz clock2_dw

# DriveWire disk image format
OS9FORMAT_CMD = $(OS9FORMAT_DW)

include ../coco3.mak

MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -skip_gameinfo
DW_PORT      ?= 65400

run: $(DSKIMAGE)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) \
		-bitbanger socket.127.0.0.1:$(DW_PORT)

.PHONY: run
