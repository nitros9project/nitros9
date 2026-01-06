include ../../port.mak

vpath %.as $(LEVEL1)/f256/sys/backgrounds
vpath %.asm $(LEVEL1)/f256/sys/backgrounds

AFLAGS		+= -I$(LEVEL1)/$(PORT)
AFLAGS		+= -I$(LEVEL1)/$(PORT)/sys/backgrounds

DEPENDS		= ./makefile

BACKGROUNDS	= clutbeach clutgrid clutmeadow clutmetal clutspace clutstone clutstone2 clutwood \
	          pixmapbeach pixmapgrid pixmapmeadow pixmapmetal pixmapspace pixmapstone \
	          pixmapstone2 pixmapwood pixmappaintspl pixmappaint2 clutpaintspl clutpaint2 \
              pixmapwizfi pixmapwizfi2 clutwizfi clutwizfi2


ALLOBJS		= $(BACKGROUNDS)

all:	$(ALLOBJS)


clean:
	$(RM) $(ALLOBJS) *.o *.list *.map

showobjs:
	@$(ECHO) $(ALLOBJS)

identify:
	$(IDENT_SHORT) $(ALLOBJS)

