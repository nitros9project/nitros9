include port.mak

# Level 1 - Specify which shell should be used
#WHICHSHELL	= shellplus
WHICHSHELL	= shell_21

DISTRO		= $(CPU)L$(LEVEL)
DISTRONAME	= NOS9_$(CPU)_L$(LEVEL)
DISTROVER	= $(DISTRONAME)_$(NITROS9VER)_$(PORT)
BOOTFILE	= bootfiles/bootfile
DIRS		= cmds modules defs sys bootfiles


CMDS		= $(shell $(CD) cmds; make --no-print-directory showobjs)
CMDS_DEMO = $(shell $(CD) cmds; make --no-print-directory showobjs_demo)
SYSTEXT		= $(shell $(CD) sys; make --no-print-directory showtextfiles)
SYSBIN		= $(shell $(CD) sys; make --no-print-directory showbinfiles)
DEFS		= $(shell $(CD) defs; make --no-print-directory showobjs)
STARTUP		= startup

DSK		= $(DISTROVER).dsk

DSKS		= $(DSK)

# Make all components
all:
	@$(ECHO) "************************************************************"
	@$(ECHO) "*"
	@$(ECHO) "*      NitrOS-9/$(CPU) Level $(LEVEL) $(MACHINE) ($(PORT))"
	@$(ECHO) "*"
	@$(ECHO) "************************************************************"
	$(foreach dir,$(DIRS),$(MAKE) -C $(dir) &&) :

# Clean all components
clean:	dskclean
	$(foreach dir,$(DIRS),$(MAKE) -C $(dir) clean &&) :

dskclean:
	$(RM) $(DSKS)

dsk: all $(DSKS)

copyToSDAndEject: $(DSK)
	$(CP) $(DSK) /Volumes/CORSHAM/NOS9.DSK
	diskutil eject /Volumes/CORSHAM

dskcopy: $(DSKS)
	$(CP) $(DSKS) $(DSKDIR)

$(DSK):
	$(RM) $@
	$(OS9FORMAT_DW) -e -q $@ -n"NitrOS-9/$(CPU) Level 1"
	$(OS9GEN) $@ -b=$(BOOTFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/$(WHICHSHELL) shell
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup

info:
	@$(ECHO) "*** NitrOS-9/6809 Level 1 for the Corsham 6809 SS-50 ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)

