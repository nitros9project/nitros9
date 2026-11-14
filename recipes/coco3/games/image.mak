.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
LEVEL = 2
GAME_DIR = $(NITROS9_GAMES_DIR)/$(GAME_SOURCE)
include $(GAME_RECIPE_DIR)/configs/$(GAME).mak
GAME_TRANSPORTS ?= floppy
ifeq ($(filter $(GAME_TRANSPORTS),$(TRANSPORT)),)
$(error GAME=$(GAME) supports TRANSPORT=$(GAME_TRANSPORTS))
endif

RECIPE = game_$(GAME)_$(CPU)_$(TRANSPORT)
OBJDIR = .obj
LIBDIR = .lib
MODDIR = .mods
PORTDEFSDIR =
# These small game disks need the font/pattern files, not the full help library.
SYSTEXT =
CMDS_BASE = shell grfdrv utilpak1 load link echo merge
PIPE =
STARTUP = $(if $(GAME_STARTUP),$(GAME_STARTUP),startup.game)
GAME_DATA_DIR ?= .
GAME_DATA_PROGRAMS ?=
GAME_BUILD_TARGET ?= all
ifneq ($(GAME_C3),1)
CMDS_BASE = shell $(if $(filter-out 32,$(TERM_COLS)),grfdrv)
SYSDIR =
endif

ifeq ($(SIERRA),1)
GAME_REPLAY ?= $(NITROS9DIR)/scripts/sierra-replay.lua
GAME_REPLAY_FRAMES ?= 7200
GAME_REPLAY_SECONDS ?= 140
DSKIMAGE = $(DISK1)
GAME_ROOTFILES = $(SUPPORTFILES1)
RECIPE_OUTPUTS = $(DISK1) $(DISK2) $(DISK3)
endif

ifneq ($(TRANSPORT),floppy)
DWIO_MODULE = $(if $(filter becker,$(TRANSPORT)),dwio_becker.sb,dwio.sb)
DW_BOOT_MODULE = $(if $(filter becker,$(TRANSPORT)),boot_dw_becker,boot_dw)
RBF = rbf.mn rbdw.dr $(DWIO_MODULE) ddx0.dd x1.dd x2.dd x3.dd
KERNEL_TRACK = $(REL) $(DW_BOOT_MODULE) krn
CLOCK = clock_60hz clock2_dw
OS9FORMAT_CMD = $(OS9FORMAT_DW)
endif

include $(GAME_RECIPE_DIR)/../coco3.mak
# Only the selected terminal and a few window descriptors are needed.
SCF = scf.mn vtio.dr co3hires.sb snddrv_cc3.sb joydrv_joy.sb $(TERM_IO) $(TERM_WIN_DT) \
	$(if $(filter-out 32,$(TERM_COLS)),w.dw w1.dw w2.dw w3.dw)

GAME_EXECUTABLES = $(addprefix $(GAME_DIR)/,$(GAME_PROGRAMS))
GAME_FILES = $(addprefix $(GAME_DIR)/,$(GAME_ROOTFILES) $(GAME_SYSFILES) $(GAME_DATA_PROGRAMS)) $(GAME_SCREENFILES)
RECIPE_DEPS += $(GAME_EXECUTABLES) $(GAME_FILES) $(GAME_RECIPE_DIR)/image.mak \
	$(GAME_RECIPE_DIR)/configs/$(GAME).mak $(NITROS9DIR)/scripts/install-game.py
ifeq ($(SIERRA),1)
RECIPE_DEPS += $(GAME_DIR)/$(TOC_INPUT)
endif

# Build against the current checkout; never fetch, reset or switch local sources.
game-build:
	@test -f "$(GAME_DIR)/Makefile" || { echo "Missing game sources: $(GAME_DIR)"; exit 1; }
ifeq ($(GAME_C3),1)
	$(MAKE) -C "$(LANGUAGES)/c3" runtime
endif
	$(MAKE) -C "$(GAME_DIR)" NITROS9DIR="$(NITROS9DIR)" PORT=coco3 C3ROOT="$(LANGUAGES)/c3" $(GAME_BUILD_TARGET)
	@{ git -C "$(NITROS9DIR)" log -1 --format='nitros9 %H'; \
	   git -C "$(NITROS9_GAMES_DIR)" log -1 --format='nitros9-games %H'; \
	   git -C "$(NITROS9_GAMES_DIR)" status --short --untracked-files=normal -- "$(GAME_SOURCE)"; } > revisions.txt
	@cat revisions.txt

startup.game: $(GAME_RECIPE_DIR)/configs/$(GAME).mak
	@printf 'link shell\n' > $@
ifneq ($(GAME_COMMAND),)
	@printf '%s\n' '$(GAME_COMMAND) </term' >> $@
endif

