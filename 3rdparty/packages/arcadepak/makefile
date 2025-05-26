include $(NITROS9DIR)/rules.mak

6809L2		= $(LEVEL2)/coco3
DEPENDS		= ./makefile

CMD		= $(6809L2)/cmds
DISK_40D	= ArcadePack_40d.dsk
DISK_80D	= ArcadePack_80d.dsk
DISK_DW 	= ArcadePack_dw.dsk
DISK_BECKER	= ArcadePack_becker.dsk
CMDS		= grfdrv runb
SHELLMODS	= $(CMD)/shell_21 $(CMD)/dir $(CMD)/echo $(CMD)/link $(CMD)/load $(CMD)/mdir
		
SMASHCMDS	= $(shell $(CD) smash; make --no-print-directory showobjs)
SMASHSYS	= $(shell $(CD) smash; make --no-print-directory showsys)
SMASHROOT	= $(shell $(CD) smash; make --no-print-directory showroot)
THEXCMDS	= $(shell $(CD) thexder; make --no-print-directory showobjs)
THEXSYS		= $(shell $(CD) thexder; make --no-print-directory showsys)
THEXROOT	= $(shell $(CD) thexder; make --no-print-directory showroot)
SHANGCMDS	= $(shell $(CD) shanghai; make --no-print-directory showobjs)
SHANGSYS	= $(shell $(CD) shanghai; make --no-print-directory showsys)
SHANGROOT	= $(shell $(CD) shanghai; make --no-print-directory showroot)
MD		= $(6809L2)/modules

# We make our own bootfile and kernel track
KERNEL		= $(MD)/rel_40 $(MD)/boot_1773_6ms $(MD)/krn
KERNEL_DW	= $(MD)/rel_40 $(MD)/boot_dw $(MD)/krn
KERNEL_BECKER	= $(MD)/rel_40 $(MD)/boot_dw_becker $(MD)/krn

