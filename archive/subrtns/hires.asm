********************************************************************
* HiRes - HiRes Joystick Subroutine Module
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
*   1    Created for Coyota project                     BGP 98/??/??

                    nam       HiRes
                    ttl       HiRes Joystick Subroutine Module

                    ifp1
                    use       defsfile
                    endc

edition             set       1

                    mod       eom,name,Sbrtn+Objct,Reent+0,HiRes,size

size                equ       .

name                fcs       /HiRes/
                    fcb       edition

* Hi-Res Read Routine
*
* Taken in part from "High Hopes for the Hi-Res"
* by William Barden, Jr., Rainbow Magazine, Feb 1990, pp. 42
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


HiRes               ldd       2,s                 get param count
                    cmpd      #4                  4 params?
                    bne       error
                    ldd       [4,s]               get joystick num.
* fix up joystick value
                    lslb                          shift left 3 times
                    lslb
                    lslb
                    pshs      b
                    lda       #$00                fetch X value
                    bsr       HiResHW
                    std       [9,s]               save in param addr
                    lda       #$08                fetch Y value
                    ldb       ,s+                 get joystick selector
                    bsr       HiResHW
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


* Hi-Res Hardware read routine
*
* This code is a hybrid of William Barden's Hi-Res
* interface code in the February 1990 Rainbow, and
* the code in CC3IO.  It prevents infinite looping
* that can happen in Barden's code.  It also caps the
* value at 639.
*
* Entry:
*   A  = value to place in $FF01 (00 for X, 08 for Y)
*   B  = value to place in $FF03 (00 for Right, 08 for Left)
*
* Exit:
*   D  = value

* Delays for CoCo 3 OS-9 Level Two vs. CoCo 2 OS-9 Level One
                    ifgt      Level-1
SETTLDLY            equ       94
POLLDLY             equ       809
HIVAL               equ       640
                    else
SETTLDLY            equ       94*2
POLLDLY             equ       404
HIVAL               equ       320
                    endc

HiResHW             pshs      a
                    lda       $FF01
                    anda      #$F7
                    ora       ,s+
                    sta       $FF01               select X or Y

                    pshs      b
                    lda       $FF03
                    anda      #$F7
                    ora       ,s+
                    sta       $FF03               select Right or Left

* turn off ramp
                    lda       $FF20
                    anda      #$03
                    ora       #$FC
                    sta       $FF20               turn off ramp

* delay for settling
                    ldb       #SETTLDLY           delay loop
Settle              decb
                    bne       Settle

                    ldd       #POLLDLY
                    pshs      a
                    lda       $FF20
                    anda      #$23
                    sta       $FF20               turn on ramp
RampCnt             lda       $FF00               get byte at $FF00
                    bmi       CompVal             branch if voltage hit
                    decb                          B initially $29
                    bne       RampCnt
                    dec       ,s                  ,S initially $03
                    bpl       RampCnt
                    puls      a
                    ldd       #HIVAL-1            just assume highest
                    rts
CompVal             puls      a
                    decb
                    pshs      b,a                 push hi-res count
                    ldd       #HIVAL
                    subd      ,s++                subtract count from 640
                    bcc       CompVal2
                    clra
                    clrb
                    rts
CompVal2            cmpd      #HIVAL-1
                    bcs       HiHWRts
                    ldd       #HIVAL-1
HiHWRts             rts

                    emod
eom                 equ       *
                    end
