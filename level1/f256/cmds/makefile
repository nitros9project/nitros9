include ../port.mak

vpath %.as $(LEVEL1)/cmds
vpath %.asm $(LEVEL1)/cmds:$(3RDPARTY)/packages/basic09:$(3RDPARTY)/packages/bf

DEPENDS		= ./makefile $(NOSLIB)/net.o

AFLAGS         += --includedir=$(3RDPARTY)/packages/basic09 --includedir=$(3RDPARTY)/packages/bf
LFLAGS         += -L $(NITROS9DIR)/lib -lnet -lf256 -lalib -lf256snd

BASIC09		= basic09 runb inkey syscall foenix
BF  			= bf
CMDS			= $(STD_CMDS) bootos9 fnxinfo fnxreset play $(BASIC09) $(BF)

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
