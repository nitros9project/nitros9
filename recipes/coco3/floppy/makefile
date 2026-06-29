LEVEL = 2
MINIMAL ?= 0
KEYRPT ?=
CLEAN_EXTRA += startup.keyrpt startup.minimal

ifeq ($(MINIMAL),1)
RECIPE ?= coco3_minimal
RBF = rbf.mn rb1773.dr ddd0_$(TRACKS)d.dd
SCF ?= scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) \
	$(TERM_WIN_DT)
PIPE =
CMDS_BASE = shell grfdrv
SYSDIR =
PORTDEFSDIR =
STARTUP = startup.minimal
ifneq ($(KEYRPT),)
CMDS_BASE += keyrpt
endif
endif

BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA)
DSK_EXTRA_DEPS = $(MODDIR)/sysgo_dd
DSK_POST_COPY = $(MAKE) copy-sysgo-root DSKIMAGE=$@
ifeq ($(MINIMAL),0)
BASIC09_CMDS = basic09 gfx gfx2 inkey runb syscall
CMDS_EXTRA += $(BASIC09_CMDS)
endif

ifneq ($(KEYRPT),)
ifeq ($(MINIMAL),0)
STARTUP = startup.keyrpt
endif
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

.PHONY: copy-sysgo-root run startup.minimal

ifneq ($(KEYRPT),)
KEYRPT_ARGS = $(if $(filter 0,$(KEYRPT)),0 0,$(KEYRPT))
ifeq ($(MINIMAL),0)
startup.keyrpt: $(NITROS9DIR)/level2/$(PORT)/startup
	{ echo "keyrpt $(KEYRPT_ARGS)</1"; cat $<; } >$@
endif
endif

startup.minimal:
	echo "link shell" > $@
ifneq ($(KEYRPT),)
	echo "keyrpt $(KEYRPT_ARGS)</1" >> $@
endif

$(MODDIR)/basic09: basic09.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@
