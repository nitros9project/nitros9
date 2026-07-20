********************************************************************
* SWRead - Read SmartWatch clock
*
* Copyright May, 1990 by Robert Gault

* SWREAD will read smartwatch compensating for 12hr mode if active
* time will be sent to OS-9 in 24hr mode for compatability
*
* The routine does grab a large uninterruptible block of time from
* the system, but no other way seems possible.
*
* syntax  swread [n&]      n=1-60 minutes
* D.Daywk stored for possible use
*
* Ed.    Comments                                       Who YY/MM/DD
* ------------------------------------------------------------------
* 1      Created                                        RG  91/03/01
* 1      Changed irq handling; MPI handling;            RG  91/10/29
*        error handling
* 1      Removed relocation routine. Removal could be   RG  92/12/26
*        dangerous if OS-9 did not grab block from the
*        low addresses first. Code must not be in a
*        RAM/ROM block when ROMs activated.
* 2      Relocated part of clock read routine to        RG  94/12/19
*        shorten the time spent with irqs off.
* 3      Adapted module for Level-1 use. Trimmed code.  RG  04/07/24
*        Forced to add back the relocation loop for Level-1.
*        Attempted to write a clock2 modules but just too
*        difficult to acquire needed system low ram.
*        Removed 6309 code for consistency as it had
*        little effect on speed or size.
*        Switched from Chain to Setime to Fork.

                    nam       SWRead
                    ttl       Read SmartWatch clock

                    ifp1
                    use       defsfile
                    endc

DOHELP              equ       0
SETIME              equ       0

* Next three lines for testing purposes. Remove as makefile will
* handle this choice.
*Level    equ   1
*Level    equ   2
*D.TSec    equ   $5A

cartI               equ       $FF22               cartridge IRQ report
MPI.Slct            set       $FF7F
rom                 equ       $FFDE
ram                 equ       $FFDF
IEN                 equ       %00100000
FEN                 equ       %00010000
SCS                 equ       %00000100
ROM1                equ       %00000010
ROM0                equ       %00000001
RTC.Base            equ       $C000
RTC.Blk             equ       $3E
RTC.Read            equ       4
RTC.Zero            equ       0
RTC.One             equ       1

type                set       prgrm+objct
revs                set       reent+1
edition             set       3

                    mod       pgrmend,name,type,revs,start,size

name                fcs       /SWRead/
                    fcb       edition

locblk0             rmb       2                   pointer to block 0
locblk3E            rmb       2                   pointer to block $3E ie. disk ROM
sleep               rmb       1                   sleep interval time in minutes
byte1               rmb       1                   clock read data; if no change - no clock
clkflag             rmb       1                   set when clock is found
mpiimage            rmb       1
sleepflg            rmb       1                   indicates multiple reads requested
timer               rmb       1                   count down for sleep interval; per minute
century             rmb       1                   century flag
rawdata             rmb       8                   direct readout from clock chip
relocimg            rmb       300                 place in data for relocated code
stack               rmb       200
size                equ       .

message1            fcc       /no clock found/
                    fcb       C$CR
                    ifne      SETIME
setime              fcc       /setime/            forced chain to setime routine
                    fcb       C$CR
                    endc

                    ifne      DOHELP
errmes              fcb       C$LF
                    fcc       /SWRead syntax:/
                    fcb       C$LF,C$LF
                    fcc       /SWRead [n&]/
                    fcb       C$LF
                    fcc       /           The parameter string is optional; n = 1 to 60 min/
                    fcb       C$LF
                    fcc       /           permits watch to be polled in background every/
                    fcb       C$LF
                    fcc       /           n minutes. Use decimal time values./
                    fcb       C$CR
                    endc
errmes2             fcb       C$LF
                    fcc       /Don't have relocation memory./
                    fcb       C$LF,C$CR

start               clr       sleepflg
                    cmpd      #2
                    blo       noparams
                    ldd       ,x
                    cmpa      #'?
                    beq       syntax
                    cmpa      #'-
                    beq       syntax

                    cmpb      #'0                 if second byte is CR then only one number
                    blo       onebyte
                    subd      #$3030              convert from ascii to bcd

                    cmpd      #$600               one hour skip is max
                    bhi       syntax
                    cmpb      #9                  must be a number from 0-9
                    bhi       syntax

                    pshs      b                   convert reg.D to hexidecimal
                    ldb       #10
                    mul
                    addb      ,s+
                    bra       storeit

