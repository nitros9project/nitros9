# CoCo 3 DriveWire "mega" recipe.
#
# Start with the standard CoCo 3 DriveWire configuration, then fetch and
# build maintained external OS-9 software at pinned revisions.

include ../dw/recipe.mak

RECIPE = coco3_dw_mega
SCF += scdwp.dr p_scdwp.dd \
	midi_scdwv.dd \
	z1_scdwv.dd z2_scdwv.dd z3_scdwv.dd \
	z4_scdwv.dd z5_scdwv.dd z6_scdwv.dd z7_scdwv.dd
CLEAN_DIRS += .external

EXTERNAL_DIR ?= .external
COCO_SHELF ?= $(abspath $(NITROS9DIR)/..)

INFOCOM_REPO ?= https://github.com/rlucente-retro/infocom-os9-port.git
INFOCOM_REF ?= 23c88a7d40f0591c451ca53fbe7887a30f559718
INFOCOM_SRC = $(EXTERNAL_DIR)/infocom-os9-port
INFOCOM_CHECKOUT = $(INFOCOM_SRC)/.checkout-$(INFOCOM_REF)
INFOCOM_CMD = $(INFOCOM_SRC)/infocom

RAAKATU_REPO ?= https://github.com/drpitre/raakatu.git
RAAKATU_REF ?= 9777b7f626ecece7992ac384d3c94ed306417365
RAAKATU_SRC = $(EXTERNAL_DIR)/raakatu
RAAKATU_CHECKOUT = $(RAAKATU_SRC)/.checkout-$(RAAKATU_REF)
RAAKATU_CMD = $(RAAKATU_SRC)/raakatu

FORTH09_REPO ?= https://github.com/drpitre/forth09.git
FORTH09_REF ?= c96200c25ee1e9a1091f52d42d5a452d9802c9cb
FORTH09_SRC = $(EXTERNAL_DIR)/forth09
FORTH09_CHECKOUT = $(FORTH09_SRC)/.checkout-$(FORTH09_REF)
FORTH09_COCO_DIR = $(FORTH09_SRC)/coco
FORTH09_CMD = $(FORTH09_COCO_DIR)/forth09
FORTH09_TEST = $(FORTH09_COCO_DIR)/forthtest.4th

# The interpreter supports Version 3 story files. Override INFOCOM_STORY_DIR
# and INFOCOM_STORIES to package another legally obtained collection.
INFOCOM_STORY_DIR ?= $(NITROS9_APPS_DIR)/cpm/software/zork
INFOCOM_STORIES ?= ZORK1.DAT ZORK2.DAT ZORK3.DAT
INFOCOM_STORY_FILES = $(addprefix $(INFOCOM_STORY_DIR)/,$(INFOCOM_STORIES))

$(MODDIR)/midi_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=14

$(MODDIR)/z1_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=17

$(MODDIR)/z2_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=18

$(MODDIR)/z3_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=19

$(MODDIR)/z4_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=20

$(MODDIR)/z5_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=21

$(MODDIR)/z6_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=22

$(MODDIR)/z7_scdwv.dd: scdwvdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DAddr=23

CMDS_EXTRA += forth09 infocom raakatu
RECIPE_DEPS += $(FORTH09_CMD) $(FORTH09_TEST) $(INFOCOM_CMD) $(RAAKATU_CMD) $(INFOCOM_STORY_FILES)

# The shared image builder copies commands from $(MODDIR). Link the external
# build products there so they go through the normal copy and attribute path.
$(MODDIR)/infocom: $(INFOCOM_CMD) | $(MODDIR)
	ln -sf $(abspath $<) $@

$(MODDIR)/raakatu: $(RAAKATU_CMD) | $(MODDIR)
	ln -sf $(abspath $<) $@

$(MODDIR)/forth09: $(FORTH09_CMD) | $(MODDIR)
	ln -sf $(abspath $<) $@

