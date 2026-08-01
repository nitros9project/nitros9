********************************************************************
* fnsethost - set the hostname of a FujiNet host slot
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
* FUJI$WriteHostSlots request: OP_FUJI, command, then all eight slots
request             rmb       2+HOSTARRSZ
hostslots           equ       request+2
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fnsethost <host_slot> <host>/
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
                    tst       ,y
                    beq       help
                    tfr       y,x
                    lbsr      TO_NON_SP
                    tst       ,x
                    beq       help
                    pshs      x                   hostname argument

                    lbsr      NOpen
                    lbcs      argerr
                    sta       netpath,u
                    lbsr      FBReady
                    lbcs      closearg

* fetch the current slots so the others are written back unchanged
                    leax      request,u
                    ldd       #OP_FUJI*256+FUJI$ReadHostSlots
                    std       ,x
                    ldy       #2
                    lbsr      FBCmd
                    lbcs      closearg

                    leax      hostslots,u
                    ldy       #HOSTARRSZ
                    lbsr      FBRead
                    lbcs      closearg

* replace the requested slot
                    leax      hostslots,u
                    lda       hostslot,u
                    ldb       #HOSTSLOTSZ
                    mul
                    leax      d,x
                    ldb       #HOSTSLOTSZ
clearloop           clr       ,x+
                    decb
                    bne       clearloop
                    leax      -HOSTSLOTSZ,x
                    puls      y                   hostname argument
                    ldb       #HOSTSLOTSZ-1
copyloop            lda       ,y+
                    beq       writeback
                    cmpa      #C$CR
                    beq       writeback
                    sta       ,x+
                    decb
                    bne       copyloop

* send all eight slots back
writeback           leax      request,u
                    ldd       #OP_FUJI*256+FUJI$WriteHostSlots
                    std       ,x
                    ldy       #2+HOSTARRSZ
                    lbsr      FBCmd
                    bra       closeerr

closearg            leas      2,s                 drop the saved argument
closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
                    os9       F$Exit

argerr              leas      2,s
                    os9       F$Exit

                    endsect
