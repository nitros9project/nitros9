GAME_SOURCE = koronis
GAME_TRANSPORTS = floppy dw becker
GAME_PROGRAMS = koronis
GAME_COMMAND = koronis
TERM_COLS = 32
GAME_ROOTFILES = SAVE1 SAVE2 crobot2.c ctitle.c korvar level01 level02 level03 level04 level05 level06 \
    level07 level08 level09 level10 level11 level12 level13 level14 level15 level16 level17 \
    level18 level19 level20 robotbuff sinwave ultek

GAME_REPLAY = $(NITROS9DIR)/scripts/koronis-replay.lua
GAME_REPLAY_FRAMES = 10800
GAME_REPLAY_SECONDS = 200

GAME_CHECK_FLAGS = --min-screen-colors 8
