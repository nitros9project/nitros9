#
#level1/d64/makefile
#
# 2005-04-24, P.Harvey-Smith.
# 	Brought into line with CoCo makefile, for generating disk
#	names baded on CPU/Level/Release number.
#
#
# 2005-05-31, P.Harvey-Smith.
#	Added options to specify the step rate of the created 
#	floppy devices.
#
# 2006-01-08, P.Harvey-Smith.
#	Added option to compile for a Dragon 32 that has been upgraded
#	to 64K, this is almost the same as the 64, except that it lacks
#	a serial port.
#
# 2006-01-08, P.Harvey-Smith.
#	Determined experementally the correct step rate for Dragon Data
# 	5.25" drives, which is 12ms, this is over half the time of the
#	value determined by using dmode under Dragon OS9. It seems that 
#	the Dragon OS9 dis driver ignored the value set for stp, and always
#	used 12ms !!!! 
#
# 2006-01-18, P.Harvey-Smith.
#	Updates to support Tano Dragon 64, using RS-DOS controler.
#
# 2006-07-06, P.Harvey-Smith.
#	Updated to use new build system, for multiple supported platforms.
#

include port.mak

# TERMWIDTH can be either VDG or HR, for 32x16 or 51x24 respectivly
#NOTE must be lower case.
TERMWIDTH	= 42


#Default step rate for floppy drives
#Step can be one of : 0=30ms, 1=20ms, 2=12ms, 3=6ms
#Note old drives often require 30ms
#After experimenting with a real Dragon Data 5.25" drive I
#have determined that the drive will cope with 12ms step.
#Therefore setting this as the default for 32/64 also.
STEP		= 2

#Is this machine a real 64, or a 32, upgraded to 64K.
#Set to 1 for upgraded machine.
UPGRADED32	= 0

# Level 1 - Specify which shell should be used
#WHICHSHELL	= shellplus
WHICHSHELL	= shell_21

DISTRO		= $(CPU)L$(LEVEL)
DISTRONAME	= NOS9_$(CPU)_L$(LEVEL)
DISTROVER	= $(DISTRONAME)_$(NITROS9VER)_$(PORT)

BOOTFILE_COVDG		= bootfiles/bootfile_covdg_ds40
BOOTFILE_COHR		= bootfiles/bootfile_cohr_ds40
BOOTFILE_CO42		= bootfiles/bootfile_co42_ds40
BOOTFILE_COVDG_DS80	= bootfiles/bootfile_covdg_ds80
BOOTFILE_COHR_DS80	= bootfiles/bootfile_cohr_ds80
BOOTFILE_CO42_DS80	= bootfiles/bootfile_co42_ds80
BOOTFILE_COVDG_SS40	= bootfiles/bootfile_covdg_ss40
BOOTFILE_COHR_SS40	= bootfiles/bootfile_cohr_ss40
BOOTFILE_CO42_SS40	= bootfiles/bootfile_co42_ss40

BOOTFILE_DS40		= bootfiles/bootfile_co$(TERMWIDTH)_ds40
BOOTFILE_DS80		= bootfiles/bootfile_co$(TERMWIDTH)_ds80
BOOTFILE_SS40		= bootfiles/bootfile_co$(TERMWIDTH)_ss40

KERNELFILE	= bootfiles/kernel
DIRS		= cmds modules defs sys bootfiles

#DIRS		= cmds sys 
#modules bootfiles
#DDIRS		= modules bootfiles defs

CMDS		= $(shell $(CD) cmds; make --no-print-directory showdragonobjs)
CMDS525		= $(shell $(CD) cmds; make --no-print-directory showdragon525objs)
CMDS525_2	= $(shell $(CD) cmds; make --no-print-directory showdragon525objs2)
BOOTTRACK	= $(shell $(CD) modules; make --no-print-directory showboottrack)
KERNEL		= $(shell $(CD) modules; make --no-print-directory showkernel)
SYSMODS		= $(shell $(CD) modules; make --no-print-directory showsysmods)
CLOCKS		= $(shell $(CD) modules; make --no-print-directory showclocks)
RBF		= $(shell $(CD) modules; make --no-print-directory showrbf)
SCF		= $(shell $(CD) modules; make --no-print-directory showscf)
PIPE		= $(shell $(CD) modules; make --no-print-directory showpipe)
MODULECMDS	= $(WHICHSHELL) del echo format makdir merge os9gen prompt tmode