# Install payloads without text conversion: imported data includes binary files.
define RECIPE_INSTALL
	python3 $(NITROS9DIR)/scripts/install-game.py --disk "$(1)" --source "$(GAME_DIR)" \
		--programs $(GAME_PROGRAMS) --root $(GAME_ROOTFILES) --sys $(GAME_SYSFILES) \
		--data-dir "$(GAME_DATA_DIR)" --data-programs $(GAME_DATA_PROGRAMS) --screens $(GAME_SCREENFILES) \
		$(if $(SYSDIR),--sys-exists) $(if $(SIERRA),--toc "$(GAME_DIR)/$(TOC_INPUT)")
endef

# Sierra's additional volumes are data disks, built with the same geometry.
ifneq ($(DISK2),)
$(DISK2): $(addprefix $(GAME_DIR)/,$(SUPPORTFILES2)) $(GAME_RECIPE_DIR)/configs/$(GAME).mak $(NITROS9DIR)/scripts/install-game.py
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n$(DISK2_NAME)
	python3 $(NITROS9DIR)/scripts/install-game.py --disk "$@" --source "$(GAME_DIR)" --root $(SUPPORTFILES2)
endif
ifneq ($(DISK3),)
$(DISK3): $(addprefix $(GAME_DIR)/,$(SUPPORTFILES3)) $(GAME_RECIPE_DIR)/configs/$(GAME).mak $(NITROS9DIR)/scripts/install-game.py
	$(RM) $@
	$(OS9FORMAT_CMD) -q $@ -n$(DISK3_NAME)
	python3 $(NITROS9DIR)/scripts/install-game.py --disk "$@" --source "$(GAME_DIR)" --root $(SUPPORTFILES3)
endif

MAME_BINARY ?= mame
MAME_ROM_PATH ?= $(HOME)/.local/share/mame/roms
MAME_RAM ?= $(if $(SIERRA),2048K,512K)
MAME_MACHINE ?= $(if $(filter 6309,$(CPU)),coco3h,coco3)
MAME_FLAGS ?= -rompath "$(MAME_ROM_PATH)" -window -nothrottle -skip_gameinfo -ram $(MAME_RAM) \
	-autoboot_delay 3 -autoboot_command "DOS\n" -ext fdc,bios=v11 -ext:fdc:wd17xx:0 525qd
run: $(RECIPE_OUTPUTS)
ifeq ($(TRANSPORT),floppy)
	python3 $(NITROS9DIR)/scripts/mame-rgb.py --machine $(MAME_MACHINE) --config cfg
	$(MAME_BINARY) $(MAME_MACHINE) $(MAME_FLAGS) -cfg_directory cfg -nvram_directory nvram \
		-flop1 $(DSKIMAGE) $(if $(DISK2),-flop2 $(DISK2))
else
	$(error Use DriveWire to mount the $(TRANSPORT) images; run/check currently support floppy)
endif

check: $(RECIPE_OUTPUTS)
ifneq ($(TRANSPORT),floppy)
	$(error check currently supports TRANSPORT=floppy only)
endif
	python3 $(NITROS9DIR)/scripts/game-mame-smoke.py --disk "$(abspath $(DSKIMAGE))" \
		--cpu $(CPU) --game $(GAME) --program "$(GAME_DIR)/$(if $(SIERRA),mnln,$(firstword $(GAME_PROGRAMS)))" $(if $(SIERRA),--scan-mapped-modules --error-byte 0x9f) \
		--mame "$(MAME_BINARY)" --ram "$(MAME_RAM)" --rompath "$(MAME_ROM_PATH)" --output "$(CURDIR)/verification" $(GAME_CHECK_FLAGS) \
		$(if $(DISK2),--disk2 "$(abspath $(DISK2))") $(if $(GAME_CHECK_COMMAND),--command "$(GAME_CHECK_COMMAND)") \
		$(if $(GAME_REPLAY),--replay "$(GAME_REPLAY)" --min-frames $(GAME_REPLAY_FRAMES) --seconds $(GAME_REPLAY_SECONDS))

manifest:
	python3 $(NITROS9DIR)/scripts/game-collection.py manifest --output manifest.json --game $(GAME) \
		--source "$(GAME_DIR)" --cols $(TERM_COLS) --programs $(GAME_PROGRAMS) \
		--root $(GAME_ROOTFILES) $(if $(SIERRA),$(SUPPORTFILES2) $(SUPPORTFILES3)) \
		--sys $(GAME_SYSFILES) --screens $(GAME_SCREENFILES) --data-dir "$(GAME_DATA_DIR)" \
		--data-programs $(GAME_DATA_PROGRAMS) $(if $(GAME_STARTUP),--startup "$(GAME_STARTUP)") \
		--command "$(GAME_COMMAND)" $(if $(SIERRA),--sierra)

.PHONY: game-build run check manifest
