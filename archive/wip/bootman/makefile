include ../rules.mak

BOOTMAN = bootman_coco_6551 bootman_coco3_6551

all: $(BOOTMAN)

bootman_coco_6551: bootman.o boot_config.o mach_coco.o llio_6551.o llbt_1773.o
	$(LINKER) $^ -o$@

bootman_coco3_6551: bootman.o boot_config.o mach_coco3.o llio_6551.o llbt_1773.o
	$(LINKER) $^ -o$@

dsk: $(BOOTMAN)
	decb dskini BootMman.dsk
	decb copy -b -2 bootman_coco_6551 BootMan.dsk,BM6551.BIN
	decb copy -b -2 bootman_coco3_6551 BootMan.dsk,BM36551.BIN

dskclean:
	$(RM) BootMan.dsk

clean: dskclean
	$(RM) *.o bootman_coco_6551 bootman_coco3_6551 BootMan.dsk
