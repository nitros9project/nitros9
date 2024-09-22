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
*
*   2      2024/09/05  Boisy G. Pitre
* Fixed some assumptions in the code about which blocks were mapped into which
* MMU slots. Attempted to make the code a bit more general.

                    nam       Boot
                    ttl       NitrOS-9 Level 2 ROM Boot Module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       2

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
                    deca                          reduce the number of pages we're returning
                    std       1,s                 save size in D on stack

* Call F$SRtMem to return the last page of RAM.
                    leau      d,u
                    ldd       #1
                    os9       F$SRtMem
                    
RelAddy             equ       $4800

TBLOCK              equ       5
* TRICK! Map block TBLOCK into $4000 of the kernel address space temporarily, then 
* copy our special ROM copy code there and jump to it.
                    lda       $FFA2
                    pshs      a
                    lda       #TBLOCK
                    sta       $FFA2
                    ifne      H6309
                    ldw       #RelCodeL
                    else
                    ldd       #RelCodeL           code less than 256 bytes
                    endc
                    leax      RelCode,pcr
                    ldy       #RelAddy
                    ifne      H6309
                    tfm       x+,y+
                    else
Copy                lda       ,x+
                    sta       ,y+
                    decb
                    bne       Copy
                    endc

Jump                jsr       RelAddy             * jump to rel code
                    puls      a                   restore original block at $4000
                    sta       $FFA2

* Upon exit, we return to the kernel with:
*    X  = address of bootfile
*    D  = size of bootfile
*    CC = carry cleared
ExitOK              andcc     #^Carry             clear carry
Uhoh                puls      u,y,x,a,b,cc,pc


* this code executes at RelAddy
RelCode             equ       *
                    lda       #$4E                CC3 mode, MMU, 32K ROM
                    sta       $FF90
                    sta       $FFDE               ROM/RAM mode

* Map ROM Blocks in
                    ldd       $FFA6               get the two bytes at $FFA6-$FFA7
                    pshs      d                   save on the stack
                    ldd       $FFA4               get the two bytes at $FFA4-$FFA5
                    pshs      d                   save on the stack
                    ldd       #$3C3D              we're mapping the first 16K of ROM...
                    std       $FFA4               ... into $8000-$BFFF
                    lda       #$3E                and the next 8K of ROM...
                    sta       $FFA6               ... into $C000-$DFFF

* Map block 1 at $6000
                    lda       $FFA3
                    pshs      a
                    lda       1,s
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
                    lda       2,s
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
                    lda       3,s
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
                    lda       4,s
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
                    puls      d
                    std       $FFA4
                    puls      d
                    std       $FFA6
                    rts

RelCodeL            equ       *-RelCode

* Fillers to get to $1D0
Pad                 fill      $39,$1D0-3-*

                    emod
eom                 equ       *

                    end
