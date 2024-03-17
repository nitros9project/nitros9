********************************************************************
* Boot - CoCo Emulator Virtual Hard Disk Boot
*
* $Id: boot_emu.asm$
*
* Boot module for loading os9boot from emulator vhd drive
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2024/02/15  E J Jaquay
* Created.

* defines for boot_common
LSN24BIT            equ       1
FLOPPY              equ       0

                    nam       Boot
                    ttl       CoCo Emulator Virtual Hard Disk Boot

                    ifp1
                    PRAGMA    NOLIST
                    use       defsfile
                    PRAGMA    LIST
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       0

* This module is intended to replace a booter orignally written
* by Robert Gault for booting Nitros9 from a RGBDOS hard drive
* image. The use of boot common here allows for non-contigous
* OS9Boot.

                    mod       eom,name,tylg,atrv,start,size

* static storage used by boot_common

                    org       0
seglist             rmb       2                   pointer to segment list
blockloc            rmb       2                   pointer to memory requested
blockimg            rmb       2                   duplicate of the above
bootsize            rmb       2                   size in bytes
LSN0Ptr             rmb       2                   In memory LSN0 pointer
size                equ       .

name                fcs       /Boot/
                    fcb       1

* boot_common calls HWInit, HWRead, and HWTerm provided here.

                    use       boot_common.asm

* HWInit - Force floppy interrupt (from R Gault)
* Tell controller to assert an NRI to stop floppy activity.
HWInit              ldb       #13                 Forced interrupt command
                    stb       $FF48               put to floppy command address
                    clrb
delay@              decb                          Delay for NMI
                    bne       delay@              loop 256 times

* HWTerm - nothing to do
HWTerm              clrb
                    rts

* HWRead - Read a 256 byte sector from Virtual Hard Drive
*   Entry: Y = Device Address defined below
*          B,X = LSN
*          blockloc,U = buffer address
*   Exit:  X = ptr to data (i.e. ptr in blockloc,u)
*          Carry Set = Error

HWRead              stb       0,Y                 put LSN high order byte
                    stx       1,Y                 put LSN low order word
                    ldx       blockloc,U          load buffer address
                    stx       4,Y                 put address
                    ldb       Drive               load drive
                    stb       6,Y                 put drive
                    clrb                          set read command
                    stb       3,Y                 put command
                    ldb       3,Y                 get error code
                    beq       noerr               zero no error
                    comb                          set carry flag
noerr               rts

* Filler to get boot size to be $1D0.
* Subtract space for 3 byte checksum, device Address, and Drive
Filler              fill      $39,$1D0-3-2-1-*

* Info at module's end establishes boot device.
Address             fdb       $FF80
                    IFEQ      DNum-1
Drive               fcb       1
                    ELSE
Drive               fcb       0
                    ENDC

                    emod
eom                 equ       *
                    end
