# Boot from the floppy; mount the large EmuDsk volume as /DD and /H0.
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
LEVEL = 2
PORT = coco3
TERM_COLS = 80
RECIPE = games_$(CPU)
DSKIMAGE = games.vhd
VHD_SECTORS ?= 524288
OS9FORMAT_CMD = $(OS9) format -e -l$(VHD_SECTORS) -c4
STARTUP = startup.collection
PORTDEFSDIR =
SYSTEXT =
CMDS_BASE = shell grfdrv utilpak1 load link echo merge display
CMDS_EXTRA = games
RBF = rbf.mn emudsk.dr dd_emu.dd h0_emu.dd rb1773.dr d0_40d.dd d1_40d.dd
BOOTMODS_EXTRA = g40.dt vrn.dr vi.dd ftdd.dd
RECIPE_DEPS = collection.json $(NITROS9DIR)/scripts/game-collection.py
RECIPE_OUTPUTS = games.vhd games-boot.dsk
include $(GAME_RECIPE_DIR)/../coco3.mak

prepare:
	python3 $(NITROS9DIR)/scripts/game-collection.py prepare --recipe "$(GAME_RECIPE_DIR)" \
		--cpu $(CPU) --games $(GAMES) --output "$(CURDIR)"

$(MODDIR)/games: $(GAME_RECIPE_DIR)/menu.asm menu-data.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@

# Full-screen CoWin device for games that need a narrower console.
g40.asm: $(L2PMD)/term_win40.asm
	python3 $(NITROS9DIR)/scripts/game-collection.py descriptor --source $< --output $@ --number 1 --name G40

$(MODDIR)/dd_emu.dd: $(L1MD)/emudskdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=1 -DDNum=0

$(MODDIR)/h0_emu.dd: $(L1MD)/emudskdesc.asm | $(MODDIR)
	$(AS) $(AFLAGS) $< $(ASOUT)$@ -DDD=0 -DDNum=0

# The hard drive carries the files; the floppy carries the initial kernel/bootfile.
games-boot.dsk: games.vhd
	$(RM) $@
	$(OS9FORMAT_DS40) -q $@ -n"Games boot $(CPU)"
	$(OS9GEN) $@ -b=bootfile -t=kerneltrack

define RECIPE_INSTALL
	python3 $(NITROS9DIR)/scripts/game-collection.py install --manifest collection.json --disk "$(1)"
endef

MAME_BINARY ?= mame
MAME_ROM_PATH ?= $(HOME)/.local/share/mame/roms
MAME_RAM ?= 2048K
MAME_FLAGS ?= -window -skip_gameinfo
VHD_TEST_GAME ?= sokoban
ensure-boot:
	@for source in "$(GAME_RECIPE_DIR)/collection.mak" "$(GAME_RECIPE_DIR)/menu.asm" \
		"$(NITROS9DIR)/scripts/game-collection.py" "$(GAME_RECIPE_DIR)/../coco3.mak"; do \
		if test "$$source" -nt games-boot.dsk; then $(MAKE) update-boot || exit $$?; break; fi; \
	done

play: ensure-boot
	python3 $(NITROS9DIR)/scripts/mame-rgb.py --machine $(if $(filter 6309,$(CPU)),coco3h,coco3) --config cfg
	$(MAME_BINARY) $(if $(filter 6309,$(CPU)),coco3h,coco3) -rompath "$(MAME_ROM_PATH)" \
		$(MAME_FLAGS) -ram $(MAME_RAM) -cfg_directory cfg -nvram_directory nvram \
		-ext fdc,bios=v11 -ext:fdc:wd17xx:0 525qd -flop1 games-boot.dsk -hard1 games.vhd \
		-autoboot_delay 3 -autoboot_command "DOS\n"

check: $(RECIPE_OUTPUTS)
	python3 $(NITROS9DIR)/scripts/game-collection.py check --manifest collection.json --cpu $(CPU) \
		--game "$(VHD_TEST_GAME)" --mame "$(MAME_BINARY)" --rompath "$(MAME_ROM_PATH)" --ram "$(MAME_RAM)"

update-menu:
	python3 $(NITROS9DIR)/scripts/game-collection.py menu --manifest collection.json --output menu-data.asm
	$(MAKE) $(MODDIR)/games
	python3 $(NITROS9DIR)/scripts/install-game.py --disk games.vhd --source $(MODDIR) --programs games

update-boot:
	$(MAKE) libs kernelfile bootfile
	python3 $(NITROS9DIR)/scripts/game-collection.py refresh-launchers --manifest collection.json --disk games.vhd
	python3 $(NITROS9DIR)/scripts/game-collection.py refresh-sierra-tocs --manifest collection.json --disk games.vhd
	$(OS9GEN) games.vhd -t=kerneltrack
	python3 $(NITROS9DIR)/scripts/game-collection.py link-boot --disk games.vhd --bootfile bootfile
	$(RM) games-boot.dsk
	$(OS9FORMAT_DS40) -q games-boot.dsk -n"Games boot $(CPU)"
	$(OS9GEN) games-boot.dsk -b=bootfile -t=kerneltrack
	$(MAKE) update-menu
	python3 $(NITROS9DIR)/scripts/mame-rgb.py --machine $(if $(filter 6309,$(CPU)),coco3h,coco3) --config cfg

.PHONY: prepare play check update-menu update-boot ensure-boot
