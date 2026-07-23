********************************************************************
* fngethost - FujiNet utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/05/10  OpenAI
* Created.

OP_FUJI             equ       $E2
FN_READ_HOST_SLOTS  equ       $F4
HOST_SLOT_COUNT     equ       8
HOST_SLOT_SIZE      equ       32

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
hostslots           rmb       HOST_SLOT_COUNT*HOST_SLOT_SIZE
slotbuf             rmb       HOST_SLOT_SIZE+1
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fngethost <host_slot>/
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

                    leas      -2,s
                    tfr       s,x
                    ldd       #OP_FUJI*256+FN_READ_HOST_SLOTS
                    std       ,x
                    ldy       #2
                    lda       netpath,u
                    ldb       #SS.BlkWr
                    os9       I$SetStt
                    leas      2,s
                    lbcs      closeerr

                    lda       netpath,u
                    leax      hostslots,u
                    ldy       #HOST_SLOT_COUNT*HOST_SLOT_SIZE
                    os9       I$Read
                    lbcs      closeerr

                    leax      hostslots,u
                    ldb       hostslot,u
seekslot            beq       copieslot
                    leax      HOST_SLOT_SIZE,x
                    decb
                    bra       seekslot

copieslot           pshs      x
                    leax      slotbuf,u
                    ldy       ,s++
                    ldb       #HOST_SLOT_SIZE
copyloop            lda       ,y+
                    sta       ,x+
                    decb
                    bne       copyloop
                    clr       ,x

                    clra
                    ldb       hostslot,u
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcc       /: /
                    fcb       $00
                    leax      slotbuf,u
                    lbsr      PUTS
                    lbsr      PRINTS
                    fcb       C$CR,$00

exit                clrb
closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
errex               os9       F$Exit

                    endsect
