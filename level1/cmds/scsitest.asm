s******************************* ***************************
* scsitest - Test a SCSI device through the SS.DCmd call
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2005/12/11  Boisy G. Pitre
* Created.

                    nam       scsitest
                    ttl       Test a SCSI device through the SS.DCmd call

                    ifp1
                    use       defsfile
                    use       scfdefs
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
code                rmb       1
lsn                 rmb       3
left                rmb       2
path                rmb       1
txbuff              rmb       2048                to accomodate CD-ROM sector sizes
                    rmb       200
size                equ       .

IntroM              fcc       /SCSI Direct Command Test/
                    fcb       C$CR
StartM              fcc       /Sending START UNIT... /
StartML             equ       *-StartM
Done                fcc       /Done!/
                    fcb       C$CR
StartUnit           fcb       $1B,$00,$00,$00,$01,$00
StopM               fcc       /Sending STOP UNIT.../
StopML              equ       *-StopM
StopUnit            fcb       $1B,$00,$00,$00,$00,$00
ReadM               fcc       /Testing READ... /
ReadML              equ       *-ReadM

name                fcs       /scsitest/
                    fcb       edition

start               leay      txbuff,u
                    lda       #$08
                    sta       <code
                    clr       <lsn
                    clr       <lsn+1
                    clr       <lsn+2
                    lda       #$01
                    sta       <left
                    clr       <left+1
l@                  lda       ,x+
                    cmpa      #C$CR
                    beq       ok@
                    cmpa      #C$SPAC
                    beq       ok@
                    sta       ,y+
                    bra       l@
ok@                 ldd       #'@*256+C$CR
                    std       ,y
                    leax      txbuff,u

                    lda       #READ.
                    os9       I$Open
                    lbcs      exit
                    sta       path,u

                    leax      IntroM,pcr
                    lda       #1
                    ldy       #100
                    os9       I$WritLn

                    bsr       DoStartUnit
                    bcs       exit

                    bsr       DoReadSector
                    bcs       exit

                    bsr       DoStopUnit
                    bcs       exit

                    bsr       DoStartUnit
                    bcs       exit

exitok              clrb
exit                os9       F$Exit

* Do START UNIT
DoStartUnit         leax      StartM,pcr
                    ldy       #StartML
                    lda       #1
                    os9       I$Write

                    leay      StartUnit,pcr
                    lda       path,u
                    ldb       #SS.DCmd
                    os9       I$SetStt
                    bcs       exit@
                    leax      Done,pcr
                    ldy       #100
                    lda       #1
                    os9       I$WritLn
exit@               rts

* Do READ of sector
DoReadSector        leax      ReadM,pcr
                    lda       #1
                    ldy       #READML
                    os9       I$Write

                    ldd       <lsn+1
                    addd      #1
                    std       <lsn+1
                    bcc       w
                    inc       <lsn
w                   lda       <lsn

                    leay      code,u
                    leax      txbuff,u
                    lda       <path
                    ldb       #SS.DCmd
                    os9       I$SetStt
                    bcs       exit@
                    leax      Done,pcr
                    ldy       #100
                    lda       #1
                    os9       I$WritLn
exit@               rts

* Do STOP UNIT
DoStopUnit          leax      StopM,pcr
                    ldy       #StopML
                    lda       #1
                    os9       I$Write

                    leay      StopUnit,pcr
                    lda       path,u
                    ldb       #SS.DCmd
                    os9       I$SetStt
                    bcs       exit@
                    leax      Done,pcr
                    ldy       #100
                    lda       #1
                    os9       I$WritLn
exit@               rts

                    emod
eom                 equ       *
                    end
