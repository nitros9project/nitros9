include port.mak

DISTRO		= $(CPU)L$(LEVEL)
DISTRONAME	= NOS9_$(CPU)_L$(LEVEL)
DISTROVER	= $(DISTRONAME)_$(NITROS9VER)_$(PORT)
BOOTFILE_DW	= bootfiles/bootfile_dw
BOOTFILE_40D	= bootfiles/bootfile_40d
BOOTFILE_80D	= bootfiles/bootfile_80d
BOOTFILE_40D_50HZ	= bootfiles/bootfile_40d_50hz
BOOTFILE_80D_50HZ	= bootfiles/bootfile_80d_50hz
KERNELFILE	= bootfiles/kernel_1773
KERNELFILE_50HZ	= bootfiles/kernel_1773_50hz
KERNELFILE_DW	= bootfiles/kernel_dw
DIRS		= defs cmds modules sys bootfiles

CMDS		= $(shell $(CD) cmds; make --no-print-directory showobjs)
CMDS_D2		= $(shell $(CD) cmds; make --no-print-directory showobjs_d2)
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
SYSGO		= sysgo_dd

DSKDW		= $(DISTROVER)_dw.dsk
LDSKDW		= $(DISTRONAME)_dw.dsk
DSK360K_1	= $(DISTROVER)_40d_1.dsk
LDSK360K_1	= $(DISTRONAME)_40d_1.dsk
DSK360K_1_50HZ	= $(DISTROVER)_40d_1_50hz.dsk
LDSK360K_1_50HZ	= $(DISTRONAME)_40d_1_50hz.dsk
DSK360K_2	= $(DISTROVER)_40d_2.dsk
LDSK360K_2	= $(DISTRONAME)_40d_2.dsk
DSK720K		= $(DISTROVER)_80d.dsk
LDSK720K	= $(DISTRONAME)_80d.dsk
DSK720K_50HZ	= $(DISTROVER)_80d_50hz.dsk
LDSK720K_50HZ	= $(DISTRONAME)_80d_50hz.dsk
TESTDSK		= test.dsk

DSKS		= $(DSKDW) $(DSK360K_1) $(DSK360K_1_50HZ) $(DSK360K_2) $(DSK720K) $(DSK720K_50HZ)
LDSKS		= $(LDSKDW) $(LDSK360K_1) $(LDSK360K_1_50HZ) $(LDSK360K_2) $(LDSK720K) $(LDSK720K_50HZ)

# Make all components
all:
	@$(ECHO) "************************************************************"
	@$(ECHO) "*"
	@$(ECHO) "*      NitrOS-9/$(CPU) Level $(LEVEL) $(MACHINE) ($(PORT))"
	@$(ECHO) "*"
	@$(ECHO) "************************************************************"
	$(foreach dir,$(DIRS),$(MAKE) -C $(dir) &&) :

# Clean all components
clean: dskclean
	$(foreach dir, $(DIRS), ($(CD) $(dir); make clean);)

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
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(STARTUP),$@,$(file))
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

$(DSK360K_1):
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL) Disk 1"
	$(OS9GEN) $@ -b=$(BOOTFILE_40D) -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(STARTUP),$@,$(file))
	$(RM) $(LDSK360K_1)
	$(SOFTLINK) $@ $(LDSK360K_1)

$(DSK360K_1_50HZ):
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL) Disk 1"
	$(OS9GEN) $@ -b=$(BOOTFILE_40D_50HZ) -t=$(KERNELFILE_50HZ)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(STARTUP),$@,$(file))
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
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(sort $(CMDS) $(CMDS_D2)) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(sort $(CMDS) $(CMDS_D2)),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(STARTUP),$@,$(file))
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
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CD) cmds; $(OS9COPY) $(sort $(CMDS) $(CMDS_D2)) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(sort $(CMDS) $(CMDS_D2)),$@,CMDS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(STARTUP) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(STARTUP),$@,$(file))
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

info:
	@$(ECHO) "*** NitrOS-9/$(CPU) Level $(LEVEL) for the $(MACHINE) ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
