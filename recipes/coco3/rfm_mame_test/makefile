# Local floppy boot, Becker transport only for RFM.
override NITROS9DIR := $(abspath ../../..)
LEVEL = 2
RECIPE = coco3_rfm_mame_test
STARTUP =
BOOTMODS_EXTRA = dwio_becker.sb rfm rfmdrv y0
CMDS_BASE = grfdrv shell utilpak1 cmp
RECIPE_DEPS = rfmcheck rfmauto
RECIPE_INSTALL = $(CPL) rfmcheck $(1),rfmcheck; $(CPL) rfmauto $(1),rfmauto
include ../coco3.mak
vpath %.asm $(NITROS9DIR)/level1/coco1/modules

PYTHON ?= python3
MAME_BINARY ?= mame
MAME_ROMPATH = $(HOME)/.local/share/mame/roms
DW_PORT ?= 65504
TEST_SECONDS ?= 600
TEST_ROOT ?= .rfm-test
TEST_SUITE ?= all
TEST_IRQ_STRESS ?= 0
IRQ_STRESS_FLAG = $(if $(filter 1,$(TEST_IRQ_STRESS)),--irq-stress,)

$(MODDIR)/y0: rfmdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0

# Test data and command file are generated together, before the disk image.
$(MODDIR)/rfmexec: $(NITROS9DIR)/scripts/fixtures/rfmexec.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DChild=0

$(MODDIR)/rfmchild: $(NITROS9DIR)/scripts/fixtures/rfmexec.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DChild=1

$(MODDIR)/rfmfork: $(NITROS9DIR)/scripts/fixtures/rfmfork.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

rfmcheck: $(NITROS9DIR)/scripts/rfm-mame.py $(MODDIR)/rfmexec $(MODDIR)/rfmchild $(MODDIR)/rfmfork FORCE
	$(PYTHON) $< prepare --root $(TEST_ROOT) --commands $@ --suite $(TEST_SUITE) \
		--executable $(MODDIR)/rfmexec --child $(MODDIR)/rfmchild

prepare: $(DSKIMAGE)

# Opens the CoCo 3 GUI and starts the small local protocol fixture.
run: $(DSKIMAGE)
	$(PYTHON) $(NITROS9DIR)/scripts/rfm-mame.py run --root $(TEST_ROOT) \
		--disk $(DSKIMAGE) --mame "$(MAME_BINARY)" --rompath "$(MAME_ROMPATH)" \
		--port $(DW_PORT) --seconds $(TEST_SECONDS) $(IRQ_STRESS_FLAG) --interactive

# Same guest commands, no display; succeeds only after host byte verification.
check: $(DSKIMAGE)
	$(PYTHON) $(NITROS9DIR)/scripts/rfm-mame.py run --root $(TEST_ROOT) \
		--disk $(DSKIMAGE) --mame "$(MAME_BINARY)" --rompath "$(MAME_ROMPATH)" \
		--port $(DW_PORT) --seconds $(TEST_SECONDS) $(IRQ_STRESS_FLAG)

.PHONY: prepare run check
