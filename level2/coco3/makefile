include port.mak

DISTRO		= $(CPU)L$(LEVEL)
DISTRONAME	= NOS9_$(CPU)_L$(LEVEL)
DISTROVER	= $(DISTRONAME)_$(NITROS9VER)_$(PORT)
BOOTFILE_DW	= bootfiles/bootfile_dw
BOOTFILE_BECKER	= bootfiles/bootfile_becker
BOOTFILE_COCOLINK	= bootfiles/bootfile_cocolink
BOOTFILE_RS232PAK	= bootfiles/bootfile_rs232pak
BOOTFILE_DIRECTMODEMPAK	= bootfiles/bootfile_directmodempak
BOOTFILE_ARDUINO	= bootfiles/bootfile_arduino
BOOTFILE_COCOSDC	= bootfiles/bootfile_cocosdc
BOOTFILE_DW_HEADLESS	= bootfiles/bootfile_dw_headless
BOOTFILE_BECKER_HEADLESS	= bootfiles/bootfile_becker_headless
BOOTFILE_COCOLINK_HEADLESS	= bootfiles/bootfile_cocolink_headless
BOOTFILE_RS232PAK_HEADLESS	= bootfiles/bootfile_rs232pak_headless
BOOTFILE_DIRECTMODEMPAK_HEADLESS	= bootfiles/bootfile_directmodempak_headless
BOOTFILE_ARDUINO_HEADLESS	= bootfiles/bootfile_arduino_headless
BOOTFILE_40D	= bootfiles/bootfile_40d
BOOTFILE_80D	= bootfiles/bootfile_80d
BOOTFILE_40D_50HZ	= bootfiles/bootfile_40d_50hz
BOOTFILE_80D_50HZ	= bootfiles/bootfile_80d_50hz
BOOTFILE_EMUDSK	= bootfiles/bootfile_emudsk
KERNELFILE	= bootfiles/kernel_1773
KERNELFILE_50HZ	= bootfiles/kernel_1773_50hz
KERNELFILE_DW	= bootfiles/kernel_dw
KERNELFILE_BECKER	= bootfiles/kernel_becker
KERNELFILE_COCOLINK	= bootfiles/kernel_cocolink
KERNELFILE_RS232PAK	= bootfiles/kernel_rs232pak
KERNELFILE_DIRECTMODEMPAK	= bootfiles/kernel_directmodempak
KERNELFILE_ARDUINO	= bootfiles/kernel_arduino
KERNELFILE_COCOSDC	= bootfiles/kernel_cocosdc
DIRS		= defs cmds modules sys bootfiles wwwroot

CMDS		= $(shell $(CD) cmds; make --no-print-directory showobjs)
CMDS_D2		= $(shell $(CD) cmds; make --no-print-directory showobjs_d2)
CMDS_DW		= $(shell $(CD) cmds; make --no-print-directory showobjs_dw)
BOOTTRACK	= $(shell $(CD) modules; make --no-print-directory showboottrack)
KERNEL		= $(shell $(CD) modules; make --no-print-directory showkernel)
SYSMODS		= $(shell $(CD) modules; make --no-print-directory showsysmods)
CLOCKS		= $(shell $(CD) modules; make --no-print-directory showclocks)
RBF		= $(shell $(CD) modules; make --no-print-directory showrbf)
SCF		= $(shell $(CD) modules; make --no-print-directory showscf)
PIPE		= $(shell $(CD) modules; make --no-print-directory showpipe)
MODULECMDS	= shell grfdrv del echo format makdir merge os9gen prompt tmode

DEFS		= $(shell $(CD) defs; make --no-print-directory showobjs)
SYSBIN		= $(shell $(CD) sys; make --no-print-directory showbinobjs)
SYSTEXT		= $(shell $(CD) sys; make --no-print-directory showtextobjs)
STARTUP		= startup
STARTUP_DW	= startup.dw
SYSGO		= sysgo_dd
SYSGOBD		= sysgo_bd
CCBKRN		= ccbkrn

