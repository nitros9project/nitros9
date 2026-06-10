DWDOS_BIN    = /Users/boisy/Projects/coco-shelf/toolshed/dwdos/dw3dosbck.bin
DECB         = decb
MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -skip_gameinfo -ext fdc -ext:fdc:wd17xx:0 525qd
DSKIMAGE     = dwdos_becker.dsk
# MAME's dwsock (Virtual Becker Port) always connects to 127.0.0.1:65504
DW_PORT      = 65504
DW_SERVER    ?= drivewire-cli
DW_DISK      ?=

all: $(DSKIMAGE)

$(DSKIMAGE): $(DWDOS_BIN)
	$(DECB) dskini $@
	$(DECB) copy -2 -b $< $@,DWDOS.BIN

# Start the DriveWire server in the background (set DW_DISK= to a disk image)
server:
	$(DW_SERVER) --tcp-port $(DW_PORT) $(if $(DW_DISK),--disk0 $(DW_DISK),) --verbose

# Server must be running on port $(DW_PORT) before invoking run
run: $(DSKIMAGE)
	@nc -z 127.0.0.1 $(DW_PORT) 2>/dev/null || \
		(echo "ERROR: DriveWire server not running on port $(DW_PORT). Start it first with: make server DW_DISK=<path>" && exit 1)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)

clean:
	$(RM) $(DSKIMAGE)

.PHONY: all run clean server
