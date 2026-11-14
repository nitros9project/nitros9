# Corsham 6809 boot ROM

Build and validate the 8 KB EPROM image with LWTOOLS, ToolShed, and Python 3:

```sh
make -C recipes/corsham check
```

The output is `recipes/corsham/bootrom`. It retains the original EPROM layout:
4 KB of leading padding, the kernel, Init, and SD booter at `$F000`, and REL
with the hardware vectors at `$FF00` through `$FFFF`. The payload before REL
has a hard 3,840-byte limit; the build fails rather than truncating it.

Corsham's Init keeps its configuration and version fields but shares one
empty string for the optional OS description, machine description, and build
metadata. This makes room for the current kernel without disabling services
or reverting kernel fixes, and keeps the ROM size independent of branch names.
The current payload uses all 3,840 bytes. The CI build checks the size, module
CRCs, Init string offsets, and REL/vector placement to catch future overflow.

This recipe builds the ROM only. The SD-card OS9Boot and filesystem are
separate from the EPROM image.
