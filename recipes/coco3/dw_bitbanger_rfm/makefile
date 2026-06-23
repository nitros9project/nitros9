LEVEL = 2

include ../coco3.mak

MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -skip_gameinfo
DW_PORT      ?= 65400

copy-sysgo-root:
	$(OS9COPY) $(MODDIR)/sysgo_dd $(DSKIMAGE),sysgo
	$(OS9ATTR_EXEC) $(DSKIMAGE),sysgo

$(MODDIR)/y0: rfmdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDNum=0

$(MODDIR)/boot_rfm: boot_rfm.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

run: $(DSKIMAGE)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) \
		-bitbanger socket.127.0.0.1:$(DW_PORT)

.PHONY: copy-sysgo-root run
