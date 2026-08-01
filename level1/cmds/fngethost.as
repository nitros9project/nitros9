********************************************************************
* fngethost - show one FujiNet host slot
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
hostslot            rmb       1
netpath             rmb       1
request             rmb       2
hostslots           rmb       HOSTARRSZ
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fngethost <host_slot>/
                    fcb       C$CR,0
                    clrb
                    os9       F$Exit

__start             subd      #$0001
                    beq       help
                    clr       d,x

                    lbsr      DEC_BIN
                    stb       hostslot,u
                    cmpb      #HOSTSLOTS
                    bcc       help

                    lbsr      NOpen
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

                    clra
                    ldb       hostslot,u
                    lbsr      PRINT_DEC
                    lbsr      PRINTS
                    fcc       /: /
                    fcb       $00

                    leax      hostslots,u
                    lda       hostslot,u
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

                    clrb
closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
errex               os9       F$Exit

                    endsect
