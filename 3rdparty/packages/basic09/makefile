include $(NITROS9DIR)/rules.mak

DSK	= Basic09_v010100.dsk

# NitrOS-9
H6309		= $(AFLAGS) -DH6309=1
# Non-NitrOS-9
M6809		= $(AFLAGS)

DEFOPTS         = --preprocess -DLevel=2
DEPENDS		= ./makefile

DEFOBJS		= coco3vtio.d
TEXTFILES	= ReadMe install6809 install6309
OBJS		= gfx gfx2 inkey syscall
OBJS6809	= basic09_6809 runb_6809
OBJS6309	= basic09_6309 runb_6309
ALLOBJS		= $(DEFOBJS) $(OBJS) $(OBJS6809) $(OBJS6309)

all:	banner $(ALLOBJS) $(DEPENDS)

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                     Basic09                    *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

coco3vtio.d: $(DEFSDIR)/cocovtio.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DCOCOVTIO.D=0 $< > $@

gfx2: gfx2.asm
	$(AS) $(ASOUT)$@ $< $(M6809) -DLevel=2

basic09_6309: basic09.asm
	$(AS) $(ASOUT)$@ $< $(H6309)

basic09_6809: basic09.asm
	$(AS) $(ASOUT)$@ $< $(M6809)

runb_6309: runb.asm
	$(AS) $(ASOUT)$@ $< $(H6309)

runb_6809: runb.asm
	$(AS) $(ASOUT)$@ $< $(M6809)

runbt_6809: basic09.asm
	$(AS) $(ASOUT)$@ $< $(M6809) -aRUNTIME=1

clean: dskclean
	$(RM) $(ALLOBJS)

dsk: $(DSK)

$(DSK): all
	$(RM) $@
	$(OS9FORMAT_SS35) $@ -n"Basic09"
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(ALLOBJS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(ALLOBJS),$@,CMDS/$(file))
	$(CPL) $(TEXTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(TEXTFILES),$@,$(file))

dskcopy: $(DSK)
	$(CP) $(DSK) $(DSKDIR)

dskclean:
	$(RM) $(DSK)

showobjs:
	@$(ECHO) $(ALLOBJS)
	
info:
	@$(ECHO) "*** Basic09 ***"
	@$(ECHO) $(DSK)
