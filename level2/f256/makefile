include port.mak

DISTRO		= $(CPU)L$(LEVEL)
DISTRONAME	= NOS9_$(CPU)_L$(LEVEL)
DISTROVER	= $(DISTRONAME)_$(NITROS9VER)_$(PORT)
DIRS		= defs libs cmds modules sys sys/fonts bootfiles wwwroot

CMDS		= $(shell $(CD) cmds; make --no-print-directory showobjs)
CMDS_DW		= $(shell $(CD) cmds; make --no-print-directory showobjs_dw)
CMDS_CART       = $(shell $(CD) cmds; make --no-print-directory showobjs_cart)
KERNEL		= $(shell $(CD) modules; make --no-print-directory showkernel)
SYSMODS		= $(shell $(CD) modules; make --no-print-directory showsysmods)
CLOCKS		= $(shell $(CD) modules; make --no-print-directory showclocks)
RBF		= $(shell $(CD) modules; make --no-print-directory showrbf)
SCF		= $(shell $(CD) modules; make --no-print-directory showscf)
PIPE		= $(shell $(CD) modules; make --no-print-directory showpipe)

DEFS		= $(shell $(CD) defs; make --no-print-directory showobjs)
SYSBIN		= $(shell $(CD) sys; make --no-print-directory showbinobjs)
SYSTEXT		= $(shell $(CD) sys; make --no-print-directory showtextobjs)
FONTS	        = $(shell $(CD) sys/fonts; make --no-print-directory showobjs)
STARTUP		= startup
SCRIPTS     = $(shell $(CD) ../../level1/f256/scripts; echo *)
TESTS       = $(shell $(CD) ../../level1/f256/tests; echo *)
SYSGO		= sysgo

DSKSD_F256K		= $(DISTROVER)k_sd.dsk
DSKDW_F256K		= $(DISTROVER)k_dw.dsk
DSKSD_F256JR		= $(DISTROVER)jr_sd.dsk
DSKDW_F256JR		= $(DISTROVER)jr_dw.dsk
DSKCART_F256JR          = $(DISTROVER)jr_cart.dsk

#DSKS	= $(DSKSD_F256K) $(DSKDW_F256K) $(DSKSD_F256JR) $(DSKDW_F256JR) $(DSKCART_F256JR)
DSKS	= $(DSKSD_F256JR) $(DSKCART_F256JR)

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
	$(RM) $(DSKS) $(LDSKS)

dsk: all $(DSKS)

dskcopy: $(DSKS)
	$(CP) $(DSKS) $(DSKDIR)

reload:
	osascript -e 'tell application "DriveWire"' -e 'tell server of every document' -e 'reload drive 0' -e 'end tell' -e 'end tell'

