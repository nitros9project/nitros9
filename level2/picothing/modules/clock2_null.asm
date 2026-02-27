********************************************************************
* clock2_null - Null Clock2 Module for Pico-Thing
*
* Stub Clock2 module for use when there is no hardware RTC.
* GetTime and SetTime return immediately without modifying the
* system time. The system time must be set manually at boot via
* the STime utility.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2025       Initial version for Pico-Thing

                    nam       Clock2
                    ttl       Null Clock2 Module for Pico-Thing

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,JmpTable,0

name                fcs       "Clock2"
                    fcb       edition

*------------------------------------------------------------
*
* Jump table: offsets must match clock_picothing.asm calls
*   $00: jsr ,y    Init
*   $03: jsr $03,x GetTime
*   $06: jsr $06,x SetTime
*
JmpTable            lbra      Init      call at offset 0 (3 bytes)
                    bra       GetTime   call at offset 3 (2 bytes)
                    nop       padding   to reach offset 6
                    lbra      SetTime   call at offset 6

*------------------------------------------------------------
*
* GetTime - Read RTC (stub: no hardware RTC, return immediately)
*
GetTime             rts

*------------------------------------------------------------
*
* SetTime - Write RTC (stub: no hardware RTC, return immediately)
*
SetTime             rts

*------------------------------------------------------------
*
* Init - Initialize Clock2 module
*
Init                clrb
                    rts

                    emod
eom                 equ       *
                    end
