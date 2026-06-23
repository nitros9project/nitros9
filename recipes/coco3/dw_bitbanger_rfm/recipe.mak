# CoCo 3 DriveWire bitbanger recipe with RFM modules.

RECIPE = coco3_dw_bitbanger_rfm
STARTUP = $(NITROS9DIR)/level2/$(PORT)/startup.dw
OS9FORMAT_CMD = $(OS9FORMAT_DW)
KERNEL_TRACK = rel_80 boot_rfm krn

RBF = rbf.mn rbdw.dr dwio.sb ddx0.dd x1.dd x2.dd x3.dd
SCF = scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb cowin.io \
	term_win80.dt
CLOCK = clock_60hz clock2_soft

BOOTMODS_EXTRA += rfm rfmdrv y0
DSK_EXTRA_DEPS = $(MODDIR)/sysgo_dd
DSK_POST_COPY = $(MAKE) copy-sysgo-root DSKIMAGE=$@

CMDS_EXTRA += pmap dmem smap mmap