SYS		= $(shell $(CD) sys; make --no-print-directory showobjs)
DEFS		= $(shell $(CD) defs; make --no-print-directory showobjs)
ROOTFILES	= startup

DSK360K_1       = $(DISTROVER)_40d_1.dsk
LDSK360K_1      = $(DISTRONAME)_40d_1.dsk
DSK360K_2       = $(DISTROVER)_40d_2.dsk
LDSK360K_2      = $(DISTRONAME)_40d_2.dsk
DSK720K         = $(DISTROVER)_80d.dsk
LDSK720K        = $(DISTRONAME)_80d.dsk
#These are for the original SS40 Dragon drives, which still seem to be the most comon :(
DSK180K_1	= $(DISTROVER)_40s_1.dsk
DSK180K_2	= $(DISTROVER)_40s_2.dsk

DSKS		= $(DSK360K_1) $(DSK360K_2) $(DSK720K) $(DSK180K_1) $(DSK180K_2)
LDSKS		= $(LDSK360K_1) $(LDSK360K_2) $(LDSK720K) $(LDSK180K_1) $(LDSK180K_2)

# Make all components
all:
	@$(ECHO) "************************************************************"
	@$(ECHO) "*"
	@$(ECHO) "*      NitrOS-9/$(CPU) Level $(LEVEL) $(MACHINE) ($(PORT))"
	@$(ECHO) "*"
	@$(ECHO) "************************************************************"
	$(foreach dir,$(DIRS),$(MAKE) -C $(dir) STEP=$(STEP) UPGRADED32=$(UPGRADED32) &&) :

# Clean all components
clean:	dskclean
	$(foreach dir,$(DIRS),$(MAKE) -C $(dir) clean &&) :
	
dskclean:
	$(RM) $(DSKS) $(LDSKS)

dsk: all $(DSKS)

dskcopy: $(DSKS)
	$(CP) $(DSKS) $(DSKDIR)

#Dragon 64/32+

$(DSK360K_1):
	$(RM) $@
	$(OS9FORMAT_DS40) -q -dr $@ -n"NitrOS-9/$(CPU) $(MACHINE) #1"
	$(OS9GEN) $@ -d -b=$(BOOTFILE_DS40) -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/$(WHICHSHELL) shell
	$(CD) sys; $(CPL) $(SYS) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYS),$@,SYS/$(file))
	$(MAKDIR) $@,DEFS
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(ROOTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(ROOTFILES),$@,$(file))
	$(RM) $(LDSK360K_1)
	$(SOFTLINK) $@ $(LDSK360K_1)

$(DSK360K_2):
	$(RM) $@
	$(OS9FORMAT_DS40) -q -dr $@ -n"NitrOS-9/$(CPU) $(MACHINE) #2"
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/6809L1
	$(MAKDIR) $@,NITROS9/6809L1/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/6809L1/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/6809L1/CMDS/$(file))
	$(OS9RENAME) $@,NITROS9/6809L1/CMDS//$(WHICHSHELL) shell
	$(MAKDIR) $@,NITROS9/6809L1/MODULES
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/6809L1/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/6809L1/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/6809L1/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/6809L1/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/6809L1/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/6809L1/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/6809L1/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/6809L1/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/6809L1/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/6809L1/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/6809L1/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/6809L1/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/6809L1/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/6809L1/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/6809L1/BOOTLISTS
	$(MAKDIR) $@,NITROS9/6809L1/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/6809L1/SCRIPTS
	$(RM) $(LDSK360K_2)
	$(SOFTLINK) $@ $(LDSK360K_2)

