# Optional per-recipe overrides for wildbits/wildbits.mak.
#
# Usage:
#   1) Copy l1/ or l2/ to a new recipe folder (for example myrecipe/).
#   2) Copy this file to myrecipe/recipe.mak.
#   3) Edit only what you need.

# Used in output name: l<LEVEL>_<RECIPE><PLATFORM>.dsk
# Example: l1_mykitk2.dsk
RECIPE ?= wildbits

# Append additional compiler/linker flags
# AFLAGS_EXTRA += -DMY_FEATURE=1
# LFLAGS_EXTRA += -L /path/to/extra/libdir

# Append modules to the default boot list (bare names, no path prefix)
# BOOTMODS_EXTRA += mybootmod

# Append commands copied into the disk image (bare names, no path prefix)
# CMDS_EXTRA += mycmd

# Optional bootfile post-process command.
# For level 2, default is: ./padup256 bootfile
# PADUP =
