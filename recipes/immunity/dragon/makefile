# Dragon 64 + i-MMU-nity, Level 2, booting from a DragonDOS floppy
# (TRACKS=40|80). DragonDOS BOOT loads stage0_d64 from the boot area
# (LSN 2-17); stage0 loads the normal Level 2 kernel track from track 34.
MEDIA = dragon
RECIPE = immunity_dragon
PwrLnFrq ?= 50
STARTUP = $(CURDIR)/startup
include ../immunity.mak
