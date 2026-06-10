LEVEL = 2
RECIPE = 40d_rfm_test
BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	dwio_rs232pak \
	rfm rfmdrv y0 \
	$(BOOTMODS_EXTRA)

DSK_EXTRA_DEPS = $(MODDIR)/sysgo_dd
DSK_POST_COPY = $(MAKE) copy-sysgo-root DSKIMAGE=$@
BASIC09_CMDS = basic09 gfx gfx2 inkey runb syscall
CMDS_EXTRA += $(BASIC09_CMDS)

MAME ?= 0
ifeq ($(MAME),1)
STARTUP = startup.mame
endif

include ../coco3.mak

MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -skip_gameinfo -autoboot_delay 5 -autoboot_command "DOS\n" -ext fdc -ext:fdc:wd17xx:0 525qd
DW_PORT      ?= 65400

run: $(DSKIMAGE)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE) -rs232 null_modem -bitbanger socket.127.0.0.1:$(DW_PORT)

copy-sysgo-root:
	$(OS9COPY) $(MODDIR)/sysgo_dd $(DSKIMAGE),sysgo
	$(OS9ATTR_EXEC) $(DSKIMAGE),sysgo

.PHONY: copy-sysgo-root run

ifeq ($(MAME),1)
startup.mame: $(NITROS9DIR)/level2/$(PORT)/startup
	{ echo "keyrpt 0 0</1"; cat $<; } >$@
endif

$(MODDIR)/basic09: basic09.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/dwio_rs232pak: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DSY6551N=1

$(MODDIR)/y0: rfmdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0
