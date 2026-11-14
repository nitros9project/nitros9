GAME_SOURCE = sokoban
GAME_PROGRAMS = build/sokoban
GAME_C3 = 1
TERM_COLS = 80
GAME_STARTUP = $(GAME_RECIPE_DIR)/startup/sokoban
GAME_SCREENFILES = $(wildcard $(GAME_DIR)/screens/screen.*)
GAME_ROOTFILES = data/sok.score
