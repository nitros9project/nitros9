LEVEL = 2
CMOC_OS9_DIR ?= $(abspath ../../../../cmoc_os9)
include ../coco3.mak

UTILPAK1 = attr build copy del deldir dir display list makdir mdir merge mfree procs rename tmode

ifeq ($(CPU),6309)
AFLAGS := $(filter-out -DH6309=1,$(AFLAGS))
else
AFLAGS := $(filter-out -DH6309=0,$(AFLAGS))
endif

CMOC_OS9_LIB_DIR ?= $(CMOC_OS9_DIR)/lib
CMOC_OS9_CGFX_DIR ?= $(CMOC_OS9_DIR)/cgfx
CMOC_OS9_UNITTEST_DIR ?= $(CMOC_OS9_DIR)/unittest
CMOC_OS9_GRAPHICTEST_DIR ?= $(CMOC_OS9_DIR)/graphictest
CMOC_OS9_SYSGO ?= sysgo_dd

$(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a:
	$(MAKE) -C $(CMOC_OS9_LIB_DIR) libc.a libcf.a

$(CMOC_OS9_CGFX_DIR)/libcgfx.a:
	$(MAKE) -C $(CMOC_OS9_CGFX_DIR) libcgfx.a

$(CMOC_OS9_UNITTEST_DIR)/%: $(CMOC_OS9_UNITTEST_DIR)/%.c $(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a $(CMOC_OS9_CGFX_DIR)/libcgfx.a
	$(MAKE) -C $(CMOC_OS9_UNITTEST_DIR) $(@F)

$(CMOC_OS9_GRAPHICTEST_DIR)/%: $(CMOC_OS9_GRAPHICTEST_DIR)/%.c $(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a $(CMOC_OS9_CGFX_DIR)/libcgfx.a
	$(MAKE) -C $(CMOC_OS9_UNITTEST_DIR) $(@F)

$(addprefix $(MODDIR)/,$(CMOC_OS9_TESTS)): $(MODDIR)/%: $(CMOC_OS9_UNITTEST_DIR)/% | $(MODDIR)
	$(CP) $(CMOC_OS9_UNITTEST_DIR)/$(@F) $@

$(addprefix $(MODDIR)/,$(CMOC_OS9_GRAPHICS_TESTS)): $(MODDIR)/%: $(CMOC_OS9_UNITTEST_DIR)/% | $(MODDIR)
	$(CP) $(CMOC_OS9_UNITTEST_DIR)/$(@F) $@

$(DSKIMAGE): kernelfile bootfile $(MODDIR)/$(CMOC_OS9_SYSGO) $(addprefix $(MODDIR)/,$(CMDS)) $(STARTUP) $(CMOC_OS9_TESTSCRIPT)
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=bootfile -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) $(MODDIR)/$(CMOC_OS9_SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(CPL) $(CMOC_OS9_TESTSCRIPT) $@,test
	$(OS9ATTR_TEXT) $@,test
