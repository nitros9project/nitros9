include ../../../../rules.mak

vpath %.asm ../objs_lsl

AFLAGS      += -I.

DEPENDS		= ./makefile

DISK_1_40D	= BlackCauldron_d1_40d.dsk
DISK_2_40D	= BlackCauldron_d2_40d.dsk
DISK_80D	= BlackCauldron_80d.dsk
DSK_DW		= BlackCauldron_dw.dsk
DSK_DW_BECKER	= BlackCauldron_becker.dsk

DSKS		= $(DISK_1_40D) $(DISK_2_40D) $(DISK_80D) $(DSK_DW) $(DSK_DW_BECKER)

DISK_1_40D_NAME = "The Black Cauldron Disk 1"
DISK_2_40D_NAME = "The Black Cauldron Disk 2"
DISK_80D_NAME   = "The Black Cauldron"
DSK_DW_NAME     = $(DISK_80D_NAME)

CMDS		= sierra mnln scrn shdw tocgen
MD		= $(LEVEL2)/coco3/modules

# We make our own bootfile and KERNEL_FLOPPY track
KERNEL_FLOPPY	= $(MD)/rel_32 $(MD)/boot_1773_6ms $(MD)/krn
KERNEL_DW	= $(MD)/rel_32 $(MD)/boot_dw $(MD)/krn
KERNEL_DW_BECKER	= $(MD)/rel_32 $(MD)/boot_dw_becker $(MD)/krn
BOOTFILE_40D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_40d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

BOOTFILE_80D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_80d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

BOOTFILE_DW	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio.sb $(MD)/ddx0.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/clock_60hz $(MD)/clock2_dw $(MD)/sysgo_dd

BOOTFILE_DW_BECKER	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio_becker.sb $(MD)/ddx0.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/clock_60hz $(MD)/clock2_dw $(MD)/sysgo_dd


BOOTCMDS	= $(LEVEL2)/coco3/cmds/shell_21 $(LEVEL2)/coco3/cmds/date \
		$(LEVEL2)/coco3/cmds/echo $(LEVEL2)/coco3/cmds/link \
		$(LEVEL2)/coco3/cmds/setime

TEXTFILES_D1	= ../startup tOC_40d.txt
TEXTFILES	= ../startup tOC_40d.txt

SUPPORTFILES_D1	= logDir object picDir sndDir viewDir vol.0 \
		vol.1 words.tok

SUPPORTFILES_D2	= object vol.0 vol.2

SUPPORTFILES	= $(sort $(SUPPORTFILES_D1) $(SUPPORTFILES_D2))

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:	dskclean
	$(RM) $(ALLOBJS) *.list *.map

$(DISK_1_40D): all
	$(RM) $@
	$(MAKE) -C $(LEVEL2)/coco3
	$(OS9FORMAT_DS40) -q $@ -n$(DISK_1_40D_NAME)
	$(MERGE) $(BOOTFILE_40D)>os9boot
	$(MERGE) $(KERNEL_FLOPPY)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MERGE) $(BOOTCMDS)>shell
	$(OS9COPY) shell $@,CMDS
	$(RM) shell
	$(OS9ATTR_EXEC) $@,CMDS/shell 
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(CPL) $(TEXTFILES_D1) $@,.
	$(OS9RENAME) $@,tOC_40d.txt tOC.txt
	$(OS9COPY) $(SUPPORTFILES_D1) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen $@,tOC.txt $@,tOC
	$(MOVE) toctmp tocgen

$(DISK_2_40D): all
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n$(DISK_2_40D_NAME)
	$(OS9COPY) $(SUPPORTFILES_D2) $@,.

$(DISK_80D): all
	$(RM) $@
	$(MAKE) -C $(LEVEL2)/coco3
	$(OS9FORMAT_DS80) -q $@ -n$(DISK_80D_NAME)
	$(MERGE) $(BOOTFILE_80D)>os9boot
	$(MERGE) $(KERNEL_FLOPPY)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MERGE) $(BOOTCMDS)>shell
	$(OS9COPY) shell $@,CMDS
	$(RM) shell
	$(OS9ATTR_EXEC) $@,CMDS/shell 
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(CPL) $(TEXTFILES) $@,.
	$(OS9RENAME) $@,tOC_40d.txt tOC.txt
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen $@,tOC.txt $@,tOC
	$(MOVE) toctmp tocgen

$(DSK_DW): all
	$(RM) $@
	$(MAKE) -C $(LEVEL2)/coco3
	$(OS9FORMAT_DW) -q $@ -n$(DSK_DW_NAME)
	$(MERGE) $(BOOTFILE_DW)>os9boot
	$(MERGE) $(KERNEL_DW)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MERGE) $(BOOTCMDS)>shell
	$(OS9COPY) shell $@,CMDS
	$(RM) shell
	$(OS9ATTR_EXEC) $@,CMDS/shell 
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(CPL) $(TEXTFILES) $@,.
	$(OS9RENAME) $@,tOC_40d.txt tOC.txt
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen $@,tOC.txt $@,tOC
	$(MOVE) toctmp tocgen

$(DSK_DW_BECKER): all
	$(RM) $@
	$(MAKE) -C $(LEVEL2)/coco3
	$(OS9FORMAT_DW) -q $@ -n$(DSK_DW_NAME)
	$(MERGE) $(BOOTFILE_DW_BECKER)>os9boot
	$(MERGE) $(KERNEL_DW_BECKER)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MERGE) $(BOOTCMDS)>shell
	$(OS9COPY) shell $@,CMDS
	$(RM) shell
	$(OS9ATTR_EXEC) $@,CMDS/shell 
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(CPL) $(TEXTFILES) $@,.
	$(OS9RENAME) $@,tOC_40d.txt tOC.txt
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen $@,tOC.txt $@,tOC
	$(MOVE) toctmp tocgen


dsk: $(DSKS)

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

info:
	@$(ECHO) "*** The Black Cauldron ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
