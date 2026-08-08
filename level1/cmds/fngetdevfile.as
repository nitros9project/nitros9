********************************************************************
* fngetdevfile - show the file mounted in a FujiNet device slot
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/09/11  Boisy Gene Pitre
* Created.
*   2      2026/07/13  Andrew Diller
* Reworked around the FujiNet transaction protocol (lib/fuji.as).

DEVSLOTS            equ       8                   device slots (firmware MAX_DISK_DEVICES)

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       2
stack               equ       200
                    endsect

                    section   bss
deviceslot          rmb       1
netpath             rmb       1
request             rmb       3
response            rmb       256+1
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fngetdevfile <device_slot>/
                    fcb       C$CR,0
                    clrb
                    os9       F$Exit

__start             subd      #$0001
                    beq       help
                    clr       d,x

                    lbsr      DEC_BIN
                    stb       deviceslot,u
                    cmpb      #DEVSLOTS
                    bcc       help

                    lbsr      NOpen
                    lbcs      errex
                    sta       netpath,u
                    lbsr      FBReady
                    lbcs      closeerr

                    leax      request,u
                    ldd       #OP_FUJI*256+FUJI$GetDevicePath
                    std       ,x
                    lda       deviceslot,u
                    sta       2,x
                    ldy       #3
                    lbsr      FBCmd
                    lbcs      closeerr

                    leax      response,u
                    ldy       #256
                    lbsr      FBRead
                    lbcs      closeerr

                    leax      response,u
                    clr       256,x               belt and braces terminator
                    lbsr      PUTS
                    lbsr      PRINTS
                    fcb       C$CR,$00

                    clrb
closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
errex               os9       F$Exit

                    endsect
