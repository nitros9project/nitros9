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
RUNBCORE	= runb_core.asm
SHAREDSRC	= basic09_rlcmp.asm basic09_floatfix.asm basic09_scalar.asm basic09_sqrt.asm basic09_miscfunc.asm basic09_logexp.asm basic09_compare.asm basic09_strops.asm basic09_trig.asm basic09_rnd.asm basic09_strfns.asm basic09_datefunc.asm
VERIFYRUNBSRC	= verify-runb-source.pl
VERIFYDIR	= .verify
BASIC09_6809_SHA256 = fbb7f72db7f5b861904e9fadeb24dd07bb9709de7467d178d80ec0ccac77796e
BASIC09_6309_SHA256 = ac3d30fe910c26fcee780f8a661a881103f6ee6f26321f1b8b8e09b1131d92b8
RUNB_6809_SHA256 = 605c7a9f0fde3fed21f7672f5c634f7c43b440f385f088e593f8acca5fccba31
RUNB_6309_SHA256 = 6c2de659b30b5dec8c9152a0d747c814d8a745211781db16aa7d2e60aa2d899e

.PHONY: all banner verify-basic09-runb verify-basic09-runb-source clean dsk dskcopy dskclean showobjs info

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

basic09_6309: basic09.asm $(RUNBCORE) $(SHAREDSRC)
	$(AS) $(ASOUT)$@ $< $(H6309)

basic09_6809: basic09.asm $(RUNBCORE) $(SHAREDSRC)
	$(AS) $(ASOUT)$@ $< $(M6809)

runb_6309: basic09.asm $(RUNBCORE) $(SHAREDSRC)
	$(AS) $(ASOUT)$@ $< $(H6309) -DINCLUDED="RUNTIM+MATHPAK"

runb_6809: basic09.asm $(RUNBCORE) $(SHAREDSRC)
	$(AS) $(ASOUT)$@ $< $(M6809) -DINCLUDED="RUNTIM+MATHPAK"

runbt_6809: basic09.asm $(RUNBCORE) $(SHAREDSRC)
	$(AS) $(ASOUT)$@ $< $(M6809) -DINCLUDED="RUNTIM+MATHPAK"

basic09_mod_6809: build-modular-basic09.pl $(MODULARSRC)
	perl build-modular-basic09.pl basic09 $@

runb_mod_6809: build-modular-basic09.pl $(MODULARSRC)
	perl build-modular-basic09.pl runb $@

verify-basic09-runb: verify-basic09-runb-source basic09_6809 runb_6809 basic09_6309 runb_6309
	@printf '%s  %s\n' "$(BASIC09_6809_SHA256)" basic09_6809 | shasum -a 256 -c -
	@printf '%s  %s\n' "$(BASIC09_6309_SHA256)" basic09_6309 | shasum -a 256 -c -
	@printf '%s  %s\n' "$(RUNB_6809_SHA256)" runb_6809 | shasum -a 256 -c -
	@printf '%s  %s\n' "$(RUNB_6309_SHA256)" runb_6309 | shasum -a 256 -c -
	@echo "basic09_6809/basic09_6309 and runb_6809/runb_6309 match known-good references"

verify-basic09-runb-source: basic09.asm $(SHAREDSRC) $(VERIFYRUNBSRC)
	perl $(VERIFYRUNBSRC) basic09.asm

clean: dskclean
	$(RM) $(ALLOBJS) $(MODULAROBJS) runbt_6809 *.list *.map
	$(RM) -r .modular-build $(VERIFYDIR)

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
