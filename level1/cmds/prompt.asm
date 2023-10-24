********************************************************************
* Prompt - Echo text and wait for a key
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2003/06/28  Boisy G. Pitre
* Created.

                    nam       Prompt
                    ttl       Echo text and wait for a key

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
inputbuf            rmb       16
devopts             rmb       32
                    rmb       450
size                equ       .

name                fcs       /Prompt/
                    fcb       edition

cr                  fcb       C$CR

start               subd      #$0001              subtract CR from param length
                    beq       readkey             if zero, don't print anything
                    clra                          clear upper 8 bits
                    tfr       d,y                 transfer length to Y
                    lda       #$01                stdout
                    os9       I$Write
                    bcs       exit
readkey             ldd       #$02*256            stderr
*         ldb   #SS.Opt		get options
                    leax      devopts,u
                    os9       I$GetStt            get 'em
                    bcs       exit
                    clr       (PD.EKO-PD.OPT),x
                    os9       I$SetStt            set 'em
                    leax      inputbuf,u
                    ldy       #$0001              one character
                    os9       I$Read              read one char from stderr
                    clrb
                    leax      devopts,u
                    inc       (PD.EKO-PD.OPT),x   turn on echo
                    os9       I$SetStt            set 'em
                    leax      cr,pcr
                    lda       #$01                to stdout
                    os9       I$WritLn            write it out
exit                os9       F$Exit

                    emod
eom                 equ       *
                    end

