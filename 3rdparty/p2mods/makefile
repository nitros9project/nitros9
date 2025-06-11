include ../../rules.mak

DEPENDS		= ./makefile
CMDS		= os9p3_sayhi sayhi tsayhi datmod tdatmod
ALLOBJS		= $(CMDS)

all:	banner $(ALLOBJS)

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*            3rd Party System Modules            *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

clean:
	$(RM) $(ALLOBJS) *.list *.map

dsk:
dskcopy:
