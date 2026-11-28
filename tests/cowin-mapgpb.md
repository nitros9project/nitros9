# CoWin mapped-buffer return regression

`cowin-mapgpb.c` creates a one-scanline graphics buffer, maps it, and repeats the
mapping request. Both calls must return the same address and the 160-byte data
length. It then writes pixels through that pointer, puts them on screen, clears
the mapped buffer, and reads the screen back to verify the mapping. Finally it
unmaps and releases the buffer and writes `/dd/maptest.result`.

Build it as an OS-9/6809 module named `maptest` using LLVM-MC6809, an installed
OS-9 picolibc sysroot, and nitros9-c-libs' LLVM compatibility library:

```sh
"$LLVM_CC" --target=mc6809-unknown-os9 --sysroot="$LLVM_SYSROOT" -Os \
  -I"$LLVM_OS9_COMPAT_ROOT/include" tests/cowin-mapgpb.c \
  "$LLVM_OS9_COMPAT_LIB" -o maptest
```

The compatibility library must include the fix that explicitly tests U in its
native register-copy loops. Without that fix the client cannot see all returned
registers, independently of CoWin's behavior.

Install `maptest` as an executable on a scratch CoCo 3 NitrOS-9 Level 2 disk with
CoWin, grfdrv and `/w`, then run it. A successful result begins with ASCII `PASS`,
followed by three big-endian 16-bit words: zero status, mapped address, and length.
A failure begins with `FAIL` followed by its numbered check and diagnostic words.
The unpatched driver fails check 6: its second call reports success but leaves
X/Y holding the input group/buffer selector and mapping flag.

The same driver source is assembled for both 6809 and 6309. Runtime verification
uses a CoCo 3 with the 6809 driver; 6309 conditional paths are also assembled.
