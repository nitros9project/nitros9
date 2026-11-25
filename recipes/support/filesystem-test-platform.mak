# Test cases and assertions are shared; only boot/device setup depends on level.
ifeq ($(LEVEL),1)
PORT = coco1
CPU ?= 6809
ifneq ($(CPU),6809)
$(error Level One runtime profiles currently require CPU=6809)
endif
MAME_MACHINE ?= coco2b
SCF = scf vtio covdg term_vdg
ifneq ($(strip $(RBF)),)
RBF = rbf rb1773 ddd0_$(TRACKS)d d0_$(TRACKS)d
endif
override CMDS_BASE := $(filter-out grfdrv utilpak1,$(CMDS_BASE)) echo load $(if $(filter utilpak1,$(CMDS_BASE)),attr build copy del deldir dir display list makdir mdir merge mfree procs rename tmode,)
# FAT-root tests load SysGo from FAT; floppy tests keep the usual resident SysGo.
BOOTMODS = ioman $(RBF) $(SCF) $(PIPE) $(CLOCK) $(BOOTMODS_EXTRA) $(if $(TEST_FAT_ROOT),,sysgo_dd)
TEST_PLATFORM_MAKE = ../../coco/coco.mak
else ifeq ($(LEVEL),2)
MAME_MACHINE ?= $(if $(filter 6309,$(CPU)),coco3h,coco3)
TEST_PLATFORM_MAKE = ../coco3.mak
else
$(error Filesystem integration supports LEVEL=1 or LEVEL=2)
endif
AFLAGS_EXTRA += -DTEST_LEVEL=$(LEVEL) -DNOPAUSE=1 $(if $(TEST_INTERACTIVE),,-DTEST_STARTUP=1)
TEST_MACHINE_FLAGS = --level $(LEVEL) --machine $(MAME_MACHINE)
