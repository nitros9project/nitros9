# NitrOS-9/6809 Level 2 bootfile for a 128K CoCo 3 with a Motorola 6809
# For Boisy's thesis work

include $(NITROS9DIR)/rules.mak

vpath %.asm ../../../utils/boisy:..:$(LEVEL2)/cmds:$(LEVEL1)/cmds:$(LEVEL1)/modules:$(3RDPARTY)/packages/basic09

AFLAGS		+= -aNoTerm=1 -acoco3=1

LFLAGS		+= -y -l=$(3RDPARTY)/libs/alib/alib.l -l=$(NITROS9DIR)/lib/sys6809l2.l 
3PDW68          = $(3RDPARTY)/packages/drivewire/6809l2
3PBOISY         = $(3RDPARTY)/utils/boisy

DEPENDS		= ./makefile

#AFLAGS          += -e -aH6309=1

DSK 		= thesis.dsk
CMDSDIR		= $(LEVEL2)/coco3/cmds
MD		= $(LEVEL2)/coco3/modules
SYSTEXT		= motd password inetd.conf
DSKS		= $(DSK)

CMDS		= $(addprefix $(CMDSDIR)/,\
		attr build cmp copy cputype date debug \
		deiniz del deldir devs dir display \
		dmem dmode dump echo edit error \
		free grfdrv help ident iniz link \
		list load login makdir mdir merge \
		mfree mmap mpi pmap proc procs \
		prompt pwd pxd rename save shell \
		sleep smap tee tmode touch tsmon \
		unlink verify xmode utilpak1 basic09 syscall \
		)

CMDS_DW		= $(3PDW68)/inetd $(3PDW68)/dw \
		$(3PDW68)/telnet $(3PBOISY)/send

CMDS_THESIS	= testmul testtfr testexg testadd testnop
SRC_THESIS	= testmul.a testtfr.a testexg.a testadd.a testnop.a

# We make our own bootfile and kernel track
KERNEL		= $(MD)/rel_80 $(MD)/boot_dw $(MD)/krn
BOOTFILE_DWTERM	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio.sb \
		$(MD)/rammer.dr $(MD)/r0_128k.dd \
		$(MD)/ddx0.dd $(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd \
		$(MD)/scf.mn \
		$(MD)/sc6551.dr $(MD)/t2_sc6551.dd $(MD)/t3_sc6551.dd \
		$(MD)/scdwn.dr $(MD)/term_scdwn.dt \
		$(MD)/n_scdwn.dd \
		$(MD)/n1_scdwn.dd $(MD)/n2_scdwn.dd $(MD)/n3_scdwn.dd \
		$(MD)/n4_scdwn.dd $(MD)/n5_scdwn.dd $(MD)/n6_scdwn.dd \
		$(MD)/n7_scdwn.dd $(MD)/n8_scdwn.dd $(MD)/n9_scdwn.dd \
		$(MD)/n10_scdwn.dd $(MD)/n11_scdwn.dd $(MD)/n12_scdwn.dd \
		$(MD)/n13_scdwn.dd $(MD)/n14_scdwn.dd \
		$(MD)/scdwp.dr $(MD)/p_scdwp.dd \
		$(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd \
		$(MD)/clock_60hz $(MD)/clock2_dw \
		$(MD)/sysgo_dd

BOOTFILE_WINTERM	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio.sb \
		$(MD)/ddx0.dd $(MD)/x1.dd $(MD)/x2.dd $(MD)/x3.dd \
		$(MD)/scf.mn \
		$(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/cowin.io $(MD)/covdg.io \
		$(MD)/term_win80.dt $(MD)/w1.dw $(MD)/w2.dw $(MD)/w3.dw $(MD)/w4.dw \
		$(MD)/w5.dw $(MD)/w6.dw $(MD)/w7.dw \
		$(MD)/scdwn.dr \
		$(MD)/n_scdwn.dd \
		$(MD)/n1_scdwn.dd $(MD)/n2_scdwn.dd $(MD)/n3_scdwn.dd \
		$(MD)/n4_scdwn.dd $(MD)/n5_scdwn.dd $(MD)/n6_scdwn.dd \
		$(MD)/n7_scdwn.dd $(MD)/n8_scdwn.dd $(MD)/n9_scdwn.dd \
		$(MD)/n10_scdwn.dd $(MD)/n11_scdwn.dd $(MD)/n12_scdwn.dd \
		$(MD)/n13_scdwn.dd $(MD)/n14_scdwn.dd \
		$(MD)/scdwp.dr $(MD)/p_scdwp.dd \
		$(MD)/pipeman.mn $(MD)/piper.dr $(MD)/pipe.dd \
		$(MD)/clock_60hz $(MD)/clock2_dw \
		$(MD)/sysgo_dd

SUPPORTFILES	= startup
BOOTFILE	= $(BOOTFILE_WINTERM)

ALLOBJS		= $(CMDS) $(CMDS_DW) $(CMDS_THESIS)

all:	makedepends $(ALLOBJS)

makedepends:
	cd $(LEVEL2)/coco3; make
	cd $(3RDPARTY)/packages/drivewire; make
	cd $(3PBOISY); make

clean:	dskclean
	$(RM) $(CMDS_THESIS)

dsk:	all $(DSKS)

$(DSK):
	cd $(3RDPARTY)/utils/supercomm; make
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_SS80) -q $@ -n"NitrOS-9 Level 2 DriveWire Server"
	$(MERGE) $(BOOTFILE)>os9boot
	$(MERGE) $(KERNEL)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(MAKDIR) $@,SYS
	$(OS9COPY) $(CMDS) $(CMDS_DW) $(CMDS_THESIS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file, $(notdir $(CMDS) $(CMDS_DW) $(CMDS_THESIS)),$@,CMDS/$(file);)
	$(MAKDIR) $@,SRC
	$(CPL) $(SRC_THESIS) $@,SRC
	$(OS9COPY) $(3RDPARTY)/utils/supercomm/supercomm $@,CMDS
	$(OS9ATTR_EXEC) $@,CMDS/supercomm
	$(CPL) $(SYSTEXT) $@,SYS
	$(OS9ATTR_TEXT) $(foreach file,$(SYSTEXT),$@,SYS/$(file))
	$(CPL) $(SUPPORTFILES) $@,.
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,$(file))

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS)

info:
	@$(ECHO) "*** NitrOS-9/6809 Level 2 DriveWire Server ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
