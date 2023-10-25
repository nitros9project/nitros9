********************************************************************
* JoyStk - Joystick Subroutine Module
*
* $Id$
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*   1    Created for Coyota project                     BGP 98/??/??

                    nam       JoyStk
                    ttl       Joystick Subroutine Module

                    ifp1
                    use       defsfile
                    endc

edition             set       1

                    mod       eom,name,Sbrtn+Objct,Reent+0,Joy,size

size                equ       .

name                fcs       /JoyStk/
                    fcb       edition

* Joystick Read Routine
*
* Entry:
*   X  = $0000 for Right, $0001 for Left
*
* Exit:
*   2,s = param count (should be 4)
*   4,s = addr of 1st param            (joystick number)
*   6,s = size of 1st param
*   8,s = addr of 2nd param            (joystick X)
*  10,s = size of 2nd param
*  12,s = addr of 3rd param            (joystick Y)
*  14,s = size of 3rd param
*  16,s = addr of 4th param            (joystick button)
*  18,s = size of 4th param

Joy                 ldd       2,s                 get param count
                    cmpd      #4                  4 params?
                    bne       error
                    ldd       [4,s]               get joystick num.
* fix up joystick value
                    lslb                          shift left 3 times
                    lslb
                    lslb
                    pshs      b
                    lda       #$00                fetch X value
                    bsr       JoyPoll
                    std       [9,s]               save in param addr
                    lda       #$08                fetch Y value
                    ldb       ,s+                 get joystick selector
                    bsr       JoyPoll
                    std       [12,s]
* get button value
                    clra
                    ldb       #$FF
                    stb       $FF02
                    ldb       $FF00
                    clr       $FF02
                    comb
                    tst       [5,s]
                    beq       BtnLft
                    andb      #$05
                    bra       BtnCnt
BtnLft              andb      #$0A
                    lsrb
BtnCnt              lsrb
                    bcc       BtnCnt2
                    orb       #$01
BtnCnt2             std       [16,s]              save button
                    clrb                          no error
                    rts
error               coma
                    ldb       #E$IllArg
                    rts


* Joystick read routine
*
* Entry:
*   A  = value to place in $FF01 (00 for X, 08 for Y)
*   B  = value to place in $FF03 (00 for Right, 08 for Left)
*
* Exit:
*   D  = value

JoyPoll             pshs      a
                    lda       $FF01
                    anda      #$F7
                    ora       ,s+
                    sta       $FF01               select X or Y

                    pshs      b
                    lda       $FF03
                    anda      #$F7
                    ora       ,s+
                    sta       $FF03               select Right or Left

* Low res binary tree search for joystick value
                    lda       #$7F                DAC value
                    ldb       #$40
                    bra       L0122

L0117               lsrb                          reset DAC offset value
                    cmpb      #$01
                    bhi       L0122
                    lsra
                    lsra
                    tfr       a,b
                    clra
                    rts
L0122               pshs      b
                    sta       $FF20
                    tst       $FF00
                    bpl       L012F
                    adda      ,s+
                    bra       L0117
L012F               suba      ,s+
                    bra       L0117

                    emod
eom                 equ       *
                    end
