include ../../../rules.mak

DEPENDS		= ./makefile

DRIVERS		= sdisk.dr
DESCS		= ddd0_35s.dd d0_35s.dd ddd0_40d.dd d0_40d.dd ddd0_80d.dd d0_80d.dd \
		d1_35s.dd d1_40d.dd d1_80d.dd d2_35s.dd d2_40d.dd d2_80d.dd \
		d3_35s.dd
PROGRAMS	= bootfix
ALLOBJS		= $(DRIVERS) $(DESCS) $(PROGRAMS)

all:	$(ALLOBJS) $(DEPENDS)

clean:
	$(RM) $(ALLOBJS) *.list *.map

dsk:
dskcopy:
dskclean:

