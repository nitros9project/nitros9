* Original integration-test program, served only by the RFM host fixture.
                    ifp1
                    use       defsfile
                    endc
tylg                set       Prgrm+Objct
atrv                set       ReEnt
                    mod       eom,name,tylg,atrv,start,$0100
                    ifne      Child
name                fcs       /rfmchild/
                    else
name                fcs       /rfmexec/
                    endc
                    fcb       1
start               leax      message,pcr
                    ldy       #endmsg-message
                    lda       #1
                    os9       I$WritLn
                    bcs       done
                    clrb
done                os9       F$Exit
message             equ       *
                    ifne      Child
                    fcc       /RFMCHILDOK/
                    else
                    fcc       /RFMEXECOK/
                    endc
                    fcb       13
endmsg              equ       *
                    emod
eom                 equ       *
