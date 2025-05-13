include ../port.mak

vpath %.as $(LEVEL1)/cmds
vpath %.asm $(LEVEL1)/cmds:$(3RDPARTY)/packages/basic09:$(3RDPARTY)/packages/brainfuck

DEPENDS		= ./makefile $(NOSLIB)/net.o

AFLAGS         += --includedir=$(3RDPARTY)/packages/basic09 --includedir=$(3RDPARTY)/packages/brainfuck
LFLAGS         += -L $(NITROS9DIR)/lib -L $(LEVEL1)/$(PORT)/libs -L $(LEVEL1)/$(PORT)/libs/fnxsnd -lnet -lf256 -lalib -lfnxsnd

BASIC09		= basic09 runb inkey syscall
BF  		= bf
CMDS		= asm attr backup bawk binex build cmp copy \
		date dcheck debug ded deiniz del deldir devs dir dirsort disasm \
		display dmode dsave dump echo edit error exbin format \
		free grep help ident iniz irqs link list load login makdir \
		megaread mdir merge mergeln mfree more padrom park printerr procs prompt pwd pxd \
		rename save setime shellplus shell_21 sleep \
		tee tmode touch tsmon unlink verify xmode \
		inetd telnet dw httpd $(BASIC09) $(BF) \
		bootos9 fnxinfo fnxreset pick play mergeln

ALLOBJS		= $(CMDS)

all:	$(DEPENDS) $(ALLOBJS)

# Some commands depend on net.o
$(NOSLIB)/net.o:
	cd $(NOSLIB); make
	
pwd:	pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

xmode:	xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

tmode:	xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

pxd:	pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1

clean:
	$(RM) $(ALLOBJS) *.list *.map

identify:
	$(IDENT_SHORT) $(ALLOBJS)

showobjs:
	@$(ECHO) $(CMDS)

showobjs_dw:
	@$(ECHO) $(CMDS)

showallobjs:
	@$(ECHO) $(ALLOBJS)
