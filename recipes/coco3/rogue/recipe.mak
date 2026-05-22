# CoCo 3 Rogue recipe defaults.

RECIPE = coco3_rogue
TERM_COLS = 80
STARTUP = ./startup

ROGUE_DIR = $(3RDPARTY)/packages/rogue
ROGUE_SUPPORT_FILES = rogue.dat rogue.hlp rogue.scr rogue.chr

override SHELLMODS = shell_21 date deiniz display echo iniz link load save unlink

BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	sysgo_dd \
	$(BOOTMODS_EXTRA)

CMDS_BASE = grfdrv shell utilpak1
CMDS_EXTRA += rogue
ROOT_FILES += $(MODDIR)/sysgo
ROOT_TEXT_FILES =
DATA_DIR = ROGUE
DATA_FILES += $(addprefix $(ROGUE_DIR)/,$(ROGUE_SUPPORT_FILES))

$(MODDIR)/rogue: $(ROGUE_DIR)/rogue | $(MODDIR)
	$(CP) $< $@

$(MODDIR)/sysgo: $(MODDIR)/sysgo_dd | $(MODDIR)
	$(CP) $< $@
