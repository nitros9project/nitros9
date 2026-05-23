LEVEL = 2
RECIPE = coco3_rogue
ROGUE_DIR = $(3RDPARTY)/packages/rogue
ROGUE_FILES = rogue.dat rogue.hlp rogue.scr rogue.chr
CMDS_BASE =
CMDS_EXTRA += dir grfdrv list mdir mfree shell rogue
DSK_EXTRA_DEPS = $(addprefix $(ROGUE_DIR)/,$(ROGUE_FILES))
DSK_POST_COPY = $(MAKE) copy-rogue-files DSKIMAGE=$@
STARTUP = ./startup

include ../coco3.mak

vpath %.asm $(ROGUE_DIR)

MAME         ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -nothrottle -skip_gameinfo -autoboot_delay 5 -autoboot_command "DOS\n" -ext fdc -ext:fdc:wd17xx:0 525qd

run: $(DSKIMAGE)
	$(MAME) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)

copy-rogue-files:
	$(OS9COPY) $(MODDIR)/sysgo_dd $(DSKIMAGE),sysgo
	$(OS9ATTR_EXEC) $(DSKIMAGE),sysgo
	$(MAKDIR) $(DSKIMAGE),ROGUE
	$(OS9COPY) $(addprefix $(ROGUE_DIR)/,$(ROGUE_FILES)) $(DSKIMAGE),ROGUE
	$(OS9ATTR_TEXT) $(foreach file,$(ROGUE_FILES),$(DSKIMAGE),ROGUE/$(file))

.PHONY: copy-rogue-files run
