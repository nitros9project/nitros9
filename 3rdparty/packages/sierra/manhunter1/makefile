include ../../../../rules.mak

vpath %.asm ../objs_lsl

AFLAGS      += -I.

DEPENDS		= ./makefile

DISK_1_80D	= ManHunterI_d1_80d.dsk
DISK_2_80D	= ManHunterI_d2_80d.dsk
DISK_3_80D	= ManHunterI_d3_80d.dsk
DISK_DW	= ManHunterI_dw.dsk
DISK_DW_BECKER	= ManHunterI_becker.dsk

DSKS		= $(DISK_1_80D) $(DISK_2_80D) $(DISK_3_80D) \
		$(DISK_DW) $(DISK_DW_BECKER)

DISK_1_80D_NAME = "Manhunter I Disk 1"
DISK_2_80D_NAME = "Manhunter I Disk 2"
DISK_3_80D_NAME = "Manhunter I Disk 3"
DISK_DW_NAME = "Manhunter I"

CMDS		= sierra mnln scrn shdw tocgen
MD		= $(LEVEL2)/coco3/modules

# We make our own bootfile and kernel track
KERNEL		= $(MD)/rel_32 $(MD)/boot_1773_6ms $(MD)/krn
KERNEL_DW	= $(MD)/rel_32 $(MD)/boot_dw $(MD)/krn
KERNEL_DW_BECKER	= $(MD)/rel_32 $(MD)/boot_dw_becker $(MD)/krn

OS9BOOT_80D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_80d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

OS9BOOT_DW = $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio.sb $(MD)/ddx0.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/clock_60hz $(MD)/clock2_dw $(MD)/sysgo_dd

OS9BOOT_DW_BECKER = $(MD)/krnp2 $(MD)/ioman $(MD)/init \
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

TEXTFILES_D1	= ../startup tOC_80d.txt
TEXTFILES	= ../startup tOC_80d.txt
TEXTFILES_DW	= ../startup tOC_dw.txt

SUPPORTFILES_D1	= logDir object picDir sndDir viewDir vol.0 \
		vol.1 vol.2 vol.9 vol.10 vol.11 vol.12 words.tok

SUPPORTFILES_D2	= object vol.0 vol.3 vol.4 vol.9 vol.10 vol.11 vol.12

SUPPORTFILES_D3	= object vol.0 vol.5 vol.9 vol.10 vol.11 vol.12

SUPPORTFILES_DW	= logDir object picDir sndDir viewDir vol.0 \
		vol.1 vol.2 vol.3 vol.4 vol.5 vol.9 vol.10 vol.11 vol.12 words.tok

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:	dskclean
	$(RM) $(ALLOBJS) *.list *.map

dsk:	all $(DSKS)

$(DISK_1_80D):
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_DS80) -q $@ -n$(DISK_1_80D_NAME)
	$(MERGE) $(OS9BOOT_80D)>os9boot
	$(MERGE) $(KERNEL)>kernel
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
	$(OS9RENAME) $@,tOC_80d.txt tOC.txt
	$(OS9COPY) $(SUPPORTFILES_D1) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen $@,tOC.txt $@,tOC
	$(MOVE) toctmp tocgen

$(DISK_DW):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n$(DISK_DW_NAME)
	$(MERGE) $(KERNEL_DW)>kernel
	$(MERGE) $(OS9BOOT_DW)>os9boot
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
	$(CPL) $(TEXTFILES_DW) $@,.
	$(OS9RENAME) $@,tOC_dw.txt tOC.txt
	$(OS9COPY) $(SUPPORTFILES_DW) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen $@,tOC.txt $@,tOC
	$(MOVE) toctmp tocgen

$(DISK_DW_BECKER):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n$(DISK_DW_NAME)
	$(MERGE) $(KERNEL_DW_BECKER)>kernel
	$(MERGE) $(OS9BOOT_DW_BECKER)>os9boot
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
	$(CPL) $(TEXTFILES_DW) $@,.
	$(OS9RENAME) $@,tOC_dw.txt tOC.txt
	$(OS9COPY) $(SUPPORTFILES_DW) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen $@,tOC.txt $@,tOC
	$(MOVE) toctmp tocgen

$(DISK_2_80D):
	$(RM) $@
	$(OS9FORMAT_DS80) -q $@ -n$(DISK_2_80D_NAME)
	$(OS9COPY) $(SUPPORTFILES_D2) $@,.

$(DISK_3_80D):
	$(RM) $@
	$(OS9FORMAT_DS80) -q $(DISK_3_80D) -n$(DISK_3_80D_NAME)
	$(OS9COPY) $(SUPPORTFILES_D3) $@,.

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

info:
	@$(ECHO) "*** Manhunter I ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)

