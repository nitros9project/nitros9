LEVEL = 2
BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA)
DSK_EXTRA_DEPS = $(MODDIR)/sysgo_dd
DSK_POST_COPY = $(MAKE) copy-sysgo-root DSKIMAGE=$@

include ../coco3.mak

MAME         ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -nothrottle -skip_gameinfo -autoboot_delay 5 -autoboot_command "DOS\n" -ext fdc -ext:fdc:wd17xx:0 525qd

run: $(DSKIMAGE)
	$(MAME) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)

copy-sysgo-root:
	$(OS9COPY) $(MODDIR)/sysgo_dd $(DSKIMAGE),sysgo
	$(OS9ATTR_EXEC) $(DSKIMAGE),sysgo

.PHONY: copy-sysgo-root run

MAME ?= 0
ifeq ($(MAME),1)
STARTUP = startup.mame
endif
include ../coco3.mak

ifeq ($(MAME),1)
startup.mame: $(NITROS9DIR)/level2/$(PORT)/startup
	{ echo "keyrpt 0 0"; cat $<; } >$@
endif
