PORT = coco3
include $(NITROS9DIR)/rules.mak

DEPENDS		= ./makefile

DEFOPTS		= --preprocess -DLevel=2
PERMDEFS	= Defsfile
DEFS		= os9.d rbf.d scf.d coco.d coco3vtio.d
ALLOBJS		= $(DEFS) $(PERMDEFS)

all:	$(ALLOBJS)

os9.d: $(DEFSDIR)/os9.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DOS9.D=0 $< > $@
	$(DROP_EXTRA_SPACES) $@

rbf.d: $(DEFSDIR)/rbf.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DRBF.D=0 $< > $@
	$(DROP_EXTRA_SPACES) $@

scf.d: $(DEFSDIR)/scf.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DSCF.D=0 $< > $@
	$(DROP_EXTRA_SPACES) $@

coco.d: $(DEFSDIR)/coco.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DCOCO.D=0 $< > $@
	$(DROP_EXTRA_SPACES) $@

coco3vtio.d: $(DEFSDIR)/cocovtio.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DCOCOVTIO.D=0 $< > $@
	$(DROP_EXTRA_SPACES) $@

clean:
	$(RM) $(DEFS) *.tmp

showobjs:
	@$(ECHO) $(ALLOBJS)
