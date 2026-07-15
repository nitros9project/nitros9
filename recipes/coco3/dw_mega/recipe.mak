# CoCo 3 DriveWire "mega" recipe.
#
# Start with the standard CoCo 3 DriveWire configuration, add the Sierra AGI
# collection, then fetch and build maintained external OS-9 software at pinned
# revisions.

include ../dw/recipe.mak

RECIPE = coco3_dw_mega
SCF += vrn.dr vi.dd
CLEAN_DIRS += .external .sierra

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

SIERRA_ROOT = $(3RDPARTY)/packages/sierra
SIERRA_OBJDIR = $(SIERRA_ROOT)/objs
SIERRA_BUILD_DIR = .sierra
SIERRA_MAKE_TOC = ../sierra/make_toc.py
SIERRA_GAMES = blackcauldron christmas86 goldrush kingsquest1 kingsquest2 \
	kingsquest3 kingsquest4 leisuresuitlarry manhunter1 manhunter2 \
	policequest1 spacequest0 spacequest1 spacequest2
SIERRA_DATA_NAMES = logDir object picDir sndDir viewDir words.tok
SIERRA_DATA_FILES = $(foreach game,$(SIERRA_GAMES), \
	$(addprefix $(SIERRA_ROOT)/$(game)/,$(SIERRA_DATA_NAMES)) \
	$(wildcard $(SIERRA_ROOT)/$(game)/vol.*))

SIERRA_TOC_TXT_blackcauldron = $(SIERRA_ROOT)/blackcauldron/tOC_80d.txt
SIERRA_TOC_TXT_christmas86 = $(SIERRA_ROOT)/christmas86/tOC.txt
SIERRA_TOC_TXT_goldrush = $(SIERRA_ROOT)/goldrush/tOC_dw.txt
SIERRA_TOC_TXT_kingsquest1 = $(SIERRA_ROOT)/kingsquest1/tOC_80d.txt
SIERRA_TOC_TXT_kingsquest2 = $(SIERRA_ROOT)/kingsquest2/tOC_80d.txt
SIERRA_TOC_TXT_kingsquest3 = $(SIERRA_ROOT)/kingsquest3/tOC_80d.txt
SIERRA_TOC_TXT_kingsquest4 = $(SIERRA_ROOT)/kingsquest4/tOC_dw.txt
SIERRA_TOC_TXT_leisuresuitlarry = $(SIERRA_ROOT)/leisuresuitlarry/tOC.txt
SIERRA_TOC_TXT_manhunter1 = $(SIERRA_ROOT)/manhunter1/tOC_dw.txt
SIERRA_TOC_TXT_manhunter2 = $(SIERRA_ROOT)/manhunter2/tOC_dw.txt
SIERRA_TOC_TXT_policequest1 = $(SIERRA_ROOT)/policequest1/tOC_dw.txt
SIERRA_TOC_TXT_spacequest0 = $(SIERRA_ROOT)/spacequest0/tOC_dw.txt
SIERRA_TOC_TXT_spacequest1 = $(SIERRA_ROOT)/spacequest1/tOC_80d.txt
SIERRA_TOC_TXT_spacequest2 = $(SIERRA_ROOT)/spacequest2/tOC_80d.txt
SIERRA_TOCS = $(addsuffix /tOC,$(addprefix $(SIERRA_BUILD_DIR)/,$(SIERRA_GAMES)))

# The interpreter supports Version 3 story files. Override INFOCOM_STORY_DIR
# and INFOCOM_STORIES to package another legally obtained collection.
INFOCOM_STORY_DIR ?= $(3RDPARTY)/packages/cpm/software/zork
INFOCOM_STORIES ?= ZORK1.DAT ZORK2.DAT ZORK3.DAT
INFOCOM_STORY_FILES = $(addprefix $(INFOCOM_STORY_DIR)/,$(INFOCOM_STORIES))

CMDS_EXTRA += forth09 infocom raakatu sierra mnln scrn shdw
RECIPE_DEPS += $(FORTH09_CMD) $(FORTH09_TEST) $(INFOCOM_CMD) $(RAAKATU_CMD) \
	$(INFOCOM_STORY_FILES) $(SIERRA_DATA_FILES) $(SIERRA_TOCS)

# Sierra's original sources select their own CPU paths and must not inherit the
# recipe's H6309 define. These commands are shared by every packaged game.
SIERRA_AFLAGS = $(filter-out -DH6309=0 -DH6309=1,$(AFLAGS))

$(MODDIR)/sierra: $(SIERRA_OBJDIR)/sierra.asm | $(MODDIR)
	$(AS) $(SIERRA_AFLAGS) $< $(ASOUT)$@

$(MODDIR)/mnln: $(SIERRA_OBJDIR)/mnln.asm | $(MODDIR)
	$(AS) $(SIERRA_AFLAGS) $< $(ASOUT)$@

$(MODDIR)/scrn: $(SIERRA_OBJDIR)/scrn.asm | $(MODDIR)
	$(AS) $(SIERRA_AFLAGS) $< $(ASOUT)$@

$(MODDIR)/shdw: $(SIERRA_OBJDIR)/shdw.asm | $(MODDIR)
	$(AS) $(SIERRA_AFLAGS) $< $(ASOUT)$@

define SIERRA_TOC_RULE
$(SIERRA_BUILD_DIR)/$(1)/tOC: $$(SIERRA_TOC_TXT_$(1)) $$(SIERRA_MAKE_TOC)
	@mkdir -p $$(@D)
	python3 $$(SIERRA_MAKE_TOC) $$< $$@
endef

$(foreach game,$(SIERRA_GAMES),$(eval $(call SIERRA_TOC_RULE,$(game))))

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
	$(MAKDIR) $(1),GAMES/SIERRA
	@for game in $(SIERRA_GAMES); do \
		$(MAKDIR) $(1),GAMES/SIERRA/$$game; \
		$(OS9COPY) $(SIERRA_ROOT)/$$game/logDir \
			$(SIERRA_ROOT)/$$game/object $(SIERRA_ROOT)/$$game/picDir \
			$(SIERRA_ROOT)/$$game/sndDir $(SIERRA_ROOT)/$$game/viewDir \
			$(SIERRA_ROOT)/$$game/words.tok $(SIERRA_ROOT)/$$game/vol.* \
			$(1),GAMES/SIERRA/$$game; \
		$(CPL) $(SIERRA_BUILD_DIR)/$$game/tOC \
			$(1),GAMES/SIERRA/$$game/tOC; \
	done
	$(MAKDIR) $(1),FORTH09
	$(CPL) $(FORTH09_TEST) $(1),FORTH09/forthtest.4th
	$(OS9ATTR_TEXT) $(1),FORTH09/forthtest.4th
endef
