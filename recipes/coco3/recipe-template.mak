# Optional per-recipe overrides for coco3/coco3.mak.
#
# Usage:
#   1) Copy l2/ to a new recipe folder (for example myrecipe/).
#   2) Copy this file to myrecipe/recipe.mak.
#   3) Edit only what you need.

# Used in output name: l<LEVEL>_<RECIPE>.dsk
# Example: l2_coco3custom.dsk
RECIPE ?= coco3

# Append additional compiler/linker flags
# AFLAGS_EXTRA += -DMY_FEATURE=1
# LFLAGS_EXTRA += -L /path/to/extra/libdir

# Append modules to the default boot list (bare names, no path prefix)
# BOOTMODS_EXTRA += mymodule

# Append commands copied into the disk image (bare names, no path prefix)
# CMDS_EXTRA += mycmd
