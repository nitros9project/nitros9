
include port.mak

# Level 2 - Specify which shell should be used
WHICHSHELL	= shellplus
#WHICHSHELL	= shell_21

DISTRO		= $(CPU)L$(LEVEL)
DISTRONAME	= NOS9_$(DISTRO)
DISTROVER	= $(DISTRONAME)_$(NITROS9VER)_$(PORT)
DISTRODSK	= $(DISTRONAME)_realcocofpga
BOOTFILE_REALCOCOFPGA = bootfiles/bootfile_realcocofpga
KERNELFILE_REALCOCOFPGA = bootfiles/kernel_realcocofpga

CMDS		= $(shell $(CD) cmds; make --no-print-directory showobjs)
BOOTTRACK	= $(shell $(CD) modules; make --no-print-directory showboottrack)
KERNEL		= $(shell $(CD) modules; make --no-print-directory showkernel)
SYSMODS		= $(shell $(CD) modules; make --no-print-directory showsysmods)
CLOCKS		= $(shell $(CD) modules; make --no-print-directory showclocks)
RBF		= $(shell $(CD) modules; make --no-print-directory showrbf)
SCF		= $(shell $(CD) modules; make --no-print-directory showscf)
PIPE		= $(shell $(CD) modules; make --no-print-directory showpipe)

B09DIR = $(3RDPARTY)/packages/basic09
B09CMDS = $(B09DIR)/gfx $(B09DIR)/gfx2 $(B09DIR)/inkey $(B09DIR)/syscall
B09CMDSFINAL = $(B09CMDS) basic09 runb

MVDIR			=	$(3RDPARTY)/packages/multivue
MVCMDSDIR		=	$(MVDIR)/cmds_6809
MVSYSSDIR		=	$(MVDIR)/sys
MVCMDS			=	$(MVCMDSDIR)/gshell $(MVCMDSDIR)/cocopr $(MVCMDSDIR)/control $(MVCMDSDIR)/demo $(MVCMDSDIR)/fstat \
					$(MVCMDSDIR)/gcal $(MVCMDSDIR)/gcalc $(MVCMDSDIR)/gclock $(MVCMDSDIR)/gport $(MVCMDSDIR)/gprint $(MVCMDSDIR)/gsort
MVSYSOBJS2		=	$(shell $(CD) $(MVSYSSDIR); make --no-print-directory showobjs)


#B09CMDSNAMES = gfx gfx2 inkey syscall b09 runb
DIRS		= defs cmds modules sys bootfiles $(B09DIR) $(MVDIR) #wwwroot

BASIC09_SAMPLES = $(foreach file,$(3RDPARTY)/packages/basic09/samples/*.b09,$(file))

MODULECMDS	= shell grfdrv del echo format makdir merge os9gen prompt tmode

DEFS		= $(shell $(CD) defs; make --no-print-directory showobjs)
SYSBIN		= $(shell $(CD) sys; make --no-print-directory showbinobjs)
SYSTEXT		= $(shell $(CD) sys; make --no-print-directory showtextobjs)
SYSGOSYSTEXT		= $(shell $(CD) sys; make --no-print-directory showsysgotextobjs)
STARTUP		= startup
SYSGO		= sysgo_dd
SYSGOBD		= sysgo_bd
CCBKRN		= ccbkrn

# Make sure is defined before the DSKS list!
VHD_REALCOCOFPGA_ALLBOARDS = $(DISTRODSK)_allboards.vhd

DSKS		=  $(VHD_REALCOCOFPGA_ALLBOARDS)

#	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
#	$(CD) cmds; $(OS9COPY) -r shellplus ../$@,CMDS/shell
$(VHD_REALCOCOFPGA_ALLBOARDS):
	$(RM) $@
	$(OS9FORMAT) -t29126 -ss -dd $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=$(BOOTFILE_REALCOCOFPGA) -t=$(KERNELFILE_REALCOCOFPGA)
#
	$(MAKDIR) $@,CMDS
	$(CD) cmds; $(OS9COPY) $(CMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(CD) cmds; $(OS9COPY) $(MVCMDS) ../$@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(notdir $(MVCMDS)),$@,CMDS/$(file))
	$(CD) cmds; $(OS9COPY) $(B09CMDS) ../$@,CMDS
	$(CD) cmds; $(OS9COPY) $(B09DIR)/basic09_6809 ../$@,CMDS/basic09
	$(CD) cmds; $(OS9COPY) $(B09DIR)/runb_6809 ../$@,CMDS/runb
	$(OS9ATTR_EXEC) $(foreach file,$(notdir $(B09CMDSFINAL)),$@,CMDS/$(file))
#
	$(MAKDIR) $@,SYS
#	$(CD) sys; $(OS9COPY) $(MVSYSSDIR)/$(MVSYSOBJS2) ../$@,SYS
#	$(OS9ATTR_EXEC) $(foreach file,$(MVSYSOBJS2),$@,SYS/$(file))
	$(CD) sys; $(OS9COPY) $(SYSBIN) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSBIN),$@,SYS/$(file))
	$(CD) sys; $(CPL) $(SYSTEXT) ../$@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
#
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