BASIC09_FILES = $(foreach file,$(3RDPARTY)/packages/basic09/samples/*.b09,$(file))
ROGUE_OBJS = $(shell $(CD) $(3RDPARTY)/packages/rogue; make --no-print-directory showobjs)
ROGUE_FILES = $(shell $(CD) $(3RDPARTY)/packages/rogue; make --no-print-directory showfiles)
BF_FILES = $(foreach file,$(3RDPARTY)/packages/bf/*.bf,$(file))
CPM_FILES = $(3RDPARTY)/packages/cpm/software
SOUND_FILES = $(foreach file,$(LEVEL1)/f256/sound/*,$(file))

$(DSKSD_F256K):
	$(RM) $@
	$(OS9FORMAT_F256SD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_sd_f256k $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,SYS/FONTS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shell ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) sys/fonts; $(OS9COPY) $(FONTS) ../../$@,SYS/FONTS
	$(OS9ATTR_EXEC) $(foreach file,$(FONTS),$@,SYS/FONTS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,ROGUE
	$(CD) $(3RDPARTY)/packages/rogue; $(OS9COPY) $(ROGUE_OBJS) ../../../level2/f256/$@,CMDS
	$(CD) $(3RDPARTY)/packages/rogue; $(OS9COPY) $(ROGUE_FILES) ../../../level2/f256/$@,ROGUE
	$(OS9ATTR_EXEC) $(foreach file,$(ROGUE_OBJS),$@,CMDS/$(file))
	$(MAKDIR) $@,BF
	$(CPL) $(BF_FILES) $@,BF
	$(MAKDIR) $@,SOUNDS
	$(OS9COPY) $(SOUND_FILES) $@,SOUNDS
	os9 dsave -e $(CPM_FILES) $@,CPM
	$(MAKDIR) $@,SCRIPTS
	$(foreach file,$(SCRIPTS),$(CPL) ../../level1/f256/scripts/$(file) $@,SCRIPTS;)
	$(MAKDIR) $@,TESTS
	$(foreach file,$(TESTS),$(CPL) ../../level1/f256/tests/$(file) $@,TESTS;)
	$(MAKDIR) $@,FEU
	$(OS9COPY) -l FEU/startup_s0 $@,FEU/startup

$(DSKDW_F256K):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_dw_f256k $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,SYS/FONTS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shell ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) sys/fonts; $(OS9COPY) $(FONTS) ../../$@,SYS/FONTS
	$(OS9ATTR_EXEC) $(foreach file,$(FONTS),$@,SYS/FONTS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,ROGUE
	$(CD) $(3RDPARTY)/packages/rogue; $(OS9COPY) $(ROGUE_OBJS) ../../../level2/f256/$@,CMDS
	$(CD) $(3RDPARTY)/packages/rogue; $(OS9COPY) $(ROGUE_FILES) ../../../level2/f256/$@,ROGUE
	$(OS9ATTR_EXEC) $(foreach file,$(ROGUE_OBJS),$@,CMDS/$(file))
	$(MAKDIR) $@,BF
	$(CPL) $(BF_FILES) $@,BF
	$(MAKDIR) $@,SOUNDS
	$(OS9COPY) $(SOUND_FILES) $@,SOUNDS
	os9 dsave -e $(CPM_FILES) $@,CPM	
	$(MAKDIR) $@,SCRIPTS
	$(foreach file,$(SCRIPTS),$(CPL) ../../level1/f256/scripts/$(file) $@,SCRIPTS;)
	$(MAKDIR) $@,TESTS
	$(foreach file,$(TESTS),$(CPL) ../../level1/f256/tests/$(file) $@,TESTS;)
	$(MAKDIR) $@,FEU
	$(OS9COPY) -l FEU/startup_x0 $@,FEU/startup

$(DSKSD_F256JR):
	$(RM) $@
	$(OS9FORMAT_F256SD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_sd_f256jr $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,SYS/FONTS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shell ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) sys/fonts; $(OS9COPY) $(FONTS) ../../$@,SYS/FONTS
	$(OS9ATTR_EXEC) $(foreach file,$(FONTS),$@,SYS/FONTS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,ROGUE
	$(CD) $(3RDPARTY)/packages/rogue; $(OS9COPY) $(ROGUE_OBJS) ../../../level2/f256/$@,CMDS
	$(CD) $(3RDPARTY)/packages/rogue; $(OS9COPY) $(ROGUE_FILES) ../../../level2/f256/$@,ROGUE
	$(OS9ATTR_EXEC) $(foreach file,$(ROGUE_OBJS),$@,CMDS/$(file))
	$(MAKDIR) $@,BF
	$(CPL) $(BF_FILES) $@,BF
	$(MAKDIR) $@,SOUNDS
	$(OS9COPY) $(SOUND_FILES) $@,SOUNDS
#	os9 dsave -e $(CPM_FILES) $@,CPM
	$(MAKDIR) $@,SCRIPTS
	$(foreach file,$(SCRIPTS),$(CPL) ../../level1/f256/scripts/$(file) $@,SCRIPTS;)
	$(MAKDIR) $@,TESTS
	$(foreach file,$(TESTS),$(CPL) ../../level1/f256/tests/$(file) $@,TESTS;)
	$(MAKDIR) $@,FEU
	$(OS9COPY) -l FEU/startup_s0 $@,FEU/startup
	
$(DSKDW_F256JR):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_dw_f256jr $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,SYS/FONTS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shell ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) sys/fonts; $(OS9COPY) $(FONTS) ../../$@,SYS/FONTS
	$(OS9ATTR_EXEC) $(foreach file,$(FONTS),$@,SYS/FONTS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,ROGUE
	$(CD) $(3RDPARTY)/packages/rogue; $(OS9COPY) $(ROGUE_OBJS) ../../../level2/f256/$@,CMDS
	$(CD) $(3RDPARTY)/packages/rogue; $(OS9COPY) $(ROGUE_FILES) ../../../level2/f256/$@,ROGUE
	$(OS9ATTR_EXEC) $(foreach file,$(ROGUE_OBJS),$@,CMDS/$(file))
	$(MAKDIR) $@,BF
	$(CPL) $(BF_FILES) $@,BF
	$(MAKDIR) $@,SOUNDS
	$(OS9COPY) $(SOUND_FILES) $@,SOUNDS
	os9 dsave -e $(CPM_FILES) $@,CPM	
	$(MAKDIR) $@,SCRIPTS
	$(foreach file,$(SCRIPTS),$(CPL) ../../level1/f256/scripts/$(file) $@,SCRIPTS;)
	$(MAKDIR) $@,TESTS
	$(foreach file,$(TESTS),$(CPL) ../../level1/f256/tests/$(file) $@,TESTS;)
	$(MAKDIR) $@,FEU
	$(OS9COPY) -l FEU/startup_x0 $@,FEU/startup

$(DSKCART_F256JR):
	$(RM) $@
	$(OS9FORMAT_CART) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_cart_f256jr $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_CART) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shell ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_CART),$@,CMDS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,SCRIPTS
	$(foreach file,$(SCRIPTS),$(CPL) ../../level1/f256/scripts/$(file) $@,SCRIPTS;)
	$(MAKDIR) $@,FEU
	$(OS9COPY) -l FEU/startup_c0 $@,FEU/startup

info:
	@$(ECHO) "*** NitrOS-9/$(CPU) Level $(LEVEL) for the $(MACHINE) ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
