include $(NITROS9DIR)/rules.mak

DSK	= BrainFuck.dsk

# NitrOS-9
H6309		= $(AFLAGS) -DH6309=1
# Non-NitrOS-9
M6809		= $(AFLAGS)

DEPENDS		= ./makefile

#SOURCEFILES = inout.bf helloworld.bf donothing.bf
SOURCEFILES = $(shell echo *.bf)
TEXTFILES	= ReadMe $(SOURCEFILES)
OBJS		= bfp
ALLOBJS		= $(OBJS)

all:	banner $(ALLOBJS) $(DEPENDS)

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                    Brainfuck                   *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

bfp: bfp.asm
	$(AS) $(ASOUT)$@ $< $(H6309)

clean: dskclean
	$(RM) $(ALLOBJS)

dsk: $(DSK)

$(DSK): all
	$(RM) $@
	$(OS9FORMAT_SS35) $@ -n"brainfuck"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(ALLOBJS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(ALLOBJS),$@,CMDS/$(file))
	$(CPL) $(TEXTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(TEXTFILES),$@,$(file))

dskcopy: $(DSK)
	$(CP) $(DSK) $(DSKDIR)

dskclean:
	$(RM) $(DSK)

# Only $(CMDS) are shown here
showobjs:
	@$(ECHO) bfp

# Only $(CMDS) are shown here
showfiles:
	@$(ECHO) $(SOURCEFILES)

info:
	@$(ECHO) "*** brainfuck ***"
	@$(ECHO) $(DSK)