syntax
                    ifne      DOHELP
                    lda       #2
                    leax      errmes,pcr
                    ldy       #300
                    os9       I$Writln
                    endc
                    clrb
                    os9       F$Exit

onebyte             suba      #'0
                    cmpa      #9
                    bhi       syntax

storeit             stb       timer
                    stb       sleep               used to reset timer on count down
                    com       sleepflg

noparams            equ       *
                    lda       MPI.Slct
                    anda      #3                  retain IRQ settings
                    ora       #$30                start at slot 4; ROM setting
                    sta       mpiimage

                    ifgt      Level-1
doit                pshs      u
                    ldb       #1                  single block
                    ldx       #RTC.Blk            disk rom; $07C000-$07DFFF
                    os9       F$MapBlk            map into user space clock ROM
                    bcs       exit2
                    stu       locblk3E            save pointer
                    ldx       #0                  system direct page
                    os9       F$MapBlk            system direct page
                    bcs       exit2
                    stu       locblk0             save pointer
                    bsr       readclk
                    ldb       #1                  block count
                    ldu       locblk3E
                    os9       F$ClrBlk            unmap the block
                    ldu       locblk0
                    os9       F$ClrBlk
                    puls      u
                    else
                    tfr       u,d
                    cmpa      #$7E
                    lbhs      noroom              the assigned DP is too close to ROM
                    ldx       #RTC.Base
                    stx       locblk3E
                    ldx       #0
                    stx       locblk0
                    leax      readclk,pcr
                    pshs      u
                    leau      relocimg,u
                    ldy       #endrel-readclk
reloc               lda       ,x+                 move the read routines to the data page
                    sta       ,u+
                    leay      -1,y
                    bne       reloc
                    puls      u
doit                jsr       relocimg,u
                    endc

                    tst       clkflag             was clock found?
                    beq       error2
                    tst       sleepflg            are we in repeat mode?
                    beq       exit

snooze              ldx       #3540               = one minute of ticks minus one second for overhead
                    os9       F$Sleep
                    cmpx      #0
                    bne       exit                received signal so quit

                    dec       timer
                    bne       snooze

                    lda       sleep               reset timer
                    sta       timer
                    bra       doit                go and read the clock

exit2               puls      u
                    bra       ex

error               ldb       #E$IllArg
                    bra       ex

error2              lda       #2                  error path
                    leax      message1,pcr
                    ldy       #40
                    os9       I$WritLn
                    ifne      SETIME
* force a normal Setime as SmartWatch was not detected
                    lda       #Prgrm+Objct        modul type
                    ldb       #2                  size of data area
                    leax      setime,pcr
                    ldy       #0                  parameter size
*         leas  stack,u
                    os9       F$Chain
                    endc
exit                equ       *
                    clrb
ex                  os9       F$Exit

* this is the heart of the clock reading routine

readclk             pshs      cc
                    ifgt      Level-1
                    lda       d.hinit,u           get $FF90 image
                    endc
                    ldb       MPI.Slct            get current setting
                    pshs      d                   save them
                    ifgt      Level-1
                    anda      #^(IEN+FEN+ROM1+ROM0) no GIME IRQ/FIRQ; external access
                    orcc      #IntMasks           stop interrupts
                    sta       $FF90
                    else
                    orcc      #IntMasks           stop interrupts
                    endc
                    sta       rom                 go to ROM mode
                    ldx       locblk3E            point to clock ROM
                    ldb       mpiimage            get new value for MPI
                    clr       clkflag             start with clock not found

findclk             stb       MPI.Slct            set new slot
                    leay      <alert,pcr          point to clock wakeup code
                    lda       RTC.Read,x          clear clock at $C004
* Reading clock fills a byte with bit0. If clock not present,
* then result is either $00 or $FF. Any other test byte will
* result in a false positive for finding the clock.
                    clrb
                    bita      #1
                    beq       f1
                    comb
f1                  stb       byte1               set initial value and look for change

nxtbyte             ldb       #8                  bits/byte
                    lda       ,y+
                    beq       gettime
