ifeq ($(LEVEL),1)
SYSDIR = .sys
$(SYSDIR):
	mkdir -p $@
SHELLMODS = shellplus date deiniz echo iniz link load save unlink
$(MODDIR)/shell: $(MODDIR)/shellplus | $(MODDIR)
	$(CP) $< $@
endif
