********************************************************************
* fnmount - mount a FujiNet host slot
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/05/10  OpenAI
* Created.
*   2      2026/07/13  Andrew Diller
* Reworked around the FujiNet transaction protocol (lib/fuji.as).

HOSTSLOTS           equ       8                   host slots (firmware MAX_HOSTS)

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
request             rmb       3
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fnmount <host_slot>/
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
                    ldd       #OP_FUJI*256+FUJI$MountHost
                    std       ,x
                    lda       hostslot,u
                    sta       2,x
                    ldy       #3
                    lbsr      FBCmd

closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
errex               os9       F$Exit

                    endsect
