# CoCo 3 Basic09 recipe.

RECIPE = coco3_basic09
STARTUP = ./startup

CMDS_BASE = $(filter-out asm dcheck debug disasm,$(STDCMDS)) grfdrv shell utilpak1
CMDS_EXTRA += basic09 runb

BASIC09_SAMPLES = \
	$(3RDPARTY)/packages/basic09/kernel_utility.b09 \
	$(wildcard $(3RDPARTY)/packages/basic09/samples/*)
