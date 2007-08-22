#
#level1/dalpha/makefile
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

PORT = dalpha
include $(NITROS9DIR)/rules.mak

CPU		= 6809
LEVEL		= 1

# TERMWIDTH can be either VDG or HR, for 32x16 or 51x24 respectivly
#NOTE must be lower case.
TERMWIDTH	= hr


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
DISTRONAME	= nos9$(CPU)l$(LEVEL)
DISTROVER	= $(DISTRONAME)$(NITROS9VER)$(PORT)

BOOTFILE_COVDG		= bootfiles/bootfile_covdg_ss80
BOOTFILE_COHR		= bootfiles/bootfile_cohr_ss80
BOOTFILE_COVDG_DS80	= bootfiles/bootfile_covdg_ds80
BOOTFILE_COHR_DS80	= bootfiles/bootfile_cohr_ds80

BOOTFILE_SS80		= bootfiles/bootfile_co$(TERMWIDTH)_ss80
BOOTFILE_DS80		= bootfiles/bootfile_co$(TERMWIDTH)_ds80

KERNELFILE	= bootfiles/kernel
DIRS		= cmds modules defs sys bootfiles

#DIRS		= cmds sys 
#modules bootfiles
#DDIRS		= modules bootfiles defs

CMDS		= $(shell $(CD) cmds; make showcocoobjs)
BOOTTRACK	= $(shell $(CD) modules; make showboottrack)
KERNEL		= $(shell $(CD) modules; make showkernel)
SYSMODS		= $(shell $(CD) modules; make showsysmods)
CLOCKS		= $(shell $(CD) modules; make showclocks)
RBF		= $(shell $(CD) modules; make showrbf)
SCF		= $(shell $(CD) modules; make showscf)
PIPE		= $(shell $(CD) modules; make showpipe)
MODULECMDS	= $(WHICHSHELL) del echo format makdir merge os9gen prompt tmode

SYS		= $(shell $(CD) sys; make showobjs)
DEFS		= $(shell $(CD) defs; make showobjs)
ROOTFILES	= startup

PACKAGENAME	= $(DISTROVER).zip
DSK360K_1       = $(DISTROVER)_80s_1.dsk
LDSK360K_1      = $(DISTRONAME)_80s_1.dsk
DSK360K_2       = $(DISTROVER)_80s_2.dsk
LDSK360K_2      = $(DISTRONAME)_80s_2.dsk
DSK720K         = $(DISTROVER)_80d.dsk
LDSK720K        = $(DISTRONAME)_80d.dsk

# Make all components
all:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*      NitrOS-9/6809 Level 1 Dragon 64 Port      *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"
	$(foreach dir, $(DIRS), ($(CD) $(dir); make STEP=$(STEP) UPGRADED32=$(UPGRADED32));)

# Clean all components
clean:	dskclean
	$(foreach dir, $(DIRS), ($(CD) $(dir); make clean);)
	
dskclean:
	-$(RM) $(PACKAGENAME) $(DSK360K_1) $(LDSK360K_1) \
	$(DSK360K_2) $(LDSK360K_2) $(DSK720K) $(LDSK720K) \
	


dsk: all $(PACKAGENAME)

dskcopy: dsk
	$(CP) $(DSK360K_1) $(DSK360K_2) $(DSK720K) $(PACKAGENAME) $(DSKDIR)

scp: dsk
	scp $(PACKAGENAME) boisy@cvs.nitros9.org:/home/nitros9/public_html

$(PACKAGENAME): $(DSK360K_1) $(DSK360K_2) $(DSK720K) ReadMe ChangeLog
	$(ARCHIVE) $@ $^

#Dragon Alpha internal drives are Single sided 80 track

$(DSK360K_1):
	$(RM) $@
	$(OS9FORMAT_SS80) -q -dr $@ -n"NitrOS-9/6809 Dragon Alpha Level 1 Disk 1"
	$(OS9GEN) $@ -d -b=$(BOOTFILE_SS80) -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(CD) cmds; $(CP) $(CMDS) ../$@,CMDS
	$(foreach file, $(CMDS), $(OS9ATTR_EXEC) $@,CMDS/$(file);)
	$(OS9RENAME) $@,CMDS/$(WHICHSHELL) shell
	$(CD) sys; $(CPL) $(SYS) ../$@,SYS
	$(foreach file, $(SYS), $(OS9ATTR_TEXT) $@,SYS/$(file);)
	$(MAKDIR) $@,DEFS
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(foreach file, $(DEFS), $(OS9ATTR_TEXT) $@,DEFS/$(file);)
	$(CPL) $(ROOTFILES) $@,.
	$(foreach file, $(ROOTFILES), $(OS9ATTR_TEXT) $@,$(file);)
	$(RM) $(LDSK360K_1)
	$(SOFTLINK) $@ $(LDSK360K_1)