$(DSK720K):
	$(RM) $@
	$(OS9FORMAT_DS80) -q -dr -c2 $@ -n"NitrOS-9/$(CPU) $(MACHINE)"
	$(OS9GEN) $@ -d -b=$(BOOTFILE_DS80) -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/$(WHICHSHELL) shell
	$(CD) sys; $(CPL) $(SYS) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYS),$@,SYS/$(file))
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(CPL) $(ROOTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(ROOTFILES),$@,$(file))
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/6809L1
	$(MAKDIR) $@,NITROS9/6809L1/CMDS
	$(CD) cmds; $(OS9COPY) $(MODULECMDS) ../$@,NITROS9/6809L1/CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(MODULECMDS),$@,NITROS9/6809L1/CMDS/$(file))
	$(OS9RENAME) $@,NITROS9/6809L1/CMDS/$(WHICHSHELL) shell
	$(MAKDIR) $@,NITROS9/6809L1/MODULES
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/BOOTTRACK
	$(CD) modules; $(OS9COPY) $(BOOTTRACK) ../$@,NITROS9/6809L1/MODULES/BOOTTRACK
	$(OS9ATTR_EXEC) $(foreach file,$(BOOTTRACK),$@,NITROS9/6809L1/MODULES/BOOTTRACK/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/KERNEL
	$(CD) modules; $(OS9COPY) $(KERNEL) ../$@,NITROS9/6809L1/MODULES/KERNEL
	$(OS9ATTR_EXEC) $(foreach file,$(KERNEL),$@,NITROS9/6809L1/MODULES/KERNEL/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/SYSMODS
	$(CD) modules; $(OS9COPY) $(SYSMODS) ../$@,NITROS9/6809L1/MODULES/SYSMODS
	$(OS9ATTR_EXEC) $(foreach file,$(SYSMODS),$@,NITROS9/6809L1/MODULES/SYSMODS/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/CLOCKS
	$(CD) modules; $(OS9COPY) $(CLOCKS) ../$@,NITROS9/6809L1/MODULES/CLOCKS
	$(OS9ATTR_EXEC) $(foreach file,$(CLOCKS),$@,NITROS9/6809L1/MODULES/CLOCKS/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/RBF
	$(CD) modules; $(OS9COPY) $(RBF) ../$@,NITROS9/6809L1/MODULES/RBF
	$(OS9ATTR_EXEC) $(foreach file,$(RBF),$@,NITROS9/6809L1/MODULES/RBF/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/SCF
	$(CD) modules; $(OS9COPY) $(SCF) ../$@,NITROS9/6809L1/MODULES/SCF
	$(OS9ATTR_EXEC) $(foreach file,$(SCF),$@,NITROS9/6809L1/MODULES/SCF/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/PIPE
	$(CD) modules; $(OS9COPY) $(PIPE) ../$@,NITROS9/6809L1/MODULES/PIPE
	$(OS9ATTR_EXEC) $(foreach file,$(PIPE),$@,NITROS9/6809L1/MODULES/PIPE/$(file))
	$(MAKDIR) $@,NITROS9/6809L1/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/6809L1/BOOTLISTS
	$(MAKDIR) $@,NITROS9/6809L1/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/6809L1/SCRIPTS
	$(RM) $(LDSK720K)
	$(SOFTLINK) $@ $(LDSK720K)


$(DSK180K_1):
	$(RM) $@
	$(OS9FORMAT_SS40) -e -dr -q $@ -n"NitrOS-9/$(CPU) $(MACHINE) #1"
	$(OS9GEN) $@ -d -b=$(BOOTFILE_SS40) -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(CD) cmds; $(OS9COPY) $(CMDS525) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS525),$@,CMDS/$(file))
	# put all commands on the first disk because we can
	$(CD) cmds; $(OS9COPY) $(CMDS525_2) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS525_2),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/$(WHICHSHELL) shell
	$(CD) sys; $(CPL) $(SYS) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYS),$@,SYS/$(file))
	$(CPL) $(ROOTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(ROOTFILES),$@,$(file))

$(DSK180K_2):
	$(RM) $@
	$(OS9FORMAT_SS40) -e -dr -q $@ -n"NitrOS-9/$(CPU) $(MACHINE) #2"
	# for space reasons, put the DEFS folder on the second disk
	$(MAKDIR) $@,DEFS
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))

info:
	@$(ECHO) "*** NitrOS-9/$(CPU) Level $(LEVEL) for the $(MACHINE) ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
