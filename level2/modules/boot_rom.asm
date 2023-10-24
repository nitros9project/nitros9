********************************************************************
* Boot - NitrOS-9 ROM Boot Module
*
* $Id: boot_rom.asm,v 1.1 2004/04/05 03:34:39 boisy Exp $
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      1998/??/??  Boisy G. Pitre
* Created.
*
*   1r1    2003/09/07  Boisy G. Pitre
* Added 6309 optimizations

                    nam       Boot
                    ttl       NitrOS-9 Level 2 ROM Boot Module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

size                equ       .

name                fcs       /Boot/
                    fcb       edition

start               equ       *
* obtain bootfile size at known offset
                    pshs      u,y,x,a,b,cc
                    orcc      #IntMasks           mask interrupts
* allocate memory from system
* memory will start at $8000, blocks 1, 2, 3 and 3F
* we allocate $100 bytes more so that the memory will start
* exactly at $8000
                    ldd       #$8000-$1300
                    os9       F$BtMem
                    bcs       Uhoh

                    stu       3,s                 save pointer in X on stack
                    std       1,s                 save size in D on stack

* TRICK!  Map block 4 into $4000, copy our special ROM copy code
*         there, then jmp to it!
                    lda       $FFA2
                    pshs      a
                    lda       #$04
                    sta       $FFA2
                    ifne      H6309
                    ldw       #RelCodeL
                    else
                    ldd       #RelCodeL           code less than 256 bytes
                    endc
                    leax      RelCode,pcr
                    ldy       #$4800
                    ifne      H6309
                    tfm       x+,y+
                    else
Copy                lda       ,x+
                    sta       ,y+
                    decb
                    bne       Copy
                    endc

Jump                jsr       $4800               * jump to rel code
                    puls      a                   restore original block at $4000
                    sta       $FFA2

* Upon exit, we return to the kernel with:
*    X  = address of bootfile
*    D  = size of bootfile
*    CC = carry cleared
ExitOK              andcc     #^Carry             clear carry
Uhoh                puls      u,y,x,a,b,cc,pc


* this code executes at $4800
RelCode             equ       *
                    lda       #$4E                CC3 mode, MMU, 32K ROM
                    sta       $FF90
                    sta       $FFDE               ROM/RAM mode

* Map ROM Blocks in
                    ldd       #$3C3D
                    std       $FFA4
                    lda       #$3E
                    sta       $FFA6

* Map block 1 at $6000
                    lda       $FFA3
                    pshs      a
                    lda       #$01
                    sta       $FFA3
* Copy first 8K of ROM
                    ldx       #$8000
                    ldy       #$6000
                    ifne      H6309
                    ldw       #$2000
                    tfm       x+,y+
                    else
Loop1               ldd       ,x++
                    std       ,y++
                    cmpx      #$A000
                    blt       Loop1
                    endc

* Map block 2 at $6000
                    lda       #$02
                    sta       $FFA3
* Copy second 8K of ROM
*         ldx   #$A000		X is already $A000
                    ldy       #$6000
                    ifne      H6309
                    ldw       #$2000
                    tfm       x+,y+
                    else
Loop2               ldd       ,x++
                    std       ,y++
                    cmpx      #$C000
                    blt       Loop2
                    endc

* Map block 3 at $6000
                    lda       #$03
                    sta       $FFA3
* Copy third 8K of ROM
*         ldx   #$C000		X is already $C000
                    ldy       #$6000
                    ifne      H6309
                    ldw       #$2000
                    tfm       x+,y+
                    else
Loop3               ldd       ,x++
                    std       ,y++
                    cmpx      #$E000
                    blt       Loop3
                    endc

* Copy remaining ROM area ($8000-$1300)
                    lda       #$3F
                    sta       $FFA3
*         ldx   #$E000		X is already $E000
                    ldy       #$6000
Loop4               clr       $FFDE               put in ROM/RAM mode to get byte
                    ldd       ,x++
                    clr       $FFDF               put back in RAM mode to store byte
                    std       ,y++
                    cmpx      #$EC00
                    blt       Loop4
*         ldx   #$6000
*         ldy   #$E000
*Loop5    ldd   ,x++
*         std   ,y++
*         cmpx  #$6C00
*         blt   Loop5

                    lda       D.HINIT             restore GIME HINIT value
                    sta       $FF90
                    puls      a                   restore org block at $6000
                    sta       $FFA3
                    lda       #$03
                    sta       $FFA6
                    ldd       #$0102
                    std       $FFA4
                    rts

RelCodeL            equ       *-RelCode

* Fillers to get to $1D0
Pad                 fill      $39,$1D0-3-*

                    emod
eom                 equ       *

                    end
