********************************************************************
* Clock2 - Dallas Semiconductor 1216 RTC Driver
*
* $Id$
*
* Dallas Semiconductor DS1216 SmartWatch
*
* Wakeup sequence $C5 3A A3 5C C5 3A A3 5C
*
* Time byte sequence in Binary Coded Decimal
*
* byte	bit 7     6     5     4     3     2     1      0
* 0        |       0.1 sec MSB       |        0.1 sec LSB     |
* 1        |  0  |   10 sec          |        seconds         |
* 2        |  0  |   10 min          |        minutes         |
* 3        |12/24|  0   | AM/PM | HR |        Hour            |
*                       |  10 HR     |        Hour            |
*        0=12, 1=24       0=AM, 1=PM
* 4        | 0   |  0   |  OSC |RESET|  0  |  Weekday         |
* 5        | 0   |  0   |  10  Date  |        Date            |
* 6        | 0   |  0   |   0  |10 Month|     Month           |
* 7        |        10 Year          |        Year            |
*
* OSC = 1;  turns off clock to save battery. RESET not used in Coco circuit.
*
* When inserted in external ROM socket, the clock is addressed at:
* $C000     bit = 0
* $C001     bit = 1
* $C004     read byte to wakeup then send wakeup sequence to bit toggles.
*           Then either read or send time.
*
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*          2004/07/28  Robert Gault
* Complete rewrite of SmartWatch segment which would never have worked.
* See previous versions for old code if desired. Routine now will search
* through all MPI slots to find clock and accept either AM/PM or military
* time. User notified if clock not found or data memory not available.
*
* Initialization routine contains code that bypasses OS-9 system calls to
* acquire needed low RAM that can't become ROM. This type of code is not
* recommended in most cases but nothing else was usable.
*          2004/07/31  Robert Gault
* Added a settime routine and changed "no clock found" routine. If the
* clock is not found, the D.Time entries are cleared but no message is sent.
* Date -t will never get passed one minute.
*          2004/07/31  Rodney Hamilton
* Improved RTCJVEmu code, conditionalized RTC type comments.
*          2004/08/2   Robert Gault
* Alphabetized all clock listings so things can be found much more easily.
* Placed list of clock types at beginning of source for record keeping.
*
*   1      2004/08/18  Boisy G. Pitre
* Separated clock2 modules for source clarity.

                    nam       Clock2
                    ttl       Dallas Semiconductor 1216 RTC Driver

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

RTC.Base            equ       $C000               clock mapped to $C000-$DFFF; $FFA6 MMU slot
RTC.Zero            equ       0                   Send zero bit
RTC.One             equ       1                   Send ones bit
RTC.Read            equ       4
*D.SWPage                 on system DP; Refer to os9defs.
D.RTCSlt            equ       0                   on SmartWatch ?data? page
D.RTCFlg            equ       1                   on SW page
D.RTCMod            equ       2
D.Temp              equ       3                   on SW page, holds "clock" data
D.Start             equ       4                   on SW page, code starts here


                    mod       eom,name,tylg,atrv,JmpTable,RTC.Base

name                fcs       "Clock2"
                    fcb       edition

                    ifne      MPIFlag
SlotSlct            fcb       MPI.Slot-1          Slot constant for MPI select code
                    endc

JmpTable
                    lbra      Init
                    bra       GetTime
                    nop
                    lbra      SetTime

GetTime             pshs      cc,d,x,y,u
                    orcc      #$50
                    lda       D.SWPage
                    clrb
                    tfr       d,u                 point to working space
                    lda       $FF7F
                    pshs      a
                    lda       D.RTCSlt,u          info for MPI slot
                    sta       $FF7F
                    clr       D.RTCMod,u          set for read time
                    jsr       D.Start,u           jsr to it
                    lbra      exit



* This set time routine forces military time. It can't turn off clock but can
* be used as a timer if time set to 0:0:0  hr:min:sec
SetTime             pshs      cc,d,x,y,u
                    orcc      #$50
                    lda       D.SWPage
                    clrb
                    tfr       d,u                 point to working space
                    lda       $FF7F
                    pshs      a
                    lda       D.RTCSlt,u          info for MPI slot
                    sta       $FF7F
                    lda       #-1
                    sta       D.RTCMod,u          indicate set time rather than read
                    ifgt      Level-1
                    ldx       #D.Slice
                    else
                    ldx       #D.TSec
                    endc
                    tfr       u,y                 get location of safe region
                    leay      >D.Start+alrtend-reloc,y point to end of wakeup code
                    lda       ,-x                 get D.Time data and store it
                    ldb       #4                  convert tenths sec, sec, min, hours
                    bsr       binbcd              to binary coded decimal
                    ifgt      Level-1
                    lda       D.Daywk
                    else
                    clra
                    endc
                    sta       ,y+                 set day of week if present
                    lda       ,x
                    ldb       #3                  convert day of month, month, year
                    bsr       binbcd              to BCD
                    jsr       >D.Start,u          send data to clock
                    lbra      exit

