include ../port.mak

vpath %.as $(LEVEL1)/cmds
vpath %.asm $(LEVEL1)/cmds:$(3RDPARTY)/packages/basic09

DEPENDS		= ./makefile

AFLAGS          += --includedir=$(3RDPARTY)/packages/basic09
LFLAGS          += -L $(NITROS9DIR)/lib -lnet -latari -lalib

CMDS		= $(STD_CMDS)

BASIC09		= basic09 runb gfx inkey syscall

ALLOBJS		= $(CMDS) $(BASIC09)

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
	@$(ECHO) $(CMDS) $(BASIC09)

showobjs_demo:
	@$(ECHO) $(CMDS_DEMO)

showallobjs:
	@$(ECHO) $(ALLOBJS)
