********************************************************************
* Clock2 - MESS Emulator RTC Driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2004/07/13  Robert Gault
* Added Vavasour/Collyer emulator & MESS (Disto) versions and relocated
* 'GetTime equ'   statement so it is not within a chip heading.
*
*   1      2004/08/18  Boisy G. Pitre
* Separated clock2 modules for source clarity.
*
*   2      2009/01/11  Robert Gault
* Corrected code for day of week. Was bitb #4 but should be bita #4.

                    nam       Clock2
                    ttl       MESS Emulator RTC Driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

RTC.Base            equ       $FF50


                    mod       eom,name,tylg,atrv,JmpTable,RTC.Base

name                fcs       "Clock2"
                    fcb       edition

JmpTable
                    rts
                    nop
                    nop
                    bra       GetTime
                    nop
                    rts


* MESS time update in Disto mode (ignores MPI)
*   Assumes that PC clock is in AM/PM mode!!!
GetTime             ldx       #RTC.Base
                    ldy       #D.Time
                    ldb       #12                 counter for data
                    stb       1,x
                    lda       ,x
                    anda      #7
                    ifne      Level-1
                    sta       <D.Daywk
                    endc
                    decb
                    bsr       getval
                    lda       -1,y
                    cmpa      #70                 if >xx70 then its 19xx
                    bhi       not20
                    adda      #100
                    sta       -1,y
not20               bsr       getval              month
                    bsr       getval              day
                    lda       #7                  AM/PM mask
                    stb       1,x
                    anda      ,x
                    bita      #4
                    pshs      cc
                    anda      #3
                    bsr       getval1
                    puls      cc
                    beq       AM
                    lda       #12                 convert to 24hr time as it is PM
                    adda      -1,y
                    sta       -1,y
AM                  bsr       getval              minute
* and now fall through into get second
getval              lda       #$0f
                    stb       1,x
                    anda      ,x
getval1             decb
                    pshs      b
                    ldb       #10
                    mul
                    stb       ,y
                    puls      b
                    stb       1,x
                    decb
                    lda       ,x
                    anda      #$0f
                    adda      ,y
                    sta       ,y+
                    rts

                    emod
eom                 equ       *
                    end

