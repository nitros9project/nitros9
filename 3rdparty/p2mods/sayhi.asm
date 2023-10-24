                    ifp1
                    use       defsfile
                    endc

Type                set       Prgrm+Objct
Revs                set       ReEnt+1
edition             set       $01

                    mod       OS9End,OS9Name,Type,Revs,Cold,256

OS9Name             fcs       "SayHi"
                    fcb       edition

* routine cold
Cold                equ       *
* The following three instructions are important.  They cause the link
* count of this module to increase by 1.  This insures that the module
* stays in memory, even if forked from disk.
                    leax      OS9Name,pcr
                    clra
                    os9       F$Link

                    leay      SvcTbl,pcr
                    os9       F$SSvc
                    bcs       Exit
                    clrb
Exit                os9       F$Exit

F$SAYHI             equ       $25

SvcTbl              equ       *
                    fcb       F$SAYHI
                    fdb       SayHi-*-2
                    fcb       $80

* Entry point to F$SAYHI system call
SayHi               ldx       R$X,u
                    bne       SayHi6
                    leax      Hello,pcr
SayHi6              ldy       #40
                    ldu       D.Proc
                    lda       P$PATH+2,u
                    os9       I$WritLn
                    rts

Hello               fcc       "Hello there user."
                    fcb       $0D

                    emod

OS9End              equ       *
                    end
