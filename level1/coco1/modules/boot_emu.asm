********************************************************************
* Boot - CoCo Emulator Virtual Hard Disk Boot
*
* $Id: boot_emu.asm v 1.0 2024/02/15$
*
* Boot module for loading os9boot from emulator vhd drive.
*
* Updated version of a booter orignally written by Robert Gault
* for booting Nitros9 from a RGBDOS hard drive image.  The use
* of boot_common allows for non-contigous OS9Boot.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2024/02/15  E J Jaquay
* Created.

* Defines for boot device can be overridden with `-D` flags.
 ifndef DEVADDR
DEVADDR             equ       $FF80
 endif

 ifndef DISKNUM
DISKNUM             equ       0
 endif

 ifndef LSN24BIT
LSN24BIT            equ       1
 endif

 ifndef FLOPPY
FLOPPY              equ       0
 endif

                    nam       Boot
                    ttl       CoCo Emulator Virtual Hard Disk Boot
tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       0

* Static storage used by boot_common
                    org       0
seglist             rmb       2                   pointer to segment list
blockloc            rmb       2                   pointer to memory requested
blockimg            rmb       2                   duplicate of the above
bootsize            rmb       2                   size in bytes
LSN0Ptr             rmb       2                   In memory LSN0 pointer
size                equ       .

                    ifp1
                    use       defsfile
                    endc

                    mod       eom,name,tylg,atrv,start,size
name                fcs       /Boot/

* boot_common calls HWInit, HWRead, and HWTerm.
                    use       boot_common.asm

* HWInit - Stop any floppy activity.
* Force floppy interrupt per R Gault
HWInit              ldb       #$d0                Force interrupt
                    stb       $FF48               put to floppy command address
                    clrb
delay@              decb                          Delay for NMI
                    bne       delay@              loop 256 times
                    lda       $FF48               clear controller
                    clr       $FF40               Motor off and clear drive select

* HWTerm - nothing to do
HWTerm              clrb
                    rts

* HWRead - Read a 256 byte sector from Virtual Hard Drive
*   Entry: Y = Device Address
*          B,X = LSN
*          blockloc,U = buffer address
*   Exit:  X = ptr to data (i.e. ptr in blockloc,u)
*          Carry Set = Error
HWRead              stb       0,Y                 put LSN high order byte
                    stx       1,Y                 put LSN low order word
                    ldx       blockloc,U          load buffer address
                    stx       4,Y                 put address
                    ldb       Drive,PCR           load drive
                    stb       6,Y                 put drive
                    clrb                          set read command
                    stb       3,Y                 put command
                    ldb       3,Y                 get device status
                    beq       noerr               zero no error
                    comb                          set carry flag
noerr               rts

* Filler to get boot size to be $1D0.
* Subtract space for 3 byte checksum, device Address, and Drive
Filler              fill      $39,$1D0-3-2-1-*

Address             fdb       DEVADDR
Drive               fcb       DISKNUM
                    emod

eom                 equ       *
                    end

