LEVEL = 2

# Becker port kernel track and modules
KERNEL_TRACK ?= $(REL) boot_dw_becker krn

RBF ?= rbf.mn rbdw.dr dwio_becker.sb ddx0.dd x0.dd x1.dd x2.dd x3.dd \
	ddd0_40d.dd d0_40d.dd d1_40d.dd d2_40d.dd

SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb cowin.io \
	term_win80.dt w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw \
	w8.dw w9.dw w10.dw w11.dw w12.dw w13.dw w14.dw w15.dw

CLOCK ?= clock_60hz clock2_dw

OS9FORMAT_CMD = $(OS9FORMAT_DW)

DSK_EXTRA_DEPS = $(MODDIR)/sysgo_dd
DSK_POST_COPY = $(MAKE) copy-sysgo-root DSKIMAGE=$@

HDBDOS_ROM   = /Users/boisy/Projects/coco-shelf/toolshed/hdbdos/hdbdw3bc3.rom
MAME_ROMPATH = /Users/boisy/Documents/Resources/Computing/mame/roms

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

copy-sysgo-root:
	$(OS9COPY) $(MODDIR)/sysgo_dd $(DSKIMAGE),sysgo
	$(OS9ATTR_EXEC) $(DSKIMAGE),sysgo

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

# HDB-DOS Becker port disk controller ROM (replaces disk11.rom)
# Becker port must be enabled in MAME Tab -> Machine Configuration
coco3.zip: $(HDBDOS_ROM)
	unzip -p $(MAME_ROMPATH)/coco3.zip coco3.rom > /tmp/coco3.rom
	cp $< /tmp/disk11.rom
	zip -j $@ /tmp/coco3.rom /tmp/disk11.rom
	$(RM) /tmp/coco3.rom /tmp/disk11.rom

# run-hdbdos: type DOS at BASIC prompt — no cassette needed
run-hdbdos: $(DSKIMAGE) coco3.zip
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) \
		-rompath "$(CURDIR);$(MAME_ROMPATH)"

# run: cassette approach (CLOADM:EXEC then DOS)
run: $(DSKIMAGE) $(DWDOS_CAS)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -cass $(DWDOS_CAS)

clean:
	$(RM) *.list *.map bootfile $(KERNELFILE) *.dsk buildinfo coco3.zip \
		$(DWDOS_BIN) $(DWDOS_CAS)
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)

.PHONY: all run run-hdbdos clean
