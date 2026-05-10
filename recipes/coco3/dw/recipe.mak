# CoCo 3 DriveWire-oriented recipe defaults.

RECIPE = coco3_dw
STARTUP = $(NITROS9DIR)/level2/$(PORT)/startup.dw
OS9FORMAT_CMD = $(OS9FORMAT_DW)
KERNEL_TRACK = rel_80 boot_dw krn

RBF = rbf.mn rbdw.dr dwio.sb ddx0.dd x1.dd x2.dd x3.dd
SCF = scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb cowin.io \
	term_win80.dt w.dw w1.dw w2.dw w3.dw w4.dw w5.dw w6.dw w7.dw \
	w8.dw w9.dw w10.dw w11.dw w12.dw w13.dw w14.dw w15.dw \
	scdwv.dr n_scdwv.dd n1_scdwv.dd n2_scdwv.dd \
	n3_scdwv.dd n4_scdwv.dd n5_scdwv.dd
CLOCK = clock_60hz clock2_dw

CMDS_EXTRA += dw inetd telnet httpd
