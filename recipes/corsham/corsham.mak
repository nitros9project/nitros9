PORT = corsham
CPU = 6809
LEVEL = 1
.DEFAULT_GOAL := all
include ../rules.mak

AFLAGS += -I. -I$(L1PD) -I$(L1PMD) -I$(L1MD)/kernel -I$(L1MD) -DH6309=0
ROM_MODULES = krn krnp2 init boot_cshsd
ROM_PARTS = $(addprefix $(MODDIR)/,$(ROM_MODULES))

# $F000-$FEFF holds the kernel, Init, and SD booter. REL and its hardware
# vectors must remain at $FF00-$FFFF. The lower half of the 8K EPROM is padding.
all: bootrom

bootrom: $(ROM_PARTS) $(MODDIR)/rel corsham.mak
	$(MERGE) $(ROM_PARTS) > bootrom_p1
	$(PADROM) 3840 bootrom_p1
	$(MERGE) bootrom_p1 $(MODDIR)/rel > $@.tmp
	$(PADROM) 8192 -b $@.tmp
	$(MOVE) $@.tmp $@
	$(RM) bootrom_p1

check: bootrom
	python3 $(NITROS9DIR)/scripts/check-corsham-rom.py bootrom

clean:
	$(RM) -r $(MODDIR)
	$(RM) bootrom bootrom.tmp bootrom_p1 buildinfo

.PHONY: all check clean
