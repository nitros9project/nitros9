include ../../../rules.mak

DEPENDS		= ./makefile

DRIVERS		=	rammer_nocan.dr rammer_nocan_63.dr
DESCS		= r0_nocan.dd
DSK			= Modules_NoCan_Rammer.dsk
ALLOBJS		= $(DRIVERS) $(DESCS) $(DSK)

all:	$(ALLOBJS) $(DEPENDS)

rammer_nocan_63.dr: rammer.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS) -DH6309=1

rammer_nocan.dr: rammer.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

r0_nocan.dd: r0.asm
	$(AS) $(ASOUT)$@ $< $(AFLAGS)

clean:
	$(RM) $(ALLOBJS)

dskclean:
	$(RM) $(DSK)

dsk: $(DSK)

$(DSK): all
	$(RM) $@
	$(OS9FORMAT_SS35) $@ -n"NoCanModules"
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/6809_L2
	$(MAKDIR) $@,NITROS9/6309_L2
	$(MAKDIR) $@,NITROS9/6809_L2/MODULES
	$(MAKDIR) $@,NITROS9/6309_L2/MODULES
	$(MAKDIR) $@,NITROS9/6809_L2/MODULES/RBF
	$(MAKDIR) $@,NITROS9/6309_L2/MODULES/RBF
	$(OS9COPY) r0_nocan.dd $@,NITROS9/6809_L2/MODULES/RBF/r0_nocan.dd
	$(OS9COPY) r0_nocan.dd $@,NITROS9/6309_L2/MODULES/RBF/r0_nocan.dd
	$(OS9COPY) rammer_nocan.dr $@,NITROS9/6809_L2/MODULES/RBF/rammer_nocan.dr
	$(OS9COPY) rammer_nocan_63.dr $@,NITROS9/6309_L2/MODULES/RBF/rammer_nocan.dr

dskcopy: $(DSK)
	$(CP) $(DSK) $(DSKDIR)

info:
	@$(ECHO) "*** Modules NoCan Rammer ***"
	@$(ECHO) $(DSK)

