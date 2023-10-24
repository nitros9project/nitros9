                    nam       MakDir              Vr. 5
                    ttl       Automatically capitalizes directories

                    ifp1
                    use       defsfile
                    endc

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Fin

Name                fcs       /MakDir/
Vrsn                fcb       $05

                    org       0

Stuff               rmb       80
Stack               rmb       200
Fin                 equ       .

Start               pshs      x
Loop                lda       ,x+
                    cmpa      #'a
                    blo       DecIt
                    cmpa      #'z
                    bhi       DecIt
                    anda      #$df
                    sta       -1,x
DecIt               decb
                    bne       Loop
                    puls      x
MakDir              ldb       #$bf
Execute             os9       I$MakDir
                    bcs       Error
                    clrb
Error               os9       F$Exit

                    emod
Size                equ       *
                    end

