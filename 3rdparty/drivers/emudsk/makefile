include ../../../rules.mak

DEPENDS		= ./makefile

DRIVERS		= emudsk_6809.dr emudsk_6309.dr
DESCS		= h0.dd ddh0.dd h1.dd
DSK			= Modules_EmuDisk.dsk
ALLOBJS		= $(DRIVERS) $(DESCS) $(DSK)

all:	$(ALLOBJS) $(DEPENDS)

emudsk_6809.dr: emudsk.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

emudsk_6309.dr: emudsk.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DH6309=1

dsk: $(DSK)

$(DSK): all
	$(RM) $@
	$(OS9FORMAT_SS35) $@ -n"EmuDsk"
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/6809_L2
	$(MAKDIR) $@,NITROS9/6309_L2
	$(MAKDIR) $@,NITROS9/6809_L2/MODULES
	$(MAKDIR) $@,NITROS9/6309_L2/MODULES
	$(MAKDIR) $@,NITROS9/6809_L2/MODULES/RBF
	$(MAKDIR) $@,NITROS9/6309_L2/MODULES/RBF
	$(OS9COPY) h0.dd $@,NITROS9/6809_L2/MODULES/RBF/h0_emudisk.dd
	$(OS9COPY) h0.dd $@,NITROS9/6309_L2/MODULES/RBF/h0_emudisk.dd
	$(OS9COPY) h1.dd $@,NITROS9/6809_L2/MODULES/RBF/h1_emudisk.dd
	$(OS9COPY) h1.dd $@,NITROS9/6309_L2/MODULES/RBF/h1_emudisk.dd
	$(OS9COPY) ddh0.dd $@,NITROS9/6809_L2/MODULES/RBF/ddh0_emudisk.dd
	$(OS9COPY) ddh0.dd $@,NITROS9/6309_L2/MODULES/RBF/ddh0_emudisk.dd
	$(OS9COPY) emudsk_6809.dr $@,NITROS9/6809_L2/MODULES/RBF/emudsk.dr
	$(OS9COPY) emudsk_6309.dr $@,NITROS9/6309_L2/MODULES/RBF/emudsk.dr

dskcopy: $(DSK)
	$(CP) $(DSK) $(DSKDIR)

dskclean:
	$(RM) $(DSK)

clean:
	$(RM) $(ALLOBJS)

info:
	@$(ECHO) "*** EmuDsk ***"
	@$(ECHO) $(DSK)
