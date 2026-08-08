********************************************************************
* fnlisthosts - list the FujiNet host slots
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/05/10  OpenAI
* Created.
*   2      2026/07/13  Andrew Diller
* Reworked around the FujiNet transaction protocol (lib/fuji.as).

HOSTSLOTS           equ       8                   host slots (firmware MAX_HOSTS)
HOSTSLOTSZ          equ       32                  bytes per host slot
HOSTARRSZ           equ       HOSTSLOTS*HOSTSLOTSZ

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
hostslots           rmb       HOSTARRSZ
                    endsect

                    section   code

__start             lbsr      NOpen
                    lbcs      errex
                    sta       netpath,u
                    lbsr      FBReady
                    lbcs      closeerr

                    leax      request,u
                    ldd       #OP_FUJI*256+FUJI$ReadHostSlots
                    std       ,x
                    ldy       #2
                    lbsr      FBCmd
                    lbcs      closeerr

                    leax      hostslots,u
                    ldy       #HOSTARRSZ
                    lbsr      FBRead
                    lbcs      closeerr

                    clr       slotnum,u
nextslot            ldb       slotnum,u
                    cmpb      #HOSTSLOTS
                    bcc       closeok

                    clra
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcc       /: /
                    fcb       $00

                    leax      hostslots,u
                    lda       slotnum,u
                    ldb       #HOSTSLOTSZ
                    mul
                    leax      d,x
                    tst       ,x
                    bne       showname
                    lbsr      PRINTS
                    fcc       /<empty>/
                    fcb       $00
                    bra       endline
showname            lbsr      PUTS
endline             lbsr      PRINTS
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
