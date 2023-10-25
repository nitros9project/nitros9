********************************************************************
* Clock2 - Harris RTC Driver
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2004/08/18  Boisy G. Pitre
* Separated clock2 modules for source clarity.

                    nam       Clock2
                    ttl       Harris RTC Driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

RTC.Base            equ       $FF60               Base address for clock

                    mod       eom,name,tylg,atrv,JmpTable,RTC.Base

name                fcs       "Clock2"
                    fcb       edition

                    ifne      MPIFlag
SlotSlct            fcb       MPI.Slot-1          Slot constant for MPI select code
                    endc

JmpTable
                    rts
                    nop
                    nop
                    bra       GetTime
                    nop
                    lbra      SetTime


GetTime             pshs      cc
                    orcc      #IntMasks           Disable interrupts

                    ldu       M$Mem,pcr           Get base address
                    ldy       #D.Time             Pointer to time in system map

                    lda       #%00001100          Init command register (Normal,Int. Disabled,
                    sta       $11,u               Run,24-hour mode, 32kHz)

                    lda       ,u                  Read base address to set-up clock regs for read
                    lda       6,u                 Get year
                    sta       ,y+
                    lda       4,u                 Get month
                    sta       ,y+
                    lda       5,u                 Get day
                    sta       ,y+
                    lda       1,u                 Get hour
                    sta       ,y+
                    lda       2,u                 Get minute
                    sta       ,y+
                    lda       3,u                 Get second
                    sta       ,y+

                    puls      cc,pc               Re-enable interrupts


SetTime             pshs      cc
                    orcc      #IntMasks           Disable interrupts

                    ldu       M$Mem,pcr           Get base address
                    ldy       #D.Time             Pointer to time in system map

                    lda       #%00000100          Init command register (Normal,Int. Disabled,
                    sta       $11,u               STOP clock,24-hour mode, 32kHz)

                    lda       ,y+                 Get year
                    sta       6,u
                    lda       ,y+                 Get month
                    sta       4,u
                    lda       ,y+                 Get day
                    sta       5,u
                    lda       ,y+                 Get hour
                    sta       1,u
                    lda       ,y+                 Get minute
                    sta       2,u
                    lda       ,y                  Get second
                    sta       3,u

                    lda       #%00001100          Init command register (Normal,Int. Disabled,
                    sta       $11,u               START clock,24-hour mode, 32kHz)

                    puls      cc,pc               Re-enable interrupts


                    emod
eom                 equ       *
                    end

