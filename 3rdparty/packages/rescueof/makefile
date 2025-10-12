include ../../../rules.mak

DEPENDS		= ./makefile

DSK_FLOPPY	= RescueOnFractalus.dsk
DSK_DW		= RescueOnFractalus_dw.dsk
DSK_DW_BECKER	= RescueOnFractalus_becker.dsk

CMDS		= rescue
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

SUPPORTFILES	= body heads larms legs lips panel1 rofvar rship.c rtitle.c scores

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:	dskclean
	$(RM) $(ALLOBJS) *.list *.map

dsk:	all $(DSKS)

$(DSK_FLOPPY):
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_SS35) -q $@ -n"Rescue on Fractalus"
	$(MERGE) $(BOOTFILE_FLOPPY)>os9boot
	$(MERGE) $(KERNEL_FLOPPY)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(LEVEL2)/coco3/cmds/shell_21 $@,CMDS/shell
	$(OS9ATTR_EXEC) $@,CMDS/shell
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/rescue AutoEx
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,$(file))

$(DSK_DW):
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_SS35) -q $@ -n"Rescue on Fractalus"
	$(MERGE) $(BOOTFILE_DW)>os9boot
	$(MERGE) $(KERNEL_DW)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(LEVEL2)/coco3/cmds/shell_21 $@,CMDS/shell
	$(OS9ATTR_EXEC) $@,CMDS/shell
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/rescue AutoEx
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,$(file))

$(DSK_DW_BECKER):
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_SS35) -q $@ -n"Rescue on Fractalus"
	$(MERGE) $(BOOTFILE_DW_BECKER)>os9boot
	$(MERGE) $(KERNEL_DW_BECKER)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(LEVEL2)/coco3/cmds/shell_21 $@,CMDS/shell
	$(OS9ATTR_EXEC) $@,CMDS/shell
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/rescue AutoEx
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,$(file))

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

info:
	@$(ECHO) "*** Rescue on Fractalus ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
