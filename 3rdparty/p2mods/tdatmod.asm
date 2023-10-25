                    ifp1
                    use       defsfile
                    endc

F$DatMod            equ       $25

Type                set       Prgrm+Objct
Revs                set       ReEnt+1
edition             set       $01

                    mod       OS9End,OS9Name,Type,Revs,start,256

OS9Name             fcs       "tdatmod"
                    fcb       edition

* routine cold
start               equ       *
                    lda       ,x
                    cmpa      #$0D
                    beq       bye
                    ldy       #256
                    ldd       #Data*256+ReEnt
                    os9       F$DatMod
                    bcs       error
bye                 clrb
error               os9       F$Exit

                    emod

OS9End              equ       *
                    end
