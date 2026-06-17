LEVEL = 2
RECIPE ?= coco3_minimal
RBF = rbf.mn rb1773.dr ddd0_40d.dd
SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) \
	$(TERM_WIN_DT)
BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA)
DSK_EXTRA_DEPS = $(MODDIR)/sysgo_dd
DSK_POST_COPY = $(MAKE) copy-sysgo-root DSKIMAGE=$@
CMDS_BASE = shell grfdrv
STARTUP = startup
SYSDIR =
PORTDEFSDIR =

MAME ?= 0
ifeq ($(MAME),1)
CMDS_BASE += keyrpt
endif

include ../coco3.mak

MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -rompath $(MAME_ROM_PATH) -window -nothrottle -skip_gameinfo -autoboot_delay 5 -autoboot_command "DOS\n" -ext fdc -ext:fdc:wd17xx:0 525qd

run: $(DSKIMAGE)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)

copy-sysgo-root:
	$(OS9COPY) $(MODDIR)/sysgo_dd $(DSKIMAGE),sysgo
	$(OS9ATTR_EXEC) $(DSKIMAGE),sysgo

.PHONY: copy-sysgo-root run $(STARTUP)

$(STARTUP):
	echo "link shell" > $@
ifeq ($(MAME),1)
	echo "keyrpt 0 0</1" >> $@
endif	