$(DSK360K_2):
	$(RM) $@
	$(OS9FORMAT_SS80) -q -dr $@ -n"NitrOS-9/6809 Dragon Alpha Level 1 Disk 2"
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/6809L1
	$(MAKDIR) $@,NITROS9/6809L1/CMDS
	$(CD) cmds; $(CP) $(MODULECMDS) ../$@,NITROS9/6809L1/CMDS
	$(foreach file, $(MODULECMDS), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/CMDS/$(file);)
	$(OS9RENAME) $@,NITROS9/6809L1/CMDS//$(WHICHSHELL) shell
	$(MAKDIR) $@,NITROS9/6809L1/MODULES
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/BOOTTRACK
	$(CD) modules; $(CP) $(BOOTTRACK) ../$@,NITROS9/6809L1/MODULES/BOOTTRACK
	$(foreach file, $(BOOTTRACK), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/BOOTTRACK/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/KERNEL
	$(CD) modules; $(CP) $(KERNEL) ../$@,NITROS9/6809L1/MODULES/KERNEL
	$(foreach file, $(KERNEL), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/KERNEL/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/SYSMODS
	$(CD) modules; $(CP) $(SYSMODS) ../$@,NITROS9/6809L1/MODULES/SYSMODS
	$(foreach file, $(SYSMODS), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/SYSMODS/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/CLOCKS
	$(CD) modules; $(CP) $(CLOCKS) ../$@,NITROS9/6809L1/MODULES/CLOCKS
	$(foreach file, $(CLOCKS), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/CLOCKS/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/RBF
	$(CD) modules; $(CP) $(RBF) ../$@,NITROS9/6809L1/MODULES/RBF
	$(foreach file, $(RBF), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/RBF/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/SCF
	$(CD) modules; $(CP) $(SCF) ../$@,NITROS9/6809L1/MODULES/SCF
	$(foreach file, $(SCF), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/SCF/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/PIPE
	$(CD) modules; $(CP) $(PIPE) ../$@,NITROS9/6809L1/MODULES/PIPE
	$(foreach file, $(PIPE), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/PIPE/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/6809L1/BOOTLISTS
	$(MAKDIR) $@,NITROS9/6809L1/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/6809L1/SCRIPTS
	$(RM) $(LDSK360K_2)
	$(SOFTLINK) $@ $(LDSK360K_2)

$(DSK720K):
	$(RM) $@
	$(OS9FORMAT_DS80) -q -dr -c2 $@ -n"NitrOS-9/6809 Dragon Level 1"
	$(OS9GEN) $@ -d -b=$(BOOTFILE_DS80) -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(MAKDIR) $@,DEFS
	$(CD) cmds; $(CP) $(CMDS) ../$@,CMDS
	$(foreach file, $(CMDS), $(OS9ATTR_EXEC) $@,CMDS/$(file);)
	$(OS9RENAME) $@,CMDS/$(WHICHSHELL) shell
	$(CD) sys; $(CPL) $(SYS) ../$@,SYS
	$(foreach file, $(SYS), $(OS9ATTR_TEXT) $@,SYS/$(file);)
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(foreach file, $(DEFS), $(OS9ATTR_TEXT) $@,DEFS/$(file);)
	$(CPL) $(ROOTFILES) $@,.
	$(foreach file, $(ROOTFILES), $(OS9ATTR_TEXT) $@,$(file);)
	$(MAKDIR) $@,NITROS9
	$(MAKDIR) $@,NITROS9/6809L1
	$(MAKDIR) $@,NITROS9/6809L1/CMDS
	$(CD) cmds; $(CP) $(MODULECMDS) ../$@,NITROS9/6809L1/CMDS
	$(foreach file, $(MODULECMDS), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/CMDS/$(file);)
	$(OS9RENAME) $@,NITROS9/6809L1/CMDS/$(WHICHSHELL) shell
	$(MAKDIR) $@,NITROS9/6809L1/MODULES
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/BOOTTRACK
	$(CD) modules; $(CP) $(BOOTTRACK) ../$@,NITROS9/6809L1/MODULES/BOOTTRACK
	$(foreach file, $(BOOTTRACK), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/BOOTTRACK/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/KERNEL
	$(CD) modules; $(CP) $(KERNEL) ../$@,NITROS9/6809L1/MODULES/KERNEL
	$(foreach file, $(KERNEL), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/KERNEL/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/SYSMODS
	$(CD) modules; $(CP) $(SYSMODS) ../$@,NITROS9/6809L1/MODULES/SYSMODS
	$(foreach file, $(SYSMODS), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/SYSMODS/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/CLOCKS
	$(CD) modules; $(CP) $(CLOCKS) ../$@,NITROS9/6809L1/MODULES/CLOCKS
	$(foreach file, $(CLOCKS), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/CLOCKS/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/RBF
	$(CD) modules; $(CP) $(RBF) ../$@,NITROS9/6809L1/MODULES/RBF
	$(foreach file, $(RBF), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/RBF/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/SCF
	$(CD) modules; $(CP) $(SCF) ../$@,NITROS9/6809L1/MODULES/SCF
	$(foreach file, $(SCF), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/SCF/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/MODULES/PIPE
	$(CD) modules; $(CP) $(PIPE) ../$@,NITROS9/6809L1/MODULES/PIPE
	$(foreach file, $(PIPE), $(OS9ATTR_EXEC) $@,NITROS9/6809L1/MODULES/PIPE/$(file);)
	$(MAKDIR) $@,NITROS9/6809L1/BOOTLISTS
	$(CD) bootlists; $(CPL) *.bl ../$@,NITROS9/6809L1/BOOTLISTS
	$(MAKDIR) $@,NITROS9/6809L1/SCRIPTS
	$(CD) scripts; $(CPL) mb* ../$@,NITROS9/6809L1/SCRIPTS
	$(RM) $(LDSK720K)
	$(SOFTLINK) $@ $(LDSK720K)
