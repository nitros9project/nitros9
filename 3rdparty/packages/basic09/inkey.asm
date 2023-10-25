********************************************************************
* Inkey - Key detect subroutine
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   1      1998/10/26  Boisy G. Pitre
* Put a proper edition number after the name.

                    nam       Inkey
                    ttl       Key detect subroutine

* Disassembled 98/09/11 11:55:29 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       0
size                equ       .

name                fcs       /Inkey/
                    fcb       edition

start               leax      $04,s
                    ldd       $02,s
                    cmpd      #$0001
                    beq       L0033
                    cmpd      #$0002
                    bne       L0057
                    ldd       [<$04,s]
                    ldx       $06,s
                    leax      -$01,x
                    beq       L0031
                    leax      -$01,x
                    bne       L0057
                    tfr       b,a
L0031               leax      $08,s
L0033               ldu       $02,x
                    ldx       ,x
                    ldb       #$FF
                    stb       ,x
                    cmpu      #$0002
                    bcs       L0043
                    stb       $01,x
L0043               ldb       #SS.Ready
                    os9       I$GetStt
                    bcs       L0052
                    ldy       #0001
                    os9       I$Read
                    rts
L0052               cmpb      #E$NotRdy
                    bne       L0059
                    rts
L0057               ldb       #E$ParmEr
L0059               coma
                    rts

                    emod
eom                 equ       *
                    end

