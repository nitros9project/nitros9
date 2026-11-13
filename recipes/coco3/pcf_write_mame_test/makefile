override RECIPE := coco3_pcf_write_mame_test
override BOOTMODS_EXTRA := pcf blkdrv llcocovhd dd_fat pc0
override CMDS_BASE := grfdrv shell mdir dir list copy cmp makdir del deldir attr dcheck pwd pxd pcfshare pcfrmdir rename pcfren
RANDOM_SEED ?= 20261108
RANDOM_STEPS ?= 120
ROOT_TEST_FLAGS = --write-test --seed $(RANDOM_SEED) --steps $(RANDOM_STEPS)
FAT_WRITE = 1
TEST_SECONDS = 3600
include ../fat_root_mame_test/makefile

$(MODDIR)/pcfshare: $(NITROS9DIR)/scripts/fixtures/pcfshare.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(addprefix $(MODDIR)/,attr dcheck pwd pxd): $(NITROS9DIR)/level1/cmds/rbfguard.asm

$(MODDIR)/deldir: $(DEFSDIR)/readdir.d

$(MODDIR)/pcfrmdir: $(NITROS9DIR)/scripts/fixtures/pcfrmdir.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# CPU stress tests include seek gaps, overwrites and truncation beyond shell ops.
RANDOM_CPU_STEPS ?= 150
RANDOM_CPU_SEEDS ?= 17 20261108
check-random: prepare
	$(PYTHON) $(NITROS9DIR)/scripts/test-pcf-random.py --image $(ROOT_TEST)/fat32-root.vhd --output .random-cpu --steps $(RANDOM_CPU_STEPS) --seeds $(RANDOM_CPU_SEEDS) --fsck "$(FAT_CHECK)"

# Run both real guest integrations from one recipe.
check-all: check check-rename check-random
	$(MAKE) -C ../rbf_mame_test check

demo-all: demo
	$(MAKE) -C ../rbf_mame_test demo
.PHONY: check-random check-all demo-all

$(MODDIR)/pcfren: $(NITROS9DIR)/scripts/fixtures/pcfren.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

check-rename:
	$(PYTHON) $(NITROS9DIR)/scripts/test-pcf-rename.py
	$(PYTHON) $(NITROS9DIR)/scripts/test-rename.py
.PHONY: check-rename
