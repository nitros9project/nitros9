include $(NITROS9DIR)/rules.mak

dirs	= coco1 coco1_6309 deluxe coco2 coco2_6309 coco2b tano d64 dalpha atari \
		 corsham f256 #dplus
ifdef PORTS
dirs	= $(PORTS)
endif

# Make all components
all:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*             NitrOS-9 Level 1 Ports             *"
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
	@$(foreach dir, $(dirs), $(MAKE) -C $(dir) info; $(ECHO);)

