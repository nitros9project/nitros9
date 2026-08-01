********************************************************************
* fnsetdevfile - set the file mounted in a FujiNet device slot
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

FILEPATHSZ          equ       256

DEVSLOTS            equ       8                   device slots (firmware MAX_DISK_DEVICES)
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
deviceslot          rmb       1
hostslot            rmb       1
mountmode           rmb       1
netpath             rmb       1
* FUJI$SetDevicePath request: OP_FUJI, command, ds, hs, mode, path[256]
request             rmb       5+FILEPATHSZ
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fnsetdevfile <device_slot> <host_slot> <mode> <path>/
                    fcb       C$CR,0
                    clrb
                    os9       F$Exit

__start             subd      #$0001
                    lbeq      help
                    clr       d,x

                    lbsr      DEC_BIN
                    stb       deviceslot,u
                    cmpb      #DEVSLOTS
                    lbcc      help
                    tst       ,y
                    lbeq      help
                    tfr       y,x
                    lbsr      TO_NON_SP
                    lbsr      DEC_BIN
                    stb       hostslot,u
                    cmpb      #HOSTSLOTS
                    lbcc      help
                    tst       ,y
                    lbeq      help
                    tfr       y,x
                    lbsr      TO_NON_SP
                    lbsr      DEC_BIN
                    stb       mountmode,u
                    tst       ,y
                    lbeq      help
                    tfr       y,x
                    lbsr      TO_NON_SP
                    tst       ,x
                    lbeq      help
                    pshs      x                   path argument

                    lbsr      NOpen
                    lbcs      argerr
                    sta       netpath,u
                    lbsr      FBReady
                    lbcs      closearg

* build the request
                    leax      request,u
                    ldd       #OP_FUJI*256+FUJI$SetDevicePath
                    std       ,x
                    lda       deviceslot,u
                    sta       2,x
                    lda       hostslot,u
                    sta       3,x
                    lda       mountmode,u
                    sta       4,x
                    leax      5,x
                    ldy       #FILEPATHSZ
zeroloop            clr       ,x+                 NUL pad the whole path field
                    leay      -1,y
                    bne       zeroloop
                    leax      -FILEPATHSZ,x
                    puls      y                   path argument
                    ldb       #FILEPATHSZ-1
copyloop            lda       ,y+
                    beq       send
                    cmpa      #C$CR
                    beq       send
                    sta       ,x+
                    decb
                    bne       copyloop

send                leax      request,u
                    ldy       #5+FILEPATHSZ
                    lbsr      FBCmd

closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
                    os9       F$Exit

closearg            leas      2,s
                    bra       closeerr

argerr              leas      2,s
                    os9       F$Exit

                    endsect
