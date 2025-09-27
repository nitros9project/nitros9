include ../port.mak

DEPENDS		= ./makefile

DEFOPTS		= --preprocess -DLevel=2
PERMDEFS	= defsfile
DEFS		= os9.d rbf.d scf.d f256.d f256vtio.d
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

f256.d: $(DEFSDIR)/f256.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DF256.D=0 $< > $@
	$(DROP_EXTRA_SPACES) $@

f256vtio.d: $(DEFSDIR)/f256vtio.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DF256VTIO.D=0 $< > $@
	$(DROP_EXTRA_SPACES) $@

clean:
	$(RM) $(DEFS) *.tmp

showobjs:
	@$(ECHO) $(ALLOBJS)
