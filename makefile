
ifndef NITROS9DIR
NITROS9DIR = $(PWD)
endif

export NITROS9DIR
include rules.mak

dirs	=  $(NOSLIB) $(LEVEL1) $(LEVEL2) $(LEVEL3) $(3RDPARTY)

# Allow the user to specify a selection of ports to build
ifdef PORTS
dirs = $(NOSLIB)
dirs += $(filter $(foreach p,$(PORTS),$(LEVEL1)/$(p) $(LEVEL2)/$(p)),$(wildcard $(LEVEL1)/* $(LEVEL2)/*))
endif

# Make all components
all:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*              THE NITROS-9 PROJECT              *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) &&) :

# Clean all components
clean:
	$(RM) nitros9project.zip
	$(RM) $(DSKDIR)/*.dsk $(DSKDIR)/*.DSK $(DSKDIR)/*.img
	$(RM) $(DSKDIR)/ReadMe
	$(RM) $(DSKDIR)/index.html $(DSKDIR)/index.shtml
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) clean &&) :

# Make DSK images
dsk:	all
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dsk &&) :

# Copy DSK images
dskcopy:	all
	mkdir -p $(DSKDIR)
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dskcopy &&) :
	$(MKDSKINDEX) $(DSKDIR) > $(DSKDIR)/index.html

# Clean DSK images
dskclean:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dskclean &&) :

info:
	@$(foreach dir,$(dirs), $(MAKE) --no-print-directory -C $(dir) info &&) :

# This section is to do the nightly build and upload 
# to sourceforge.net you must set the environment
# variable SOURCEUSER to the userid you have for sourceforge.net
# The "burst" script is found in the scripts folder and must
# on your ssh account at sourceforge.net
ifdef	SOURCEUSER
nightly: clean dskcopy
	$(MAKE) info > $(DSKDIR)/ReadMe
	$(ARCHIVE) nitros9project $(DSKDIR)/*
	scp nitros9project.zip $(SOURCEUSER),nitros9@web.sourceforge.net:/home/project-web/nitros9/htdocs/nitros9project-$(shell date +%Y%m%d).zip 
	ssh $(SOURCEUSER),nitros9@shell.sourceforge.net create
	ssh $(SOURCEUSER),nitros9@shell.sourceforge.net "./burst nitros9project $(shell date +%Y%m%d)"
else
nightly:
	@$(ECHO) ""
	@$(ECHO) ""
	@$(ECHO) "You need to set the SOURCEUSER variable"
	@$(ECHO) "You may wish to refer to the nightly"
	@$(ECHO) "section of the makefile."
endif
