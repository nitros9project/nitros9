GAME_SOURCE = subsim
GAME_PROGRAMS = sub presub sub1 sub2 sub3 sub4 sub5 sub6
GAME_COMMAND = sub
TERM_COLS = 32
GAME_ROOTFILES = control1.cmp convoys.dat diesel.dat fonts.dat germap.cmp hiscore.dat mission.txt \
    missions.dat radar.dat shipmap2.dat sintbl.dat stitle.pic sub.dat usamap.cmp status.dat \
    substats.dat
GAME_DATA_DIR = SUB
GAME_DATA_PROGRAMS = sub6

GAME_STARTUP = $(GAME_RECIPE_DIR)/startup/subsim
GAME_CHECK_FLAGS = --min-screen-colors 3
