include ../../../rules.mak

DEPENDS		= ./makefile

CMDS		= snake sdir sdrive

ALLOBJS		= $(CMDS)

DSKTLU		= TLindner_Utils.dsk

DSKS		= $(DSKTLU)

all:	banner $(ALLOBJS) $(DEPENDS)	

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*               tlindner utilities               *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

$(DSKTLU): $(CMDS)
	$(RM) $@
	$(OS9FORMAT) -q $@ -n"tlindner utilities"
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
	@$(ECHO) "*** tlindner utilities ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)


