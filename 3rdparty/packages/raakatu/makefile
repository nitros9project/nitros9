include ../../../rules.mak

DEPENDS		= ./makefile

DSK		= Raakatu.dsk
CMDS		= raaka-tu raakatu
MD		= $(LEVEL2)/coco3/modules

# We make our own bootfile and kernel track
KERNEL   	= $(MD)/rel_32 $(MD)/boot_1773_6ms $(MD)/krn
OS9BOOT		= $(MD)/krnp2 $(MD)/ioman $(MD)/init \
		$(MD)/rbf.mn \
		$(MD)/rb1773.dr $(MD)/ddd0_40d.dd \
		$(MD)/scf.mn $(MD)/vtio.dr \
		$(MD)/joydrv_joy.sb $(MD)/snddrv_cc3.sb \
		$(MD)/covdg_small.io $(MD)/term_vdg.dt \
		$(MD)/clock_60hz $(MD)/clock2_soft $(MD)/sysgo_dd

SUPPORTFILES	= 

ALLOBJS		= $(CMDS)

all:	$(ALLOBJS)

clean:	dskclean
	$(RM) $(ALLOBJS)

$(DSK): all
	$(RM) $@
	$(CD) $(LEVEL2)/coco3; make
	$(OS9FORMAT_SS35) $@ -n"Raaka-Tu"
	$(MERGE) $(OS9BOOT)>os9boot
	$(MERGE) $(KERNEL)>kernel_1773
	$(OS9GEN) $@ -b=os9boot -t=kernel_1773
	$(RM) os9boot kernel_1773
	$(MAKDIR) $@,CMDS
	$(OS9COPY) $(CMDS) $@,CMDS
	$(OS9ATTR_EXEC) $(foreach file,$(CMDS),$@,CMDS/$(file))
	$(OS9RENAME) $@,CMDS/raakatu AutoEx
	$(OS9COPY) $(LEVEL2)/coco3/cmds/shell_21 $@,CMDS/shell
	$(OS9ATTR_EXEC) $@,CMDS/shell
#	$(OS9ATTR_TEXT) $(foreach file,$(SUPPORTFILES),$@,SUB/$(file))

dsk: $(DSK)

dskcopy: $(DSK)
	$(CP) $(DSK) $(DSKDIR)

dskclean:
	$(RM) $(DSK)

run: $(DSK)
	mess -inipath ~/Documents/SDLMESS -video opengl -window coco3 -flop1 $(DSK)
