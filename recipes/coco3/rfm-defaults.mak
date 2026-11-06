# Shared RFM-only system configuration; transport modules come from each recipe.
include ../dw/recipe.mak
RECIPE_OUTPUTS = prepare
RBF =
KERNEL_TRACK = rel_80 $(DW_BOOT_MODULE) krn
BOOTMODS = krnp2 ioman init \
	rfm rfmdrv $(DWIO_MODULE) dd_rfm \
	$(SCF) $(PIPE) $(CLOCK) $(BOOTMODS_EXTRA)
