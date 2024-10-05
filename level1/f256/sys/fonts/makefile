include ../../port.mak

vpath %.as $(LEVEL1)/f256/sys/fonts
vpath %.asm $(LEVEL1)/f256/sys/fonts

AFLAGS		+= -I$(LEVEL1)/$(PORT)
AFLAGS		+= -I$(LEVEL1)/$(PORT)/sys/fonts

DEPENDS		= ./makefile

FONTS	= 800yfont.sb applefont.sb BigBluefont.sb boxedfont.sb bannerfont.sb \
	  c256seriffont.sb cbmfont.sb commodedorfont.sb enemigafont.sb f256standardfont.sb \
	  IIishfont.sb jessefont.sb msxbannerfont.sb msxfont.sb petticoatsfont.sb \
	  phoenixegafont.sb quadrotextfont.sb techfont.sb thickefont.sb

ALLOBJS		= $(FONTS)

all:	$(ALLOBJS)


clean:
	$(RM) $(ALLOBJS) *.o *.list *.map

showobjs:
	@$(ECHO) $(ALLOBJS)

identify:
	$(IDENT_SHORT) $(ALLOBJS)

