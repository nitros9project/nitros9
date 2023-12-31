include port.mak

DISTRO		= $(CPU)L$(LEVEL)
DISTRONAME	= NOS9_$(CPU)_L$(LEVEL)
DISTROVER	= $(DISTRONAME)_$(NITROS9VER)_$(PORT)
BOOTFILE_DW	= bootfiles/bootfile_dw
DIRS		= defs cmds modules sys bootfiles wwwroot

CMDS		= $(shell $(CD) cmds; make --no-print-directory showobjs)
CMDS_DW		= $(shell $(CD) cmds; make --no-print-directory showobjs_dw)
KERNEL		= $(shell $(CD) modules; make --no-print-directory showkernel)
SYSMODS		= $(shell $(CD) modules; make --no-print-directory showsysmods)
CLOCKS		= $(shell $(CD) modules; make --no-print-directory showclocks)
RBF		= $(shell $(CD) modules; make --no-print-directory showrbf)
SCF		= $(shell $(CD) modules; make --no-print-directory showscf)
PIPE		= $(shell $(CD) modules; make --no-print-directory showpipe)

DEFS		= $(shell $(CD) defs; make --no-print-directory showobjs)
SYSBIN		= $(shell $(CD) sys; make --no-print-directory showbinobjs)
SYSTEXT		= $(shell $(CD) sys; make --no-print-directory showtextobjs)
STARTUP		= startup
STARTUP_DW	= startup.dw
SYSGO		= sysgo_dd

DSKSD		= $(DISTROVER)_sd.dsk
LDSKSD		= $(DISTRONAME)_sd.dsk
DSKDW		= $(DISTROVER)_dw.dsk
LDSKDW		= $(DISTRONAME)_dw.dsk

DSKS		= $(DSKSD) $(DSKDW)
LDSKS	= $(LDSKSD) $(LDSKDW)

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
	osascript -e 'tell application "DriveWire"' -e 'tell server of first document' -e 'reload drive 0' -e 'end tell' -e 'end tell'

BASIC09_FILES = $(foreach file,$(3RDPARTY)/packages/basic09/samples/*.b09,$(file))
ROGUE_OBJS = $(shell $(CD) $(3RDPARTY)/packages/rogue; make --no-print-directory showobjs)
ROGUE_FILES = $(shell $(CD) $(3RDPARTY)/packages/rogue; make --no-print-directory showfiles)
BF_FILES = $(foreach file,$(3RDPARTY)/packages/brainfuck/*.bf,$(file))
CPM_FILES = $(3RDPARTY)/packages/cpm/software

$(DSKSD):
	$(RM) $@
	$(OS9FORMAT_F256SD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_sd $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shellplus ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
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
	$(MAKDIR) $@,BRAINFUCK
	$(CPL) $(BF_FILES) $@,BRAINFUCK
	os9 dsave -e $(CPM_FILES) $@,CPM
	$(RM) $(LDSKSD)
	$(SOFTLINK) $@ $(LDSKSD)

$(DSKDW):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_dw $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shellplus ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,ROGUE
	$(CD) $(3RDPARTY)/packages/rogue; $(OS9COPY) $(ROGUE_OBJS) ../../../level2/f256/$@,CMDS
	$(CD) $(3RDPARTY)/packages/rogue; $(OS9COPY) $(ROGUE_FILES) ../../../level2/f256/$@,ROGUE
	$(OS9ATTR_EXEC) $(foreach file,$(ROGUE_OBJS),$@,CMDS/$(file))
	$(MAKDIR) $@,BRAINFUCK
	$(CPL) $(BF_FILES) $@,BRAINFUCK
	os9 dsave -e $(CPM_FILES) $@,CPM	
	$(RM) $(LDSKDW)
	$(SOFTLINK) $@ $(LDSKDW)

info:
	@$(ECHO) "*** NitrOS-9/$(CPU) Level $(LEVEL) for the $(MACHINE) ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
