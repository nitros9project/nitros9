include $(NITROS9DIR)/rules.mak

vpath %.asm ../objs

DEPENDS		= ./makefile

DISK_1_40D	= blackcauldron_d1_40d.dsk
DISK_2_40D	= blackcauldron_d2_40d.dsk

DISK_1_40D_NAME = "The Black Cauldron Disk 1"
DISK_2_40D_NAME = "The Black Cauldron Disk 2"

CMDS		= sierra mnln scrn shdw tocgen
MD		= $(LEVEL2)/coco3/modules

# We make our own bootfile and kernel track
KERNEL		= $(MD)/rel_32 $(MD)/boot_1773_6ms $(MD)/krn
OS9BOOT_40D	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_40d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/keydrv_cc3.sb $(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

BOOTCMDS	= $(LEVEL2)/coco3/cmds/shell_21 $(LEVEL2)/coco3/cmds/date \
		$(LEVEL2)/coco3/cmds/echo $(LEVEL2)/coco3/cmds/link \
		$(LEVEL2)/coco3/cmds/setime

TEXTFILES_D1	= startup tOC_40d.txt
TEXTFILES	= startup tOC_40d.txt

SUPPORTFILES_D1	= logDir object picDir sndDir viewDir vol.0 \
		vol.1

SUPPORTFILES_D2	= object vol.0 vol.2

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:	dskclean
	$(RM) $(ALLOBJS)

dsk:	all
	$(RM) $(DISK_1_40D) $(DISK_2_40D)
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_DS40) -q $(DISK_1_40D) -n$(DISK_1_40D_NAME)
	$(MERGE) $(OS9BOOT_40D)>os9boot_40d
	$(MERGE) $(KERNEL)>kernel_1773
	$(OS9GEN) $(DISK_1_40D) -b=os9boot_40d -t=kernel_1773
	$(RM) os9boot_40d os9boot_40d kernel_1773
	$(MAKDIR) $(DISK_1_40D),CMDS
	$(CP) $(CMDS) $(DISK_1_40D),CMDS
	$(foreach file, $(CMDS), $(OS9ATTR_EXEC) $(DISK_1_40D),CMDS/$(file);)
	$(MERGE) $(BOOTCMDS)>shell
	$(CP) shell $(DISK_1_40D),CMDS
	$(RM) shell
	$(OS9ATTR) $(DISK_1_40D),CMDS/shell -e -pe -pr -e -w -r
	$(OS9RENAME) $(DISK_1_40D),CMDS/sierra AutoEx
	$(CPL) $(TEXTFILES_D1) $(DISK_1_40D),.
	$(OS9RENAME) $(DISK_1_40D),tOC_40d.txt tOC.txt
	$(CP) $(SUPPORTFILES_D1) $(DISK_1_40D),.
	tocgen $(DISK_1_40D),tOC.txt $(DISK_1_40D),tOC
	$(OS9FORMAT_DS40) -q $(DISK_2_40D) -n$(DISK_2_40D_NAME)
	$(CP) $(SUPPORTFILES_D2) $(DISK_2_40D),.

dskcopy: dsk
	$(CP) $(DISK_1_40D) $(DISK_2_40D)

dskclean:
	$(RM) $(DISK_1_40D) $(DISK_2_40D) $(DISK_3_40D)