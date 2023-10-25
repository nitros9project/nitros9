********************************************************************
* Clock2 - Coco3FPGA Analog Board RTC Driver
* for the Maxim Integrated DS3231 RTC
* Coco3FPGA ONLY!
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2004/08/18  Boisy G. Pitre
* Separated clock2 modules for source clarity.
*
*   2      2017/01/21  Robert Gault
* Modified clock2_elim.asm to work with the DS3231 on the Coco3FPGA
*
*   3      2017/01/23  Gary Becker
* Corrected the timing of the Read/Write activation routines
*
*   4      2017/01/23  Robert Gault
* Corrected a bug in the Setime routine and added a "stpreg" routine
*
*   5      2017/01/24  Bill Pierce
* Removed erronius "stpreg" routine, cleaned up code, re-assembled, IT WORKS!

                    nam       Clock2
                    ttl       Coco3FPGA Analog Board RTC Driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       4

* All bits not specified must be set to 0!
RTC.sec             equ       $00                 0-59
RTC.min             equ       $01                 0-59
RTC.hr              equ       $02                 bit 6 12/24, bit5 PM/AM, or 20hr, bit4 10hr, bit3-0 hr:0-23
RTC.day             equ       $03                 bit 2-0: 1-7
RTC.date            equ       $04                 bit5-4 10 date, bit 3-0 date: 1-31
RTC.mn              equ       $05                 bit4 10 mn, bit3-0 mn
RTC.yr              equ       $06                 bit7-4 10yr, bit3-0 yr
RTC.base            equ       $FF80
RTC.data            equ       $FF81               data I/O
RTC.cmd             equ       $FF82               $D1=read, $D0=write
RTC.adr             equ       $FF83               indicates 00h-06h see above
RTC.tog             equ       RTC.base            set 1 then 0
RTC.stat            equ       RTC.base            wait for $80 to show ready

                    mod       eom,name,tylg,atrv,JmpTable,RTC.base

name                fcs       "Clock2"
                    fcb       edition

JmpTable
                    lbra      INIT
                    bra       GetTime
                    nop
                    lbra      SetTime
                    lbra      GetSta
                    lbra      SetSta
                    lbra      TERM

GetTime             ldx       M$Mem,pcr           get RTC base address from fake memory requirement
                    ldd       #$D106              read and year
                    sta       2,x
                    bsr       rdreg
                    lda       1,x                 get year
                    bsr       bcd2hex
                    sta       <D.Year
                    ldb       #5                  month register address
                    bsr       rdreg
                    lda       1,x
                    anda      #%11111             keep only month
                    bsr       bcd2hex
                    sta       <D.Month
                    ldb       #4                  day of month register address
                    bsr       rdreg
                    lda       1,x
                    bsr       bcd2hex
                    sta       <D.Day
                    ldb       #2                  hour register address
                    bsr       rdreg
                    lda       1,x
                    anda      #%111111            assume 24hr clock
                    pshs      a
                    anda      #%11111             limit to 19
                    bsr       bcd2hex
                    puls      b                   recover original time
                    andb      #%100000            test for 20+
                    beq       no20
                    adda      #20
no20                sta       <D.Hour
                    ldb       #1                  minute register address
                    bsr       rdreg
                    lda       1,x
                    bsr       bcd2hex
                    sta       <D.Min
                    clrb                          second register address
                    bsr       rdreg
                    lda       1,x
                    bsr       bcd2hex
                    sta       <D.Sec
UpdTExit            rts

rdreg               stb       3,x                 set mode
                    ldb       #1                  activate
                    stb       ,x
LP1                 lda       ,x                  Done yet?
                    bmi       LP1                 No, loop
                    clr       ,x                  Clear for activation
LP2                 lda       ,x                  get status
                    anda      #$80
                    beq       LP2                 Update In Progress, loop
                    rts

* Convert Bitcode to Hex
bcd2hex             pshs      b
                    tfr       a,b                 copy the bcd number
                    andb      #15                 keep the lowest digit
                    pshs      b                   save it
                    anda      #$F0
                    ldb       #160
                    mul                           times 10
                    adda      ,s+                 add partials
                    puls      b,pc

SetTime             pshs      cc                  save interrupt status
                    orcc      #IntMasks           disable IRQs
                    ldx       M$Mem,pcr           get RTC base address from fake memory requirement
                    ldd       #$D006              write and year
                    sta       2,x
                    ldy       #D.Time             point [Y] to time variables in DP
                    lda       ,y+                 get year
                    bsr       hex2bcd
                    sta       1,x
                    bsr       rdreg
                    lda       ,y+                 month
                    bsr       hex2bcd
                    sta       1,x
                    ldb       #5                  month
                    bsr       rdreg
                    lda       ,y+                 day
                    bsr       hex2bcd
                    sta       1,x
                    ldb       #4                  day
                    bsr       rdreg
                    lda       ,y+                 hour
                    bsr       hex2bcd
                    sta       1,x
                    ldb       #2                  hour
                    bsr       rdreg
                    lda       ,y+                 minute
                    bsr       hex2bcd
                    sta       1,x
                    ldb       #1                  minute
                    bsr       rdreg
                    lda       ,y                  sec
                    sta       1,x
                    clrb                          sec = 0
                    bsr       rdreg
                    puls      cc                  Recover IRQ status
                    rts

* Convert Hex to Bitcode
hex2bcd             pshs      b
                    ldb       #$FF
lp10                incb
                    suba      #10
                    bcc       lp10
                    adda      #10
                    lslb
                    lslb
                    lslb
                    lslb
                    pshs      b
                    adda      ,s+
                    puls      b,pc

INIT                equ       *
GetSta              equ       *
SetSta              equ       *
TERM                equ       *
                    rts

                    emod
eom                 equ       *
                    end

