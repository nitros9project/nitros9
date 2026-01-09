********************************************************************
* melody - play a melody using SS.Tone
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2023/01/08
* Created.

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       5

                    mod       eom,name,tylg,atrv,start,size

                    org       0
filepath            rmb       1
parmptr             rmb       2
readbuff            rmb       650
size                equ       .

name                fcs       /melody/
                    fcb       edition


start               ldd       #$01*256+SS.Tone
                    ldy       #$0000
                    ldx       #$0001
l@                  os9       I$SetStt
                    bcs       exit
                    leay      8,y
                    cmpy      #1024
                    blt       l@
                    pshs      d
                    tfr       x,d
                    inca
                    tfr       d,x
                    puls      d
                    ldy       #0000
                    bra       l@

                    clrb                  
exit                os9       F$Exit                                        

                    emod
eom                 equ       *
                    end
