include ../../../../rules.mak

vpath %.asm ../objs

AFLAGS      += -I.

DEPENDS		= ./makefile

DSK_FLOPPY	= LeisureSuitLarry.dsk
DSK_DW		= LeisureSuitLarry_dw.dsk
DSK_DW_BECKER	= LeisureSuitLarry_becker.dsk

DSK_NAME	= "Leisure Suit Larry"

DSKS		= $(DSK_FLOPPY) $(DSK_DW) $(DSK_DW_BECKER)

CMDS		= sierra mnln scrn shdw tocgen
MD		= $(LEVEL2)/coco3/modules

# We make our own bootfile and kernel track
KERNEL_FLOPPY	= $(MD)/rel_32 $(MD)/boot_1773_6ms $(MD)/krn
KERNEL_DW	= $(MD)/rel_32 $(MD)/boot_dw $(MD)/krn
KERNEL_DW_BECKER	= $(MD)/rel_32 $(MD)/boot_dw_becker $(MD)/krn

BOOTFILE_FLOPPY	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_40d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/sidirq.dr $(MD)/sid.dd \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

BOOTFILE_DW	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio.sb $(MD)/ddx0.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/sidirq.dr $(MD)/sid.dd \
		$(MD)/clock_60hz $(MD)/clock2_dw $(MD)/sysgo_dd

BOOTFILE_DW_BECKER	= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rbdw.dr $(MD)/dwio_becker.sb $(MD)/ddx0.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/vrn.dr $(MD)/vi.dd \
		$(MD)/sidirq.dr $(MD)/sid.dd \
		$(MD)/clock_60hz $(MD)/clock2_dw $(MD)/sysgo_dd

SUPPORTFILES	= logDir object picDir sndDir viewDir vol.0 \
		vol.1 vol.2 vol.3 vol.4 words.tok $(SIDFILES)

# Phase 2: optional SID polyphonic sound sidecar files.
# Generated from the user's PC AGI leisuresuitlarry install by the Python
# extractor in ../tools/.  If $(LSL_PCASSETS) is unset or its
# SNDDIR is missing, $(SIDFILES) is empty and the build proceeds with
# mono-only sound resources (Phase 1 behaviour, fully backwards
# compatible with the original engine).
LSL_PCASSETS	?= $(HOME)/leisuresuitlarry-pcassets
SIDFILES	:= $(if $(wildcard $(LSL_PCASSETS)/SNDDIR),sidDir sidSnd,)
dsk: $(SIDFILES)

sidDir sidSnd:	$(LSL_PCASSETS)/SNDDIR ../tools/agi_sid_extract.py \
		../tools/agi_snd_parser.py
	python3 ../tools/agi_sid_extract.py $(LSL_PCASSETS) \
		--sid-dir sidDir --sid-snd sidSnd

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:	dskclean
	$(RM) $(ALLOBJS) *.list *.map

dsk:	all $(DSKS)

$(DSK_FLOPPY):
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_DS80) -q $@ -n$(DSK_NAME)
	$(MERGE) $(BOOTFILE_FLOPPY)>os9boot
	$(MERGE) $(KERNEL_FLOPPY)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen tOC.txt $@,tOC
	$(MOVE) toctmp tocgen
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,$(file))

$(DSK_DW):
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_DW) -q $@ -n$(DSK_NAME)
	$(MERGE) $(BOOTFILE_DW)>os9boot
	$(MERGE) $(KERNEL_DW)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen tOC.txt $@,tOC
	$(MOVE) toctmp tocgen
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,$(file))

$(DSK_DW_BECKER):
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_DW) -q $@ -n$(DSK_NAME)
	$(MERGE) $(BOOTFILE_DW_BECKER)>os9boot
	$(MERGE) $(KERNEL_DW_BECKER)>kernel
	$(OS9GEN) $@ -b=os9boot -t=kernel
	$(RM) os9boot kernel
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/sierra AutoEx
	$(OS9COPY) $(SUPPORTFILES) $@,.
	$(MOVE) tocgen toctmp	# to not confuse Windows hosts
	tocgen tOC.txt $@,tOC
	$(MOVE) toctmp tocgen
	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,$(file))

dskcopy: dsk
	$(CP) $(DSKS) $(DSKDIR)

dskclean:
	$(RM) $(DSKS) sidDir sidSnd

info:
	@$(ECHO) "*** Leisure Suit Larry ***"
	@$(foreach dsk, $(DSKS), $(ECHO) $(dsk);)
