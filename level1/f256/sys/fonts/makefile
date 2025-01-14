include ../../port.mak

vpath %.as $(LEVEL1)/f256/sys/fonts
vpath %.asm $(LEVEL1)/f256/sys/fonts

AFLAGS		+= -I$(LEVEL1)/$(PORT)
AFLAGS		+= -I$(LEVEL1)/$(PORT)/sys/fonts

DEPENDS		= ./makefile

FONTS	= 800yfont applefont bigbluefont boxedfont bannerfont.sb \
	  c256seriffont cbmfont commodedorfont enemigafont f256standardfont \
	  IIishfont jessefont msxbannerfont msxfont petticoatsfont \
	  phoenixegafont.sb quadrotextfont techfont thickefont

ALLOBJS		= $(FONTS)

all:	$(ALLOBJS)


clean:
	$(RM) $(ALLOBJS) *.o *.list *.map

showobjs:
	@$(ECHO) $(ALLOBJS)

identify:
	$(IDENT_SHORT) $(ALLOBJS)

