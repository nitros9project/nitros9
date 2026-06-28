LEVEL = 2
BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA)
DSK_EXTRA_DEPS = $(MODDIR)/sysgo_dd
DSK_POST_COPY = $(MAKE) copy-sysgo-root DSKIMAGE=$@
BASIC09_CMDS = basic09 gfx gfx2 inkey runb syscall
CMDS_EXTRA += $(BASIC09_CMDS)

KEYRPT ?=
ifneq ($(KEYRPT),)
STARTUP = startup.keyrpt
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

.PHONY: copy-sysgo-root run

ifneq ($(KEYRPT),)
KEYRPT_ARGS = $(if $(filter 0,$(KEYRPT)),0 0,$(KEYRPT))
startup.keyrpt: $(NITROS9DIR)/level2/$(PORT)/startup
	{ echo "keyrpt $(KEYRPT_ARGS)</1"; cat $<; } >$@
endif

$(MODDIR)/basic09: basic09.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@
