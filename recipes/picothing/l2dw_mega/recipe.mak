# Pico-Thing Level 2 "mega" recipe (DriveWire boot).
#
# Same expanded payload as l2_mega, but /DD is DriveWire drive 0, for a board
# booted with the monitor's `nitros9 drivewire`: REL loads OS9Boot over the
# auxiliary ACIA from a DriveWire server instead of the PATA disk.

include ../l2dw/recipe.mak
include ../mega.mak

RECIPE = picothing_dw_mega
