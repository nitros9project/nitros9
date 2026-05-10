# CoCo 1/2 DriveWire-oriented recipe defaults.

RECIPE = coco_dw
STARTUP = $(NITROS9DIR)/level1/$(PORT)/startup.dw
OS9FORMAT_CMD = $(OS9FORMAT_DW)
KERNEL_TRACK = rel krn krnp2 init boot_dw
RBF = rbf rbdw dwio ddx0 x1 x2 x3
CLOCK = clock_60hz clock2_dw
CMDS_EXTRA += dw inetd telnet httpd
