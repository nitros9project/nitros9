# Optional per-recipe overrides for coco3/coco3.mak.
#
# Usage:
#   1) Copy l2/ to a new recipe folder (for example myrecipe/).
#   2) Copy this file to myrecipe/recipe.mak.
#   3) Edit only what you need.

# Used in output name: l<LEVEL>_<RECIPE>.dsk
# Example: l2_coco3custom.dsk
RECIPE ?= coco3

# Set CPU on the make command line to select the CoCo 3 build flavor.
# Supported values: 6809, 6309
# Example: make CPU=6309
# CPU = 6809

# Set to 32, 40, or 80 to select the /TERM display width (default: 80).
#   32 uses the VDG chip (covdg.io + term_vdg.dt, 32x16 CoCo 1/2-style).
#   40 and 80 use the CoCo 3 window system (cowin.io + term_win{40,80}.dt).
# TERM_COLS = 32

# Set to 1 for black/white /TERM colors instead of the default black/green
# (applies to 40- and 80-column window modes only).
# TERM_ALTCOLOR = 1

# Append additional compiler/linker flags
# AFLAGS_EXTRA += -DMY_FEATURE=1
# LFLAGS_EXTRA += -L /path/to/extra/libdir

# Append modules to the default boot list (bare names, no path prefix)
# BOOTMODS_EXTRA += mymodule

# Append commands copied into the disk image (bare names, no path prefix)
# CMDS_EXTRA += mycmd
