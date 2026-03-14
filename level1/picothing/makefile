include port.mak

# Level 1 - Specify which shell should be used
WHICHSHELL	= shell_21

DISTRO		= $(CPU)L$(LEVEL)
DISTRONAME	= NOS9_$(CPU)_L$(LEVEL)
DISTROVER	= $(DISTRONAME)_$(NITROS9VER)_$(PORT)
BOOTFILE	= bootfiles/bootfile
OS9KERNEL_IDE	= bootfiles/os9kernel
OS9KERNEL_DW	= bootfiles/os9kernel_dw
DIRS		= cmds modules defs sys bootfiles

CMDS		= $(shell $(CD) cmds; make --no-print-directory showobjs)
SYSTEXT		= $(shell $(CD) sys; make --no-print-directory showtextfiles)
SYSBIN		= $(shell $(CD) sys; make --no-print-directory showbinfiles)
DEFS		= $(shell $(CD) defs; make --no-print-directory showobjs)
STARTUP		= startup

DSK_IDE		= $(DISTROVER).dsk
DSK_DW		= $(DISTROVER)_dw.dsk

DSKS		= $(DSK_IDE) $(DSK_DW)

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

dskcopy: $(DSKS)
	$(CP) $(DSKS) $(DSKDIR)

# IDE boot disk image
$(DSK_IDE):
	$(RM) $@
	$(OS9FORMAT_DS80) -q $@ -n"NitrOS-9/$(CPU) Level 1"
	$(OS9GEN) $@ -b=$(BOOTFILE)
	$(OS9COPY) $(OS9KERNEL_IDE) $@,OS9Kernel
	$(OS9ATTR_EXEC) $@,OS9Kernel
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

# DriveWire boot disk image
$(DSK_DW):
	$(RM) $@
	$(OS9FORMAT_DS80) -q $@ -n"NitrOS-9/$(CPU) Level 1 DW"
	$(OS9GEN) $@ -b=$(BOOTFILE)
	$(OS9COPY) $(OS9KERNEL_DW) $@,OS9Kernel
	$(OS9ATTR_EXEC) $@,OS9Kernel
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
	@$(ECHO) "*** NitrOS-9/6809 Level 1 for the Pico-Thing ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
