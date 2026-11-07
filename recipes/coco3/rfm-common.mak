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

prepare: ../rfm-prepare.py libs $(BOOTSTRAP) bootfile $(MODDIR)/sysgo_dd $(addprefix $(MODDIR)/,$(CMDS)) $(STARTUP) | $(SYSDIR)
	$(MAKE) -C $(SYSDIR) -f $(SYS_RECIPE) --no-print-directory
	$(PYTHON) ../rfm-prepare.py --recipe "$(CURDIR)" --commands $(CMDS) --sys-binary $(SYSBIN) --sys-text $(SYSTEXT) sysgo.cfg --startup "$(STARTUP)"

host-root: prepare

.PHONY: prepare host-root
