LEVEL = 2
include ../coco3.mak

run: $(DSKIMAGE)
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -flop1 $(DSKIMAGE)

ifneq ($(KEYRPT),)
KEYRPT_ARGS = $(if $(filter 0,$(KEYRPT)),0 0,$(KEYRPT))
ifeq ($(MINIMAL),0)
startup.keyrpt: $(NITROS9DIR)/level2/$(PORT)/startup
	{ echo "keyrpt $(KEYRPT_ARGS)</1"; cat $<; } >$@
endif
endif

startup.minimal:
	echo "link shell" > $@
ifneq ($(KEYRPT),)
	echo "keyrpt $(KEYRPT_ARGS)</1" >> $@
endif

.PHONY: run startup.minimal