DSKDW		= $(DISTROVER)_dw.dsk
LDSKDW		= $(DISTRONAME)_dw.dsk
DSKDWHEADLESS	= $(DISTROVER)_dw_headless.dsk
LDSKDWHEADLESS	= $(DISTRONAME)_dw_headless.dsk
DSK360K_1	= $(DISTROVER)_40d_1.dsk
LDSK360K_1	= $(DISTRONAME)_40d_1.dsk
DSK360K_1_50HZ	= $(DISTROVER)_40d_1_50hz.dsk
LDSK360K_1_50HZ	= $(DISTRONAME)_40d_1_50hz.dsk
DSKBECKER	= $(DISTROVER)_becker.dsk
DSKARDUINO	= $(DISTROVER)_arduino.dsk
DSKCOCOSDC	= $(DISTROVER)_cocosdc.dsk
DSKBECKERHEADLESS	= $(DISTROVER)_becker_headless.dsk
DSKARDUINOHEADLESS	= $(DISTROVER)_arduino_headless.dsk
DSK360K_2	= $(DISTROVER)_40d_2.dsk
LDSK360K_2	= $(DISTRONAME)_40d_2.dsk
DSK720K		= $(DISTROVER)_80d.dsk
LDSK720K	= $(DISTRONAME)_80d.dsk
DSK720K_50HZ	= $(DISTROVER)_80d_50hz.dsk
LDSK720K_50HZ	= $(DISTRONAME)_80d_50hz.dsk
DSKCOCOLINK	= $(DISTROVER)_cocolink.dsk
LDSKCOCOLINK	= $(DISTRONAME)_cocolink.dsk
DSKRS232PAK	= $(DISTROVER)_rs232pak.dsk
LDSKRS232PAK	= $(DISTRONAME)_rs232pak.dsk
DSKDIRECTMODEMPAK	= $(DISTROVER)_directmodempak.dsk
LDSKDIRECTMODEMPAK	= $(DISTRONAME)_directmodempak.dsk
DSKCOCOLINKHEADLESS	= $(DISTROVER)_cocolink_headless.dsk
LDSKCOCOLINKHEADLESS	= $(DISTRONAME)_cocolink_headless.dsk
DSKRS232PAKHEADLESS	= $(DISTROVER)_rs232pak_headless.dsk
LDSKRS232PAKHEADLESS	= $(DISTRONAME)_rs232pak_headless.dsk
DSKDIRECTMODEMPAKHEADLESS	= $(DISTROVER)_directmodempak_headless.dsk
LDSKDIRECTMODEMPAKHEADLESS	= $(DISTRONAME)_directmodempakpak_headless.dsk
LDSKBECKER	= $(DISTRONAME)_becker.dsk
LDSKARDUINO	= $(DISTRONAME)_arduino.dsk
LDSKCOCOSDC	= $(DISTRONAME)_cocosdc.dsk
LDSKBECKERHEADLESS	= $(DISTRONAME)_becker_headless.dsk
LDSKARDUINOHEADLESS	= $(DISTRONAME)_arduino_headless.dsk
DSKEMUDSK = $(DISTROVER)_emudsk.dsk
LDSKEMUDSK = $(DISTRONAME)_emudsk.dsk
TESTDSK		= test.dsk

DSKS		= $(DSK360K_1) $(DSK360K_1_50HZ) $(DSK360K_2) \
		$(DSK720K) $(DSK720K_50HZ) $(DSKDW) $(DSKDWHEADLESS) \
		$(DSKBECKER) $(DSKARDUINO) $(DSKBECKERHEADLESS) \
		$(DSKARDUINOHEADLESS) $(DSKCOCOSDC) $(DSKRS232PAK) $(DSKDIRECTMODEMPAK) \
		$(DSKCOCOLINK) $(DSKCOCOLINKHEADLESS) $(DSKRS232PAKHEADLESS) $(DSKDIRECTMODEMPAKHEADLESS) \
		$(DSKEMUDSK)
LDSKS		= $(LDSK360K_1) $(LDSK360K_1_50HZ) $(LDSK360K_2) \
		$(LDSK720K) $(LDSK720K_50HZ) $(LDSKDW) $(LDSKDWHEADLESS) \
		$(LDSKBECKER) $(LDSKARDUINO) $(LDSKBECKERHEADLESS) \
		$(LDSKARDUINOHEADLESS) $(LDSKCOCOSDC) $(LDSKRS232PAK) $(LDSKDIRECTMODEMPAK) \
		$(LDSKCOCOLINK) $(LDSKCOCOLINKHEADLESS) $(LDSKRS232PAKHEADLESS) $(LDSKDIRECTMODEMPAKHEADLESS) \
		$(LDSKEMUDSK)

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

$(DSKDW):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_DW) -t=$(KERNELFILE_DW)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKDW)
	$(SOFTLINK) $@ $(LDSKDW)

$(DSKBECKER):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_BECKER) -t=$(KERNELFILE_BECKER)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKBECKER)
	$(SOFTLINK) $@ $(LDSKBECKER)

$(DSKCOCOLINK):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_COCOLINK) -t=$(KERNELFILE_COCOLINK)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKCOCOLINK)
	$(SOFTLINK) $@ $(LDSKCOCOLINK)

$(DSKRS232PAK):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_RS232PAK) -t=$(KERNELFILE_RS232PAK)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKRS232PAK)
	$(SOFTLINK) $@ $(LDSKRS232PAK)

$(DSKDIRECTMODEMPAK):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_DIRECTMODEMPAK) -t=$(KERNELFILE_DIRECTMODEMPAK)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKDIRECTMODEMPAK)
	$(SOFTLINK) $@ $(LDSKDIRECTMODEMPAK)