nxtbit              lsra                          do a serial generation
                    bcs       high
                    cmpa      RTC.Zero,x          talk to clock at $C000; cmp faster than tst
                    bra       high2
high                cmpa      RTC.One,x           talk to clock at $C001
high2               decb
                    bne       nxtbit
                    bra       nxtbyte

* Code to tell swatch socket to switch from ROM to clock.
alert               fcb       $C5,$3A,$A3,$5C,$C5,$3A,$A3,$5C,0

gettime             lda       #8                  8 bytes to read from clock
                    pshs      a
                    ifgt      Level-1
                    ldy       #rawdata
                    else
                    leay      rawdata,u
                    endc
* read serial bit stream from clock
timebyte            lsr       RTC.Read,x          this is faster than a short loop with dec/bne
                    rora
                    lsr       RTC.Read,x
                    rora
                    lsr       RTC.Read,x
                    rora
                    lsr       RTC.Read,x
                    rora
                    lsr       RTC.Read,x
                    rora
                    lsr       RTC.Read,x
                    rora
                    lsr       RTC.Read,x
                    rora
                    lsr       RTC.Read,x
                    rora
                    sta       ,y+                 store in raw data
                    tst       clkflag             once clock found, bypass tests
                    bne       maybe
                    cmpa      byte1
                    beq       maybe               always possible a clock byte looks like ROM
                    inc       clkflag
maybe               dec       ,s
                    bne       timebyte
                    leas      1,s                 yank counter
                    tst       clkflag
                    bne       found
                    ldb       mpiimage
                    bitb      #$30                did we get to slot 0?
                    beq       found               yes? then quick looking
                    subb      #$10                next slot
                    stb       mpiimage
                    bra       findclk

noclk               rts
found               equ       *
                    sta       ram                 go back to RAM mode
                    puls      d
                    stb       MPI.Slct            restore to original setting
                    tst       cartI               clear CART flag for autostart ROM pack present in MPI
                    ifgt      Level-1
                    sta       $FF90               restore GIME mode
                    endc
                    puls      cc                  restore IRQs
                    tst       clkflag
                    beq       noclk
                    ifgt      Level-1
                    ldx       #rawdata
                    leay      D.Slice,u
                    else
                    leax      rawdata,u
                    ldy       #D.TSec             $5A
                    endc
                    ldb       #8
                    pshs      b
trans               lda       ,x+                 translate serial data into OS-9 format
                    ldb       ,s
                    cmpb      #1                  year
                    bne       notyr
                    cmpa      #$80                binary coded decimal number
                    bhi       nintn
                    sta       century
                    bra       notyr
nintn               clr       century
notyr               cmpb      #4                  day of the week
                    bne       notdywk
                    ifgt      Level-1
                    anda      #7
                    sta       D.Daywk,u
                    endc
                    bra       nxtdata
notdywk             cmpb      #5                  special 12/24, AM/PM indicator
                    bne       cnvrt               convert any number
                    bita      #%10000000          12/24 hour bit
                    beq       cnvrt               24 hour time
                    bita      #%00100000          AM/PM bit since 12 hour time, check AM/PM
                    pshs      cc
                    anda      #%00011111          keep only time 1-12
                    puls      cc
                    bne       PMhr
                    cmpa      #$12                bcd value
                    bne       cnvrt
                    clra                          12 AM = 0 hrs 24hr time
                    bra       cnvrt
Pmhr                cmpa      #$12                bcd value
                    beq       cnvrt               12PM = 1200 24 hr time
                    adda      #$12                bcd value; other times (1-11) add 12; ie. 1300-2300
cnvrt               clrb                          convert BCD to binary
a1                  cmpa      #$10
                    bcs       a2
                    addd      #$f00a
                    bra       a1
a2                  pshs      a
                    addb      ,s+
                    stb       ,-y                 decrease pointer and then store
nxtdata             dec       ,s
                    bne       trans
                    tst       century
                    beq       not20
                    lda       #100                user convention for >1999 values
                    adda      ,y
                    sta       ,y
not20               puls      b,pc

* This is the end of the code to be relocated.
endrel              equ       *

noroom              lda       #2
                    leax      errmes2,pcr
                    ldy       #300
                    os9       I$WritLn
                    clrb
                    os9       F$Exit

                    emod
pgrmend             equ       *
                    end
