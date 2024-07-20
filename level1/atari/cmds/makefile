include ../port.mak

vpath %.as $(LEVEL1)/cmds
vpath %.asm $(LEVEL1)/cmds:$(3RDPARTY)/packages/basic09:$(3RDPARTY)/packages/bf

DEPENDS		= ./makefile

AFLAGS          += --includedir=$(3RDPARTY)/packages/basic09 --includedir=$(3RDPARTY)/packages/bf
LFLAGS          += -L $(NITROS9DIR)/lib -lnet -latari -lalib

BASIC09 		= basic09 runb inkey syscall
BF      		= bf

ALLOBJS		= $(STD_CMDS) fuji $(BASIC09) $(BF)

all:	$(ALLOBJS)

pwd:	pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPWD=1

xmode:	xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DXMODE=1

tmode:	xmode.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DTMODE=1

pxd:	pd.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DPXD=1
	
clean:
	$(RM) $(ALLOBJS)

identify:
	$(IDENT_SHORT) $(ALLOBJS)

showobjs:
	@$(ECHO) $(ALLOBJS)

showobjs_dw:
	@$(ECHO) $(ALLOBJS)

showallobjs:
	@$(ECHO) $(ALLOBJS)
