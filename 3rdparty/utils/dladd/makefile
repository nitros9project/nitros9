include ../../../rules.mak

DEPENDS		:= ./makefile

CMDS		= cls fast slow

ALLOBJS		= $(CMDS)

DSKDLADDUTILS	= DLadd_Utils.dsk

DSKS		= $(DSKDLADDUTILS)

all:	banner $(ALLOBJS) $(DEPENDS)	

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*              David Ladd's Utilities            *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

$(DSKDLADDUTILS): $(CMDS)
	$(RM) $@
	$(OS9FORMAT) -q $@ -n"David's utilities"
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
	@$(ECHO) "*** David Ladd's Utilities ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)


