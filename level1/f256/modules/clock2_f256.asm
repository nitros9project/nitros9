********************************************************************
* Clock2 - F256 Clock Driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2023/09/20  Boisy G. Pitre
* Created.

                    nam       Clock2
                    ttl       F256 Clock Driver

                    use       defsfile

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       len,name,Sbrtn+Objct,ReEnt+0,JmpTable,RTC.Base

name                fcs       "Clock2"
                    fcb       edition

JmpTable            rts                           Init
                    nop
                    nop
                    bra       GetTime             Read
                    nop
                    bra       SetTime             Write

GetTime             ldx       M$Mem,pcr           get RTC base address
                    lda       RTC_CTRL,x          get the RTC control byte
                    ora       #(RTC_UTI|RTC_24HR) turn on UTI bit to update external registers
                    sta       RTC_CTRL,x          and save it back
                    lda       RTC_SEC,x           get the RTC value
                    bsr       bcd2bin             convert from BCD to binary
                    stb       <D.Sec              save in globals
                    lda       RTC_MIN,x           get the RTC value
                    bsr       bcd2bin             convert from BCD to binary
                    stb       <D.Min              save in globals
                    lda       RTC_HRS,x           get the RTC value
                    bsr       bcd2bin             convert from BCD to binary
                    stb       <D.Hour             save in globals
                    lda       RTC_DAY,x           get the RTC value
                    bsr       bcd2bin             convert from BCD to binary
                    stb       <D.Day              save in globals
                    lda       RTC_MONTH,x         get the RTC value
                    bsr       bcd2bin             convert from BCD to binary
                    stb       <D.Month            save in globals
                    lda       RTC_YEAR,x          get the RTC value
                    bsr       bcd2bin             convert from BCD to binary
                    addb      #100                assume we're always in 20th century
                    stb       <D.Year             save in globals
                    lda       RTC_CTRL,x          get the RTC control byte
                    anda      #^(RTC_UTI|RTC_24HR) turn off UTI bit to update external registers
                    sta       RTC_CTRL,x          and save it back
                    rts                           return to the caller

SetTime             ldx       M$Mem,pcr           get RTC base address
                    lda       RTC_CTRL,x          get the RTC control byte
                    ora       #(RTC_UTI|RTC_24HR) turn on UTI bit to update external registers
                    sta       RTC_CTRL,x          and save it back
                    lda       <D.Sec              get the globals value
                    bsr       bin2bcd             convert from binary to BCD
                    stb       RTC_SEC,x           save in RTC
                    lda       <D.Min              get the globals value
                    bsr       bin2bcd             convert from binary to BCD
                    stb       RTC_MIN,x           save in RTC
                    lda       <D.Hour             get the globals value
                    bsr       bin2bcd             convert from binary to BCD
                    stb       RTC_HRS,x           save in RTC
                    lda       <D.Day              get the globals value
                    bsr       bin2bcd             convert from binary to BCD
                    stb       RTC_DAY,x           save in RTC
                    lda       <D.Month            get the globals value
                    bsr       bin2bcd             convert from binary to BCD
                    stb       RTC_MONTH,x         save in RTC
                    lda       <D.Year             get the globals value
                    suba      #100                assume we're always in 20th century
                    bsr       bin2bcd             convert from binary to BCD
                    stb       RTC_YEAR,x          save in RTC
                    lda       RTC_CTRL,x          get the RTC control byte
                    anda      #^(RTC_UTI|RTC_24HR) turn off UTI bit to update external registers
                    sta       RTC_CTRL,x          and save it back
                    rts                           return to the caller

* Convert BCD to binary
* Entry: A = BCD byte
* Exit:  B = binary byte
bcd2bin             clrb                          clear the binary accumulator
loop@               cmpa      #$10                compare A to BCD 10
                    bcs       out@                branch if A is less than
                    addd      #$F00A              else decrease BCD A by $10 and add binary 10 to B
                    bra       loop@               and test again
out@                pshs      a                   save the binary version of the tens value to the stack
                    addb      ,s+                 add the binary ones value to the tens value
                    rts                           return to the caller

* Convert binary to BCD
* Entry: A = binary byte
* Exit:  B = BCD byte
bin2bcd             clrb                          clear the BCD accumulator
loop@               cmpa      #10                 compare A to binary 10
                    bcs       bcd2@               branch if A is less than
                    addd      #$F610              else decrease binary A by 10 and add BCD $10 to B
                    bra       loop@               and test again
bcd2@               pshs      a                   save the BCD version of the tens value to the stack
                    addb      ,s+                 add in the remainder; BCD = binary when less than 10
                    rts                           return to the caller

                    emod
len                 equ       *
                    end

