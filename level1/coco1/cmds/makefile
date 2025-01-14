include ../port.mak

vpath %.as $(LEVEL1)/cmds
vpath %.asm $(LEVEL1)/cmds:$(3RDPARTY)/packages/basic09

DEPENDS		= ./makefile $(NOSLIB)/net.o

AFLAGS		+= -I$(LEVEL1)/$(PORT)
AFLAGS		+= -I$(3RDPARTY)/packages/basic09
LFLAGS		+= -L $(NITROS9DIR)/lib -lnet -lcoco -lalib

CMDS			= $(STD_CMDS) cobbler grfdrv mpi os9gen tuneport

CMDS_D2		= copy del echo format merge os9gen prompt tmode

CMDS_DW		= inetd telnet dw httpd

BASIC09		= basic09 runb gfx inkey syscall

ALLOBJS		= $(CMDS) $(CMDS_D2) $(CMDS_DW) $(BASIC09)

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

showobjs_d2:
	@$(ECHO) $(CMDS_D2) $(BASIC09)

showobjs_dw:
	@$(ECHO) $(CMDS) $(CMDS_DW)

showallobjs:
	@$(ECHO) $(ALLOBJS)
