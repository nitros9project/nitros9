include ../../../rules.mak

DEPENDS		= ./makefile

DSK_FLOPPY	= SubBattleSimulator.dsk
DSK_DW		= SubBattleSimulator_dw.dsk
DSK_DW_BECKER	= SubBattleSimulator_becker.dsk

CMDS		= presub sub sub1 sub2 sub3 sub4 sub5 sub6
MD		= $(LEVEL2)/coco3/modules

DSKS		= $(DSK_FLOPPY) $(DSK_DW) $(DSK_DW_BECKER)

# We make our own bootfile and kernel track
KERNEL_FLOPPY	= $(MD)/rel_32 $(MD)/boot_1773_6ms $(MD)/krn
KERNEL_DW	= $(MD)/rel_32 $(MD)/boot_dw $(MD)/krn
KERNEL_DW_BECKER	= $(MD)/rel_32 $(MD)/boot_dw_becker $(MD)/krn

BOOTFILE_FLOPPY	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_40d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

BOOTFILE_DW	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio.sb $(MD)/ddx0.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/clock_60hz $(MD)/clock2_dw $(MD)/sysgo_dd

BOOTFILE_DW_BECKER	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio_becker.sb $(MD)/ddx0.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/clock_60hz $(MD)/clock2_dw $(MD)/sysgo_dd

SUPPORTFILES	= control1.cmp convoys.dat diesel.dat fonts.dat germap.cmp \
		hiscore.dat mission.txt missions.dat radar.dat shipmap2.dat \
		sintbl.dat stitle.pic sub.dat usamap.cmp status.dat substats.dat 

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:	dskclean
	$(RM) $(ALLOBJS) *.list *.map

dsk:	all $(DSKS)

$(DSK_FLOPPY):
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_DS40) $@ -n"Sub Battle Simulator"
	$(MERGE) $(BOOTFILE_FLOPPY)>os9boot
	$(MERGE) $(KERNEL_FLOPPY)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS $@,SUB
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9COPY) $(LEVEL2)/coco3/cmds/shell_21 $@,CMDS/shell
	$(OS9ATTR_EXEC) $@,CMDS/shell
	$(OS9RENAME) $@,CMDS/presub AutoEx
	$(OS9COPY) $(SUPPORTFILES) $@,SUB
	$(OS9COPY) sub6 $@,SUB
	$(OS9ATTR_EXEC) $@,SUB/sub6
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,SUB/$(file))

$(DSK_DW):
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_SS80) $@ -n"Sub Battle Simulator"
	$(MERGE) $(BOOTFILE_DW)>os9boot
	$(MERGE) $(KERNEL_DW)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS $@,SUB
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9COPY) $(LEVEL2)/coco3/cmds/shell_21 $@,CMDS/shell
	$(OS9ATTR_EXEC) $@,CMDS/shell
	$(OS9RENAME) $@,CMDS/presub AutoEx
	$(OS9COPY) $(SUPPORTFILES) $@,SUB
	$(OS9COPY) sub6 $@,SUB
	$(OS9ATTR_EXEC) $@,SUB/sub6
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,SUB/$(file))

$(DSK_DW_BECKER):
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_SS80) $@ -n"Sub Battle Simulator"
	$(MERGE) $(BOOTFILE_DW_BECKER)>os9boot
	$(MERGE) $(KERNEL_DW_BECKER)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS $@,SUB
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9COPY) $(LEVEL2)/coco3/cmds/shell_21 $@,CMDS/shell
	$(OS9ATTR_EXEC) $@,CMDS/shell
	$(OS9RENAME) $@,CMDS/presub AutoEx
	$(OS9COPY) $(SUPPORTFILES) $@,SUB
	$(OS9COPY) sub6 $@,SUB
	$(OS9ATTR_EXEC) $@,SUB/sub6
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,SUB/$(file))

dskcopy:	dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

info:
	@$(ECHO) "*** Sub Battle Simulator ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
