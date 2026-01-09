include ../port.mak

DEPENDS		= ./makefile

DEFOPTS		= --preprocess -DLevel=1
DEFSDIR		= ../../../defs
DEFS		= defsfile
ALLOBJS		= $(DEFS)

all:	$(ALLOBJS)

defsfile: defsfile.asm
	$(AS) $(DEFOPTS)  $< > $@

clean:
	$(RM) $(DEFS)

showobjs:
	@$(ECHO) $(ALLOBJS)
