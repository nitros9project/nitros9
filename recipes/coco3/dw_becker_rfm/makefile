LEVEL = 2
include ../coco3.mak
include ../rfm-common.mak

DW_PORT ?= 65504
DW_BIND ?= 127.0.0.1
MAME_BINARY ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS ?= -window -skip_gameinfo -autoboot_delay 3 -autoboot_command "DOS\n"
MAME_ROMPATH ?= $(HOME)/.local/share/mame/roms
HDBDOS_ROM ?= $(NITROS9DIR)/../toolshed/hdbdos/hdbdw3bc3.rom

$(MODDIR)/boot_rfm_becker: boot_rfm.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DBECKER=1

$(MODDIR)/dwio_becker.sb: dwio.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DBECKER=1

serve: prepare
	"$(DRIVEWIRE_SERVER)" --bind "$(DW_BIND)" --tcp-port $(DW_PORT) --disk0 "$(CURDIR)/$(BOOTSTRAP)" --rfm-root "$(CURDIR)"

coco3.zip: $(HDBDOS_ROM)
	mkdir -p .rom
	unzip -p "$(MAME_ROMPATH)/coco3.zip" coco3.rom > .rom/coco3.rom
	cp "$<" .rom/disk11.rom
	zip -j $@ .rom/coco3.rom .rom/disk11.rom

# Start the server separately with make serve. Enable the Becker port in MAME.
run: prepare coco3.zip
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -rompath "$(CURDIR);$(MAME_ROMPATH)"

.PHONY: serve run
