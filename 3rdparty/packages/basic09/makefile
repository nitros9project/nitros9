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
SHAREDSRC	= basic09_stmtexec.asm basic09_rlcmp.asm basic09_floatfix.asm basic09_scalar.asm basic09_sqrt.asm basic09_miscfunc.asm basic09_logexp.asm basic09_compare.asm basic09_strops.asm basic09_trig.asm basic09_rnd.asm basic09_strfns.asm basic09_datefunc.asm basic09_iofunc.asm
VERIFYRUNBSRC	= verify-runb-source.pl
VERIFYDIR	= .verify
BASIC09_6809_SHA256 = abfa8300da434d52aadd530427075a7c89e54eeeeb204282c44252ba540d4904
BASIC09_6309_SHA256 = 8fb7c502e350b23c4021be31d0657226b6974b1b779c87997b753457616c641b
RUNB_6809_SHA256 = f285c562d2925d96383a399ec84630aa6905de3b16c728c0ac6edc56f70e552d
RUNB_6309_SHA256 = 985dfe7ca6016ac347d251f36d76fbf079b715820c72c08051f548799dfb9110

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

runb_6309: runb.asm $(RUNBCORE) $(SHAREDSRC)
	$(AS) $(ASOUT)$@ $< $(H6309)

runb_6809: runb.asm $(RUNBCORE) $(SHAREDSRC)
	$(AS) $(ASOUT)$@ $< $(M6809)

runbt_6809: runb.asm $(RUNBCORE) $(SHAREDSRC)
	$(AS) $(ASOUT)$@ $< $(M6809)

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

verify-basic09-runb-source: basic09.asm $(RUNBCORE) $(SHAREDSRC) $(VERIFYRUNBSRC)
	perl $(VERIFYRUNBSRC) basic09.asm
	perl $(VERIFYRUNBSRC) $(RUNBCORE)

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
