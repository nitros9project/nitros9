LEVEL = 2
BASIC09_CMDS = basic09 gfx2 gfx inkey syscall
BASIC09_SAMPLES ?= $(3RDPARTY)/packages/basic09/samples/hello.b09
CMDS_EXTRA += $(BASIC09_CMDS)
include ../coco3.mak

$(MODDIR)/basic09: $(3RDPARTY)/packages/basic09/modular/basic09 | $(MODDIR)
	$(CP) $< $@
