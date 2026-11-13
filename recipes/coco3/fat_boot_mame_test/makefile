# DOS still loads the kernel track from floppy; Boot loads OS9Boot from FAT32.
override RECIPE := coco3_fat_boot_mame_test
KERNEL_TRACK = $(REL) boot_fat32 krn
FATAUTO = ../fat_mame_test/fatauto
MAME_TEST_FLAGS = --fat-boot
FAT_BOOT = 1
FAT_IMAGE = .fat-test/fat32-boot.vhd
include ../fat_mame_test/makefile
$(FAT_IMAGE): bootfile $(NITROS9DIR)/scripts/make-fat32-image.py
	$(PYTHON) $(NITROS9DIR)/scripts/make-fat32-image.py $@ --boot-file bootfile
