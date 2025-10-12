include ../../../../rules.mak

vpath %.asm	$(LEVEL2)/sys

AFLAGS      += -I.

DEPENDS		= ./makefile

SYSFILES	= env.file
HELPFILES	= cocopr.hp control.hp gcal.hp gcalc.hp gclock.hp gport.hp \
		gprint.hp gshell.hp
ASSETFILES	= stdfonts stdpats_2 stdpats_4 stdpats_16 stdptrs \
		ibmedcfont isolatin1font

HELPMSG		= helpmsg

TEXTFILES	= $(SYSFILES) $(HELPMSG)
ALLOBJS		= $(ASSETFILES) $(TEXTFILES)

all:	$(ALLOBJS) $(DEPENDS)

$(HELPMSG): $(HELPFILES)
	$(MERGE) $(HELPFILES) > $@

clean:
	$(RM) $(HELPMSG) $(ASSETFILES) *.list *.map

showbinobjs:
	@$(ECHO) $(ASSETFILES)

showtextobjs:
	@$(ECHO) $(TEXTFILES)

showobjs:
	@$(ECHO) $(ALLOBJS)
