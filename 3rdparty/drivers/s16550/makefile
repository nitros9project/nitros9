include ../../../rules.mak

DEPENDS		= ./makefile

DRIVERS		= s16550_large.dr
DESCS		= t2_s16550.dd
ALLOBJS		= $(DRIVERS) $(DESCS)

all:	$(ALLOBJS) $(DEPENDS)

clean:
	$(RM) $(ALLOBJS) *.list *.map

dsk:
dskcopy:
dskclean:

