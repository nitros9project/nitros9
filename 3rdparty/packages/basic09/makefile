include $(NITROS9DIR)/rules.mak

DSK	= Basic09_v010100.dsk

# NitrOS-9
H6309		= $(AFLAGS) -DH6309=1
# Non-NitrOS-9
M6809		= $(AFLAGS)

DEFOPTS         = --preprocess -DLevel=2
DEPENDS		= ./makefile

DEFOBJS		= coco3vtio.d
TEXTFILES	= ReadMe2 install6809 install6309
OBJS		= gfx gfx2 inkey syscall
OBJS6809	= basic09_6809 runb_6809
OBJS6309	= basic09_6309 runb_6309
ALLOBJS		= $(DEFOBJS) $(OBJS) $(OBJS6809) $(OBJS6309)
MODULAROBJS	= basic09_mod_6809 runb_mod_6809
MODULARSRC	= modular/comand.asm modular/compil.asm modular/binder.asm \
		  modular/stmts.asm modular/exprsn.asm modular/cnvio.asm \
		  modular/defs modular/b09defs modular/b09type modular/jmpdefs \
		  modular/linkage modular/editor

all:	banner $(ALLOBJS) $(DEPENDS)

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                     Basic09                    *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

coco3vtio.d: $(DEFSDIR)/cocovtio.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DCOCOVTIO.D=0 $< > $@

gfx2: gfx2.asm coco3vtio.d
	$(AS) $(ASOUT)$@ $< $(M6809) -DLevel=2

basic09_6309: basic09.asm
	$(AS) $(ASOUT)$@ $< $(H6309)

basic09_6809: basic09.asm
	$(AS) $(ASOUT)$@ $< $(M6809)

runb_6309: basic09.asm
	$(AS) $(ASOUT)$@ $< $(H6309) -DINCLUDED="RUNTIM+MATHPAK"

runb_6809: basic09.asm
	$(AS) $(ASOUT)$@ $< $(M6809) -DINCLUDED="RUNTIM+MATHPAK"

runbt_6809: basic09.asm
	$(AS) $(ASOUT)$@ $< $(M6809) -aRUNTIME=1

basic09_mod_6809: build-modular-basic09.pl $(MODULARSRC)
	perl build-modular-basic09.pl basic09 $@

runb_mod_6809: build-modular-basic09.pl $(MODULARSRC)
	perl build-modular-basic09.pl runb $@

clean: dskclean
	$(RM) $(ALLOBJS) $(MODULAROBJS) *.list *.map
	$(RM) -r .modular-build

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
