include ../rules.mak

dirs	= drivers fmgrs p2mods subrtns utils packages

# Make all components
all:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*               3rd Party Software               *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) &&) :

# Clean all components
clean:
	$(foreach dir, $(dirs), ($(CD) $(dir); make clean);)

# Make DSK images
dsk:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dsk &&) :

# Clean DSK images
dskclean:
	$(foreach dir, $(dirs), ($(CD) $(dir); make dskclean);)

# Copy DSK images
dskcopy:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dskcopy &&) :

# Info
info:
	@$(foreach dir, $(dirs), $(MAKE) -C $(dir) info;)
