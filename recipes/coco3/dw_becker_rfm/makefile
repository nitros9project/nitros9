LEVEL = 2

# Becker port kernel track and modules
KERNEL_TRACK ?= $(REL) boot_rfm_becker krn

RBF ?= rbf.mn rbdw.dr dwio_becker.sb ddx0.dd x0.dd x1.dd x2.dd x3.dd
SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb cowin.io \
	term_win80.dt w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw
CLOCK ?= clock_60hz clock2_soft

# DW virtual disk image served by the DriveWire server as /DD.
OS9FORMAT_CMD = $(OS9FORMAT_DW)

DSK_EXTRA_DEPS = $(MODDIR)/sysgo_dd
DSK_POST_COPY = $(MAKE) post-copy DSKIMAGE=$@
BOOTMODS_EXTRA += rfm rfmdrv y0
CMDS_EXTRA += pmap dmem smap mmap

HDBDOS_ROM   = /Users/boisy/Projects/coco-shelf/toolshed/hdbdos/hdbdw3bc3.rom
MAME_ROMPATH = /Users/boisy/Documents/Resources/Computing/mame/roms

MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -d -window -skip_gameinfo -autoboot_delay 3 -autoboot_command "DOS\n"
DW_PORT      ?= 65504
STARTUP      ?= $(NITROS9DIR)/level2/$(PORT)/startup.dw

MAME ?= 0
ifeq ($(MAME),1)
MAME_FLAGS   = -d -window -nothrottle -skip_gameinfo -autoboot_delay 3 -autoboot_command "DOS\n"
STARTUP      = startup.mame
endif

include ../coco3.mak

copy-sysgo-root:
	$(OS9COPY) $(MODDIR)/sysgo_dd $(DSKIMAGE),sysgo
	$(OS9ATTR_EXEC) $(DSKIMAGE),sysgo

# Write sysgo and then re-stamp the kernel track last so it can't be overwritten.
post-copy:
	$(OS9COPY) $(MODDIR)/sysgo_dd $(DSKIMAGE),sysgo
	$(OS9ATTR_EXEC) $(DSKIMAGE),sysgo

all: libs $(DSKIMAGE) OS9Boot

OS9Boot: bootfile
	cp bootfile $@

$(MODDIR)/boot_dw_becker: boot_dw.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DBECKER=1

$(MODDIR)/boot_rfm_becker: boot_rfm.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DBECKER=1

$(MODDIR)/dwio_becker.sb: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DBECKER=1

$(MODDIR)/y0: rfmdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0

# HDB-DOS Becker port disk controller ROM (replaces disk11.rom)
# Becker port must be enabled in MAME Tab -> Machine Configuration
coco3.zip: $(HDBDOS_ROM)
	unzip -p $(MAME_ROMPATH)/coco3.zip coco3.rom > /tmp/coco3.rom
	cp $< /tmp/disk11.rom
	zip -j $@ /tmp/coco3.rom /tmp/disk11.rom
	$(RM) /tmp/coco3.rom /tmp/disk11.rom

# run: HDB-DOS ROM fetches boot track from DriveWire server — no floppy needed.
run: $(DSKIMAGE) coco3.zip
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) \
		-rompath "$(CURDIR);$(MAME_ROMPATH)"

clean:
	$(RM) *.list *.map bootfile OS9Boot $(KERNELFILE) *.dsk buildinfo coco3.zip
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)

ifeq ($(MAME),1)
startup.mame: $(NITROS9DIR)/level2/$(PORT)/startup.dw
	{ echo "keyrpt 0 0</1"; cat $<; } >$@
endif

.PHONY: all run run-hdbdos copy-sysgo-root post-copy clean
