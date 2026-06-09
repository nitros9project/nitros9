********************************************************************
* fnmount - FujiNet utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/05/10  OpenAI
* Created.

OP_FUJI             equ       $E2
FN_MOUNT_HOST       equ       $F9
HOST_SLOT_COUNT     equ       8

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       1
stack               equ       200
                    endsect

                    section   bss
hostslot            rmb       1
netpath             rmb       1
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fnmount <host_slot>/
                    fcb       C$CR,0
                    lbra      exit

__start             subd      #$0001
                    beq       help
                    clr       d,x
                    lbsr      DEC_BIN
                    stb       hostslot,u
                    cmpb      #HOST_SLOT_COUNT
                    bcc       help

                    lbsr      NOpen
                    lbcs      errex
                    sta       netpath,u

                    leas      -3,s
                    tfr       s,x
                    ldd       #OP_FUJI*256+FN_MOUNT_HOST
                    std       ,x
                    lda       hostslot,u
                    sta       2,x
                    ldy       #3
                    lda       netpath,u
                    ldb       #SS.BlkWr
                    os9       I$SetStt
                    leas      3,s

exit                clrb
closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
errex               os9       F$Exit

                    endsect
