# OS-9 Commands/Utilities
#

include ../../../rules.mak

DEPENDS		= ./makefile

CMDS		= del mode send timer bigbro font makdir \
		 tee joypoll

ALLOBJS		= $(CMDS)

DSKBOISYUTILS	= Boisy_Utils.dsk

DSKS		= $(DSKBOISYUTILS)

all:	banner $(ALLOBJS) $(DEPENDS)	

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*             Boisy Pitre's Utilities            *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

$(DSKBOISYUTILS): $(CMDS)
	$(RM) $@
	$(OS9FORMAT) -q $@ -n"Boisy's utilities"
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
	@$(ECHO) "*** Boisy Pitre's Utilities ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)

