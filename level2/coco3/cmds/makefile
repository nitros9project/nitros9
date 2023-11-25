include ../port.mak

vpath %.as $(LEVEL2)/cmds:$(LEVEL1)/cmds
vpath %.asm $(LEVEL2)/cmds:$(LEVEL1)/cmds:$(3RDPARTY)/packages/basic09

DEPENDS		= ./makefile $(NOSLIB)/net.o

AFLAGS          += --includedir=$(3RDPARTY)/packages/basic09
AFLAGS          += --includedir=../defs
LFLAGS		+= -L$(NITROS9DIR)/lib
ifdef	H6309
LFLAGS		+= -lcoco3_6309
else
LFLAGS		+= -lcoco3
endif
LFLAGS		+= -lnet -lalib 

CMDS		= asm attr backup binex build cmp cobbler copy cputype \
		date dcheck debug ded deiniz del deldir devs dir dirsort disasm \
		display dmem dmode dsave dump echo edit error exbin \
		format free grfdrv help ident iniz irqs link list load login \
		makdir mdir megaread merge mfree minted mmap modpatch montype mpi os9gen padrom park \
		pmap proc procs prompt pwd pxd reboot rename save setime \
		shell_21 sleep smap tee tmode touch tsmon tuneport unlink verify wcreate xmode

CMDS_D2         = basic09 runb gfx2 gfx inkey syscall copy del echo format \
                merge os9gen prompt tmode

CMDS_DW		= inetd dw telnet httpd

SHELLMODS	= shellplus date deiniz echo iniz link load save unlink

UTILPAK1	= attr build copy del deldir dir display list makdir mdir \
		merge mfree procs rename tmode

# Files not compilable by os9asm: config
all:	$(DEPENDS) $(CMDS) $(CMDS_D2) $(CMDS_DW) shell utilpak1 $(DEPENDS)

# Some commands depend on net.o
$(NOSLIB)/net.o:
	cd $(NOSLIB); make
	
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

shell:  $(SHELLMODS) $(DEPENDS)
	$(MERGE) $(SHELLMODS) >$@
	@$(ECHO) "*** Be sure the size of this file is less than 7681 bytes! ***"
	@ls -l $@
	@$(ECHO) ""

utilpak1:  $(UTILPAK1) $(DEPENDS)
	$(MERGE) $(UTILPAK1) >$@
	@$(ECHO) "*** Be sure the size of this file is less than 7681 bytes! ***"
	@ls -l $@
	@$(ECHO) ""

clean:
	$(RM) shell utilpak1 $(SUBS) $(SHELLMODS) $(CMDS) $(CMDS_D2) $(CMDS_DW)

# Only $(CMDS) are shown here
showobjs:
	@$(ECHO) shell utilpak1 $(CMDS)

showobjs_dw:
	@$(ECHO) shell utilpak1 $(sort $(CMDS) $(CMDS_D2) $(CMDS_DW))

showobjs_d2:
	@$(ECHO) $(CMDS_D2)

identify:
	$(IDENT_SHORT) $(ALLOBJS)
