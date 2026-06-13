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

# Loadable modules — on disk in /Modules, not baked into bootfile
# Note: rammer.dr, r0.dd, rbdw.dr, dwio.sb, x0.dd are in bootfile
LOADMODS    = $(addprefix modules/,$(GFX) \
              ddx0.dd \
              scdwv.dr term_scdwv.dt n_scdwv.dd \
              n1_scdwv.dd n2_scdwv.dd n3_scdwv.dd n4_scdwv.dd \
              i0_pt.dd i1_pt.dd i2_pt.dd i3_pt.dd \
              i4_pt.dd i5_pt.dd i6_pt.dd i7_pt.dd \
              j0_pt.dd j1_pt.dd j2_pt.dd j3_pt.dd \
              j4_pt.dd j5_pt.dd j6_pt.dd j7_pt.dd \
              clock2_dw)

# All modules for large disk images (everything except kernel pair and raw REL)
ALLMODS      = $(addprefix modules/,$(filter-out krn krnp2 rel_picothing,\
                  $(SYSMODS) $(CLOCKS) $(RBF) $(SCF) $(GFX) $(DW) $(PIPE)))

DSK_PT      = $(DISTROVER).dsk
DSK_X0      = $(DISTROVER)_x0.dsk
DSK_I0      = $(DISTROVER)_i0.dsk
DSKS        = $(DSK_PT) $(DSK_X0) $(DSK_I0)

# Make all components
all: _build_banner _build_subdirs

.PHONY: _build_banner _build_subdirs

_build_banner:
	@$(ECHO) "************************************************************"
	@$(ECHO) "*"
	@$(ECHO) "*      NitrOS-9/$(CPU) Level $(LEVEL) $(MACHINE) ($(PORT))"
	@$(ECHO) "*"
	@$(ECHO) "************************************************************"
	$(MAKE) -C $(NITROS9DIR)/lib

_build_subdirs: _build_banner
	$(foreach dir,$(DIRS),$(MAKE) -C $(dir) &&) :

# Clean all components
clean: dskclean
	$(foreach dir,$(DIRS),$(MAKE) -C $(dir) clean &&) :

dskclean:
	$(RM) $(DSKS)

# dsk always rebuilds subdirs first, then disk images
dsk: _build_subdirs $(DSKS)

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

# Standard SD boot disk (SS35, boots from /DD = /I0 via IDE)
$(DSK_PT):
	$(RM) $@
	$(OS9FORMAT_DS80) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
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
	$(MAKDIR) $@,Modules
	$(OS9COPY) $(LOADMODS) $@,Modules
	$(OS9ATTR_EXEC) $(foreach mod,$(notdir $(LOADMODS)),$@,Modules/$(mod))

$(DSK_X0):
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
	$(MAKDIR) $@,Modules
	$(OS9COPY) $(ALLMODS) $@,Modules
	$(OS9ATTR_EXEC) $(foreach mod,$(notdir $(ALLMODS)),$@,Modules/$(mod))

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
	$(MAKDIR) $@,Modules
	$(OS9COPY) $(ALLMODS) $@,Modules
	$(OS9ATTR_EXEC) $(foreach mod,$(notdir $(ALLMODS)),$@,Modules/$(mod))

info:
	@$(ECHO) "*** NitrOS-9/$(CPU) Level $(LEVEL) for the $(MACHINE) ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)