OS9BOOT_40D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_40d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cogrf.io $(MD)/term_win40.dt $(MD)/w.dw $(MD)/w1.dw \
		$(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw $(MD)/w5.dw \
		$(MD)/w6.dw $(MD)/w7.dw \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

OS9BOOT_80D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_80d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cogrf.io $(MD)/term_win40.dt $(MD)/w.dw $(MD)/w1.dw \
		$(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw $(MD)/w5.dw \
		$(MD)/w6.dw $(MD)/w7.dw \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

OS9BOOT_DW	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio.sb $(MD)/ddx0.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cogrf.io $(MD)/term_win40.dt $(MD)/w.dw $(MD)/w1.dw \
		$(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw $(MD)/w5.dw \
		$(MD)/w6.dw $(MD)/w7.dw \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

OS9BOOT_BECKER	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio_becker.sb $(MD)/ddx0.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cogrf.io $(MD)/term_win40.dt $(MD)/w.dw $(MD)/w1.dw \
		$(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw $(MD)/w5.dw \
		$(MD)/w6.dw $(MD)/w7.dw \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

ALLOBJS		= $(CMDS)

DSKS		= $(DISK_40D) $(DISK_80D) $(DISK_DW) $(DISK_BECKER)

all: shell
	$(CD) smash; make
	$(CD) thexder; make
	$(CD) shanghai; make

dsk:	all $(DSKS)

shell:	$(DEPENDS)
	$(MERGE) $(SHELLMODS)>$@
	@$(ECHO) "*** Be sure the size of this file is less than 7681 bytes! ***"
	@ls -l $@
	@$(ECHO) ""

$(DISK_40D): all
	$(RM) $@
	$(CD) $(6809L2); make
	$(OS9FORMAT_DS40) $@ -n"NitrOS-9 Arcade Pack"
	$(MERGE) $(OS9BOOT_40D)>os9boot
	$(MERGE) $(KERNEL)>kernel_1773
	$(OS9GEN) $@ -b=os9boot -t=kernel_1773
	$(RM) os9boot kernel_1773
	$(MAKDIR) $@,CMDS
	$(OS9COPY) shell $@,CMDS
	$(OS9ATTR_EXEC) $@,CMDS/shell
	$(OS9COPY) $(foreach file,$(CMDS),$(6809L2)/cmds/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(SMASHCMDS),smash/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(SMASHCMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(THEXCMDS),thexder/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(THEXCMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(SHANGCMDS),shanghai/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(SHANGCMDS),$@,CMDS/$(file))
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MAKDIR) $@,SYS
	$(OS9COPY) $(foreach file,$(SMASHSYS),smash/$(file)) $@,SYS
	$(OS9COPY) -r $(foreach file,$(THEXSYS),thexder/$(file)) $@,SYS
	$(OS9COPY) $(foreach file,$(SHANGSYS),shanghai/$(file)) $@,SYS
	$(OS9COPY) $(foreach file,$(SMASHROOT),smash/$(file)) $@,
	$(OS9COPY) $(foreach file,$(THEXROOT),thexder/$(file)) $@,
	$(OS9COPY) $(foreach file,$(SHANGROOT),shanghai/$(file)) $@,
	$(CPL) startup $@,

$(DISK_80D): all
	$(RM) $@
	$(CD) $(6809L2); make
	$(OS9FORMAT_DS80) $@ -n"NitrOS-9 Arcade Pack"
	$(MERGE) $(OS9BOOT_80D)>os9boot
	$(MERGE) $(KERNEL)>kernel_1773
	$(OS9GEN) $@ -b=os9boot -t=kernel_1773
	$(RM) os9boot kernel_1773
	$(MAKDIR) $@,CMDS
	$(OS9COPY) shell $@,CMDS/shell
	$(OS9ATTR_EXEC) $@,CMDS/shell
	$(OS9COPY) $(foreach file,$(CMDS),$(6809L2)/cmds/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(SMASHCMDS),smash/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(SMASHCMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(THEXCMDS),thexder/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(THEXCMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(SHANGCMDS),shanghai/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(SHANGCMDS),$@,CMDS/$(file))
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MAKDIR) $@,SYS
	$(OS9COPY) $(foreach file,$(SMASHSYS),smash/$(file)) $@,SYS
	$(OS9COPY) -r $(foreach file,$(THEXSYS),thexder/$(file)) $@,SYS
	$(OS9COPY) $(foreach file,$(SHANGSYS),shanghai/$(file)) $@,SYS
	$(OS9COPY) $(foreach file,$(SMASHROOT),smash/$(file)) $@,
	$(OS9COPY) $(foreach file,$(THEXROOT),thexder/$(file)) $@,
	$(OS9COPY) $(foreach file,$(SHANGROOT),shanghai/$(file)) $@,
	$(CPL) startup $@,

$(DISK_DW): all
	$(RM) $@
	$(CD) $(6809L2); make
	$(OS9FORMAT_DW) $@ -n"NitrOS-9 Arcade Pack"
	$(MERGE) $(OS9BOOT_DW)>os9boot
	$(MERGE) $(KERNEL_DW)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) shell $@,CMDS/shell
	$(OS9ATTR_EXEC) $@,CMDS/shell
	$(OS9COPY) $(foreach file,$(CMDS),$(6809L2)/cmds/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(SMASHCMDS),smash/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(SMASHCMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(THEXCMDS),thexder/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(THEXCMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(SHANGCMDS),shanghai/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(SHANGCMDS),$@,CMDS/$(file))
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MAKDIR) $@,SYS
	$(OS9COPY) $(foreach file,$(SMASHSYS),smash/$(file)) $@,SYS
	$(OS9COPY) -r $(foreach file,$(THEXSYS),thexder/$(file)) $@,SYS
	$(OS9COPY) $(foreach file,$(SHANGSYS),shanghai/$(file)) $@,SYS
	$(OS9COPY) $(foreach file,$(SMASHROOT),smash/$(file)) $@,
	$(OS9COPY) $(foreach file,$(THEXROOT),thexder/$(file)) $@,
	$(OS9COPY) $(foreach file,$(SHANGROOT),shanghai/$(file)) $@,
	$(CPL) startup $@,

$(DISK_BECKER): all
	$(RM) $@
	$(CD) $(6809L2); make
	$(OS9FORMAT_DW) $@ -n"NitrOS-9 Arcade Pack"
	$(MERGE) $(OS9BOOT_BECKER)>os9boot
	$(MERGE) $(KERNEL_BECKER)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) shell $@,CMDS/shell
	$(OS9ATTR_EXEC) $@,CMDS/shell
	$(OS9COPY) $(foreach file,$(CMDS),$(6809L2)/cmds/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(SMASHCMDS),smash/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(SMASHCMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(THEXCMDS),thexder/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(THEXCMDS),$@,CMDS/$(file))
	$(OS9COPY) $(foreach file,$(SHANGCMDS),shanghai/$(file)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(SHANGCMDS),$@,CMDS/$(file))
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MAKDIR) $@,SYS
	$(OS9COPY) $(foreach file,$(SMASHSYS),smash/$(file)) $@,SYS
	$(OS9COPY) -r $(foreach file,$(THEXSYS),thexder/$(file)) $@,SYS
	$(OS9COPY) $(foreach file,$(SHANGSYS),shanghai/$(file)) $@,SYS
	$(OS9COPY) $(foreach file,$(SMASHROOT),smash/$(file)) $@,
	$(OS9COPY) $(foreach file,$(THEXROOT),thexder/$(file)) $@,
	$(OS9COPY) $(foreach file,$(SHANGROOT),shanghai/$(file)) $@,
	$(CPL) startup $@,

clean:	dskclean
	$(RM) shell *.list *.map
	$(CD) smash; make clean
	$(CD) thexder; make clean
	$(CD) shanghai; make clean

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS) 

info:
	@$(ECHO) "*** NitrOS-9 Arcade Pak ***"
	@$(ECHO) $(DISK_40D) $(DISK_80D)

