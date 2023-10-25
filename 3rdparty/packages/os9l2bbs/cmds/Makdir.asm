                    nam       Makdir
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $01

                    mod       eom,name,tylg,atrv,start,size

U0000               rmb       400
size                equ       .

name                fcs       /Makdir/            * 000D 4D 61 6B 64 69 F2 Makdir
start               ldb       #63                 * 0013 C6 3F          F?
                    os9       I$MakDir            * 0015 10 3F 85       .?.
                    bcs       L001B               * 0018 25 01          %.
                    clrb                          * 001A 5F             _
L001B               os9       F$Exit              * 001B 10 3F 06       .?.

                    emod
eom                 equ       *
                    end
