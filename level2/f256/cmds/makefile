include ../port.mak

vpath %.as $(LEVEL1)/f256/cmds:$(LEVEL2)/cmds:$(LEVEL1)/cmds
vpath %.asm $(LEVEL1)/f256/cmds:$(LEVEL2)/cmds:$(LEVEL1)/cmds:$(3RDPARTY)/packages/basic09:$(3RDPARTY)/packages/brainfuck:$(3RDPARTY)/packages/cpm:$(3RDPARTY)/packages/rogue

DEPENDS		= ./makefile $(NOSLIB)/net.o

AFLAGS      += -I$(LEVEL2)/$(PORT)
AFLAGS      += -I$(3RDPARTY)/packages/basic09
AFLAGS      += -I$(3RDPARTY)/packages/brainfuck
AFLAGS      += -I$(3RDPARTY)/packages/cpm
AFLAGS      += -I../defs
LFLAGS		+= -L$(NITROS9DIR)/lib -L$(LEVEL2)/$(PORT)/libs
LFLAGS		+= -lf256 -lfnxsnd
LFLAGS		+= -lnet -lalib -lnos96809l2

BASIC09	= basic09 runb inkey syscall foenix
BF      = bf
CPM     = cpm
CMDS_DW = inetd dw telnet httpd
CMDS    = asm attr backup bawk binex build cmp copy \
		date dcheck debug ded deiniz del deldir devs dir dirsort disasm \
		display dmem dmode dsave dump echo edit error exbin \
		format free grep help ident iniz irqs link list load login \
		makdir mdir megaread merge mergeln mfree minted mmap modpatch more padrom park \
		pmap proc procs prompt pwd pxd rename save setime shellplus \
		shell_21 sleep smap tee tmode touch tsmon unlink verify xmode \
		bootos9 fnxinfo fnxreset rogue fstatus fcfg xtclut drawtest play foenix \
		$(CMDS_DW) $(BASIC09) $(BF) $(CPM)

CMDS_CART      = asm attr backup bawk binex build cmp copy \
		date dcheck debug ded deiniz del deldir devs dir dirsort disasm \
		display dmem dmode dsave dump echo edit error exbin \
		format free grep help ident iniz irqs link list load login \
		makdir mdir megaread merge mergeln mfree minted mmap modpatch more padrom park \
		pmap proc procs prompt pwd pxd rename save setime shellplus \
		shell_21 sleep smap tee tmode touch tsmon unlink verify xmode \
		bootos9 fnxinfo fnxreset rogue fstatus fcfg xtclut drawtest play foenix

SHELLMODS	= shellplus echo iniz link load save unlink

UTILPAK1	= attr copy date del deiniz dir display list makdir mdir \
		merge mfree procs rename tmode unlink

# Files not compilable by os9asm: config
all:	$(DEPENDS) $(CMDS) shell utilpak1

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
	$(RM) shell utilpak1 $(SUBS) $(SHELLMODS) $(CMDS) *.list *.map

# Only $(CMDS) are shown here
showobjs:
	@$(ECHO) shell utilpak1 $(CMDS)

showobjs_dw:
	@$(ECHO) shell utilpak1 $(sort $(CMDS))

showobjs_cart:
	@$(ECHO) shell utilpak1 $(CMDS_CART)

identify:
	$(IDENT_SHORT) $(ALLOBJS)
