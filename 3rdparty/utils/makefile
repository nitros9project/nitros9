include ../../rules.mak

dirs	= boisy dasm smartwatch supercomm dladd winfo gene tlindner fpgarom sleuth3 xcom9

# Make all components
all:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                    Utilities                   *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) &&) :

# Clean all components
clean:
	$(foreach dir, $(dirs), ($(CD) $(dir); make clean);)

# Make DSK images
dsk:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dsk &&) :

dskclean:
	$(foreach dir, $(dirs), ($(CD) $(dir); make dskclean);)

# Copy DSK images
dskcopy:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dskcopy &&) :

# info
info:
	@$(foreach dir, $(dirs), $(MAKE) -C $(dir) info; $(ECHO);)
