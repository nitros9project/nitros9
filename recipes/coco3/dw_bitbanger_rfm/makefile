LEVEL = 2
include ../coco3.mak
include ../rfm-common.mak

serve: prepare
	@test -n "$(SERIAL_PORT)" || { echo "Set SERIAL_PORT to the CoCo adapter path"; exit 1; }
	"$(DRIVEWIRE_SERVER)" --serial-port "$(SERIAL_PORT)" --baud $(BAUD) --disk0 "$(CURDIR)/$(BOOTSTRAP)" --rfm-root "$(CURDIR)"

MAME_BINARY ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS ?= -window -skip_gameinfo
DW_PORT ?= 65400

# For an emulator TCP-to-bitbanger setup, start its matching server separately.
run: prepare
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -bitbanger socket.127.0.0.1:$(DW_PORT)

.PHONY: serve run
