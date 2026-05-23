LEVEL = 1
include ../coco.mak

MAME         ?= mame
MAME_MACHINE ?= coco
MAME_FLAGS   ?= -window -nothrottle -skip_gameinfo -autoboot_delay 5 -autoboot_command "DOS\n" -ext fdc -ext:fdc:wd17xx:0 525qd

run: $(DSKIMAGE)
	$(MAME) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)

.PHONY: run
