# Rules for commands supplied by the sibling nitros9-languages repository.

BASIC09_CPU := $(if $(filter 6309,$(CPU)),6309,6809)
BASIC09_DIR := $(LANGUAGES)/basic09

basic09: $(BASIC09_DIR)/basic09_$(BASIC09_CPU)
	$(CP) $< $@

runb: $(BASIC09_DIR)/runb_$(BASIC09_CPU)
	$(CP) $< $@

$(BASIC09_DIR)/basic09_$(BASIC09_CPU):
	$(MAKE) -C $(BASIC09_DIR) basic09_$(BASIC09_CPU)

$(BASIC09_DIR)/runb_$(BASIC09_CPU):
	$(MAKE) -C $(BASIC09_DIR) runb_$(BASIC09_CPU)
