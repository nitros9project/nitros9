# Local kernel track only; OS9Boot and /DD are plain RFM host files.
override NITROS9DIR := $(abspath ../../..)
LEVEL = 2
RECIPE = coco3_rfm_boot_test
STARTUP =
RBF =
KERNEL_TRACK = $(REL) boot_rfm_becker krn
BOOTMODS_EXTRA = dwio_becker.sb rfm rfmdrv dd_rfm
CMDS_BASE = grfdrv shell utilpak1 cmp
include ../coco3.mak
vpath %.asm $(NITROS9DIR)/level1/coco1/modules
.DEFAULT_GOAL := prepare

PYTHON ?= python3
TEST_ROOT ?= .rfm-boot
DRIVEWIRE_CLI ?= drivewire-cli
MAME_BINARY ?= mame
MAME_ROMPATH ?= $(HOME)/.local/share/mame/roms
TEST_SECONDS ?= 180

$(MODDIR)/boot_rfm_becker: boot_rfm.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DBECKER=1

$(MODDIR)/dd_rfm: rfmdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1 -DDNum=0

bootstrap.dsk: kernelfile
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"RFM bootstrap only"
	$(OS9GEN) $@ -t=$(KERNELFILE)

prepare: libs bootstrap.dsk bootfile $(MODDIR)/sysgo_dd $(addprefix $(MODDIR)/,$(CMDS)) | $(SYSDIR)
	$(MAKE) -C $(SYSDIR) -f $(SYS_RECIPE) --no-print-directory
	$(PYTHON) $(NITROS9DIR)/scripts/rfm-boot-test.py prepare --recipe $(CURDIR) --root $(TEST_ROOT)

.PHONY: prepare

check: prepare
	$(PYTHON) $(NITROS9DIR)/scripts/rfm-boot-test.py run --recipe $(CURDIR) --root $(TEST_ROOT) \
		--server "$(DRIVEWIRE_CLI)" --mame "$(MAME_BINARY)" --rompath "$(MAME_ROMPATH)" --seconds $(TEST_SECONDS)

run: prepare
	$(PYTHON) $(NITROS9DIR)/scripts/rfm-boot-test.py run --recipe $(CURDIR) --root $(TEST_ROOT) \
		--server "$(DRIVEWIRE_CLI)" --mame "$(MAME_BINARY)" --rompath "$(MAME_ROMPATH)" --seconds 3600 --interactive

.PHONY: check run
