********************************************************************
* fnmountimg - mount the disk image set in a FujiNet device slot
*
* Use fnsetdevfile to point the device slot at an image on a host,
* then this command to mount it.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/07/13  Andrew Diller
* Created.

DEVSLOTS            equ       8                   device slots (firmware MAX_DISK_DEVICES)

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       1
stack               equ       200
                    endsect

                    section   bss
deviceslot          rmb       1
mountmode           rmb       1
netpath             rmb       1
request             rmb       4
                    endsect

                    section   code

help                lbsr      PRINTS
                    fcc       /Usage: fnmountimg <device_slot> [<mode>]/
                    fcb       C$CR
                    fcc       /       mode: 1=read (default), 2=write/
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
                    ldb       #1                  default: read only
                    stb       mountmode,u
                    tst       ,y
                    beq       doit
                    tfr       y,x
                    lbsr      TO_NON_SP
                    tst       ,x
                    beq       doit
                    lbsr      DEC_BIN
                    stb       mountmode,u

doit                lbsr      NOpen
                    lbcs      errex
                    sta       netpath,u
                    lbsr      FBReady
                    lbcs      closeerr

                    leax      request,u
                    ldd       #OP_FUJI*256+FUJI$MountImage
                    std       ,x
                    lda       deviceslot,u
                    sta       2,x
                    lda       mountmode,u
                    sta       3,x
                    ldy       #4
                    lbsr      FBCmd

closeerr            pshs      b,cc
                    lda       netpath,u
                    os9       I$Close
                    puls      b,cc
errex               os9       F$Exit

                    endsect
