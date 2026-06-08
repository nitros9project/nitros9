# CoCo 3 Sierra AGI recipe defaults.

GAME ?= kingsquest3
RECIPE = coco3_$(GAME)
TERM_COLS = 32
STARTUP = ./startup
CMDS_BASE = shell utilpak1
SIERRA_DIR = $(3RDPARTY)/packages/sierra/$(GAME)
SIERRA_DATA_FILES = $(notdir $(wildcard $(SIERRA_DIR)/logDir $(SIERRA_DIR)/object \
	$(SIERRA_DIR)/picDir $(SIERRA_DIR)/sndDir $(SIERRA_DIR)/viewDir \
	$(SIERRA_DIR)/words.tok $(SIERRA_DIR)/vol.*))

ifeq ($(GAME),blackcauldron)
SIERRA_DEFAULT_MEDIA = 80d
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_40d.txt
else ifeq ($(GAME),christmas86)
SIERRA_DEFAULT_MEDIA = 80d
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC.txt
else ifeq ($(GAME),goldrush)
SIERRA_DEFAULT_MEDIA = dw
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),kingsquest1)
SIERRA_DEFAULT_MEDIA = 80d
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_80d.txt
else ifeq ($(GAME),kingsquest2)
SIERRA_DEFAULT_MEDIA = 80d
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_80d.txt
else ifeq ($(GAME),kingsquest3)
SIERRA_DEFAULT_MEDIA = 80d
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_80d.txt
else ifeq ($(GAME),kingsquest4)
SIERRA_DEFAULT_MEDIA = dw
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),leisuresuitlarry)
SIERRA_DEFAULT_MEDIA = 80d
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC.txt
else ifeq ($(GAME),manhunter1)
SIERRA_DEFAULT_MEDIA = dw
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),manhunter2)
SIERRA_DEFAULT_MEDIA = dw
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),policequest1)
SIERRA_DEFAULT_MEDIA = dw
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),spacequest0)
SIERRA_DEFAULT_MEDIA = dw
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_dw.txt
else ifeq ($(GAME),spacequest1)
SIERRA_DEFAULT_MEDIA = 80d
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_80d.txt
else ifeq ($(GAME),spacequest2)
SIERRA_DEFAULT_MEDIA = 80d
SIERRA_TOC_DEFAULT = $(SIERRA_DIR)/tOC_80d.txt
else
$(error Unsupported Sierra GAME "$(GAME)")
endif

# Override SIERRA_MEDIA on the command line to build a game with a different
# supported disk backend, e.g. GAME=kingsquest3 SIERRA_MEDIA=dw.
SIERRA_MEDIA ?= $(SIERRA_DEFAULT_MEDIA)
SIERRA_TOC_DW = $(wildcard $(SIERRA_DIR)/tOC_dw.txt)
SIERRA_TOC_TXT ?= $(if $(and $(filter dw,$(SIERRA_MEDIA)),$(SIERRA_TOC_DW)),$(SIERRA_TOC_DW),$(SIERRA_TOC_DEFAULT))

ifeq ($(SIERRA_MEDIA),80d)
OS9FORMAT_CMD = $(OS9FORMAT_DS80)
RBF = rbf.mn rb1773.dr ddd0_80d.dd
KERNEL_TRACK = rel_32 boot_1773_6ms krn
else ifeq ($(SIERRA_MEDIA),dw)
OS9FORMAT_CMD = $(OS9FORMAT_DW)
RBF = rbf.mn rbdw.dr dwio.sb ddx0.dd
KERNEL_TRACK = rel_32 boot_dw krn
else
$(error Unsupported SIERRA_MEDIA "$(SIERRA_MEDIA)")
endif

# Sierra's AGI games expect the CoCo 3 VDG-compatible terminal stack plus
# the VRN and VI modules.
SCF = scf.mn vtio.dr snddrv_cc3.sb joydrv_joy.sb covdg_small.io \
	term_vdg.dt vrn.dr vi.dd
PIPE =
BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	sysgo_dd \
	$(BOOTMODS_EXTRA)

CMDS_EXTRA += sierra mnln scrn shdw
