include ../port.mak

vpath %.hp $(LEVEL2)/sys:$(LEVEL1)/sys

DEPENDS     = ./makefile

L1TXTFILES  = errmsg password
L2TXTFILES  = $(LEVEL2)/sys/motd
TEXTFILES   = $(L2TXTFILES) $(L1TXTFILES)
BINFILES    =

ALLOBJS     = $(TEXTFILES) $(BINFILES)

all:    $(L1TXTFILES) $(DEPENDS)

$(L1TXTFILES):
	$(SOFTLINK) -f $(LEVEL1)/sys/$@

clean:
	$(RM) $(L1TXTFILES)

showbinobjs:
	@$(ECHO) $(BINFILES)

showtextobjs:
	@$(ECHO) $(TEXTFILES)

showobjs:
	@$(ECHO) $(ALLOBJS)

