# Floppy kernel track only; OS9Boot, /DD, commands and startup are FAT32 files.
override NITROS9DIR := $(abspath ../../..)
LEVEL = 2
TERM_COLS = 80
RECIPE = coco3_fat_root_mame_test
STARTUP =
RECIPE_OUTPUTS = bootstrap.dsk
RBF =
PIPE =
SCF = scf.mn vtio.dr co3hires.sb snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) $(TERM_WIN_DT) w.dw
KERNEL_TRACK = $(REL) boot_fat32 krn
BOOTMODS_EXTRA = pcf blkdrv llcocovhd dd_fat
CMDS_BASE = grfdrv shell mdir dir list copy cmp
include ../coco3.mak
vpath %.asm $(NITROS9DIR)/level1/coco1/modules
.DEFAULT_GOAL := prepare
PYTHON ?= python3
MAME_BINARY ?= mame
MAME_ROMPATH ?= $(HOME)/Documents/Resources/Computing/mame/roms
TEST_SECONDS ?= 260
MAME_VIDEO ?=
ROOT_TEST = .fat-root
FAT_CHECK ?= /sbin/fsck_msdos
MAME_TEST_FLAGS ?=
ROOT_TEST_FLAGS ?=
FAT_WRITE ?= 0

$(MODDIR)/pcf: $(NITROS9DIR)/level1/modules/fatwrite.asm $(DEFSDIR)/blkdrv.d $(DEFSDIR)/pcf.d $(DEFSDIR)/readdir.d $(DEFSDIR)/rename-name.d
$(MODDIR)/blkdrv $(MODDIR)/llcocovhd: $(DEFSDIR)/blkdrv.d
$(MODDIR)/dd_fat: fatdesc.asm makefile | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1 -DFATVHD=1 -DFATBase=0 -DFATLength=131072 -DFATPort=0xFF80 -DFATWrite=$(FAT_WRITE)

bootstrap.dsk: kernelfile
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"FAT32 kernel track only"
	$(OS9GEN) $@ -t=$(KERNELFILE)

prepare: libs bootstrap.dsk bootfile $(MODDIR)/sysgo_dd $(addprefix $(MODDIR)/,$(CMDS)) startup | $(SYSDIR)
	$(MAKE) -C $(SYSDIR) -f $(SYS_RECIPE) --no-print-directory
	$(PYTHON) $(NITROS9DIR)/scripts/fat32-root-mame.py prepare --recipe $(CURDIR) --root $(ROOT_TEST) $(ROOT_TEST_FLAGS)

check: prepare
	$(PYTHON) $(NITROS9DIR)/scripts/fat32-root-mame.py run --recipe $(CURDIR) --root $(ROOT_TEST) $(ROOT_TEST_FLAGS) --mame "$(MAME_BINARY)" --rompath "$(MAME_ROMPATH)" --seconds $(TEST_SECONDS) --fsck "$(FAT_CHECK)" $(MAME_TEST_FLAGS) $(if $(MAME_VIDEO),--video "$(MAME_VIDEO)")
ifeq ($(FAT_WRITE),1)
	$(PYTHON) $(NITROS9DIR)/scripts/fat32-root-mame.py run --recipe $(CURDIR) --root $(ROOT_TEST) $(ROOT_TEST_FLAGS) --reopen --mame "$(MAME_BINARY)" --rompath "$(MAME_ROMPATH)" --seconds $(TEST_SECONDS) --fsck "$(FAT_CHECK)" $(MAME_TEST_FLAGS)
endif
all: prepare
.PHONY: prepare check

$(MODDIR)/pc0: fatdesc.asm makefile | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DFATVHD=1 -DFATBase=0 -DFATLength=131072 -DFATPort=0xFF80 -DFATWrite=$(FAT_WRITE)

demo:
	$(MAKE) check MAME_TEST_FLAGS=--visible
.PHONY: demo