$(INFOCOM_CHECKOUT):
	@mkdir -p $(EXTERNAL_DIR)
	@if test ! -d $(INFOCOM_SRC)/.git; then git clone $(INFOCOM_REPO) $(INFOCOM_SRC); fi
	git -C $(INFOCOM_SRC) fetch --depth 1 origin $(INFOCOM_REF)
	git -C $(INFOCOM_SRC) checkout --detach $(INFOCOM_REF)
	@touch $@

$(RAAKATU_CHECKOUT):
	@mkdir -p $(EXTERNAL_DIR)
	@if test ! -d $(RAAKATU_SRC)/.git; then git clone $(RAAKATU_REPO) $(RAAKATU_SRC); fi
	git -C $(RAAKATU_SRC) fetch --depth 1 origin $(RAAKATU_REF)
	git -C $(RAAKATU_SRC) checkout --detach $(RAAKATU_REF)
	@touch $@

$(FORTH09_CHECKOUT):
	@mkdir -p $(EXTERNAL_DIR)
	@if test ! -d $(FORTH09_SRC)/.git; then git clone $(FORTH09_REPO) $(FORTH09_SRC); fi
	git -C $(FORTH09_SRC) fetch --depth 1 origin $(FORTH09_REF)
	git -C $(FORTH09_SRC) checkout --detach $(FORTH09_REF)
	@touch $@

$(INFOCOM_CMD): $(INFOCOM_CHECKOUT)
	$(MAKE) -C $(INFOCOM_SRC) --no-print-directory NITROS9DIR=$(NITROS9DIR) infocom

$(RAAKATU_CMD): $(RAAKATU_CHECKOUT)
	$(MAKE) -C $(RAAKATU_SRC) --no-print-directory os9 \
		COCO_SHELF=$(COCO_SHELF) \
		CMOC=$(COCO_SHELF)/bin/cmoc \
		CMOC_OS9_DIR=$(COCO_SHELF)/cmoc_os9

$(FORTH09_CMD): $(FORTH09_CHECKOUT)
	$(COCO_SHELF)/bin/cmoc --cpp="cpp -Wno-builtin-macro-redefined" \
		--os9 --add-os9-stack-space=16384 -D_strass=memcpy \
		-I$(COCO_SHELF)/cmoc_os9/include --compile \
		-o $(FORTH09_COCO_DIR)/main.o $(FORTH09_SRC)/main.c
	$(COCO_SHELF)/bin/cmoc --cpp="cpp -Wno-builtin-macro-redefined" \
		--os9 --add-os9-stack-space=16384 -D_strass=memcpy \
		-I$(COCO_SHELF)/cmoc_os9/include --compile \
		-o $(FORTH09_COCO_DIR)/dictiona.o $(FORTH09_SRC)/dictiona.c
	$(COCO_SHELF)/bin/cmoc --cpp="cpp -Wno-builtin-macro-redefined" \
		--os9 --add-os9-stack-space=16384 -D_strass=memcpy \
		-I$(COCO_SHELF)/cmoc_os9/include --compile \
		-o $(FORTH09_COCO_DIR)/basic_fu.o $(FORTH09_SRC)/basic_fu.c
	$(COCO_SHELF)/bin/cmoc --cpp="cpp -Wno-builtin-macro-redefined" \
		--os9 --add-os9-stack-space=16384 -o $@ \
		$(FORTH09_COCO_DIR)/main.o $(FORTH09_COCO_DIR)/dictiona.o \
		$(FORTH09_COCO_DIR)/basic_fu.o -L$(COCO_SHELF)/cmoc_os9/lib -lc

define RECIPE_INSTALL
	$(MAKDIR) $(1),GAMES
	$(MAKDIR) $(1),GAMES/INFOCOM
	$(OS9COPY) $(INFOCOM_STORY_FILES) $(1),GAMES/INFOCOM
	$(MAKDIR) $(1),FORTH09
	$(CPL) $(FORTH09_TEST) $(1),FORTH09/forthtest.4th
	$(OS9ATTR_TEXT) $(1),FORTH09/forthtest.4th
endef
