********************************************************************
* Clock2 - DS12885 RTC driver (Pico-Thing)
*
* The Pico-Thing v2 board carries a battery-backed DS12885 real-time
* clock strapped in Motorola mode, decoded by the GAL at RTC.Idx
* (register-select) and RTC.Dat (data).  The chip is MC146818 register
* compatible.  The Pico normally owns it and keeps it running, so OS-9
* must NOT write it at boot: Init does nothing (no mode force, no seed),
* which previously clobbered the good time the Pico had set.  GetTime
* reads the chip every minute; SetTime writes it only on a deliberate
* F$STime (the setime command).  The chip is held in binary, 24-hour
* mode, so its registers map straight onto the D.Time packet.  A set
* also starts the oscillator, so setime brings a stopped chip back to
* life.
*
* Each register access is a two-step, non-atomic pair (select then
* read/write), so interrupts are masked around GetTime and SetTime.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/09/16
* Created for the Pico-Thing DS12885.
*   2      2026/10/25
* SetTime starts the oscillator, so a set revives a stopped chip.

                    nam       Clock2
                    ttl       DS12885 RTC driver

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

* DS12885 register numbers (MC146818 compatible)
R.Sec               equ       0         seconds
R.Min               equ       2         minutes
R.Hour              equ       4         hours
R.Date              equ       7         day of month
R.Month             equ       8         month
R.Year              equ       9         year 0-99
R.RegA              equ       10        status/control A
R.RegB              equ       11        control B

* register bit definitions
b.UIP               equ       %10000000 reg A: update in progress
DV.Run              equ       %00100000 reg A: oscillator on, divider counting
b.SET               equ       %10000000 reg B: halt updates for read or write
b.DM                equ       %00000100 reg B: data mode, 1 = binary
b.24                equ       %00000010 reg B: 1 = 24-hour

* mode we hold reg B in while writing: binary, 24-hour, updates enabled
RunMode             equ       b.DM!b.24

                    mod       eom,name,tylg,atrv,JmpTable,0

name                fcs       "Clock2"
                    fcb       edition

* clock2 entry table: init at offset 0, GetTime at 3, SetTime at 6
JmpTable            bra       Init      ; offset 0
                    nop
                    bra       GetTime   ; offset 3
                    nop
                    lbra      SetTime   ; offset 6

* RTCRd - read the DS12885 register whose number is in A, return it in A
* enter with interrupts already masked
RTCRd               sta       >RTC.Idx  ; select the register
                    lda       >RTC.Dat  ; read its value
                    rts

* RTCWr - write B to the DS12885 register whose number is in A
* enter with interrupts already masked
RTCWr               sta       >RTC.Idx  ; select the register
                    stb       >RTC.Dat  ; write the value
                    rts

* Init - called from the clock module at start-up.  The Pico owns the
* chip and keeps it running, so there is nothing to do and, above all,
* nothing to write: forcing the mode register or seeding a default here
* would overwrite the good time the Pico had set.
Init                clrb                ; success; never write the chip
                    rts

* GetTime - read the clock into the system D.Time packet
GetTime             pshs      cc,d,x,y
                    orcc      #IntMasks ; disable interrupts around the reads
                    ldx       #$1000    ; bounded wait so a dead chip cannot hang us
GTWait              lda       #R.RegA   ; wait out any update in progress
                    lbsr      RTCRd
                    bita      #b.UIP
                    beq       GTGo      ; not in progress, safe to read
                    leax      -1,x
                    bne       GTWait
GTGo                ldy       #D.Time   ; system time packet
                    lda       #R.Year
                    lbsr      RTCRd     ; rtc year is two digits (0-99)
                    cmpa      #70       ; century window: 00-69 are 20xx
                    bhs       gtyr@     ; 70-99 stay in the 1900s
                    adda      #100      ; fold to D.Time's 1900-based year
gtyr@               sta       ,y+       ; year
                    lda       #R.Month
                    lbsr      RTCRd
                    sta       ,y+       ; month
                    lda       #R.Date
                    lbsr      RTCRd
                    sta       ,y+       ; day
                    lda       #R.Hour
                    lbsr      RTCRd
                    sta       ,y+       ; hour
                    lda       #R.Min
                    lbsr      RTCRd
                    sta       ,y+       ; minute
                    lda       #R.Sec
                    lbsr      RTCRd
                    sta       ,y+       ; second
                    puls      cc,d,x,y,pc

* SetTime - write the system D.Time packet into the clock.
*
* OS-9's boot start-up sets a placeholder time to kick the software
* clock (SysGo, and dwio's clock-start on a DriveWire boot): both use
* December 31, 23:59:59, expecting the RTC read at the following 00
* seconds to supply the real time.  Never persist that placeholder to
* the Pico's chip - it would clobber the good time the Pico set - so a
* set whose date is exactly Dec-31 23:59:59 is ignored; any other (a
* deliberate setime) is written.
SetTime             pshs      cc,d,y
                    ldy       #D.Time
                    lda       $01,y     ; month
                    cmpa      #12
                    bne       SetGo     ; not the placeholder - write it
                    lda       $02,y     ; day
                    cmpa      #31
                    bne       SetGo
                    lda       $03,y     ; hour
                    cmpa      #23
                    bne       SetGo
                    lda       $04,y     ; minute
                    cmpa      #59
                    bne       SetGo
                    lda       $05,y     ; second
                    cmpa      #59
                    beq       SetDone   ; the boot placeholder - do not write
SetGo               orcc      #IntMasks ; disable interrupts around the writes
                    lbsr      WriteClk  ; y still points at D.Time
SetDone             puls      cc,d,y,pc

* WriteClk - write six binary time bytes (year, month, day, hour, min,
* second) from Y into the clock, freezing updates around the write
* enter with interrupts already masked
WriteClk            ldb       #RunMode!b.SET ; halt updates while we write
                    lda       #R.RegB
                    lbsr      RTCWr
                    ldb       ,y+       ; year (D.Time, 1900-based)
                    cmpb      #100      ; 20xx?
                    blo       wtyr@     ; no, it is a 19xx year
                    subb      #100      ; fold back to the RTC two-digit year
wtyr@               lda       #R.Year
                    lbsr      RTCWr
                    ldb       ,y+       ; month
                    lda       #R.Month
                    lbsr      RTCWr
                    ldb       ,y+       ; day
                    lda       #R.Date
                    lbsr      RTCWr
                    ldb       ,y+       ; hour
                    lda       #R.Hour
                    lbsr      RTCWr
                    ldb       ,y+       ; minute
                    lda       #R.Min
                    lbsr      RTCWr
                    ldb       ,y+       ; second
                    lda       #R.Sec
                    lbsr      RTCWr
                    ldb       #DV.Run   ; start the oscillator in case it is stopped
                    lda       #R.RegA
                    lbsr      RTCWr
                    ldb       #RunMode  ; release the freeze, updates resume
                    lda       #R.RegB
                    lbsr      RTCWr
                    rts

                    emod
eom                 equ       *
                    end
