include ../../../rules.mak

DEPENDS		= ./makefile

DSK           	= rogue.dsk

CMDS		= rogue

DSKS		= $(DSK)

SUPPORTFILES	= rogue.dat rogue.hlp rogue.scr rogue.chr

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:	dskclean
	$(RM) $(ALLOBJS)

dsk:	all $(DSKS)

$(DSK):
	$(RM) $@
	$(OS9FORMAT_SS80) -q $@ -n"Rogue"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/rogue rogue
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,$(file))

showfiles:
	@$(ECHO) $(SUPPORTFILES)
	
showobjs:
	@$(ECHO) $(ALLOBJS)
	
dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

info:
	@$(ECHO) "*** Rogue ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
