********************************************************************
* fnlistdevs - FujiNet utility
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/05/10  OpenAI
* Created.

OP_FUJI               equ     $E2
FN_READ_DEVICE_SLOTS  equ     $F2
DEVICE_SLOT_COUNT     equ     8
DEVICE_SLOT_SIZE      equ     38
DEVICE_FILE_SIZE      equ     36

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
slotnum             rmb       1
devices             rmb       DEVICE_SLOT_COUNT*DEVICE_SLOT_SIZE
filebuf             rmb       DEVICE_FILE_SIZE+1
                    endsect

                    section   code

__start             lbsr      NOpen
                    lbcs      errex
                    sta       netpath,u

                    leas      -2,s
                    tfr       s,x
                    ldd       #OP_FUJI*256+FN_READ_DEVICE_SLOTS
                    std       ,x
                    ldy       #2
                    lda       netpath,u
                    ldb       #SS.BlkWr
                    os9       I$SetStt
                    leas      2,s
                    lbcs      closeerr

                    lda       netpath,u
                    leax      devices,u
                    ldy       #DEVICE_SLOT_COUNT*DEVICE_SLOT_SIZE
                    os9       I$Read
                    lbcs      closeerr

                    clr       slotnum,u
nextslot            ldb       slotnum,u
                    cmpb      #DEVICE_SLOT_COUNT
                    bcc       closeok

                    leax      devices,u
                    ldb       slotnum,u
seekslot            beq       printslot
                    leax      DEVICE_SLOT_SIZE,x
                    decb
                    bra       seekslot

printslot           clra
                    ldb       slotnum,u
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcc       /: hs=/
                    fcb       $00
                    clra
                    ldb       ,x
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcc       / mode=/
                    fcb       $00
                    clra
                    ldb       1,x
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcc       / file=/
                    fcb       $00

                    leay      filebuf,u
                    leax      2,x
                    ldb       #DEVICE_FILE_SIZE
copyloop            lda       ,x+
                    sta       ,y+
                    decb
                    bne       copyloop
                    clr       ,y
                    leax      filebuf,u
                    lbsr      PUTS
                    lbsr      PRINTS
                    fcb       C$CR,$00

                    inc       slotnum,u
                    bra       nextslot

closeok             clrb
closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
errex               os9       F$Exit

                    endsect
