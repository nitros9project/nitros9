include ../../../rules.mak

DEPENDS		= ./makefile

CMDS		= xcom9

ALLOBJS		= $(CMDS)

DSK     	= xcom9.dsk

DSKS		= $(DSK)

all:	banner $(ALLOBJS) $(DEPENDS)	

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                      Xcom9                     *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

$(DSKSUPERCOMM): $(CMDS)
	$(RM) $@
	$(OS9FORMAT) -q $@ -n"Xcom9"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))

dsk: all $(DSKS)

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

clean: dskclean
	$(RM) $(ALLOBJS) *.map *.list

info:
	@$(ECHO) "*** Xcom9 ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)


