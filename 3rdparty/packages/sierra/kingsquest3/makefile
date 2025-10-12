include ../../../../rules.mak

vpath %.asm ../objs_lsl

AFLAGS      += -I.

DEPENDS		= ./makefile

DISK_1_40D	= KingsQuestIII_d1_40d.dsk
DISK_2_40D	= KingsQuestIII_d2_40d.dsk
DISK_3_40D	= KingsQuestIII_d3_40d.dsk
DISK_80D	= KingsQuestIII_80d.dsk
DSK_DW		= KingsQuestIII_dw.dsk
DSK_DW_BECKER	= KingsQuestIII_becker.dsk

DSKS		= $(DISK_1_40D) $(DISK_2_40D) $(DISK_3_40D) $(DISK_80D) $(DSK_DW) $(DSK_DW_BECKER)

DISK_1_40D_NAME = "King's Quest III Disk 1"
DISK_2_40D_NAME = "King's Quest III Disk 2"
DISK_3_40D_NAME = "King's Quest III Disk 3"
DISK_80D_NAME   = "King's Quest III"
DSK_DW_NAME	= "King's Quest III"

CMDS		= sierra mnln scrn shdw tocgen
MD		= $(LEVEL2)/coco3/modules

# We make our own bootfile and kernel track
KERNEL		= $(MD)/rel_32 $(MD)/boot_1773_6ms $(MD)/krn
KERNEL_DW	= $(MD)/rel_32 $(MD)/boot_dw $(MD)/krn
KERNEL_DW_BECKER	= $(MD)/rel_32 $(MD)/boot_dw_becker $(MD)/krn

OS9BOOT_40D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_40d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

OS9BOOT_80D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
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
TEXTFILES	= ../startup tOC_80d.txt
TEXTFILES_DW = ../startup tOC_dw.txt

SUPPORTFILES_D1	= logDir object picDir sndDir viewDir vol.0 \
		vol.1 vol.2 vol.3 vol.4 vol.12 vol.14 words.tok

SUPPORTFILES_D2	= object vol.0 vol.5 vol.6 vol.7 vol.8 vol.11 vol.12 vol.14

SUPPORTFILES_D3	= object vol.0 vol.5 vol.6 vol.7 vol.9 vol.11 vol.12 vol.14

SUPPORTFILES	= logDir object picDir sndDir viewDir vol.0 \
		vol.1 vol.2 vol.3 vol.4 vol.5 vol.6 vol.7 vol.8 vol.9 \
		vol.11 vol.12 vol.14 words.tok

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:	dskclean
	$(RM) $(ALLOBJS) *.list *.map

$(DISK_1_40D): all
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_DS40) -q $@ -n$(DISK_1_40D_NAME)
	$(MERGE) $(OS9BOOT_40D)>os9boot_40d
	$(MERGE) $(KERNEL)>kernel_1773
	$(OS9GEN) $@ -b=os9boot_40d -t=kernel_1773
	$(RM) os9boot_40d kernel_1773
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

$(DISK_3_40D): all
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n$(DISK_3_40D_NAME)
	$(OS9COPY) $(SUPPORTFILES_D3) $@,.

$(DISK_80D): all
	$(RM) $@
	$(MAKE) -C $(LEVEL2)/coco3
	$(OS9FORMAT_DS80) -q $@ -n$(DISK_80D_NAME)
	$(MERGE) $(OS9BOOT_80D)>os9boot_80d
	$(MERGE) $(KERNEL)>kernel_1773
	$(OS9GEN) $@ -b=os9boot_80d -t=kernel_1773
	$(RM) os9boot_80d kernel_1773
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MERGE) $(BOOTCMDS)>shell
	$(OS9COPY) shell $@,CMDS
	$(RM) shell
	$(OS9ATTR_EXEC) $@,CMDS/shell 
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(CPL) $(TEXTFILES) $@,.
	$(OS9RENAME) $@,tOC_80d.txt tOC.txt
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen $@,tOC.txt $@,tOC
	$(MOVE) toctmp tocgen

$(DSK_DW): all
	$(RM) $@
	$(MAKE) -C $(LEVEL2)/coco3
	$(OS9FORMAT_DW) -q $@ -n$(DSK_DW_NAME)
	$(MERGE) $(BOOTFILE_DW)>os9boot_dw
	$(MERGE) $(KERNEL_DW)>kernel_dw
	$(OS9GEN) $@ -b=os9boot_dw -t=kernel_dw
	$(RM) os9boot_dw kernel_dw
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MERGE) $(BOOTCMDS)>shell
	$(OS9COPY) shell $@,CMDS
	$(RM) shell
	$(OS9ATTR_EXEC) $@,CMDS/shell 
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(CPL) $(TEXTFILES_DW) $@,.
	$(OS9RENAME) $@,tOC_dw.txt tOC.txt
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen $@,tOC.txt $@,tOC
	$(MOVE) toctmp tocgen

$(DSK_DW_BECKER): all
	$(RM) $@
	$(MAKE) -C $(LEVEL2)/coco3
	$(OS9FORMAT_DW) -q $@ -n$(DSK_DW_NAME)
	$(MERGE) $(BOOTFILE_DW_BECKER)>os9boot_dw
	$(MERGE) $(KERNEL_DW_BECKER)>kernel_dw
	$(OS9GEN) $@ -b=os9boot_dw -t=kernel_dw
	$(RM) os9boot_dw kernel_dw
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MERGE) $(BOOTCMDS)>shell
	$(OS9COPY) shell $@,CMDS
	$(RM) shell
	$(OS9ATTR_EXEC) $@,CMDS/shell 
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(CPL) $(TEXTFILES_DW) $@,.
	$(OS9RENAME) $@,tOC_dw.txt tOC.txt
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
	@$(ECHO) "*** King's Quest III ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
