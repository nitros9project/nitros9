include ../../port.mak

vpath %.as $(LEVEL1)/wildbits/sys/backgrounds
vpath %.asm $(LEVEL1)/wildbits/sys/backgrounds

AFLAGS		+= -I$(LEVEL1)/$(PORT)
AFLAGS		+= -I$(LEVEL1)/$(PORT)/sys/backgrounds

DEPENDS		= ./makefile

BACKGROUNDS	= clutbeach clutgrid clutmeadow clutmetal clutspace clutstone clutstone2 clutwood \
	          pixmapbeach pixmapgrid pixmapmeadow pixmapmetal pixmapspace pixmapstone \
	          pixmapstone2 pixmapwood pixmappaintspl pixmappaint2 clutpaintspl clutpaint2 \
              pixmapwizfi pixmapwizfi2 clutwizfi clutwizfi2 testclutbm0 testclutbm1 testclutbm2 \
              testpixmapbm0 testpixmapbm1 testpixmapbm2

ALLOBJS		= $(BACKGROUNDS)

all:	$(ALLOBJS)


clean:
	$(RM) $(ALLOBJS) *.o *.list *.map

showobjs:
	@$(ECHO) $(ALLOBJS)

identify:
	$(IDENT_SHORT) $(ALLOBJS)

