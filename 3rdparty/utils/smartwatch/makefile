include ../../../rules.mak

DEPENDS		= ./makefile

CMDS		= getclk swread swset

ALLOBJS		= $(CMDS)

DSKSMARTWATCH	= SmartWatch.dsk

DSKS		= $(DSKSMARTWATCH)

all:	banner $(ALLOBJS) $(DEPENDS)	

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*               SmartWatch Utilities             *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

$(DSKSMARTWATCH): $(CMDS)
	$(RM) $@
	$(OS9FORMAT) -q $@ -n"SmartWatch utilities"
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
	@$(ECHO) "*** SmartWatch Utilities ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)


