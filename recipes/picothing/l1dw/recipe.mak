# Pico-Thing Level 1 DriveWire-boot recipe.
#
# Same modules as the IDE build, but OS9Kernel carries the DriveWire boot
# module (boot_dw_pt) so the system loads OS9Boot over the auxiliary ACIA
# from a DriveWire server instead of the PATA disk.

RECIPE = picothing_dw
OS9KERNEL = os9kernel_dw
