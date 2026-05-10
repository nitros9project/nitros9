include ../port.mak

DEPENDS		= ./makefile

DEFOPTS		= --preprocess -DLevel=2
PERMDEFS	= Defsfile
DEFS		= os9.d rbf.d scf.d wildbits.d wildbits_vtio.d
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

wildbits.d: $(DEFSDIR)/wildbits.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DWILDBITS.D=0 $< > $@
	$(DROP_EXTRA_SPACES) $@

wildbits_vtio.d: $(DEFSDIR)/wildbits_vtio.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DWILDBITS_VTIO.D=0 $< > $@
	$(DROP_EXTRA_SPACES) $@

clean:
	$(RM) $(DEFS) *.tmp

showobjs:
	@$(ECHO) $(ALLOBJS)
