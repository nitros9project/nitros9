include port.mak

DISTRO      = $(CPU)L$(LEVEL)
DISTRONAME  = NOS9_$(CPU)_L$(LEVEL)
DISTROVER   = $(DISTRONAME)_$(NITROS9VER)_$(PORT)

BOOTFILE_PT = bootfiles/bootfile_pt
DIRS        = cmds modules sys bootfiles

CMDS        = $(shell $(CD) cmds; make --no-print-directory showobjs)
KERNEL      = $(shell $(CD) modules; make --no-print-directory showkernel)
SYSMODS     = $(shell $(CD) modules; make --no-print-directory showsysmods)
CLOCKS      = $(shell $(CD) modules; make --no-print-directory showclocks)
RBF         = $(shell $(CD) modules; make --no-print-directory showrbf)
SCF         = $(shell $(CD) modules; make --no-print-directory showscf)
GFX         = $(shell $(CD) modules; make --no-print-directory showgfx)
DW          = $(shell $(CD) modules; make --no-print-directory showdw)
PIPE        = $(shell $(CD) modules; make --no-print-directory showpipe)

SYSBIN      = $(shell $(CD) sys; make --no-print-directory showbinobjs)
SYSTEXT     = $(shell $(CD) sys; make --no-print-directory showtextobjs)
STARTUP     = startup
SYSGO       = sysgo

DSK_PT      = $(DISTROVER).dsk
DSK_I0      = $(DISTROVER)_i0.dsk
DSKS        = $(DSK_PT) $(DSK_I0)

# Make all components
all:
	@$(ECHO) "************************************************************"
	@$(ECHO) "*"
	@$(ECHO) "*      NitrOS-9/$(CPU) Level $(LEVEL) $(MACHINE) ($(PORT))"
	@$(ECHO) "*"
	@$(ECHO) "************************************************************"
	$(MAKE) -C $(NITROS9DIR)/lib
	$(foreach dir,$(DIRS),$(MAKE) -C $(dir) &&) :

# Clean all components
clean: dskclean
	$(foreach dir,$(DIRS),$(MAKE) -C $(dir) clean &&) :

dskclean:
	$(RM) $(DSKS)

dsk: all $(DSKS)

dskcopy: $(DSKS)
	$(CP) $(DSKS) $(DSKDIR)

$(DSK_PT):
	$(RM) $@
	$(OS9FORMAT) -l4194304 -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_PT)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(OS9COPY) bootfiles/os9kernel $@,OS9Kernel
	$(OS9ATTR_EXEC) $@,OS9Kernel
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup

# IDE partition volume (512MB = 2097152 sectors, matches /I0 geometry)
$(DSK_I0):
	$(RM) $@
	$(OS9FORMAT) -l2097152 -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_PT)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(OS9COPY) bootfiles/os9kernel $@,OS9Kernel
	$(OS9ATTR_EXEC) $@,OS9Kernel
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup

info:
	@$(ECHO) "*** NitrOS-9/$(CPU) Level $(LEVEL) for the $(MACHINE) ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)

