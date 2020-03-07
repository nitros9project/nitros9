ifeq ($(PORT),)
        PORT=d64
endif
include $(NITROS9DIR)/rules.mak

vpath %.asm $(LEVEL1)/cmds:$(3RDPARTY)/packages/basic09

DEPENDS		= ./makefile

BASIC09FILES	= runb.asm gfx.asm inkey.asm syscall.asm

CMDS		= asm attr backup binex build cmp cobbler copy cputype \
		date dcheck debug ded deiniz del deldir devs dir dirsort disasm \
		display dmode dsave dump echo edit error exbin format \
		free grfdrv help ident iniz irqs link list load login makdir \
		megaread mdir merge mfree mpi os9gen padrom park printerr procs prompt pwd pxd \
		rename runb save setime shellplus shell_21 sleep \
		tee tmode touch tsmon tuneport unlink verify xmode

DRAGONCMDS	= asm attr backup binex build cmp cobbler_dragon copy cputype \
		date dcheck debug ded deiniz del deldir devs dir dirsort disasm \
		display dmode dsave dump echo edit error exbin format \
		free grfdrv help ident iniz irqs link list load login makdir \
		megaread mdir merge mfree mpi os9gen padrom park printerr procs prompt pwd pxd \
		rename runb save setime shellplus shell_21 sleep \
		tee tmode touch tsmon tuneport unlink verify xmode

DRAGON525CMDS	= asm attr backup binex build cmp cobbler_dragon copy date del deldir \
		dir display dmode dsave dump echo exbin format free ident link list \
		load login makdir mdir merge mfree os9gen printerr procs pwd pxd rename \
		save setime shell_21 sleep tee tmode tsmon unlink verify xmode

DRAGON525CMDS2	= cputype dcheck debug ded deiniz devs dirsort disasm edit error \
		grfdrv help iniz irqs megaread mpi padrom park prompt \
		runb shellplus touch tuneport 


SUBS		= gfx inkey syscall
ALLOBJS		= $(CMDS) $(DRAGONCMDS) $(SUBS)

all:	$(ALLOBJS)

alldragon: $(DRAGONCMDS) $(SUBS)


pwd:	pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

xmode:	xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

tmode:	xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

pxd:	pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1
	
cobbler_dragon: cobbler.asm
	$(AS) $(AFLAGS) $< $(ASOUT)cobbler_dragon -DDRAGON=1

clean:
	$(RM) $(ALLOBJS)

identify:
	$(IDENT_SHORT) $(ALLOBJS)

showallobjs:
	@$(ECHO) $(ALLOBJS)

showcocoobjs:
	@$(ECHO) $(CMDS) $(SUBS)

showdragonobjs:
	@$(ECHO) $(sort $(CMDS) $(DRAGONCMDS))

showdragon525objs:
	@$(ECHO) $(DRAGON525CMDS) $(SUBS)

showdragon525objs2:
	@$(ECHO) $(DRAGON525CMDS2)
