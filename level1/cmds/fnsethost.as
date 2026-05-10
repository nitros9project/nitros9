********************************************************************
* fnsethost - FujiNet utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/05/10  OpenAI
* Created.

OP_FUJI              equ      $E2
FN_READ_HOST_SLOTS   equ      $F4
FN_WRITE_HOST_SLOTS  equ      $F3
HOST_SLOT_COUNT      equ      8
HOST_SLOT_SIZE       equ      32

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
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fnsethost <host_slot> <host>/
                    fcb       C$CR,0
                    lbra      exit

__start             subd      #$0001
                    beq       help
                    clr       d,x

                    lbsr      DEC_BIN
                    stb       hostslot,u
                    cmpb      #HOST_SLOT_COUNT
                    bcc       help
                    tst       ,y
                    beq       help
                    tfr       y,x
                    lbsr      TO_NON_SP
                    tst       ,x
                    beq       help
                    pshs      x

                    lbsr      NOpen
                    lbcs      startfail
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
seekslot            beq       clearslot
                    leax      HOST_SLOT_SIZE,x
                    decb
                    bra       seekslot

clearslot           ldy       #HOST_SLOT_SIZE
clearloop           clr       ,x+
                    leay      -1,y
                    bne       clearloop
                    leax      -HOST_SLOT_SIZE,x
                    puls      y
                    ldb       #HOST_SLOT_SIZE-1
copyloop            lda       ,y+
                    beq       writeback
                    cmpa      #C$CR
                    beq       writeback
                    sta       ,x+
                    decb
                    bne       copyloop

writeback           leas      -2,s
                    tfr       s,x
                    ldd       #OP_FUJI*256+FN_WRITE_HOST_SLOTS
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
                    ldb       #SS.BlkWr
                    os9       I$SetStt
                    bra       closeerr

exit                clrb
startfail           os9       F$Exit

closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
                    os9       F$Exit

                    endsect
