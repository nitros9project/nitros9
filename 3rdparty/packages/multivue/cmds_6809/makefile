include ../../../../rules.mak

DEPENDS		= ./makefile

OSCMDS		= $(LEVEL2)/coco3/cmds/shell $(LEVEL2)/coco3/cmds/utilpak1 \
		$(LEVEL2)/coco3/cmds/grfdrv $(LEVEL2)/coco3/cmds/backup \
		$(LEVEL2)/coco3/cmds/format $(LEVEL2)/coco3/cmds/free $(LEVEL2)/coco3/cmds/help
CMDS		= gshell cocopr control demo fstat \
		gcal gcalc gclock gport gprint gsort

ALLOBJS		= $(OSCMDS) $(CMDS)

all:	cmds $(ALLOBJS)

cmds:
	$(CD) $(LEVEL2)/coco3/cmds; make

gshell: gshell.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

clean:
	$(RM) $(CMDS) *.list *.map

showobjs:
	@$(ECHO) $(ALLOBJS)

identify:
	$(IDENT_SHORT) $(ALLOBJS)
