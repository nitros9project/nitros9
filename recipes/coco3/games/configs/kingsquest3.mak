GAME_SOURCE = sierra/kingsquest3
SIERRA = 1
TERM_COLS = 32
BOOTMODS_EXTRA = vrn.dr vi.dd
TRACKS = 80
DISK1 = KingsQuestIII.dsk
DISK1_NAME = "King's Quest III"
TOC_INPUT = tOC_80d.txt
SUPPORTFILES1 = logDir object picDir sndDir viewDir vol.0 vol.1 vol.2 vol.3 vol.4 vol.5 vol.6 vol.7 \
    vol.8 vol.9 vol.11 vol.12 vol.14 words.tok
GAME_PROGRAMS = sierra mnln scrn shdw tocgen
GAME_COMMAND = sierra
GAME_STARTUP = $(GAME_RECIPE_DIR)/startup/sierra

GAME_CHECK_FLAGS = --min-screen-colors 8
