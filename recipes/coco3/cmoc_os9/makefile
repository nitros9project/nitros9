LEVEL = 2
CMOC_OS9_DIR ?= $(abspath ../../../../cmoc_os9)
include ../coco3.mak
include $(CMOC_OS9_DIR)/recipes/coco3/cmoc_os9/nitros9.mak

$(addprefix $(CMOC_OS9_UNITTEST_DIR)/,$(CMOC_OS9_GRAPHICS_TESTS)): $(CMOC_OS9_LIB_DIR)/libc.a $(CMOC_OS9_LIB_DIR)/libcf.a $(CMOC_OS9_CGFX_DIR)/libcgfx.a
	$(MAKE) -C $(CMOC_OS9_UNITTEST_DIR) $(@F)
