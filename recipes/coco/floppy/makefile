LEVEL = 1
MINIMAL ?= 0
KEYRPT ?=
CLEAN_EXTRA += startup.keyrpt startup.minimal

ifeq ($(MINIMAL),1)
RECIPE ?= coco_minimal
RBF = rbf rb1773 ddd0_$(TRACKS)d
PIPE =
CMDS_BASE = shell_21
STARTUP = startup.minimal
ifneq ($(KEYRPT),)
CMDS_BASE += keyrpt
endif
endif

ifneq ($(KEYRPT),)
ifeq ($(MINIMAL),0)
STARTUP = startup.keyrpt
endif
endif

include ../coco.mak

MAME_BINARY  ?= mame
MAME_MACHINE ?= coco2b
MAME_FLAGS   ?= -rompath $(MAME_ROM_PATH) -window -nothrottle -skip_gameinfo -autoboot_delay 5 -autoboot_command "DOS\n" -ext fdc -ext:fdc:wd17xx:0 525qd

run: $(DSKIMAGE)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)

.PHONY: run startup.minimal

ifneq ($(KEYRPT),)
KEYRPT_ARGS = $(if $(filter 0,$(KEYRPT)),0 0,$(KEYRPT))
ifeq ($(MINIMAL),0)
startup.keyrpt: $(NITROS9DIR)/level1/$(PORT)/startup
	{ echo "keyrpt $(KEYRPT_ARGS)</1"; cat $<; } >$@
endif
endif

startup.minimal:
	: > $@
ifneq ($(KEYRPT),)
	echo "keyrpt $(KEYRPT_ARGS)</1" >> $@
endif
