include ../../rules.mak

DEPENDS		= ./makefile

CMDS		= cpu hires_l1 hires_l2 joystk

ALLOBJS		= $(CMDS)

all:	banner $(ALLOBJS) $(DEPENDS)
 
banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*          3rd Party Subroutine Modules          *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

hires_l1: hires.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DLevel=1

hires_l2: hires.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DLevel=2

clean:
	$(RM) $(ALLOBJS) *.list *.map

dsk:
dskcopy:
