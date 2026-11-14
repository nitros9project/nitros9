# Public entry point. Keep each game/CPU/transport in its own build directory.
.DEFAULT_GOAL := all
GAME_RECIPE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
NITROS9DIR ?= $(abspath $(GAME_RECIPE_DIR)/../../..)
NITROS9_GAMES_DIR ?= $(abspath $(NITROS9DIR)/../nitros9-games)
LANGUAGES ?= $(abspath $(NITROS9DIR)/../nitros9-languages)
GAME ?= rogue
CPU ?= 6809
GAMES ?= $(AVAILABLE_GAMES)
TRANSPORT ?= floppy
SUPPORTED_GAMES := $(basename $(notdir $(wildcard $(GAME_RECIPE_DIR)/configs/*.mak)))
AVAILABLE_GAMES := $(shell python3 "$(NITROS9DIR)/scripts/game-collection.py" available --recipe "$(GAME_RECIPE_DIR)" --source "$(NITROS9_GAMES_DIR)")
ifneq ($(words $(GAME)),1)
$(error GAME must select exactly one game)
endif
ifeq ($(filter $(SUPPORTED_GAMES),$(GAME)),)
$(error Unknown GAME "$(GAME)"; choose $(SUPPORTED_GAMES))
endif
ifneq ($(words $(CPU)),1)
$(error CPU must select exactly one processor)
endif
ifeq ($(filter 6809 6309,$(CPU)),)
$(error Unsupported CPU "$(CPU)")
endif
ifneq ($(words $(TRANSPORT)),1)
$(error TRANSPORT must select exactly one transport)
endif
ifeq ($(filter floppy dw becker,$(TRANSPORT)),)
$(error Unsupported TRANSPORT "$(TRANSPORT)"; choose floppy, dw, becker)
endif
BUILD_DIR := $(GAME_RECIPE_DIR)/.build/$(GAME)/$(CPU)/$(TRANSPORT)
export NITROS9DIR NITROS9_GAMES_DIR LANGUAGES GAME CPU TRANSPORT GAME_RECIPE_DIR

all disk run check payload:
	@mkdir -p "$(BUILD_DIR)"
	@printf '%s\n' 'GAME_RECIPE_DIR := $(GAME_RECIPE_DIR)' \
		'NITROS9DIR ?= $(NITROS9DIR)' 'NITROS9_GAMES_DIR ?= $(NITROS9_GAMES_DIR)' \
		'LANGUAGES ?= $(LANGUAGES)' 'GAME := $(GAME)' 'CPU := $(CPU)' \
		'TRANSPORT := $(TRANSPORT)' 'include $(GAME_RECIPE_DIR)/image.mak' > "$(BUILD_DIR)/makefile"
	cp "$(GAME_RECIPE_DIR)/../floppy/defsfile" "$(BUILD_DIR)/defsfile"
	$(MAKE) -C "$(BUILD_DIR)" -f "$(GAME_RECIPE_DIR)/image.mak" game-build
	$(MAKE) -C "$(BUILD_DIR)" -f "$(GAME_RECIPE_DIR)/image.mak" $(if $(filter payload,$@),manifest,$(if $(filter disk,$@),all,$@))

COLLECTION_DIR := $(GAME_RECIPE_DIR)/.build/collection/$(CPU)
export GAMES
vhd check-vhd:
	@mkdir -p "$(COLLECTION_DIR)"
	@printf '%s\n' 'GAME_RECIPE_DIR := $(GAME_RECIPE_DIR)' \
		'NITROS9DIR ?= $(NITROS9DIR)' 'NITROS9_GAMES_DIR ?= $(NITROS9_GAMES_DIR)' \
		'LANGUAGES ?= $(LANGUAGES)' 'CPU := $(CPU)' \
		'GAMES := $(GAMES)' 'include $(GAME_RECIPE_DIR)/collection.mak' > "$(COLLECTION_DIR)/makefile"
	cp "$(GAME_RECIPE_DIR)/../floppy/defsfile" "$(COLLECTION_DIR)/defsfile"
	$(MAKE) -C "$(COLLECTION_DIR)" prepare
	$(MAKE) -C "$(COLLECTION_DIR)" $(if $(filter check-vhd,$@),check,all)

run-vhd:
	@if test ! -f "$(COLLECTION_DIR)/games.vhd"; then $(MAKE) vhd; \
	elif test ! -f "$(COLLECTION_DIR)/games-boot.dsk"; then $(MAKE) update-vhd-boot; fi
	$(MAKE) -C "$(COLLECTION_DIR)" play

update-vhd-menu:
	@test -f "$(COLLECTION_DIR)/games.vhd" || { echo "Build a collection with make vhd first"; exit 1; }
	$(MAKE) -C "$(COLLECTION_DIR)" update-menu

update-vhd-boot:
	@test -f "$(COLLECTION_DIR)/games.vhd" || { echo "Build a collection with make vhd first"; exit 1; }
	$(MAKE) -C "$(COLLECTION_DIR)" update-boot

clean:
	rm -rf "$(BUILD_DIR)"

clean-vhd:
	rm -rf "$(COLLECTION_DIR)"

list:
	@printf '%s\n' $(SUPPORTED_GAMES)

.PHONY: all disk run check payload clean clean-vhd list vhd run-vhd check-vhd update-vhd-menu update-vhd-boot
