GAME_SOURCE = mmission
GAME_PROGRAMS = mm mod1.dat mod2.dat mod3.dat mod4.dat mod5.dat  		mod6.sbr mod7.sbr mod8.sbr
GAME_COMMAND = mm
TERM_COLS = 32
GAME_ROOTFILES = global.dat mm.lib mm.pnl mm.ttl mod7.lib

GAME_STARTUP = $(GAME_RECIPE_DIR)/startup/mmission
GAME_REPLAY = $(NITROS9DIR)/scripts/mmission-replay.lua
GAME_REPLAY_FRAMES = 7200
GAME_REPLAY_SECONDS = 140
GAME_CHECK_FLAGS = --min-screen-colors 4
