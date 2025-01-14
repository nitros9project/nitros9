include port.mak

DISTRO		= $(CPU)L$(LEVEL)
DISTRONAME	= NOS9_$(CPU)_L$(LEVEL)
DISTROVER	= $(DISTRONAME)_$(NITROS9VER)_$(PORT)
DIRS		= defs libs cmds modules sys sys/fonts bootfiles wwwroot feu

CMDS		= $(shell $(CD) cmds; make --no-print-directory showobjs)
KERNEL		= $(shell $(CD) modules; make --no-print-directory showkernel)
SYSMODS		= $(shell $(CD) modules; make --no-print-directory showsysmods)
CLOCKS		= $(shell $(CD) modules; make --no-print-directory showclocks)
RBF		= $(shell $(CD) modules; make --no-print-directory showrbf)
SCF		= $(shell $(CD) modules; make --no-print-directory showscf)
PIPE		= $(shell $(CD) modules; make --no-print-directory showpipe)

DEFS		= $(shell $(CD) defs; make --no-print-directory showobjs)
SYSBIN		= $(shell $(CD) sys; make --no-print-directory showbinfiles)
SYSTEXT		= $(shell $(CD) sys; make --no-print-directory showtextfiles)
STARTUP		= startup
SCRIPTS     = $(shell $(CD) scripts; echo *)
TESTS       = $(shell $(CD) tests; echo *)
SYSGO		= sysgo

DSKSD_F256K		= $(DISTROVER)k_sd.dsk
DSKDW_F256K		= $(DISTROVER)k_dw.dsk

DSKSD_F256JR		= $(DISTROVER)jr_sd.dsk
DSKDW_F256JR		= $(DISTROVER)jr_dw.dsk

DSKS		= $(DSKSD_F256K) $(DSKDW_F256K) $(DSKSD_F256JR) $(DSKDW_F256JR)

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

redisk:
	osascript -e 'tell application "DriveWire"' -e 'tell server of first document' -e 'reload drive 0' -e 'end tell' -e 'end tell'
	
dsk: all $(DSKS)

dskcopy: $(DSKS)
	$(CP) $(DSKS) $(DSKDIR)

reload:
	osascript -e 'tell application "DriveWire"' -e 'tell server of first document' -e 'reload drive 0' -e 'end tell' -e 'end tell'

BASIC09_FILES = $(foreach file,$(3RDPARTY)/packages/basic09/samples/*.b09,$(file))
BF_FILES = $(foreach file,$(3RDPARTY)/packages/bf/*.bf,$(file))
SOUND_FILES = $(foreach file,sound/*,$(file))

$(DSKSD_F256K):
	$(RM) $@
	$(OS9FORMAT_F256SD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_sd_f256k $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shellplus ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,BF
	$(CPL) $(BF_FILES) $@,BF
	$(MAKDIR) $@,SOUNDS
	$(OS9COPY) $(SOUND_FILES) $@,SOUNDS
	$(MAKDIR) $@,SCRIPTS
	$(CD) scripts; $(CPL) $(SCRIPTS) ../$@,SCRIPTS
	$(MAKDIR) $@,TESTS
	$(CD) tests; $(CPL) $(TESTS) ../$@,TESTS

$(DSKDW_F256K):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_dw_f256k $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shellplus ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,BF
	$(CPL) $(BF_FILES) $@,BF
	$(MAKDIR) $@,SOUNDS
	$(OS9COPY) $(SOUND_FILES) $@,SOUNDS
	$(MAKDIR) $@,SCRIPTS
	$(CD) scripts; $(CPL) $(SCRIPTS) ../$@,SCRIPTS
	$(MAKDIR) $@,TESTS
	$(CD) tests; $(CPL) $(TESTS) ../$@,TESTS

$(DSKSD_F256JR):
	$(RM) $@
	$(OS9FORMAT_F256SD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_sd_f256jr $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shellplus ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,BF
	$(CPL) $(BF_FILES) $@,BF
	$(MAKDIR) $@,SOUNDS
	$(OS9COPY) $(SOUND_FILES) $@,SOUNDS
	$(MAKDIR) $@,SCRIPTS
	$(CD) scripts; $(CPL) $(SCRIPTS) ../$@,SCRIPTS
	$(MAKDIR) $@,TESTS
	$(CD) tests; $(CPL) $(TESTS) ../$@,TESTS

$(DSKDW_F256JR):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9COPY) bootfiles/bootfile_dw_f256jr $@,OS9Boot
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) -r shellplus ../$@,CMDS/shell
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_FILES) $@,BASIC09
	$(MAKDIR) $@,BF
	$(CPL) $(BF_FILES) $@,BF
	$(MAKDIR) $@,SOUNDS
	$(OS9COPY) $(SOUND_FILES) $@,SOUNDS
	$(MAKDIR) $@,SCRIPTS
	$(CD) scripts; $(CPL) $(SCRIPTS) ../$@,SCRIPTS
	$(MAKDIR) $@,TESTS
	$(CD) tests; $(CPL) $(TESTS) ../$@,TESTS

info:
	@$(ECHO) "*** NitrOS-9/$(CPU) Level $(LEVEL) for the $(MACHINE) ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)


c1.dsk:
	$(OS9FORMAT) -q -t120 -st16 $@ -n"F256 Flash Disk"
	$(MAKDIR) $@,CMDS
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))

flash_c1: c1.dsk
	rm bulk.csv
	i=0; while [ "$$i" -le 59 ]; do \
		vv=`printf "%02x" $$i`; \
		dd status=none bs=8k skip=$$i count=1 if=$^ of=c1_$$vv; \
		echo "$$vv,c1_$$vv" >> bulk.csv; \
		i=$$((i + 1));\
	done	
	bulk_flash bulk.csv
	rm c1_* bulk.csv
