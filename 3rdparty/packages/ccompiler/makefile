include ../../../rules.mak

DSK		= CCompiler.dsk
CMDS		= cc1 c.prep c.pass1 c.pass2 c.opt c.asm c.link make

ALLOBJS		= $(CMDS)

# Make all components
all:	banner $(ALLOBJS)

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                    C Compiler                  *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

# Clean all components
clean:	dskclean
	$(RM) $(ALLOBJS) *.list *.map

dsk: $(DSK)

$(DSK): all
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n"C Compiler"
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,LIB
	$(MAKDIR) $@,DEFS
	$(MAKDIR) $@,SOURCES
	$(MAKDIR) $@,SOURCES/SYS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CPL) defs/*.h $@,DEFS
	$(OS9COPY) lib/*.l lib/*.r $@,LIB
	$(CPL) sources/*.c $@,SOURCES
	$(CPL) sources/*.a $@,SOURCES/SYS

dskcopy: $(DSK)
	$(CP) $(DSK) $(DSKDIR)

dskclean:
	$(RM) $(DSK)

info:
	@$(ECHO) "*** Microware C Compiler ***"
	@$(ECHO) $(DSK)
