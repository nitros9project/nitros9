GAME_SOURCE = arcadepak
GAME_PROGRAMS = smash/smash smash/custom thexder/thexder thexder/thexs shanghai/shanghai shanghai/stile
GAME_SYSFILES = smash/flags.dat smash/ia.fnt smash/smash.dat smash/smash.hsc thexder/ia.fnt \
    shanghai/cards.til shanghai/shanghai.til shanghai/traffic.til
GAME_ROOTFILES = smash/empty_smash.txt thexder/empty_thexder.txt shanghai/empty_tiles.vef
GAME_STARTUP = $(GAME_RECIPE_DIR)/startup/arcadepak
TERM_COLS = 40
GAME_CHECK_COMMAND = smash
