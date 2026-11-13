override NITROS9DIR := $(abspath ../../..)
LEVEL = 2
TERM_COLS = 80
RECIPE = coco3_rbf_mame_test
STARTUP = startup
CMDS_BASE = grfdrv shell mdir dir list copy cmp makdir del deldir attr dcheck
RBF = rbf.mn rb1773.dr ddd0_$(TRACKS)d.dd d0_$(TRACKS)d.dd
SCF = scf.mn vtio.dr co3hires.sb snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) $(TERM_WIN_DT) w.dw
PIPE =
include ../coco3.mak
$(MODDIR)/deldir $(MODDIR)/dir: $(DEFSDIR)/readdir.d
$(MODDIR)/attr $(MODDIR)/dcheck: $(NITROS9DIR)/level1/cmds/rbfguard.asm
PYTHON ?= python3
MAME_BINARY ?= mame
MAME_ROMPATH ?= $(HOME)/Documents/Resources/Computing/mame/roms
check: $(DSKIMAGE)
	$(PYTHON) $(NITROS9DIR)/scripts/rbf-mame.py --recipe $(CURDIR) --mame "$(MAME_BINARY)" --rompath "$(MAME_ROMPATH)" $(MAME_TEST_FLAGS)
demo:
	$(MAKE) check MAME_TEST_FLAGS=--visible
.PHONY: check demo
