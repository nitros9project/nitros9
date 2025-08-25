include $(NITROS9DIR)/rules.mak

DEPENDS		= ./makefile

CMDS		= smash custom

SYSFILES	= flags.dat ia.fnt smash.dat smash.hsc

ROOTFILES	= empty_smash.txt

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:
	$(RM) $(ALLOBJS) *.list *.map

showobjs:
	@$(ECHO) $(CMDS)

showroot:
	@$(ECHO) $(ROOTFILES)

showsys:
	@$(ECHO) $(SYSFILES)
