# Pico-Thing Level 2 "mega" payload (shared by l2_mega and l2dw_mega).
#
# Expands the standard Level 2 image onto a 4 MB solid-state volume and adds
# the maintained language toolchains from the sibling nitros9-languages
# checkout: Microware BASIC09 (interpreter + RunB runtime + sample programs)
# and the OS-9 C compiler.  The standard commands cputype and reboot round
# out the utility set (neither is in the base Level 2 command list).
#
# Unlike the CoCo 3 and Wildbits mega images this recipe deliberately leaves
# out Forth, the Level 2 BBS, and the Infocom interpreter/stories.

# 4 MB solid volume: 16384 * 256-byte sectors.  Replaces the 720K DS80
# floppy geometry that the base recipe formats.
OS9FORMAT_CMD = os9 format -e -l16384

# ---- BASIC09 (from nitros9-languages) ------------------------------------

BASIC09_CPU := $(if $(filter 6309,$(CPU)),6309,6809)
BASIC09_DIR := $(LANGUAGES)/basic09
BASIC09_SAMPLES = $(BASIC09_DIR)/kernel_utility.b09 \
                  $(wildcard $(BASIC09_DIR)/samples/*)

$(MODDIR)/basic09: $(BASIC09_DIR)/basic09_$(BASIC09_CPU) | $(MODDIR)
	$(CP) $< $@
$(MODDIR)/runb: $(BASIC09_DIR)/runb_$(BASIC09_CPU) | $(MODDIR)
	$(CP) $< $@

$(BASIC09_DIR)/basic09_$(BASIC09_CPU):
	$(MAKE) -C $(BASIC09_DIR) basic09_$(BASIC09_CPU)
$(BASIC09_DIR)/runb_$(BASIC09_CPU):
	$(MAKE) -C $(BASIC09_DIR) runb_$(BASIC09_CPU)

# ---- OS-9 C compiler (from nitros9-languages) ----------------------------

CCOMPILER_DIR ?= $(LANGUAGES)/ccompiler
CCOMPILER_DSK = $(CCOMPILER_DIR)/CCompiler.dsk
CCOMPILER_INPUTS = $(CCOMPILER_DIR)/Makefile $(CCOMPILER_DIR)/defsfile \
                   $(wildcard $(CCOMPILER_DIR)/*.asm) \
                   $(wildcard $(CCOMPILER_DIR)/defs/*) \
                   $(wildcard $(CCOMPILER_DIR)/lib/*) \
                   $(wildcard $(CCOMPILER_DIR)/sources/*)

$(CCOMPILER_DSK): $(CCOMPILER_INPUTS)
	$(MAKE) -C $(CCOMPILER_DIR) --no-print-directory \
		NITROS9DIR=$(NITROS9DIR) CCompiler.dsk

# ---- extra commands and disk install -------------------------------------

# basic09 and runb are copied through the normal $(MODDIR) command path;
# cputype (level1/cmds) and reboot (level2/cmds) resolve via the shared
# vpath in rules.mak.
CMDS_EXTRA += basic09 runb cputype reboot

RECIPE_DEPS += $(CCOMPILER_DSK)

# The C compiler ships as its own OS-9 disk; dsave its CMDS, LIB, DEFS and
# SOURCES trees onto the mega image.
define RECIPE_INSTALL
	$(OS9) dsave -e -r $(CCOMPILER_DSK),CMDS $(1),CMDS
	@for cmd in $$($(OS9) dir $(CCOMPILER_DSK),CMDS | tail -n +3); do \
		$(OS9ATTR_EXEC) "$(1),CMDS/$$cmd"; \
	done
	$(MAKDIR) $(1),LIB
	$(OS9) dsave -e -r $(CCOMPILER_DSK),LIB $(1),LIB
	$(MAKDIR) $(1),DEFS
	$(OS9) dsave -e -r $(CCOMPILER_DSK),DEFS $(1),DEFS
	$(MAKDIR) $(1),SOURCES
	$(OS9) dsave -e -r $(CCOMPILER_DSK),SOURCES $(1),SOURCES
endef
