DWDOS_SRC    = /Users/boisy/Projects/coco-shelf/toolshed/dwdos/dw3dos.asm
DWDOS_BIN    = dw3dosbck_cc3.bin
DWDOS_CAS    = dw3dosbck_cc3.cas
DECB         = decb
MAKEWAV      = makewav
MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -window -skip_gameinfo
DW_PORT      ?= 65504

all: $(DWDOS_CAS)

$(DWDOS_BIN): $(DWDOS_SRC)
	lwasm.orig --format=decb --no-warn=ifp1 --pragma=condundefzero \
		-o$@ $< -DCoCo=3 -DBIN=1 -DBECKER=1

$(DWDOS_CAS): $(DWDOS_BIN)
	$(MAKEWAV) -r -c -k -2 -n DWDOS -o$@ $<

# Load via cassette — no -ext fdc so $FF41-$FF42 (Becker port) is uncontested
# At BASIC prompt: CLOADM:EXEC
run: $(DWDOS_CAS)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -beckerport 1 -cass $(DWDOS_CAS)

clean:
	$(RM) $(DWDOS_BIN) $(DWDOS_CAS)

.PHONY: all run clean
