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

redisk:
	osascript -e 'tell application "DriveWire"' -e 'tell server of first document' -e 'reload drive 0' -e 'end tell' -e 'end tell'
	
dsk: all $(DSKS)

dskcopy: $(DSKS)
	$(CP) $(DSKS) $(DSKDIR)

reload:
	osascript -e 'tell application "DriveWire"' -e 'tell server of first document' -e 'reload drive 0' -e 'end tell' -e 'end tell'

basic09:
	$(CD) $(3RDPARTY)/packages/basic09; make

bf:
	$(CD) $(3RDPARTY)/packages/brainfuck; make

BASIC09_OBJS = $(shell $(CD) $(3RDPARTY)/packages/basic09; make --no-print-directory show6809objs)
BASIC09_FILES = $(shell $(CD) $(3RDPARTY)/packages/basic09; make --no-print-directory showfiles)
BF_OBJS = $(shell $(CD) $(3RDPARTY)/packages/brainfuck; make --no-print-directory showobjs)
BF_FILES = $(shell $(CD) $(3RDPARTY)/packages/brainfuck; make --no-print-directory showfiles)

$(DSKSD): basic09 bf
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
	$(CD) $(3RDPARTY)/packages/basic09; $(OS9COPY) $(BASIC09_OBJS) ../../../level1/f256/$@,CMDS
	$(OS9COPY) $(3RDPARTY)/packages/basic09/basic09_6809 $@,CMDS/basic09
	$(OS9COPY) $(3RDPARTY)/packages/basic09/runb_6809 $@,CMDS/runb
	$(OS9ATTR_EXEC) $@,CMDS/basic09
	$(OS9ATTR_EXEC) $@,CMDS/runb
	$(MAKDIR) $@,BRAINFUCK
	$(CD) $(3RDPARTY)/packages/brainfuck; $(OS9COPY) $(BF_OBJS) ../../../level1/f256/$@,CMDS
	$(CD) $(3RDPARTY)/packages/brainfuck; $(OS9COPY) $(BF_FILES) ../../../level1/f256/$@,BRAINFUCK
	$(OS9ATTR_EXEC) $(foreach file,$(BF_OBJS),$@,CMDS/$(file))
	$(RM) $(LDSKSD)
	$(SOFTLINK) $@ $(LDSKSD)

$(DSKDW): basic09 bf
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
	$(OS9COPY) $(3RDPARTY)/packages/basic09/basic09_6809 $@,CMDS/basic09
	$(OS9COPY) $(3RDPARTY)/packages/basic09/runb_6809 $@,CMDS/runb
	$(OS9ATTR_EXEC) $@,CMDS/basic09
	$(OS9ATTR_EXEC) $@,CMDS/runb
	$(MAKDIR) $@,BRAINFUCK
	$(CD) $(3RDPARTY)/packages/brainfuck; $(OS9COPY) $(BF_OBJS) ../../../level1/f256/$@,CMDS
	$(CD) $(3RDPARTY)/packages/brainfuck; $(CPL) $(BF_FILES) ../../../level1/f256/$@,BRAINFUCK
	$(OS9ATTR_EXEC) $(foreach file,$(BF_OBJS),$@,CMDS/$(file))
	$(RM) $(LDSKDW)
	$(SOFTLINK) $@ $(LDSKDW)

info:
	@$(ECHO) "*** NitrOS-9/$(CPU) Level $(LEVEL) for the $(MACHINE) ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
