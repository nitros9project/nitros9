# CoCo 3 DriveWire "mega" recipe.
#
# Start with the standard CoCo 3 DriveWire configuration, then fetch and build
# maintained external OS-9 software at pinned revisions.

include ../dw/recipe.mak

RECIPE = coco3_dw_mega
TELNET_PORT ?= 6809
HTTPD_PORT ?= 8809
BBS_PORT ?= 6909
SCF += scdwp.dr p_scdwp.dd \
	midi_scdwv.dd \
	z1_scdwv.dd z2_scdwv.dd z3_scdwv.dd \
	z4_scdwv.dd z5_scdwv.dd z6_scdwv.dd z7_scdwv.dd
CLEAN_DIRS += .external
CLEAN_EXTRA += .inetd.conf

EXTERNAL_DIR ?= .external
COCO_SHELF ?= $(abspath $(NITROS9DIR)/..)

INFOCOM_REPO ?= https://github.com/rlucente-retro/infocom-os9-port.git
INFOCOM_REF ?= 23c88a7d40f0591c451ca53fbe7887a30f559718
INFOCOM_SRC = $(EXTERNAL_DIR)/infocom-os9-port
INFOCOM_CHECKOUT = $(INFOCOM_SRC)/.checkout-$(INFOCOM_REF)
INFOCOM_CMD = $(INFOCOM_SRC)/infocom

RAAKATU_REPO ?= https://github.com/drpitre/raakatu.git
RAAKATU_REF ?= 14f175c3d20ffad71fb960d989a25c7904e3fd7d
RAAKATU_SRC = $(EXTERNAL_DIR)/raakatu
RAAKATU_CHECKOUT = $(RAAKATU_SRC)/.checkout-$(RAAKATU_REF)
RAAKATU_STORY = $(RAAKATU_SRC)/raakatu.z3

FORTH09_REPO ?= https://github.com/drpitre/forth09.git
FORTH09_REF ?= c96200c25ee1e9a1091f52d42d5a452d9802c9cb
FORTH09_SRC = $(EXTERNAL_DIR)/forth09
FORTH09_CHECKOUT = $(FORTH09_SRC)/.checkout-$(FORTH09_REF)
FORTH09_COCO_DIR = $(FORTH09_SRC)/coco
FORTH09_CMD = $(FORTH09_COCO_DIR)/forth09
FORTH09_TEST = $(FORTH09_COCO_DIR)/forthtest.4th

OS9L2BBS_DIR ?= $(NITROS9_APPS_DIR)/os9l2bbs
OS9L2BBS_BUILD_DIR = $(OS9L2BBS_DIR)/6809l2
OS9L2BBS_DSK = $(OS9L2BBS_BUILD_DIR)/OS9L2BBS.dsk

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

CMDS_EXTRA += forth09 infocom
RECIPE_DEPS += $(FORTH09_CMD) $(FORTH09_TEST) $(INFOCOM_CMD) \
	$(INFOCOM_STORY_FILES) $(RAAKATU_STORY) $(OS9L2BBS_DSK) \
	bbslogin .inetd.conf

.inetd.conf: inetd.conf
	@sed -e 's/%TELNET_PORT%/$(TELNET_PORT)/' \
		-e 's/%HTTPD_PORT%/$(HTTPD_PORT)/' \
		-e 's/%BBS_PORT%/$(BBS_PORT)/' $< > $@

# The shared image builder copies commands from $(MODDIR). Link the external
# build products there so they go through the normal copy and attribute path.
$(MODDIR)/infocom: $(INFOCOM_CMD) | $(MODDIR)
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

$(RAAKATU_STORY): $(RAAKATU_CHECKOUT)
	@test -f $@

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

$(OS9L2BBS_DSK):
	$(MAKE) -C $(OS9L2BBS_DIR) --no-print-directory NITROS9DIR=$(NITROS9DIR)

define RECIPE_INSTALL
	$(CPL) .inetd.conf $(1),SYS/inetd.conf -r
	$(OS9ATTR_TEXT) $(1),SYS/inetd.conf
	$(MAKDIR) $(1),GAMES
	$(MAKDIR) $(1),GAMES/INFOCOM
	@for story in $(INFOCOM_STORY_FILES); do \
		story_name=$${story##*/}; \
		story_name=$$(printf '%s' "$$story_name" | tr '[:upper:]' '[:lower:]'); \
		$(OS9COPY) "$$story" "$(1),GAMES/INFOCOM/$$story_name"; \
	done
	$(OS9COPY) $(RAAKATU_STORY) $(1),GAMES/INFOCOM
	$(MAKDIR) $(1),FORTH09
	$(CPL) $(FORTH09_TEST) $(1),FORTH09/forthtest.4th
	$(OS9ATTR_TEXT) $(1),FORTH09/forthtest.4th
	$(OS9) dsave -e -r $(OS9L2BBS_DSK),CMDS $(1),CMDS
	@for cmd in $$($(OS9) dir $(OS9L2BBS_DSK),CMDS | tail -n +3); do \
		$(OS9ATTR_EXEC) "$(1),CMDS/$$cmd"; \
	done
	$(MAKDIR) $(1),BBS
	$(OS9) dsave -e -r $(OS9L2BBS_DIR)/bbs $(1),BBS
	$(CPL) bbslogin $(1),BBS/bbslogin -r
	$(OS9ATTR_EXEC) $(1),BBS/bbslogin
	@find $(OS9L2BBS_DIR)/bbs -type f -print | while IFS= read -r file; do \
		rel=$${file#$(OS9L2BBS_DIR)/bbs/}; \
		case "$$rel" in \
			BBS.userstats|*/BBS.mail.inx|*/bbs.msg.inx|*/DLD.key|*/DLD.lst|*/Quikterm) ;; \
			*) $(CPL) "$$file" "$(1),BBS/$$rel" -r ;; \
		esac; \
	done
endef
