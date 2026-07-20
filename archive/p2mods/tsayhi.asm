                    ifp1
                    use       defsfile
                    endc

Type                set       Prgrm+Objct
Revs                set       ReEnt+1
edition             set       $01

                    mod       OS9End,OS9Name,Type,Revs,start,256

OS9Name             fcs       "TSayHi"
                    fcb       edition

F$SAYHI             equ       $25

* routine cold
start               equ       *
                    lda       ,x
                    cmpa      #$0D
                    bne       SayHi
                    ldx       #$0000
SayHi               os9       F$SAYHI
                    bcs       error
                    clrb
error               os9       F$Exit

                    emod

OS9End              equ       *
                    end
