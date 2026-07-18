include ../../port.mak

vpath %.as $(LEVEL1)/wildbits/sys/fonts
vpath %.asm $(LEVEL1)/wildbits/sys/fonts

AFLAGS		+= -I$(LEVEL1)/$(PORT)
AFLAGS		+= -I$(LEVEL1)/$(PORT)/sys/fonts

FONTS	= 800yfont anglefont applefont bannerfont.sb bigbluefont boldfont boxedfont  \
	  c256seriffont cbmfont commodedorfont comicfont emojifont enemigafont \
	  f256standardfont gothicfont IIishfont jessefont msxbannerfont msxfont petticoatsfont \
	  phoenixegafont.sb quadrotextfont retrofont singlefont techfont thickefont \
      uncialfont versalsfont

ALLOBJS		= $(FONTS)

all:	$(ALLOBJS)


clean:
	$(RM) $(ALLOBJS) *.o *.list *.map

showobjs:
	@$(ECHO) $(ALLOBJS)

identify:
	$(IDENT_SHORT) $(ALLOBJS)
