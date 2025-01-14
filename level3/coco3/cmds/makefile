PORT = coco3
include $(NITROS9DIR)/rules.mak

vpath %.asm $(LEVEL3)/cmds:$(LEVEL2)/cmds:$(LEVEL1)/cmds:$(3RDPARTY)/packages/basic09

DEPENDS		= ./makefile
AFLAGS		+= --includedir=$(3RDPARTY)/packages/basic09
AFLAGS		+= --includedir=../defs

CMDS		= asm attr backup bawk binex build cmp cobbler copy cputype \
		date dcheck debug ded deiniz del deldir devs dir dirsort disasm \
		display dmem dmode dsave dump echo edit error exbin \
		format free grfdrv help ident iniz irqs link list load login \
		makdir mdir megaread merge mfree mmap modpatch montype more mpi os9gen padrom park \
		pmap proc procs prompt pwd pxd reboot rename save setime \
		shell_21 sleep smap sfree tee tmode touch tsmon tuneport unlink verify wcreate xmode

CMDS_D2		= basic09 runb gfx2 gfx inkey syscall copy del echo format \
			merge os9gen prompt tmode

SHELLMODS	= shellplus date deiniz echo iniz link load save unlink
UTILPAK1	= attr build copy del deldir dir display list makdir mdir \
		merge mfree procs rename tmode

# Files not compilable by os9asm: config
all:	$(CMDS) $(CMDS_D2) shell utilpak1 $(DEPENDS)

runb:	runb.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@
	$(MERGE) $@ $(SUBS)>$@.tmp
	$(RM) $@
	$(MOVE) $@.tmp $@

tmode:	xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

xmode:	xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

pwd:	pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

pxd:	pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

shell:	$(SHELLMODS) $(DEPENDS)
		$(MERGE) $(SHELLMODS)>$@
		@$(ECHO) "*** Be sure the size of this file is less than 7681 bytes! ***"
		@ls -l $@
		@$(ECHO) ""

utilpak1:	$(UTILPAK1) $(DEPENDS)
			$(MERGE) $(UTILPAK1)>$@
			@$(ECHO) "*** Be sure the size of this file is less than 7681 bytes! ***"
			@ls -l $@
			@$(ECHO) ""

clean:
	$(RM) shell utilpak1 $(SUBS) $(SHELLMODS) $(CMDS) $(CMDS_D2)

# Only $(CMDS) are shown here
showobjs:
	@$(ECHO) shell utilpak1 $(CMDS)

showobjs_d2:
	@$(ECHO) $(CMDS_D2)

identify:
	$(IDENT_SHORT) $(ALLOBJS)
