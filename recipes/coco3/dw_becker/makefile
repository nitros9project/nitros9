DWDOS_BIN    = /Users/boisy/Projects/coco-shelf/toolshed/dwdos/dw3dosbck.bin
DECB         = decb
MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -skip_gameinfo -ext fdc -ext:fdc:wd17xx:0 525qd
DSKIMAGE     = dwdos_becker.dsk
DW_PORT      ?= 65504

all: $(DSKIMAGE)

$(DSKIMAGE): $(DWDOS_BIN)
	$(DECB) dskini $@
	$(DECB) copy $< $@,DWDOS.BIN

run: $(DSKIMAGE)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)

clean:
	$(RM) $(DSKIMAGE)

.PHONY: all run clean
