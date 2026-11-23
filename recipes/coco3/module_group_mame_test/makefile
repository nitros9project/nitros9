override NITROS9DIR := $(abspath ../../..)
LEVEL = 2
TERM_COLS = 80
RECIPE = coco3_module_group_mame_test
STARTUP = startup
CMDS_BASE = grfdrv shell groupcheck
RBF = rbf.mn rb1773.dr ddd0_$(TRACKS)d.dd d0_$(TRACKS)d.dd
SCF = scf.mn vtio.dr co3hires.sb snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) $(TERM_WIN_DT) w.dw
PIPE =
BOOTMODS_EXTRA = residenta residentb
RECIPE_DEPS = short.grp long.grp
define RECIPE_INSTALL
$(OS9COPY) short.grp long.grp $(1),
$(OS9ATTR_EXEC) $(1),short.grp $(1),long.grp
endef
include ../coco3.mak
$(MODDIR)/residenta $(MODDIR)/residentb $(MODDIR)/shorta $(MODDIR)/shortb $(MODDIR)/longa $(MODDIR)/longb: member.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DGROUP=$(if $(findstring resident,$@),3,$(if $(findstring short,$@),1,2)) -DMEMBER=$(if $(filter %a,$@),1,2)
short.grp: $(MODDIR)/shorta $(MODDIR)/shortb
	$(MERGE) $^ > $@
long.grp: $(MODDIR)/longa $(MODDIR)/longb
	$(MERGE) $^ > $@
PYTHON ?= python3
MAME_BINARY ?= mame
MAME_ROMPATH ?= $(HOME)/Documents/Resources/Computing/mame/roms
check: $(DSKIMAGE)
	$(PYTHON) $(NITROS9DIR)/scripts/module-group-mame.py --recipe $(CURDIR) --mame "$(MAME_BINARY)" --rompath "$(MAME_ROMPATH)"
.PHONY: check
