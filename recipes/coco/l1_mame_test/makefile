override NITROS9DIR := $(abspath ../../..)
LEVEL = 1
RECIPE = coco_l1_mame_test
STARTUP = startup
CMDS_BASE = shell_21 l1check
RBF = rbf rb1773 ddd0_40d d0_40d
PIPE =
include ../coco.mak
PYTHON ?= python3
MAME_BINARY ?= mame
MAME_MACHINE ?= coco2b
MAME_ROMPATH ?= $(HOME)/Documents/Resources/Computing/mame/roms
check: $(DSKIMAGE)
	$(PYTHON) $(NITROS9DIR)/scripts/l1-runtime-mame.py --recipe $(CURDIR) --machine $(MAME_MACHINE) --mame "$(MAME_BINARY)" --rompath "$(MAME_ROMPATH)"
.PHONY: check
