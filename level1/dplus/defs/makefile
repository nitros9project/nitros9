PORT=dplus

include $(NITROS9DIR)/rules.mak

DEPENDS		= ./makefile

DEFOPTS		= --preprocess -DLevel=1
DEFSDIR		= ../../../defs
DEFS		= defsfile os9.d rbf.d scf.d dragon.d dragonvtio.d
ALLOBJS		= $(DEFS)

all:	$(ALLOBJS)

defsfile: defsfile.asm
	$(AS) $(DEFOPTS)  $< > $@

os9.d: $(DEFSDIR)/os9.d
	$(AS) $(DEFOPTS) -DOS9.D=0 $< > $@

rbf.d: $(DEFSDIR)/rbf.d
	$(AS) $(DEFOPTS) -DRBF.D=0 $< > $@

scf.d: $(DEFSDIR)/scf.d
	$(AS) $(DEFOPTS) -DSCF.D=0 $< > $@

dragon.d: $(DEFSDIR)/dragon.d
	$(AS) $(DEFOPTS) -DDRAGON.D=0 $< > $@

dragonvtio.d: $(DEFSDIR)/cocovtio.d
	$(AS) $(DEFOPTS) -DDRAGONVTIO.D=0 $< > $@

clean:
	$(RM) $(DEFS)

showobjs:
	@$(ECHO) $(ALLOBJS)
