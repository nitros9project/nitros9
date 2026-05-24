LEVEL = 2
BASIC09_CMDS = basic09 runb basic09m runbm gfx2 gfx inkey syscall
BASIC09_SAMPLES ?= $(3RDPARTY)/packages/basic09/samples/hello.b09
CMDS_EXTRA += $(BASIC09_CMDS)
include ../coco3.mak

BASIC09_MODULAR_BUILDER = $(3RDPARTY)/packages/basic09/build-modular-basic09.pl
BASIC09_MODULAR_SRC = $(BASIC09_MODULAR_BUILDER) \
	$(wildcard $(3RDPARTY)/packages/basic09/modular/*)

$(MODDIR)/basic09m: $(BASIC09_MODULAR_SRC) | $(MODDIR)
	perl $(BASIC09_MODULAR_BUILDER) basic09 $@

$(MODDIR)/runbm: $(BASIC09_MODULAR_SRC) | $(MODDIR)
	perl $(BASIC09_MODULAR_BUILDER) runb $@
