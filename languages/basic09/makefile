include $(NITROS9DIR)/rules.mak

DSK	= basic09.dsk
COCO3_FLOPPY_RECIPE_DIR = $(NITROS9DIR)/recipes/coco3/floppy
COCO3_FLOPPY_BASE_NAME  = l2_coco3.dsk
COCO3_FLOPPY_BASE       = $(COCO3_FLOPPY_RECIPE_DIR)/$(COCO3_FLOPPY_BASE_NAME)

# Non-NitrOS-9
M6809		= $(AFLAGS)

DEFOPTS         = --preprocess -DLevel=2
DEPENDS		= ./makefile
MICROWARE_DIR	= microware
MICROWARE_SRCS	= \
	$(MICROWARE_DIR)/build-modular-basic09.py \
	$(MICROWARE_DIR)/makefile \
	$(MICROWARE_DIR)/comand.asm \
	$(MICROWARE_DIR)/compil.asm \
	$(MICROWARE_DIR)/binder.asm \
	$(MICROWARE_DIR)/stmts.asm \
	$(MICROWARE_DIR)/exprsn.asm \
	$(MICROWARE_DIR)/cnvio.asm \
	$(MICROWARE_DIR)/defs \
	$(MICROWARE_DIR)/b09defs \
	$(MICROWARE_DIR)/b09type \
	$(MICROWARE_DIR)/jmpdefs \
	$(MICROWARE_DIR)/linkage \
	$(MICROWARE_DIR)/editor

DEFOBJS		= coco3vtio.d
TEXTFILES	= ReadMe2 install6809 install6309
OBJS		= gfx gfx2 inkey syscall
OBJS6809	= basic09_6809 runb_6809
OBJS6309	= basic09_6309 runb_6309
ALLOBJS		= $(DEFOBJS) $(OBJS) $(OBJS6809) $(OBJS6309)
DSKOBJS		= $(OBJS) $(OBJS6809)

.NOTPARALLEL:

.PHONY: all banner clean dsk dskcopy dskclean showobjs info

all:	banner $(ALLOBJS) $(DEPENDS)

banner:
	@$(ECHO) "**************************************************"
	@$(ECHO) "*                                                *"
	@$(ECHO) "*                     Basic09                    *"
	@$(ECHO) "*                                                *"
	@$(ECHO) "**************************************************"

coco3vtio.d: $(DEFSDIR)/cocovtio.d
	$(AS) $(AFLAGS) $(DEFOPTS) -DCOCOVTIO.D=0 $< > $@

gfx2: gfx2.asm coco3vtio.d
	$(AS) $(ASOUT)$@ $< $(M6809) -DLevel=2

$(OBJS6809) $(OBJS6309): $(MICROWARE_SRCS)
	$(MAKE) -C $(MICROWARE_DIR) $@
	$(CP) $(MICROWARE_DIR)/$@ $@

clean: dskclean
	$(RM) $(ALLOBJS) *.list *.map
	$(MAKE) -C $(MICROWARE_DIR) clean

dsk: $(DSK)

$(DSK): $(DSKOBJS) $(COCO3_FLOPPY_BASE)
	$(RM) $@
	$(CP) $(COCO3_FLOPPY_BASE) $@
	$(OS9COPY) -r basic09_6809 $@,CMDS/basic09
	$(OS9COPY) -r runb_6809 $@,CMDS/runb
	$(OS9COPY) -r gfx $@,CMDS/gfx
	$(OS9COPY) -r gfx2 $@,CMDS/gfx2
	$(OS9COPY) -r inkey $@,CMDS/inkey
	$(OS9COPY) -r syscall $@,CMDS/syscall
	$(OS9ATTR_EXEC) $@,CMDS/basic09 $@,CMDS/runb $@,CMDS/gfx \
		$@,CMDS/gfx2 $@,CMDS/inkey $@,CMDS/syscall

dskcopy: $(DSK)
	$(CP) $(DSK) $(DSKDIR)

dskclean:
	$(RM) $(DSK)

showobjs:
	@$(ECHO) $(ALLOBJS)

info:
	@$(ECHO) "*** Basic09 ***"
	@$(ECHO) $(DSK)
