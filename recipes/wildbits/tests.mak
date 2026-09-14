# Level 2 TESTS overlay: sources stay in the repository.
ifeq ($(LEVEL),2)
override TESTS_DIR = $(LEVEL2)/wildbits/tests
override TESTS =
TESTS_RAW = l1_platform_80x15 l2_mountains_40x15 l3_clouds_40x15
override TESTS_BIN = $(filter-out $(TESTS_RAW),$(notdir $(basename $(wildcard $(TESTS_DIR)/*.asm))))
RECIPE_DEPS += $(filter-out %.asm,$(wildcard $(TESTS_DIR)/*)) $(addprefix $(MODDIR)/,$(addsuffix .bin,$(TESTS_RAW)))

all:
$(addprefix $(MODDIR)/,$(filter-out sprites math fpu dma,$(TESTS_BIN))): $(MODDIR)/%: $(TESTS_DIR)/%.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(addprefix $(MODDIR)/,$(addsuffix .bin,$(TESTS_RAW))): $(MODDIR)/%.bin: $(TESTS_DIR)/%.asm | $(MODDIR)
	$(AS) $(AFLAGS) --format=raw $< $(ASOUT)$@

define RECIPE_INSTALL
	$(OS9COPY) $(filter-out %.asm $(addprefix $(TESTS_DIR)/,$(addsuffix .bin,$(TESTS_RAW))),$(wildcard $(TESTS_DIR)/*)) $(1),TESTS
	$(OS9COPY) $(addprefix $(MODDIR)/,$(addsuffix .bin,$(TESTS_RAW))) $(1),TESTS
endef
endif
