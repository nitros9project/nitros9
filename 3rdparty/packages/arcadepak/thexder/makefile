include $(NITROS9DIR)/rules.mak

DEPENDS		= ./makefile

CMDS		= thexder thexs

SYSFILES	= ia.fnt

ROOTFILES	= empty_thexder.txt

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

thexder:	thexder.asm
	$(AS) $(AFLAGS) $< $(ASOUT)$@

clean:
	$(RM) $(ALLOBJS) *.list *.map

showobjs:
	@$(ECHO) $(CMDS)

showsys:
	@$(ECHO) $(SYSFILES)

showroot:
	@$(ECHO) $(ROOTFILES)
