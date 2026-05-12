# Common rules for Sierra-on-Wildbits recipes.
#
# Each per-game makefile must set before including this file:
#   LEVEL         = 2
#   RECIPE        = <short name>     used in disk image filename
#   GAME_SUBDIR   = <dirname>        subdir under 3rdparty/packages/sierra/
#   OBJS_SUBDIR   = <dirname>        assembly source subdir (objs_lsl)
#   GAME_DIR_NAME = <name>           GAMES/<name> directory on the disk image
#   SUPPORTFILES  = <file list>      game data files to copy

SIERRA_EXES  = sierra mnln scrn shdw tocgen
CMDS_EXTRA  += $(SIERRA_EXES)
AFLAGS_EXTRA += -I$(3RDPARTY)/packages/sierra/$(GAME_SUBDIR)

BOOTMODS_EXTRA += vrn vi
PADUP = ../l2/padup256 bootfile
STARTUP = sierra.startup

include ../wildbits.mak

# Sierra games need only a minimal command set on disk.
# utilpak1 (loaded at startup) provides dir, mfree, procs, etc.
CMDS = shellplus utilpak1 bootos9 dir mdir mfree copy load link $(SIERRA_EXES)

vpath %.asm $(3RDPARTY)/packages/sierra/objs_wb
vpath %.asm $(3RDPARTY)/packages/sierra/$(OBJS_SUBDIR)

$(addprefix $(MODDIR)/,$(SIERRA_EXES)): $(MODDIR)/%: %.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

sierra.startup: FORCE
	printf "link shell\niniz wz\nchd GAMES/$(GAME_DIR_NAME)\nsierra\n" > $@

.PHONY: game-data
game-data: $(DSKIMAGE)
	-$(MAKDIR) $(DSKIMAGE),GAMES
	-$(MAKDIR) $(DSKIMAGE),GAMES/$(GAME_DIR_NAME)
	$(OS9COPY) $(addprefix $(3RDPARTY)/packages/sierra/$(GAME_SUBDIR)/,$(SUPPORTFILES)) \
		$(DSKIMAGE),GAMES/$(GAME_DIR_NAME)

all: game-data
