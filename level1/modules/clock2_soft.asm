********************************************************************
* Clock2 - Software Clock Driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2003/08/18  Boisy G. Pitre
* Separated clock2 modules for source clarity.

                    nam       Clock2
                    ttl       Software Clock Driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1


RTC.Base            equ       0                   Have to have one defined.

                    mod       len,name,Sbrtn+Objct,ReEnt+0,JmpTable,RTC.Base

name                fcs       "Clock2"
                    fcb       edition

JmpTable
                    rts                           Init
                    nop
                    nop
                    bra       GetTime             Read
                    nop
                    rts                           Write

GetTime             lda       <D.Min              grab current minute
                    inca                          minute+1
                    cmpa      #60                 End of hour?
                    blo       UpdMin              no, Set start of minute
                    ldd       <D.Day              get day, hour
                    incb                          hour+1
                    cmpb      #24                 End of Day?
                    blo       UpdHour             ..no
                    inca                          day+1
                    leax      <months-1,pcr       point to months table with offset-1: Jan = +1
                    ldb       <D.Month            this month
                    cmpa      b,x                 end of month?
                    bls       UpdDay              ..no, update the day
                    cmpb      #2                  yes, is it Feb?
                    bne       NoLeap              ..no, ok
                    ldb       <D.Year             else get year
                    andb      #$03                check for leap year: good until 2099
                    cmpd      #$1D00              29th on leap year?
                    beq       UpdDay              ..yes, skip it
NoLeap              ldd       <D.Year             else month+1
                    incb                          month+1
                    cmpb      #13                 end of year?
                    blo       UpdMonth            ..no
                    inca                          year+1
                    ldb       #$01                set month to jan
UpdMonth            std       <D.Year             save year, month
                    lda       #$01                day=1st
UpdDay              clrb                          hour=midnite
UpdHour             std       <D.Day              save day,hour
                    clra                          minute=00
UpdMin              clrb                          seconds=00
                    std       <D.Min              save min,secs
UpdTExit            rts

months              fcb       31,28,31,30,31,30,31,31,30,31,30,31 Days in each month

                    emod
len                 equ       *
                    end

