# HDB-DOS loads only the kernel track; all OS files are served through RFM.
include ../dw/recipe.mak
RECIPE = coco3_rfm
RECIPE_OUTPUTS = prepare
RBF =
KERNEL_TRACK = rel_80 boot_rfm krn
BOOTMODS = krnp2 ioman init \
	rfm rfmdrv dwio.sb dd_rfm \
	$(SCF) $(PIPE) $(CLOCK) $(BOOTMODS_EXTRA)
