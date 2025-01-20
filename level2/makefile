include $(NITROS9DIR)/rules.mak

dirs	= coco3 coco3_6309 coco3fpga f256 realcocofpga #mc09l2
ifdef PORTS
dirs	= $(PORTS)
endif

# Make all components
all:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*             NitrOS-9 Level 2 Ports             *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) &&) :

# Clean all components
clean:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) clean &&) :

# Make DSK images
dsk:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dsk &&) :

# Copy DSK images
dskcopy:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dskcopy &&) :

# Clean DSK images
dskclean:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dskclean &&) :

# Info
info:
	@$(foreach dir,$(dirs),$(MAKE) -C $(dir) info; $(ECHO);)
