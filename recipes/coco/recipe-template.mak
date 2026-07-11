# Optional per-recipe overrides for coco/coco.mak.
#
# Usage:
#   1) Copy floppy/ to a new recipe folder (for example myrecipe/).
#   2) Copy this file to myrecipe/recipe.mak.
#   3) Edit only what you need.

# Used in output name: l<LEVEL>_<RECIPE>.dsk
# Example: l1_mykit.dsk
RECIPE ?= coco

# Set floppy media to 40 or 80 tracks (default: 40).
# Example: make TRACKS=80
# TRACKS = 40

# Set to 1 for a smaller bootable floppy with core modules and shell only.
# Example: make MINIMAL=1
# MINIMAL = 0

# Set to 0 to disable OS-9 key repeat in a generated startup file.
# Leave unset to keep the normal startup file.
# MAME = 1 is accepted by floppy recipes as a compatibility alias.
# KEYRPT = 0

# Set to 1 to enable true lowercase on CoCo 2 boards with the 6847T1 VDG chip.
# Assembles term_vdg with ModCoVDG+1 instead of ModCoVDG.
# VDG_T1 = 1

# Append additional compiler/linker flags
# AFLAGS_EXTRA += -DMY_FEATURE=1
# LFLAGS_EXTRA += -L /path/to/extra/libdir

# Append modules to the default bootfile merge (bare names, no path prefix)
# BOOTMODS_EXTRA += mybootmod

# Append commands copied into the disk image (bare names, no path prefix)
# CMDS_EXTRA += mycmd
