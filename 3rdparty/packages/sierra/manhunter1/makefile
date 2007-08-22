include $(NITROS9DIR)/rules.mak

vpath %.asm ../objs

DEPENDS		= ./makefile

DISK_1_80D	= manhunter1_d1_80d.dsk
DISK_2_80D	= manhunter1_d2_80d.dsk
DISK_3_80D	= manhunter1_d3_80d.dsk

DISK_1_80D_NAME = "Manhunter I Disk 1"
DISK_2_80D_NAME = "Manhunter I Disk 2"
DISK_3_80D_NAME = "Manhunter I Disk 3"

CMDS		= sierra mnln scrn shdw tocgen
MD		= $(LEVEL2)/coco3/modules

# We make our own bootfile and kernel track
KERNEL		= $(MD)/rel_32 $(MD)/boot_1773_6ms $(MD)/krn
OS9BOOT_80D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_80d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/keydrv_cc3.sb $(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

BOOTCMDS	= $(LEVEL2)/coco3/cmds/shell_21 $(LEVEL2)/coco3/cmds/date \
		$(LEVEL2)/coco3/cmds/echo $(LEVEL2)/coco3/cmds/link \
		$(LEVEL2)/coco3/cmds/setime

TEXTFILES_D1	= startup tOC_80d.txt
TEXTFILES	= startup tOC_80d.txt

SUPPORTFILES_D1	= logDir object picDir sndDir viewDir vol.0 \
		vol.2 vol.9 vol.10 vol.11 vol.12 words.tok

SUPPORTFILES_D2	= object vol.0 vol.4 vol.9 vol.10 vol.11 vol.12

SUPPORTFILES_D3	= object vol.0 vol.5 vol.9 vol.10 vol.11 vol.12

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:	dskclean
	$(RM) $(ALLOBJS)

dsk:	all
	$(RM) $(DISK_1_80D) $(DISK_2_80D) $(DISK_3_80D)
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_DS80) -q $(DISK_1_80D) -n$(DISK_1_80D_NAME)
	$(MERGE) $(OS9BOOT_80D)>os9boot_80d
	$(MERGE) $(KERNEL)>kernel_1773
	$(OS9GEN) $(DISK_1_80D) -b=os9boot_80d -t=kernel_1773
	$(RM) os9boot_80d os9boot_80d kernel_1773
	$(MAKDIR) $(DISK_1_80D),CMDS
	$(CP) $(CMDS) $(DISK_1_80D),CMDS
	$(foreach file, $(CMDS), $(OS9ATTR_EXEC) $(DISK_1_80D),CMDS/$(file);)
	$(MERGE) $(BOOTCMDS)>shell
	$(CP) shell $(DISK_1_80D),CMDS
	$(RM) shell
	$(OS9ATTR) $(DISK_1_80D),CMDS/shell -e -pe -pr -e -w -r
	$(OS9RENAME) $(DISK_1_80D),CMDS/sierra AutoEx
	$(CPL) $(TEXTFILES_D1) $(DISK_1_80D),.
	$(OS9RENAME) $(DISK_1_80D),tOC_80d.txt tOC.txt
	$(CP) $(SUPPORTFILES_D1) $(DISK_1_80D),.
	tocgen $(DISK_1_80D),tOC.txt $(DISK_1_80D),tOC
	$(OS9FORMAT_DS80) -q $(DISK_2_80D) -n$(DISK_2_80D_NAME)
	$(CP) $(SUPPORTFILES_D2) $(DISK_2_80D),.
	$(OS9FORMAT_DS80) -q $(DISK_3_80D) -n$(DISK_3_80D_NAME)
	$(CP) $(SUPPORTFILES_D3) $(DISK_3_80D),.

dskcopy: dsk
	$(CP) $(DISK_1_80D) $(DISK_2_80D) $(DISK_3_80D)

dskclean:
	$(RM) $(DISK_1_80D) $(DISK_2_80D) $(DISK_3_80D)