GAME_SOURCE = adventure
GAME_PROGRAMS = build/adventure
GAME_C3 = 1
TERM_COLS = 80
GAME_STARTUP = $(GAME_RECIPE_DIR)/startup/adventure
GAME_ROOTFILES = $(patsubst $(GAME_DIR)/%,%,$(wildcard $(GAME_DIR)/data/*.dat))
GAME_DATA_DIR = GAMES/ADVENT
