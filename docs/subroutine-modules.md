# Subroutine modules

A *subroutine module* is OS-9's form of a runtime library: a self-contained,
relocatable module that other programs link to with `F$Link` and call through a
single execution entry. It is module type `Sbrtn` (`$20`). The trap handlers
that behave like shared system libraries — `math`, `cio` and friends — are also
subroutine modules; they differ only in how they are reached (through the user
trap mechanism rather than a plain link-and-call).

This note describes what a well-formed subroutine module looks like, using the
definitions in `defs/os9.d` and the kernel behaviour in
`level1/modules/kernel/flink.asm`.

## Module layout

Every OS-9 module shares a fixed nine-byte header, then a type-dependent part,
then the module body, and finally a three-byte CRC. For a subroutine module the
fields are:

| Offset | Field | Size | Meaning |
| --- | --- | --- | --- |
| `$00` | `M$ID` | 2 | Sync bytes `$87CD`, marking the start of a module |
| `$02` | `M$Size` | 2 | Total module size in bytes, including the trailing CRC |
| `$04` | `M$Name` | 2 | Offset from the module start to the name string |
| `$06` | `M$Type` | 1 | Type in the high nibble (`$20` = `Sbrtn`), language in the low nibble |
| `$07` | `M$Revs` | 1 | Attributes in the high nibble, revision level in the low nibble |
| `$08` | `M$Parity` | 1 | Header check byte |
| `$09` | `M$Exec` | 2 | Offset from the module start to the execution entry point |
| `$0B` | `M$Mem` | 2 | Data memory the module needs when it runs |

The nine bytes up to `M$IDSize` (`$09`) are common to all module types;
`M$Exec` and `M$Mem` are the executable-module extension shared with program
modules.

The header check and CRC are integrity fields the assembler fills in, not values
you write by hand:

- `M$Parity` is chosen so that the exclusive-OR of header bytes `$00` through
  `$08` is `$FF`.
- The last three bytes of the module are a 24-bit CRC (polynomial `$800063`)
  over the whole module. The kernel verifies it at load time when CRC checking
  is enabled (`Feature1` bit `CRCOn`).

## The name string

`M$Name` points at the module's name, stored as an `fcs` string — plain ASCII
with the high bit set on the final character to mark the end. This is the name
`F$Link` matches against, so it is the public identity of your library. It is
conventional to place the name string immediately after the header.

## Type, language and attributes

- **Type/language** (`M$Type`): combine the type with the language in the low
  nibble. A subroutine module written in assembly is `Sbrtn+Objct` (`$21`);
  built for 6309 native code it is `Sbrtn+Obj6309` (`$27`). Other language
  values (`ICode`, `PCode`, `CCode`) exist for modules produced by the
  respective compilers.
- **Attributes** (`M$Revs`, high nibble):
  - `ReEnt` (`$80`) marks the module re-entrant and therefore shareable. Set
    this for any library that must serve more than one process at once; see the
    reentrancy rules below.
  - `ModNat` (`$20`) flags a 6309 native-mode module.

## Writing one

Bracket the source with the `mod` and `emod` directives. `mod` lays down the
header from its arguments; `emod` closes the module and lets the assembler
compute `M$Size`, `M$Parity` and the CRC.

```assembly
                    nam       MyLib
                    ttl       example subroutine module

                    ifp1
                    use       defsfile
                    endc

* mod  size,name,type/lang,attr/rev,exec,mem
                    mod       eom,name,Sbrtn+Objct,ReEnt+1,entry,0

name                fcs       /MYLIB/         ; module name, high bit ends it

* Public entry. Register conventions are yours to define and document,
* but by convention parameters arrive in the registers and the routine
* returns with the carry flag clear on success, set on error with an
* error code in B.
entry               pshs      x,y,u           ; save what you clobber
                    ...                       ; the library's work
                    puls      x,y,u           ; restore
                    clrb                      ; no error
                    rts                       ; return to the linking caller

eom                 equ       *               ; emod computes the CRC here
                    emod                      ; close the module
```

The `mod` arguments map straight onto the header fields: size to `M$Size`,
`name` to `M$Name`, `Sbrtn+Objct` to `M$Type`, `ReEnt+1` to `M$Revs` (re-entrant,
revision 1), `entry` to `M$Exec`, and `0` to `M$Mem`.

### Position independence

The module may be loaded at any address, so all internal references must be
relative. Use `bsr`/`lbsr` and PC-relative addressing to reach code and
constant data inside the module rather than absolute `jsr` or absolute operands.
This matches the wider project convention for module-internal calls.

### The data area

`M$Mem` declares how much scratch memory the routine needs when it runs. Keep
all writable state there rather than inside the module image itself: a
re-entrant module is a single shared copy of read-only code, so it must not
modify its own body. If your library needs no private storage, `M$Mem` is `0`.

## How it is found and used

`F$Link` is a memory-only operation. It searches the resident module directory
(`D.ModDir`) for an entry whose name matches and whose type matches the
requested type/language byte. It does **not** read from disk: if the module is
not already resident, `F$Link` returns `E$MNF`. A subroutine module becomes
resident one of three ways:

- it is merged into the bootfile and present from boot,
- it is read in explicitly with `F$Load` (or the `load` command), or
- it arrives through a chained module list.

The common "link, and if that fails load then link" idiom lives in the C library
and shell startup, not in the kernel.

On a successful link the kernel increments the module's link count
(`MD$Link`), and returns the module header address in `U`, the absolute
execution entry (`M$Exec` added to the module base) in `Y`, the type/language
byte in `A`, and the attributes/revision byte in `B`. The caller then calls the
library through `Y`. `F$Unlink` decrements the link count when the caller is
finished; the module becomes reclaimable once no process holds it.

### Reentrancy and the link count

If a module is **not** marked `ReEnt`, only one process may link to it at a
time. A second link attempt while the link count is non-zero returns
`E$ModBsy`. Mark a library `ReEnt` and keep it free of self-modifying state so
that it can be shared, which is the normal expectation for a library.

### Level 1 and Level 2

Under Level 1 the linked module is directly reachable in the flat 64K address
space, so linking is little more than the directory search and the link-count
bump. Under Level 2 the module lives in the system map, so `F$Link` also maps
the module's memory blocks into the calling process's address space and
maintains per-block use counts alongside the module link count. This is
transparent to the module itself — a correctly written, position-independent,
re-entrant subroutine module needs no changes to work at either level.

## Checklist

A well-formed subroutine module:

- opens with `mod` and closes with `emod`, so the size, header parity and CRC
  are correct;
- has type `Sbrtn` combined with the correct language nibble;
- is marked `ReEnt` unless it genuinely must be single-user, and holds no
  writable state in its own image;
- names itself with an `fcs` string that `M$Name` points at;
- reaches all internal code and data through relative addressing;
- declares its scratch requirement in `M$Mem` and keeps per-call state there;
- documents the register conventions of its entry point, and returns with the
  carry flag clear on success or set with an error code in `B`.
