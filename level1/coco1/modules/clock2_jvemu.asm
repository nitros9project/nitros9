********************************************************************
* Clock2 - Jeff Vavasour CoCo 3 Emulator RTC Driver
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
*          2004/07/31  Rodney Hamilton
* Improved RTCJVEmu code, conditionalized RTC type comments.
*
*   1      2004/08/18  Boisy G. Pitre
* Separated clock2 modules for source clarity.

                    nam       Clock2
                    ttl       Jeff Vavasour CoCo 3 Emulator RTC Driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

RTC.Base            equ       $FFC0

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

GetTime             ldx       #RTC.Base
                    ldd       ,x                  get year (CCYY)
                    suba      #20
                    bmi       yr1                 19xx, OK as is
yr0                 addb      #100                20xx adjustment
                    deca                          also check for
                    bpl       yr0                 21xx (optional)
yr1                 stb       <D.Year             set year (~YY)
                    ldd       2,x                 get date
                    std       <D.Month            set date (MMDD)
                    ifne      Level-1
                    ldd       4,x                 get time (wwhh)
                    sta       <D.Daywk            set day of week
                    else
                    ldb       5,x                 get hour (hh)
                    endc
                    stb       <D.Hour             set hour (hh)
                    ldd       6,x                 get time (mmss)
                    std       <D.Min              set time (mmss)
                    rts

                    emod
eom                 equ       *
                    end

