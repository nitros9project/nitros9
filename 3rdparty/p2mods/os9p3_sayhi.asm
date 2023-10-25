                    ifp1
                    use       defsfile
                    endc

Type                set       Systm+Objct
Revs                set       ReEnt+1
edition             set       $01

                    mod       OS9End,OS9Name,Type,Revs,Cold,256

OS9Name             fcs       "OS9p3"
                    fcb       $01

* routine cold
Cold                leay      SvcTbl,pcr
                    os9       F$SSvc
                    rts

F$SAYHI             equ       $25

SvcTbl              equ       *
                    fcb       F$SAYHI
                    fdb       SayHi-*-2
                    fcb       $80

SayHi               ldx       R$X,u
                    bne       SayHi6
                    ldy       D.Proc
                    ldu       P$SP,y
                    leau      -40,u
                    lda       D.SysTsk
                    ldb       P$TASK,y
                    ldy       #40
                    leax      Hello,pcr
                    os9       F$Move
                    leax      0,u
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
