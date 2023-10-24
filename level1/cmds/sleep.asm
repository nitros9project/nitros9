********************************************************************
* Sleep - Sleep for some ticks
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.

                    nam       Sleep
                    ttl       Sleep for some ticks

* Disassembled 98/09/14 23:48:34 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

                    org       0
u0000               rmb       450
size                equ       .

name                fcs       /Sleep/
                    fcb       edition

start               clra
                    clrb
                    bsr       L0028
                    bsr       L0028
                    bsr       L0028
                    bsr       L0028
                    bsr       L0028
                    tfr       d,x
                    os9       F$Sleep
                    clrb
                    os9       F$Exit
L0028               pshs      b,a
                    ldb       ,x
                    subb      #$30
                    bcs       L0048
                    cmpb      #$09
                    bhi       L0048
                    leax      $01,x
                    pshs      b
                    ldb       #$0A
                    mul
                    stb       $01,s
                    lda       $02,s
                    ldb       #$0A
                    mul
                    addb      ,s+
                    adca      ,s
                    std       ,s
L0048               puls      pc,b,a

                    emod
eom                 equ       *
                    end

