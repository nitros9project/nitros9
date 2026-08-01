********************************************************************
* fnlistdevs - list the FujiNet device (disk) slots
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/05/10  OpenAI
* Created.
*   2      2026/07/13  Andrew Diller
* Reworked around the FujiNet transaction protocol (lib/fuji.as).

DEVSLOTS            equ       8                   device slots (firmware MAX_DISK_DEVICES)
DEVSLOTSZ           equ       38                  hostSlot,mode,filename[36]
DEVFILESZ           equ       36                  filename field size
DEVARRSZ            equ       DEVSLOTS*DEVSLOTSZ

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       2
stack               equ       200
                    endsect

                    section   bss
netpath             rmb       1
slotnum             rmb       1
request             rmb       2
devices             rmb       DEVARRSZ
filebuf             rmb       DEVFILESZ+1
                    endsect

                    section   code

__start             lbsr      NOpen
                    lbcs      errex
                    sta       netpath,u
                    lbsr      FBReady
                    lbcs      closeerr

                    leax      request,u
                    ldd       #OP_FUJI*256+FUJI$ReadDevSlots
                    std       ,x
                    ldy       #2
                    lbsr      FBCmd
                    lbcs      closeerr

                    leax      devices,u
                    ldy       #DEVARRSZ
                    lbsr      FBRead
                    lbcs      closeerr

                    clr       slotnum,u
nextslot            ldb       slotnum,u
                    cmpb      #DEVSLOTS
                    bcc       closeok

                    clra
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcc       /: hs=/
                    fcb       $00

                    leax      devices,u
                    lda       slotnum,u
                    ldb       #DEVSLOTSZ
                    mul
                    leax      d,x
                    clra
                    ldb       ,x                  host slot
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcc       / mode=/
                    fcb       $00
                    clra
                    ldb       1,x                 access mode
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcc       / file=/
                    fcb       $00

* copy the filename out so it is always terminated
                    leay      filebuf,u
                    leax      2,x
                    ldb       #DEVFILESZ
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