$(DSKARDUINO):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_ARDUINO) -t=$(KERNELFILE_ARDUINO)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKARDUINO)
	$(SOFTLINK) $@ $(LDSKARDUINO)

$(DSKCOCOSDC):
	$(RM) $@
	$(OS9FORMAT) -t1024 -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_COCOSDC) -t=$(KERNELFILE_COCOSDC)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKCOCOSDC)
	$(SOFTLINK) $@ $(LDSKCOCOSDC)

$(DSKDWHEADLESS):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_DW_HEADLESS) -t=$(KERNELFILE_DW)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKDWHEADLESS)
	$(SOFTLINK) $@ $(LDSKDWHEADLESS)

$(DSKBECKERHEADLESS):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_BECKER_HEADLESS) -t=$(KERNELFILE_BECKER)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKBECKERHEADLESS)
	$(SOFTLINK) $@ $(LDSKBECKERHEADLESS)

$(DSKCOCOLINKHEADLESS):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_COCOLINK_HEADLESS) -t=$(KERNELFILE_COCOLINK)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKCOCOLINKHEADLESS)
	$(SOFTLINK) $@ $(LDSKCOCOLINKHEADLESS)

$(DSKRS232PAKHEADLESS):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_RS232PAK_HEADLESS) -t=$(KERNELFILE_RS232PAK)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKRS232PAKHEADLESS)
	$(SOFTLINK) $@ $(LDSKRS232PAKHEADLESS)

$(DSKDIRECTMODEMPAKHEADLESS):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_DIRECTMODEMPAK_HEADLESS) -t=$(KERNELFILE_DIRECTMODEMPAK)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKDIRECTMODEMPAKHEADLESS)
	$(SOFTLINK) $@ $(LDSKDIRECTMODEMPAKHEADLESS)

$(DSKARDUINOHEADLESS):
	$(RM) $@
	$(OS9FORMAT_DW) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_ARDUINO_HEADLESS) -t=$(KERNELFILE_ARDUINO)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS_DW) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_DW),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP_DW) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKARDUINOHEADLESS)
	$(SOFTLINK) $@ $(LDSKARDUINOHEADLESS)

$(DSK360K_1):
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL) Disk 1"
	$(OS9GEN) $@ -b=$(BOOTFILE_40D) -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(RM) $(LDSK360K_1)
	$(SOFTLINK) $@ $(LDSK360K_1)

$(DSK360K_1_50HZ):
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL) Disk 1"
	$(OS9GEN) $@ -b=$(BOOTFILE_40D_50HZ) -t=$(KERNELFILE_50HZ)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(RM) $(LDSK360K_1_50HZ)
	$(SOFTLINK) $@ $(LDSK360K_1_50HZ)

$(DSK360K_2):
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL) Disk 2"
	$(MAKDIR) $@,CMDS
	$(CD) cmds; $(OS9COPY) $(CMDS_D2) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS_D2),$@,CMDS/$(file))
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSK360K_2)
	$(SOFTLINK) $@ $(LDSK360K_2)

$(DSK720K):
	$(RM) $@
	$(OS9FORMAT_DS80) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_80D) -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(sort $(CMDS) $(CMDS_D2)) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(sort $(CMDS) $(CMDS_D2)),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSK720K)
	$(SOFTLINK) $@ $(LDSK720K)

$(DSK720K_50HZ):
	$(RM) $@
	$(OS9FORMAT_DS80) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_80D_50HZ) -t=$(KERNELFILE_50HZ)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(sort $(CMDS) $(CMDS_D2)) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(sort $(CMDS) $(CMDS_D2)),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSK720K_50HZ)
	$(SOFTLINK) $@ $(LDSK720K_50HZ)

$(DSKEMUDSK):
	$(RM) $@
	$(OS9FORMAT_DS80) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_EMUDSK) -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(CCBKRN) $@,$(CCBKRN)
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(sort $(CMDS) $(CMDS_D2)) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(sort $(CMDS) $(CMDS_D2)),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(notdir $(SYSTEXT)),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/$(DISTRO)
	$(MAKDIR) $@,NITROS9/$(DISTRO)/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/$(DISTRO)/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/$(DISTRO)/CMDS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/$(DISTRO)/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/$(DISTRO)/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/$(DISTRO)/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/$(DISTRO)/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/$(DISTRO)/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/$(DISTRO)/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/$(DISTRO)/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/$(DISTRO)/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/$(DISTRO)/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/$(DISTRO)/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/$(DISTRO)/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/$(DISTRO)/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/$(DISTRO)/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/$(DISTRO)/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/$(DISTRO)/BOOTLISTS
	$(MAKDIR) $@,NITROS9/$(DISTRO)/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/$(DISTRO)/SCRIPTS
	$(RM) $(LDSKEMUDSK)
	$(SOFTLINK) $@ $(LDSKEMUDSK)

info:
	@$(ECHO) "*** NitrOS-9/$(CPU) Level $(LEVEL) for the $(MACHINE) ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
