********************************************************************
* Tee - Split output to multiple devices
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.

                    nam       Tee
                    ttl       Split output to multiple devices

* Disassembled 98/09/14 23:50:52 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

                    org       0
u0000               rmb       1
parray              rmb       13
pcount              rmb       1
buff                rmb       256
                    rmb       450
size                equ       .

name                fcs       /Tee/
                    fcb       edition

start               clrb
                    clr       pcount,u            clear path counter
                    cmpy      #$0000              any parameters?
                    lbeq      exitok              exit if none
                    leay      parray,u            else point Y to path array

* Walk the command line parameters
parse               lda       ,x+
                    cmpa      #C$SPAC
                    beq       parse
                    cmpa      #C$COMA
                    beq       parse
                    cmpa      #C$CR
                    lbeq      parsex
* We've found a file or device name
                    leax      -1,x
                    lda       #WRITE.
                    ldb       #PREAD.+UPDAT.
                    os9       I$Create            open a path to the device or file
                    bcs       exit                branch if error
                    ldb       pcount,u            else get path counter
                    sta       b,y                 save new path in the array offset
                    incb                          increment counter
                    stb       pcount,u            and save
                    bra       parse               continue parsing command line
parsex              stb       pcount,u

* Devices on command line are open, start pumping data
L0044               clra
                    leax      buff,u
                    ldy       #256
                    os9       I$ReadLn
                    bcc       L0057
                    cmpb      #E$EOF
                    beq       exitok
                    coma
                    bra       exit
L0057               inca
                    os9       I$WritLn
                    tst       pcount,u
                    beq       L0044
                    clrb
L0060               leay      parray,u
                    lda       b,y
                    leax      buff,u
                    ldy       #256
                    os9       I$WritLn
                    bcs       exit
                    incb
                    cmpb      pcount,u
                    bne       L0060
                    bra       L0044
exitok              clrb
exit                os9       F$Exit

                    emod
eom                 equ       *
                    end
