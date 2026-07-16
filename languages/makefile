include $(NITROS9DIR)/rules.mak

dirs = basic09 bf ccompiler

all:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                    Languages                   *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) &&) :

clean:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) clean &&) :

dsk:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dsk &&) :

dskcopy:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dskcopy &&) :

dskclean:
	$(foreach dir,$(dirs),$(MAKE) -C $(dir) dskclean &&) :

info:
	@$(foreach dir,$(dirs),$(MAKE) --no-print-directory -C $(dir) info &&) :