binbcd              pshs      b
bcd3                clrb
bcd1                cmpa      #10
                    bcs       bcd2
                    addd      #$f610              decrease bin regA by 10 add bcd $10 to regB
                    bra       bcd1
bcd2                pshs      a
                    addb      ,s+                 add in remainder; BCD = binary when less than 10
                    stb       ,y+                 place in message to clock
                    lda       ,-x                 get next byte of D.Time
                    dec       ,s                  decrease counter
                    bne       bcd3
                    puls      b,pc

* This becomes D.Start
reloc               equ       *
                    ifgt      Level-1
                    lda       D.HINIT
                    anda      #$CC
                    sta       $FF90
                    endc
                    ldb       $FFA6               choose to use normal location
                    pshs      b
                    ldb       #$3E
                    stb       $FFA6               reset MMU for clock
                    sta       $FFDE
                    ldd       #RTC.Base
                    tfr       a,dp                DP now points to clock
                    tst       D.RTCMod,u          are we reading the clock or setting it?
                    beq       findclk             go if reading
                    lbsr      wakeup              we are setting a found clock
                    lbra      found
findclk             lda       #-1
                    sta       alrtend,pcr
                    lbsr      wakeup              wakeup the clock
                    ldx       #D.Sec              one incoming byte dropped
                    lda       #8                  bytes to get
                    pshs      a
L0050               ldb       #8                  bits to get
L0052               lsr       <RTC.Read           get a bit
                    rora
                    decb
                    bne       L0052
                    tst       D.RTCFlg,u
                    bne       maybe
                    cmpa      D.Temp,u
                    beq       maybe               clock might look like ROM
                    inc       D.RTCFlg,u          found the clock
maybe               sta       ,x                  transfer it to time
                    lda       ,s                  check loop counter
                    cmpa      #8
                    beq       L006F               skip if 0.1 sec
                    cmpa      #4
                    bne       L006B               skip if not day of week
                    ifgt      Level-1
                    lda       ,x                  move to correct location
                    anda      #7
                    sta       D.Daywk
                    endc
                    bra       L006F
L006B               cmpa      #5                  hour byte
                    bne       wd
                    lda       ,x
                    bita      #%10000000          12/24hr
                    beq       wd
                    bita      #%00100000          AM/PM
                    pshs      cc
                    anda      #%00011111          keep only time
                    puls      cc
                    bne       pm
                    cmpa      #$12                these are BCD tests
                    bne       am
                    clr       ,x                  12AM=0hr military
                    bra       wd
pm                  cmpa      #$12                12PM=12hr military
                    beq       wd
                    adda      #$12                1-11PM add 12 for military
am                  sta       ,x
wd                  leax      -1,x                update time slot
                    bsr       L0087               convert from BCD to binary
L006F               dec       ,s
                    bne       L0050               get the next byte from clock
                    lda       1,x                 get year
                    cmpa      #50                 half assed test for century
                    bhs       c19
                    adda      #100                make it 20th
c19                 sta       1,x
                    leas      1,s
                    tst       D.RTCFlg,u
                    bne       found
                    ldb       D.RTCSlt,u
                    bitb      #$30
                    beq       found
                    subb      #$10                not found so move to next slot
                    stb       D.RTCSlt,u
                    stb       $FF7F
                    lbra      findclk
found               clra                          system DP is always 0
                    tfr       a,dp
                    ifgt      Level-1
                    lda       D.HINIT             reset system before rts
                    sta       $FF90
                    endc
                    sta       $FFDF
                    puls      a
                    sta       $FFA6
                    rts                           go back to normal code location

* Convert BCD to binary
L0087               lda       1,x
                    clrb
L008A               cmpa      #$10                BCD 10
                    bcs       L0094
                    addd      #$F00A              decrease BCD by $10 and add binary 10
                    bra       L008A
L0094               pshs      a
                    addb      ,s+
                    stb       1,x
term                rts

wakeup              lda       <RTC.Read           clear the clock for input
* When getting time data, bit0 is rotated into a full byte. This
* means the result is $00 or $FF for ROM. Any other value used for a test
* will give a false positive for the clock.
                    clrb
                    bita      #1
                    beq       w1
                    comb
w1                  stb       D.Temp,u
                    leax      alert,pcr           point to message
nxtbyte             ldb       #8                  8 bytes to send
                    lda       ,x+
                    cmpa      #-1                 changed from 0 to -1 to accommodate settime
                    beq       term
nxtbit              lsra                          bits sent to clock by toggling
                    bcs       high                Zero and One
                    cmpa      <RTC.Zero           faster than tst
                    bra       nxtbit2
