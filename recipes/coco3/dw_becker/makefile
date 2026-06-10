DWDOS_SRC    = /Users/boisy/Projects/coco-shelf/toolshed/dwdos/dw3dos.asm
DWDOS_BIN    = dw3dosbck_cc3.bin
DECB         = decb
MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -skip_gameinfo -ext fdc -ext:fdc:wd17xx:0 525qd
DSKIMAGE     = dwdos_becker.dsk
DW_PORT      ?= 65504

all: $(DSKIMAGE)

$(DWDOS_BIN): $(DWDOS_SRC)
	lwasm.orig --format=decb --no-warn=ifp1 --pragma=condundefzero \
		-o$@ $< -DCoCo=3 -DBIN=1 -DBECKER=1

$(DSKIMAGE): $(DWDOS_BIN)
	$(DECB) dskini $@
	$(DECB) copy -2 -b $< $@,DWDOS.BIN

run: $(DSKIMAGE)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)

clean:
	$(RM) $(DSKIMAGE) $(DWDOS_BIN)

.PHONY: all run clean
