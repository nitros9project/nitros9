LEVEL = 1
MAME ?= 0
ifeq ($(MAME),1)
STARTUP = startup.mame
endif
include ../coco.mak

<<<<<<< HEAD
MAME         ?= mame
MAME_MACHINE ?= coco
MAME_FLAGS   ?= -window -nothrottle -skip_gameinfo -autoboot_delay 5 -autoboot_command "DOS\n" -ext fdc -ext:fdc:wd17xx:0 525qd

run: $(DSKIMAGE)
	$(MAME) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)

.PHONY: run
=======
ifeq ($(MAME),1)
startup.mame: $(NITROS9DIR)/level1/$(PORT)/startup
	{ echo "keyrpt 0 0</1"; cat $<; } >$@
endif
>>>>>>> 92853301 (Add MAME startup repeat setting)
