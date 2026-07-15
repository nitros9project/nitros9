# CoCo 3 Sierra AGI recipe defaults.

GAME ?= kingsquest3
RECIPE = coco3_$(GAME)
TERM_COLS = 40
STARTUP = ./startup
CMDS_BASE = shell utilpak1 grfdrv
SIERRA_DIR = $(3RDPARTY)/packages/sierra/$(GAME)
SIERRA_DATA_FILES = $(notdir $(wildcard $(SIERRA_DIR)/logDir $(SIERRA_DIR)/object \
	$(SIERRA_DIR)/picDir $(SIERRA_DIR)/sndDir $(SIERRA_DIR)/viewDir \
	$(SIERRA_DIR)/words.tok $(SIERRA_DIR)/vol.*))

ifeq ($(GAME),blackcauldron)
SIERRA_MEDIA = 80d
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_40d.txt
else ifeq ($(GAME),christmas86)
SIERRA_MEDIA = 80d
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC.txt
else ifeq ($(GAME),goldrush)
SIERRA_MEDIA = dw
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),kingsquest1)
SIERRA_MEDIA = 80d
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_80d.txt
else ifeq ($(GAME),kingsquest2)
SIERRA_MEDIA = 80d
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_80d.txt
else ifeq ($(GAME),kingsquest3)
SIERRA_MEDIA = 80d
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_80d.txt
else ifeq ($(GAME),kingsquest4)
SIERRA_MEDIA = dw
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),leisuresuitlarry)
SIERRA_MEDIA = 80d
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC.txt
else ifeq ($(GAME),manhunter1)
SIERRA_MEDIA = dw
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),manhunter2)
SIERRA_MEDIA = dw
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),policequest1)
SIERRA_MEDIA = dw
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),spacequest0)
SIERRA_MEDIA = dw
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),spacequest1)
SIERRA_MEDIA = 80d
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_80d.txt
else ifeq ($(GAME),spacequest2)
SIERRA_MEDIA = 80d
SIERRA_TOC_TXT = $(SIERRA_DIR)/tOC_80d.txt
else
$(error Unsupported Sierra GAME "$(GAME)")
endif

ifeq ($(SIERRA_MEDIA),80d)
OS9FORMAT_CMD = $(OS9FORMAT_DS80)
RBF = rbf.mn rb1773.dr ddd0_80d.dd
KERNEL_TRACK = $(REL) boot_1773_6ms krn
else ifeq ($(SIERRA_MEDIA),dw)
OS9FORMAT_CMD = $(OS9FORMAT_DW)
RBF = rbf.mn rbdw.dr dwio.sb ddx0.dd
KERNEL_TRACK = $(REL) boot_dw krn
else
$(error Unsupported SIERRA_MEDIA "$(SIERRA_MEDIA)")
endif

# Run Sierra's AGI games with a 40-column CoWin terminal. Co3HiRes supplies
# the application-screen services formerly provided by CoVDG.
SCF = scf.mn vtio.dr co3hires.sb snddrv_cc3.sb joydrv_joy.sb cowin.io \
	term_win40.dt vrn.dr vi.dd
PIPE =
BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA)

CMDS_EXTRA += sierra mnln scrn shdw
