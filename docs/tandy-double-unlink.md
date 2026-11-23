# Same-process double-unlink diagnostic on Tandy Level Two

`DUnlink` performs all operations in one process. It reads its own 512-byte
process descriptor using `F$ID` and `F$GPrDsc`, then prints the first eight DAT
entries and eight 16-bit `P$Links` counters. It does not execute any of the
loaded utility modules. All numbers in the output are hexadecimal.

The fixture is `/dd/cmds/mall`, containing WCreate first, followed by MonType
and modpatch. The diagnostic loads that file, links MonType, unlinks WCreate
twice, then attempts to unlink MonType. Use a fresh, disposable OS-9 session
so earlier links do not affect the result. This deliberately tests an extra
unlink; it is not a balanced use of the per-module interface.

## Build and run

From the repository root:

```sh
make -C recipes/coco3/module_group_mame_test .mods/dunlink
```

Copy `.mods/dunlink` onto the test disk as `CMDS/dunlink` and give it execute
permission. On the Tandy guest, prepare the fixture and run:

```text
merge /dd/cmds/wcreate /dd/cmds/montype /dd/cmds/modpatch >/dd/cmds/mall
attr /dd/cmds/mall e
dunlink
```

Do not load mall separately first: the diagnostic does that itself. To retain
the output in the guest, use `dunlink >/dd/unlink-results`.

The output labels A as the module returned by F$Load (WCreate) and B as
MonType. `C` is the carry/error flag immediately after the operation; zero
means success. `BREG` is the raw B register, which is not an error code when
carry is clear. DAT value `333E` marks a free mapping slot.

## Observed result

Tested in MAME 0.289, CoCo 3 with 512 KB, using the original Tandy OS-9 Level
Two v02.00.01 System Master from the Color Computer Archive. Only the copied
disk's startup and test files were changed; its kernel was not modified.
The full output is in
`recipes/coco3/module_group_mame_test/tandy-double-unlink-results.txt`.

Every phase reported PID `05`. The mall group occupied slot 6 (addresses
C000–DFFF), mapped to physical block 000B:

| Phase | Group P$Links | Slot 6 DAT | Carry |
| --- | ---: | --- | ---: |
| Before load | 0 | 333E (free) | 0 |
| Load mall | 1 | 000B | 0 |
| Link MonType | 2 | 000B | 0 |
| First unlink WCreate | 1 | 000B | 0 |
| Second unlink WCreate | 0 | 333E (free) | 0 |
| Attempt unlink MonType | 0 | 333E (free) | 0 |

The second unlink removed the process's group mapping despite its outstanding
MonType link. The diagnostic continued because its own executable occupied a
separate mapping. This confirms the mapping/count problem for this deliberately
unbalanced sequence on Tandy Level Two; it does not establish a failure for
balanced links and unlinks, or prove a cross-process failure.

## NitrOS-9 fix

The NitrOS-9 Level Two `F$UnLink` now returns success without changing either
count or the mappings if the named module's `MD$Link` is already zero. This
prevents the extra unlink reproduced above from consuming MonType's remaining
group reference. It preserves the existing per-module accounting; it does not
add per-process ownership tracking for individual modules.

The nightly `module-groups` regression now records four stages for each of
its six cases: both members linked, first member unlinked, that member
unlinked again, and the remaining member unlinked. It executes the survivor
after both the valid and extra unlink, checks that the extra unlink changes
neither mappings nor group count nor group storage flags, then verifies
normal final release. Both unlink orders and single-block, multi-block,
and resident groups are covered. The Tandy output above remains the baseline
from the unmodified original kernel.
