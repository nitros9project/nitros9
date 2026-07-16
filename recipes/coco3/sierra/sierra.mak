LEVEL = 2
include ../coco3.mak

SHELLMODS = shell_21 date echo link setime

ifeq ($(CPU),6309)
AFLAGS := $(filter-out -DH6309=1,$(AFLAGS))
else
AFLAGS := $(filter-out -DH6309=0,$(AFLAGS))
endif

vpath %.as $(LEVEL2)/cmds:$(LEVEL1)/cmds
vpath %.asm $(LEVEL2)/coco3/modules/kernel:$(LEVEL2)/coco3/modules:$(LEVEL2)/modules:$(LEVEL2)/cmds:$(LEVEL1)/coco1/modules:$(LEVEL1)/modules:$(LEVEL1)/cmds:$(LANGUAGES)/basic09:$(3RDPARTY)/packages/sierra/objs

SIERRA_TOC ?= ./tOC
SIERRA_MAKE_TOC ?= ../sierra/make_toc.py
DSDD80 = -DCyls=80 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1
DSDD40 = -DCyls=40 -DSides=2 -DSectTrk=18 -DSectTrk0=18 -DInterlv=3 -DSAS=8 -DDensity=1

$(MODDIR)/covdg_small.io: covdg.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/shell_21: $(LEVEL1)/cmds/shell_21.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/date: $(LEVEL1)/cmds/date.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/echo: $(LEVEL1)/cmds/echo.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/link: $(LEVEL1)/cmds/link.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/setime: $(LEVEL1)/cmds/setime.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/shell: $(addprefix $(MODDIR)/,$(SHELLMODS)) | $(MODDIR)
	$(MERGE) $(addprefix $(MODDIR)/,$(SHELLMODS)) >$@

$(MODDIR)/sierra: sierra.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/mnln: mnln.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/scrn: scrn.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/shdw: shdw.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/ddd0_40d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD40) -DDNum=0 -DDD=1

$(MODDIR)/ddd0_80d.dd: rb1773desc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ $(DSDD80) -DDNum=0 -DDD=1

$(SIERRA_TOC): $(SIERRA_TOC_TXT) $(SIERRA_MAKE_TOC)
	python3 $(SIERRA_MAKE_TOC) $(SIERRA_TOC_TXT) $@

$(DSKIMAGE): kernelfile bootfile $(MODDIR)/sysgo_dd $(addprefix $(MODDIR)/,$(CMDS)) $(STARTUP) $(SIERRA_TOC)
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"NitrOS-9/$(CPU) Level $(LEVEL)"
	$(OS9GEN) $@ -b=bootfile -t=$(KERNELFILE)
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(addprefix $(MODDIR)/,$(CMDS)) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(OS9COPY) $(addprefix $(SIERRA_DIR)/,$(SIERRA_DATA_FILES)) $@,.
	$(CPL) $(SIERRA_TOC_TXT) $@,tOC.txt
	$(CPL) $(SIERRA_TOC) $@,tOC
	$(OS9COPY) $(MODDIR)/sysgo_dd $@,sysgo
	$(OS9ATTR_EXEC) $@,sysgo
	$(CPL) $(STARTUP) $@,startup
	$(OS9ATTR_TEXT) $@,startup

MAME         ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -inipath $(HOME)/mame -cfg_directory $(HOME)/mame/cfg -window -ext fdc -ext:fdc:wd17xx:0 525qd

ifeq ($(SIERRA_MEDIA),80d)
run: $(DSKIMAGE)
	$(MAME) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)
else
run:
	@echo "run: MAME floppy launch not supported for DriveWire media (GAME=$(GAME))"
endif

clean:
	$(RM) *.list *.map bootfile $(KERNELFILE) *.dsk buildinfo $(SIERRA_TOC)
	-rm -rf $(OBJDIR) $(LIBDIR) $(MODDIR)
