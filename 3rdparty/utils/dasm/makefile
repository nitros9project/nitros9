include ../../../rules.mak

DEPENDS		= ./makefile

CMDS		= dasm

ALLOBJS		= $(CMDS)

DSKDASM		= DAsm.dsk

DSKS		= $(DSKDASM)

all:	banner $(ALLOBJS) $(DEPENDS)	

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*              Collyer Disassembler              *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

$(DSKDASM): $(CMDS)
	$(RM) $@
	$(OS9FORMAT) -q $@ -n"Collyer Disassembler"
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
	@$(ECHO) "*** Collyer Disassembler ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)


