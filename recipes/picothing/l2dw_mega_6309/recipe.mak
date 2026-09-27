# Pico-Thing Level 2 "mega" recipe, HD6309 native (DriveWire boot).
#
# As l2dw_mega but assembled in HD6309 native mode: a DriveWire boot of
# the expanded 4 MB payload.  See ../l2dw/recipe.mak (DriveWire boot) and
# ../mega.mak (payload).

include ../l2dw/recipe.mak
include ../mega.mak

RECIPE = picothing_dw_mega
