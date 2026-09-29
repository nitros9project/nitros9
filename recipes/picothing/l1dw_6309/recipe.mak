# Pico-Thing Level 1 DriveWire-boot recipe.
#
# Same modules as the IDE build, but /DD is DriveWire drive 0 (ddx0.dd), for
# a board booted with the monitor's `nitros9 drivewire`: REL loads OS9Boot
# over the auxiliary ACIA from a DriveWire server instead of the PATA disk.

RECIPE = picothing_dw
BOOTDEV = dw