high                cmpa      <RTC.One
nxtbit2             decb
                    bne       nxtbit
                    bra       nxtbyte

* SmartWatch wakeup sequence
alert               fcb       $c5,$3a,$a3,$5c,$c5,$3a,$a3,$5c
* The next 8 bytes become time data when setting the clock. Terminator is
* now $FF instead of $00 to permit $00 as data.
alrtend             fcb       $FF
alrtime             rmb       7
                    fcb       $FF

exit                equ       *
                    puls      a
                    sta       $FF7F               restore MPI
                    tst       D.RTCFlg,u          was clock found?
                    beq       noclock
                    puls      cc,d,x,y,u,pc


Init                equ       *
                    clr       <D.SWPage           safe location for Read
                    pshs      d,x,y,u
                    ifgt      Level-1
                    ldx       <D.SysMem           get memory map
                    ldy       <D.SysDAT           get MMU map
                    ldb       #$20                first 20 pages always in use
                    abx                           point to page
A1                  tst       ,x+
                    beq       A2                  found free page so go
                    incb                          update page counter
                    bpl       A1                  still in RAM only, then go
A4                  lda       #2                  can't find RAM only memory
                    leax      mem_mes,pcr
                    ldy       #40
                    os9       I$WritLn
                    puls      d,x,y,u,pc
A2                  pshs      b                   save page #
                    andb      #%11100000          modulo MMU blocks
                    lsrb                          convert to DAT byte value
                    lsrb                          page# * $100 / $2000 = MMU #
                    lsrb                          $2000/$100=$20 at 2 bytes per MMU
                    lsrb                          then page#/$10 gives answer
                    ldd       b,y                 get the MMU value
                    cmpd      #$333E              is DAT unused
                    pshs      cc                  save answer
                    inc       1,s                 update page # for a used page
                    puls      cc,b                get back answer and page #
                    beq       A1                  if unused keep going
                    lda       #RAMinUse
                    sta       ,-x                 flag the memory in use
                    else
                    ldx       <$20                D.FMBM     free memory bit map
                    ldy       <$22                top of memory bit map
                    ldb       #-1                 preset counter
A1                  lda       ,x+                 get bits
                    incb                          update $800 counter
                    pshs      y                   test for end of map
                    cmpx      ,s+
                    bhi       A4                  send error message
                    clr       -1,s                preset bit counter
A2                  inc       ,s
                    lsra                          read left to right
                    bcs       A2
                    lda       ,s+
                    deca                          convert to number of shifts
                    cmpa      #8                  overflow value
                    beq       A1                  get more map on ov
                    pshs      a                   save the number of shifts
                    lda       #8                  bytes*8
                    mul
                    addb      ,s                  add modulo $800
                    cmpb      #$7E                need RAM not ROM for clock data
                    bhs       A4
                    lda       #%10000000          need to create mask to map the
A5                  lsra                          unused bit, so reverse the process
                    dec       ,s                  decrease shift counter
                    bne       A5
                    leas      1,s                 yank counter
                    ora       -1,x                mark bit used and
                    sta       -1,x                tell the system
                    bra       A3
A4                  leas      1,s                 yank bit info
                    lda       #2                  error path #
                    leax      mem_mes,pcr         good memory not found
                    ldy       #200
                    os9       I$WritLn
                    puls      d,x,y,u,pc
A3                  equ       *
                    endc
                    stb       <D.SWPage           keep the info for Read
                    tfr       b,a
                    clrb
                    tfr       d,x                 regX now points to SW data page
                    ldb       $FF7F               get MPI values
                    andb      #3                  keep IRQ info
                    orb       #$30                force slot #4 to start search
                    stb       D.RTCSlt,x          save the info
                    clr       D.RTCFlg,x          set to no clock found
                    clr       D.RTCMod,x          set to read time
                    leax      D.Start,x           safe location for moved code
                    ifne      H6309
                    leay      reloc,pcr
                    ldw       #exit-reloc
                    tfm       y+,x+
                    else
                    leau      reloc,pcr           relocation routine to move code
                    ldy       #exit-reloc         to a RAM only location
B3                  lda       ,u+
                    sta       ,x+
                    leay      -1,y
                    bne       B3
                    endc
                    puls      d,x,y,u,pc

noclock             equ       *
                    ldd       #7                  seven time bytes to clear
                    ldx       #D.Time
                    ifgt      Level-1
                    sta       D.Daywk
                    endc
nc                  sta       ,x+
                    decb
                    bne       nc
                    puls      cc,d,x,y,u,pc

mem_mes             fcc       /There is no system memory for/
                    fcb       $0a
                    fcc       /the SmartWatch. Please reduce/
                    fcb       $0a
                    fcc       /os9boot size or use soft clock./
                    fcb       $0d

                    emod
eom                 equ       *
                    end

