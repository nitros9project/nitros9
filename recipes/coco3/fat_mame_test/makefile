# Local floppy OS plus an external FAT32 image on the MAME VHD device.
override NITROS9DIR := $(abspath ../../..)
LEVEL = 2
TERM_COLS = 80
RECIPE = coco3_fat_mame_test
STARTUP =
CMDS_BASE = grfdrv shell mdir dir list copy cmp
# Keep this test boot small: one floppy and one 80-column console.
RBF = rbf.mn rb1773.dr ddd0_$(TRACKS)d.dd d0_$(TRACKS)d.dd
SCF = scf.mn vtio.dr co3hires.sb snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) $(TERM_WIN_DT) w.dw
PIPE =
BOOTMODS_EXTRA = pcf blkdrv llcocovhd pc0
FATAUTO ?= fatauto
RECIPE_DEPS = $(FATAUTO)
RECIPE_INSTALL = $(CPL) $(FATAUTO) $(1),fatauto
include ../coco3.mak
vpath %.asm $(NITROS9DIR)/level1/coco1/modules
PYTHON ?= python3
MAME_BINARY ?= mame
MAME_ROMPATH ?= $(HOME)/Documents/Resources/Computing/mame/roms
TEST_SECONDS ?= 400
MAME_VIDEO ?=

FAT_IMAGE ?= .fat-test/fat32.vhd
ifeq ($(FAT_BOOT),)
$(FAT_IMAGE): $(NITROS9DIR)/scripts/make-fat32-image.py
	$(PYTHON) $< $@
endif
$(MODDIR)/llcocovhd: $(DEFSDIR)/blkdrv.d
$(MODDIR)/pcf: $(NITROS9DIR)/level1/modules/fatwrite.asm $(DEFSDIR)/blkdrv.d $(DEFSDIR)/pcf.d $(DEFSDIR)/readdir.d $(DEFSDIR)/rename-name.d
$(MODDIR)/blkdrv: $(DEFSDIR)/blkdrv.d
$(MODDIR)/pc0: fatdesc.asm makefile | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DFATVHD=1 -DFATBase=0 -DFATLength=131072 -DFATPort=0xFF80
check: $(DSKIMAGE) $(FAT_IMAGE)
	$(PYTHON) $(NITROS9DIR)/scripts/fat32-mame.py --disk $(DSKIMAGE) --fat-image $(FAT_IMAGE) --mame "$(MAME_BINARY)" --rompath "$(MAME_ROMPATH)" --seconds $(TEST_SECONDS) $(MAME_TEST_FLAGS) $(if $(MAME_VIDEO),--video "$(MAME_VIDEO)")
.PHONY: check
