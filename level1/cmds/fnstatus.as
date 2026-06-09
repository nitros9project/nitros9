********************************************************************
* fnstatus - FujiNet utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/05/10  OpenAI
* Created.

OP_FUJI             equ       $E2
FN_STATUS           equ       $53
STATUS_SIZE         equ       4

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       1
stack               equ       200
                    endsect

                    section   bss
netpath             rmb       1
statusbuf           rmb       STATUS_SIZE
                    endsect

                    section   code

__start             lbsr      NOpen
                    lbcs      errex
                    sta       netpath,u

                    leas      -2,s
                    tfr       s,x
                    ldd       #OP_FUJI*256+FN_STATUS
                    std       ,x
                    ldy       #2
                    lda       netpath,u
                    ldb       #SS.BlkWr
                    os9       I$SetStt
                    leas      2,s
                    lbcs      closeerr

                    lda       netpath,u
                    leax      statusbuf,u
                    ldy       #STATUS_SIZE
                    os9       I$Read
                    lbcs      closeerr

                    lbsr      PRINTS
                    fcc       /error: $/
                    fcb       $00
                    clra
                    ldb       statusbuf,u
                    lbsr      PRINT_HEX
                    lbsr      PRINTS
                    fcc       /  cmd: $/
                    fcb       $00
                    clra
                    ldb       statusbuf+1,u
                    lbsr      PRINT_HEX
                    lbsr      PRINTS
                    fcc       /  connected: /
                    fcb       $00
                    clra
                    ldb       statusbuf+2,u
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcc       /  channel: /
                    fcb       $00
                    clra
                    ldb       statusbuf+3,u
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcb       C$CR,$00

                    clrb
closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
errex               os9       F$Exit

                    endsect
