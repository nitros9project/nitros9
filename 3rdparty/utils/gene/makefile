# OS-9 Commands/Utilities

include ../../../rules.mak

AFLAGS = -DLevel=1

DEPENDS		= ./makefile

CMDS		= bootlink vfy

ALLOBJS		= $(CMDS)

DSKGENEUTILS	= Gene_Utils.dsk

DSKS		= $(DSKGENEUTILS)

all:	banner $(ALLOBJS) $(DEPENDS)	

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*             Gene Heskett's Utilities           *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

$(DSKGENEUTILS): $(CMDS)
	$(RM) $@
	$(OS9FORMAT) -q $@ -n"Gene's utilities"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))

dsk: all $(DSKS)

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

clean: dskclean
	$(RM) $(ALLOBJS) *.list *.map

info:
	@$(ECHO) "*** Gene Heskett's Utilities ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)

