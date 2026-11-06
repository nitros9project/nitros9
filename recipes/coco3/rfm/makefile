LEVEL = 2
include ../coco3.mak

PYTHON ?= python3
DRIVEWIRE_SERVER ?= drivewire-server
SERIAL_PORT ?=
BAUD ?= 115200
BOOTSTRAP = bootstrap.dsk

$(MODDIR)/dd_rfm: rfmdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1 -DDNum=0

$(BOOTSTRAP): kernelfile
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n"CoCo 3 RFM bootstrap"
	$(OS9GEN) $@ -t=$(KERNELFILE)

prepare: libs $(BOOTSTRAP) bootfile $(MODDIR)/sysgo_dd $(addprefix $(MODDIR)/,$(CMDS)) $(STARTUP) | $(SYSDIR)
	$(MAKE) -C $(SYSDIR) -f $(SYS_RECIPE) --no-print-directory
	$(PYTHON) prepare.py --commands $(CMDS) --sys-binary $(SYSBIN) --sys-text $(SYSTEXT) sysgo.cfg --startup "$(STARTUP)"

host-root: prepare

serve: prepare
	@test -n "$(SERIAL_PORT)" || { echo "Set SERIAL_PORT to the CoCo adapter path"; exit 1; }
	"$(DRIVEWIRE_SERVER)" --serial-port "$(SERIAL_PORT)" --baud $(BAUD) --disk0 "$(CURDIR)/$(BOOTSTRAP)" --rfm-root "$(CURDIR)"

.PHONY: prepare host-root serve
