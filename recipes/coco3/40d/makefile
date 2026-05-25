LEVEL = 2
BASIC09_CMDS = basic09 runb gfx2 gfx inkey syscall
BASIC09_SAMPLES ?= $(3RDPARTY)/packages/basic09/samples/unittest.b09
CMDS_EXTRA += $(BASIC09_CMDS)
include ../coco3.mak

$(MODDIR)/basic09: basic09.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

$(MODDIR)/runb: runb.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@
