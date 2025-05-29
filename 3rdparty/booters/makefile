include ../../rules.mak

DEPENDS		= ./makefile
BOOTERS_L2	= boot_vhd boot_mmc_l2
BOOTERS_L1	= boot_mmc_l1
ALLOBJS		= $(BOOTERS_L2) $(BOOTERS_L1)

all:	$(ALLOBJS) $(DEPENDS)

clean:
	$(RM) $(ALLOBJS) *.list *.map

dsk:
dskcopy:

# OS-9 Level Two Booters
boot_ktlr_id0: boot_scsi.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=2 -DKTLR=1 -Dscsiid=1

boot_ktlr_id5: boot_scsi.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=2 -DKTLR=1 -Dscsiid=32

boot_tc3_id0: boot_scsi.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=2 -DTC3=1 -Dscsiid=1

boot_tc3_id5: boot_scsi.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=2 -DTC3=1 -Dscsiid=32

boot_vhd: boot_vhd.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=2

boot_mmc_l2: boot_mmc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=2

# OS-9 Level One Booters
boot_ktlr_id0_l1: boot_scsi.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=1 -DKTLR=1 -Dscsiid=1

boot_ktlr_id5_l1: boot_scsi.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=1 -DKTLR=1 -Dscsiid=32

boot_tc3_id0_l1: boot_scsi.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=1 -DTC3=1 -Dscsiid=1

boot_tc3_id5_l1: boot_scsi.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=1 -DTC3=1 -Dscsiid=32

boot_mmc_l1: boot_mmc.asm
	$(AS) $(AFLAGS) $(ASOUT)$@ $< -DLevel=1


