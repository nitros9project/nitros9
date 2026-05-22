# CoCo 3 Rogue recipe defaults.

RECIPE = coco3_rogue
TERM_COLS = 80
STARTUP = ./startup

NITROS9_GAMES_DIR ?= $(abspath $(NITROS9DIR)/../nitros9-games)
ROGUE_DIR ?= $(NITROS9_GAMES_DIR)/rogue
ROGUE_SUPPORT_FILES = rogue.dat rogue.hlp rogue.scr rogue.chr
ROGUE_SUPPORT_PATHS = $(addprefix $(ROGUE_DIR)/,$(ROGUE_SUPPORT_FILES))

override SHELLMODS = shell_21 date deiniz display echo iniz link load save unlink

BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA)

CMDS_BASE = grfdrv shell utilpak1
CMDS_EXTRA += rogue
RECIPE_DEPS += $(ROGUE_SUPPORT_PATHS)

$(MODDIR)/rogue: $(ROGUE_DIR)/rogue.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

define RECIPE_INSTALL
	$(MAKDIR) $(1),ROGUE
	$(OS9COPY) $(ROGUE_SUPPORT_PATHS) $(1),ROGUE
	$(OS9ATTR_TEXT) $(foreach file,$(ROGUE_SUPPORT_FILES),$(1),ROGUE/$(file))
endef
