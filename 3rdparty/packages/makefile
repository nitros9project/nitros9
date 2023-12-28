include $(NITROS9DIR)/rules.mak

dirs	= arcadepak basic09 brainfuck cpm deskmate3 ccompiler flightsim2 koronis kyumgai mmission multivue os9l2bbs pacos9 rescueof rogue sierra subsim uucpbb #raakatu

# Make all components
all:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*               3rd Party Packages               *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) &&) :

# Clean all components
clean:
	$(foreach dir, $(dirs), ($(CD) $(dir); make clean);)

# Create dsk images
dsk:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dsk &&) :

# Copy dsk images
dskcopy:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dskcopy &&) :

# Clean dsk images
dskclean:
	$(foreach dir, $(dirs), ($(CD) $(dir); make dskclean);)

# Info
info:
	@$(foreach dir, $(dirs), $(MAKE) -C $(dir) info; $(ECHO);)
