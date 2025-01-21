
include port.mak

# Level 2 - Specify which shell should be used
#WHICHSHELL	= shellplus
WHICHSHELL	= shell_21

DISTRO		= $(CPU)L$(LEVEL)
DISTRONAME	= NOS9_$(DISTRO)
DISTROVER	= $(DISTRONAME)_$(NITROS9VER)_$(PORT)
DISTRODSK	= $(DISTRONAME)_realcocofpga
BOOTFILE_REALCOCOFPGA = bootfiles/boot_realcocofpga
KERNEL_REALCOCOFPGA = bootfiles/kernel_realcocofpga

# Gather collections of lists of names of objects that other makefiles generated
CMDS		= $(shell $(CD) cmds; make --no-print-directory showobjs_dw) # extra commands like basic09
BOOTTRACK	= $(shell $(CD) modules; make --no-print-directory showboottrack)
KERNEL		= $(shell $(CD) modules; make --no-print-directory showkernel)
SYSMODS		= $(shell $(CD) modules; make --no-print-directory showsysmods)
CLOCKS		= $(shell $(CD) modules; make --no-print-directory showclocks)
RBF		= $(shell $(CD) modules; make --no-print-directory showrbf)
SCF		= $(shell $(CD) modules; make --no-print-directory showscf)
PIPE		= $(shell $(CD) modules; make --no-print-directory showpipe)
DEFS		= $(shell $(CD) defs; make --no-print-directory showobjs)
SYSBIN		= $(shell $(CD) sys; make --no-print-directory showbinobjs)
SYSTEXT		= $(shell $(CD) sys; make --no-print-directory showtextobjs)
SYSGOSYSTEXT		= $(shell $(CD) sys; make --no-print-directory showsysgotextobjs)

# No MAKE required to grab these data file pathnames
BASIC09_DIR = $(3RDPARTY)/packages/basic09
BASIC09_SAMPLES = $(foreach file,$(BASIC09_DIR)/samples/*.b09,$(file))


#MVDIR			=	$(3RDPARTY)/packages/multivue
#MVCMDSDIR		=	$(MVDIR)/cmds_6809
#MVSYSSDIR		=	$(MVDIR)/sys
#MVCMDS			=	$(MVCMDSDIR)/gshell $(MVCMDSDIR)/cocopr $(MVCMDSDIR)/control $(MVCMDSDIR)/demo $(MVCMDSDIR)/fstat \
 					$(MVCMDSDIR)/gcal $(MVCMDSDIR)/gcalc $(MVCMDSDIR)/gclock $(MVCMDSDIR)/gport $(MVCMDSDIR)/gprint $(MVCMDSDIR)/gsort
#MVSYSOBJS		=	$(shell $(CD) $(MVSYSSDIR); make --no-print-directory showobjs)

DIRS		= defs cmds modules sys bootfiles #$(BASIC09_DIR) # $(MVDIR) #wwwroot

MODULECMDS	= shell grfdrv del echo format makdir merge os9gen prompt tmode

STARTUP		= startup
SYSGO		= sysgo_dd
SYSGOBD		= sysgo_bd
#CCBKRN		= ccbkrn

# Make sure is defined before the DSKS list!
VHD_REALCOCOFPGA_ALLBOARDS = $(DISTRODSK)_allboards.vhd

DSKS		=  $(VHD_REALCOCOFPGA_ALLBOARDS)

#	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
#	$(CD) cmds; $(OS9COPY) -r shellplus ../$@,CMDS/shell

$(VHD_REALCOCOFPGA_ALLBOARDS):
	$(RM) $@
	$(OS9FORMAT) -t29126 -ss -dd $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_REALCOCOFPGA) -t=$(KERNEL_REALCOCOFPGA)
	$(MAKDIR) $@,CMDS
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(MAKDIR) $@,SYS
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
#	$(CD) sys; $(OS9COPY) $(MVSYSSDIR)/$(MVSYSOBJS) ../$@,SYS
	$(MAKDIR) $@,DEFS
	$(CD) defs; $(CPL) $(DEFS) ../$@,DEFS
	$(OS9ATTR_TEXT) $(foreach file,$(DEFS),$@,DEFS/$(file))
	$(MAKDIR) $@,BASIC09
	$(CPL) $(BASIC09_SAMPLES) $@,BASIC09
	$(OS9COPY) modules/$(SYSGO) $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup


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

info:
	@$(ECHO) "*** NitrOS-9/$(CPU) Level $(LEVEL) for the $(MACHINE) ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)

