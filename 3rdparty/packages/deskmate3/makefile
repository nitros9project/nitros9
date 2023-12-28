include $(NITROS9DIR)/rules.mak

DSK	= DeskMate3.dsk

CD68	= $(LEVEL2)/coco3/cmds
MD68	= $(LEVEL2)/coco3/modules

UTILS	= $(CD68)/shell $(CD68)/format $(CD68)/rename
CMDS	= accdata autoex desk dmalt dmapps dmbackup dmcaln dmcards dmdskini \
	dmhelp dmledger dmload dmmenu dmpaint dmterm dmtext dmtim
HELP	= dmalt.hlp dmcaln.hlp dmcards.hlp dmledger.hlp dmmenu.hlp \
	dmpaint.hlp dmterm.hlp dmtext.hlp
ROOTFILES	= Sample.fil

KERNEL68	= $(MD68)/rel_32 $(MD68)/boot_1773_6ms $(MD68)/krn

OS9BOOT68	= $(MD68)/krnp2 $(MD68)/ioman $(MD68)/init \
		$(MD68)/rbf.mn \
		$(MD68)/rb1773.dr $(MD68)/ddd0_40d.dd \
		$(MD68)/d0_40d.dd $(MD68)/d1_40d.dd $(MD68)/d2_40d.dd \
		$(MD68)/scf.mn $(MD68)/vtio.dr \
		$(MD68)/joydrv_joy.sb $(MD68)/snddrv_cc3.sb \
		$(MD68)/covdg.io $(MD68)/term_vdg.dt \
		$(MD68)/sc6551.dr $(MD68)/t2_sc6551.dd \
		$(MD68)/clock_60hz $(MD68)/clock2_soft \
		$(MD68)/sysgo_dd

# Make all components
all:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                   DeskMate 3                   *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

# Clean all components
clean:	dskclean
	$(RM) os9boot

dsk: $(DSK)

$(DSK): all
	$(RM) $@
	$(OS9FORMAT_DS40) $@ -q -n"DeskMate 3"
	$(MERGE) $(OS9BOOT68)>os9boot
	$(MERGE) $(KERNEL68)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(UTILS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(notdir $(UTILS)),$@,CMDS/$(file))
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(notdir $(CMDS)),$@,CMDS/$(file))
	$(CPL) $(HELP) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(notdir $(HELP)),$@,CMDS/$(file))
	$(OS9COPY) $(ROOTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(ROOTFILES),$@,$(file))

dskcopy: $(DSK)
	$(CP) $(DSK) $(DSKDIR)

dskclean:
	$(RM) $(DSK)

info:
	@$(ECHO) "*** DeskMate 3 ***"
	@$(ECHO) $(DSK)
