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
                    ttl       NitrOS-9 Level 1 ROM Boot Module

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


* obtain bootfile size at known offset
start               pshs      u,y,x,a,b
                    leax      eom,pcr             point to end of module
                    ldd       ,x                  get size of bootfile
                    std       ,s                  place bootfile size in A/B on stack
* allocate memory from system
                    os9       F$SRqMem
                    bcs       Uhoh
* copy bootfile from low RAM to allocated area
                    stu       2,s                 place address in X loc. on stack
                    ldx       #$2600+$1200        X points to bootfile in ROM
                    ifne      H6309
                    ldw       ,s                  get bootfile size from A/B on stack
                    tfm       x+,u+
                    else
                    ldd       ,s                  get bootfile size from A/B on stack
Loop                ldy       ,x++
                    sty       ,u++
                    subd      #2
                    bgt       Loop
                    endc

* Upon exit, we return to the kernel with:
*    X = address of bootfile
*    D = size of bootfile
Uhoh                puls      u,y,x,a,b,pc

                    emod
eom                 equ       *

* Size of bootfile (maximum is put here)
                    fdb       $2E00

