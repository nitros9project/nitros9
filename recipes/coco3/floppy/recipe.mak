# CoCo 3 floppy-oriented recipe defaults.

MINIMAL ?= 0
MAME ?= 0
ifeq ($(MAME),1)
KEYRPT_DEFAULT = 0
endif
KEYRPT ?= $(KEYRPT_DEFAULT)
CLEAN_EXTRA += startup.keyrpt startup.minimal

ifeq ($(MINIMAL),1)
RECIPE = coco3_minimal
RBF = rbf.mn rb1773.dr ddd0_$(TRACKS)d.dd
SCF ?= scf.mn vtio.dr co3hires.sb snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) \
	$(TERM_WIN_DT)
PIPE =
CMDS_BASE = shell grfdrv
SYSDIR =
PORTDEFSDIR =
STARTUP = startup.minimal
ifneq ($(KEYRPT),)
CMDS_BASE += keyrpt
endif
endif

BOOTMODS = krnp2 ioman init \
	$(RBF) \
	$(SCF) \
	$(PIPE) \
	$(CLOCK) \
	$(BOOTMODS_EXTRA)

ifeq ($(MINIMAL),0)
BASIC09_CMDS = basic09 gfx gfx2 inkey runb syscall
CMDS_EXTRA += $(BASIC09_CMDS)
endif

ifneq ($(KEYRPT),)
ifeq ($(MINIMAL),0)
STARTUP = startup.keyrpt
endif
endif

MAME_BINARY  ?= mame
MAME_MACHINE ?= coco3
MAME_FLAGS   ?= -rompath $(MAME_ROM_PATH) -window -nothrottle -skip_gameinfo -autoboot_delay 5 -autoboot_command "DOS\n" -ext fdc -ext:fdc:wd17xx:0 525qd
