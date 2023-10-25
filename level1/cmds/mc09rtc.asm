********************************************************************
* mc09rtc - read/write DS1302 RTC attached to multicomp09 GPIO
* Details of the hook-up can be inferred from the code or see the
* description here:
* https://github.com/nealcrook/multicomp6809/wiki/Adding-a-RTC
*
* Rather than bloat the timer module (which is memory-resident)
* this is a stand-alone utility that can either read the RTC and
* update the system time, or read the system time and update the
* RTC. It can be run from the startup file to set the time at boot.
*
* usage:
*
* mc09rtc -r
* read RTC and update system time
* mc09rtc -w
* write RTC with current system time
* mc09rtc -d
* dump RTC clock and RAM contents
*
* This is for the 6809: it contains no 6309-specific code.
*
*   +-----------------+  <--  Y          (highest address)
*   !                 !
*   !   Parameter     !
*   !     Area        !
*   !                 !
*   +-----------------+  <-- X, SP
*   !                 !
*   !   Data Area     !
*   !                 !
*   +- - - - - - - - -+
*   !   Direct Page   !
*   +-----------------+  <-- U, DP       (lowest address)
*
*   D = parameter area size
*  PC = module entry point abs. address
*  CC = F=0, I=0, others undefined
*
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2015/11/07  Neal Crook
* Created.
*
                    nam       mc09rtc
                    ttl       Read/write DS1302 RTC, copy to/from system time

                    use       defsfile

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

* Bit-masks for GPIO bits connected to RTC
RTCCE               equ       4                   bit 2
RTCCLK              equ       2                   bit 1
RTCDAT              equ       1                   bit 0

                    org       0
* buffer for NITROS9-format 6-byte "time packet"
sysbuf              rmb       0                   same as sysyear. [NAC HACK 2015Nov17] without "rmb 0" this becomes an offset in *code* space..
sysyear             rmb       1
sysmonth            rmb       1
sysdate             rmb       1                   documentation refers to this as "day"
syshour             rmb       1
sysmin              rmb       1
syssec              rmb       1

* buffer for RTC time registers (and, in -D, for RTC RAM)
rtcbuf              rmb       0                   same as rtcsec. [NAC HACK 2015Nov17] without "rmb 0" this becomes an offset in *code* space..
rtcsec              rmb       1
rtcmin              rmb       1
rtchour             rmb       1
rtcdate             rmb       1
rtcmonth            rmb       1
rtcday              rmb       1
rtcyear             rmb       1
rtcprot             rmb       1                   have to read this as part of the burst
rtcxxx              rmb       23                  31 bytes total, to hold RTC RAM

txtbuf              rmb       80                  text output buffer
                    rmb       200                 stack
size                equ       .

name                fcs       /mc09rtc/
                    fcb       edition

WrMsg               fcc       'RTC updated from system time'
WrMsgE
RdMsg               fcc       'System time updated from RTC'
RdMsgE

DMsg1               fcc       'Yr Mo Dt Hr Mi Se'
                    fcb       C$CR
DMsg2               fcc       '        NitrOS9 binary "time packet"'
                    fcb       C$CR
DMsg3               fcc       'Se Mi Hr Dt Mo Dy Yr Pr'
                    fcb       C$CR
DMsg4               fcc       '  DS1302 RTC BCD Date/protection'
                    fcb       C$CR
DMsg5               fcc       '                       trickle'
                    fcb       C$CR
DMsg6               fcc       '  RAM'
DMsg7               fcb       C$CR


********************************************************************
* Start of program/Entry point
start               pshs      x                   preserve pointer to cmd line args

* Load time from RTC - for use by -R and -D options.
                    lbsr      initio
                    lda       #$BF                cmd for clock read burst
                    ldx       #8                  read 8 bytes
                    leay      rtcbuf,u            where to put it: the RTC buffer
                    lbsr      rd_n

* Load system time - for use by -W and -D options.
                    leax      sysbuf,u            buffer
                    os9       F$Time              read system time into buffer
                    bcs       badexit             something bad happened

* Now, what are we expected to do?
                    puls      x
                    lda       ,x+                 first char of cmd-line arguments
*                               leading spaces stripped by shell
                    cmpa      #$2D                require "-" for -R -W -D
                    bne       badexit             not found so set carry and exit
                    lda       ,x+                 character after "-"
                    anda      #$df                force to upper case
                    cmpa      #'R
                    beq       read
                    cmpa      #'W
                    lbeq      write
                    cmpa      #'D
                    lbeq      dump
badexit             clrb                          exit code=0
                    orcc      #1                  set C to indicate error
                    os9       F$Exit

********************************************************************
* "-R" - read from RTC and update system time.
read
* Time from RTC has already been loaded in.
* Convert it and move it from RTC buffer to system time buffer.
                    lda       <rtcsec             0-59
                    anda      #$7f                omit CH flag
                    bsr       bcd2bin
                    sta       <syssec

                    lda       <rtcmin             0-59
                    bsr       bcd2bin
                    sta       <sysmin

                    lda       <rtchour            0-23
                    anda      #$3f                omit 12/24 flag
                    bsr       bcd2bin
                    sta       <syshour

                    lda       <rtcdate            1-31
                    bsr       bcd2bin
                    sta       <sysdate

                    lda       <rtcmonth           1-12
                    bsr       bcd2bin
                    sta       <sysmonth

                    lda       <rtcyear            0-99
                    bsr       bcd2bin
                    adda      #100                nitros stores year as offset from 1900
                    sta       <sysyear

                    leax      sysbuf,u            buffer
                    os9       F$STime             set system time from buffer

* Report our action and exit
                    leax      >RdMsg,pcr          point to message
                    ldy       #RdMsgE-RdMsg       length
                    lbra      prexit


********************************************************************
bcd2bin
*
* in  A= value in BCD
* out A= value in binary
*
* eg: $10 in, $0A out
* CC modified, all other registers preserved.
*
* algorithm: take tens digit, multiply by 8 and then by 2 and add
* those two values to the units.
                    pshs      b
                    tfr       a,b
                    anda      #$0f                units in A
                    andb      #$f0                tens in B
                    asrb                          tens move from *16 position to *8 position
                    pshs      b                   }
                    adda      ,s+                 } add b (8/10ths of tens) to a
                    asrb
                    asrb                          tens * 2
                    pshs      b                   }
                    adda      ,s+                 } units + 8/10ths + 2/10ths of tens
                    puls      b,pc


********************************************************************
bin2bcd
*
* in  A= value in binary
* out A= value in BCD
*
* eg: $16 in, $24 out
* CC modified, all other registers preserved.
*
* algorithm: do successive subtract of $0a and increment counter by
* $10 each time. When result is less than $0a, add in count value.
*
                    pshs      b
                    clrb
bcdnxt              cmpa      #$0a
                    blo       bcddone             branch if lower ie 0-9 remaining
                    addb      #$10                bump up by bcd 10
                    suba      #$0a                as we subtract by binary 10
                    bra       bcdnxt              and go round again

bcddone             pshs      b                   } add b to a
                    adda      ,s+                 }
                    puls      b,pc


********************************************************************
* "-W" - write system time to RTC.
write
* System time has already been loaded in.
* Convert it and move it from system time buffer to RTC buffer.
                    lda       <syssec             0-59 (I hope)
                    bsr       bin2bcd
                    sta       <rtcsec             CH bit is 0 so clock runs

                    lda       <sysmin             0-59 (I hope)
                    bsr       bin2bcd
                    sta       <rtcmin

                    lda       <syshour            0-23 (I hope)
                    anda      #$3f                select 24-hour clock
                    bsr       bin2bcd
                    sta       <rtchour

                    lda       <sysdate            1-31 (I hope)
                    bsr       bin2bcd
                    sta       <rtcdate

                    lda       <sysmonth           1-12 (I hope)
                    bsr       bin2bcd
                    sta       <rtcmonth

                    lda       #1
                    sta       <rtcday             1-7. Not used but want it legal

                    lda       <sysyear            100-199 (I hope)
                    suba      #100                [NAC HACK 2015Nov18] check first!! Error if last century.
                    bsr       bin2bcd
                    sta       <rtcyear

* Write buffer to RTC
                    lbsr      initio
                    lda       #$BE                cmd for clock write burst
                    ldx       #8                  read 8 bytes
                    leay      rtcbuf,u            get it from the RTC buffer
                    lbsr      wr_n

* Report our action and exit
                    leax      >WrMsg,pcr          point to message
                    ldy       #WrMsgE-WrMsg       length
                    lbra      prexit

********************************************************************
* "-D" - dump RTC contents.
dump
* system and RTC buffer are already loaded. Print them out then
* load and report in addition
* 1 byte from trickle-charge register, 31 bytes from RAM
*
* Yr Mo Dt Hr Mi Se
* xx xx xx xx xx xx         NitrOS9 binary "time packet"
*
* Se Mi Hr Dt Mo Dy Yr Pr
* xx xx xx xx xx xx xx xx   DS1302 RTC BCD Date/protection
* xx                        trickle
* xx xx xx xx xx xx xx xx   RAM
* xx xx xx xx xx xx xx xx
* xx xx xx xx xx xx xx xx
* xx xx xx xx xx xx xx
*

                    leax      >DMsg1,pcr          point to message
                    ldy       #80                 max length
                    lbsr      prbufb              print from x or die in the attempt

                    *         display             content of system time packet buffer
                    leay      sysbuf,u            data to display
                    leax      >txtbuf,pcr         buffer to store ASCII version
                    lda       #6                  bytes to convert
                    lbsr      hex2buf
                    ldy       #18                 2 digits + 1 space per
                    lbsr      prbufa              print txtbuf or die in the attempt

                    leax      >DMsg2,pcr          point to message
                    ldy       #80                 max length
                    lbsr      prbufb              print from x or die in the attempt

                    leax      >DMsg7,pcr          point to message - extra CR
                    ldy       #80                 max length
                    lbsr      prbufb              print from x or die in the attempt

                    leax      >DMsg3,pcr          point to message
                    ldy       #80                 max length
                    lbsr      prbufb              print from x or die in the attempt

                    *         display             content of RTC time buffer
                    leay      rtcbuf,u            data to display
                    leax      >txtbuf,pcr         buffer to store ASCII version
                    lda       #8                  bytes to convert
                    lbsr      hex2buf
                    ldy       #24                 2 digits + 1 space per
                    lbsr      prbufa              print txtbuf or die in the attempt

                    leax      >DMsg4,pcr          point to message
                    ldy       #80                 max length
                    lbsr      prbufb              print from x or die in the attempt

                    *         read                the 1-byte trickle register
                    leay      rtcbuf,u            where to store it
                    lda       #$91
                    lbsr      putcmd
                    lbsr      getbyte
                    sta       ,y+
                    lbsr      endtrans

                    *         display             1 byte from RTC time buffer
                    leay      rtcbuf,u            data to display
                    leax      >txtbuf,pcr         buffer to store ASCII version
                    lda       #1                  bytes to convert
                    lbsr      hex2buf
                    ldy       #3                  2 digits + 1 space per
                    lbsr      prbufa              print txtbuf or die in the attempt

                    leax      >DMsg5,pcr          point to message
                    ldy       #80                 max length
                    bsr       prbufb              print from x or die in the attempt

                    *         read                RAM
                    leay      rtcbuf,u            where to store it
                    lda       #$FF                RAM read burst
                    ldx       #31                 read 31 bytes
                    leay      rtcbuf,u            where to put it: the RTC buffer
                    lbsr      rd_n

                    *         display             1st 8 bytes of RTC RAM from RTC time buffer
                    leay      rtcbuf,u            data to display
                    leax      >txtbuf,pcr         buffer to store ASCII version
                    lda       #8                  bytes to convert
                    bsr       hex2buf
                    ldy       #24                 2 digits + 1 space per
                    bsr       prbufa              print txtbuf or die in the attempt

                    leax      >DMsg6,pcr          point to message
                    ldy       #80                 max length
                    bsr       prbufb              print from x or die in the attempt

                    *         display             2nd 8 bytes of RTC RAM from RTC time buffer
                    leay      8+rtcbuf,u          data to display
                    leax      >txtbuf,pcr         buffer to store ASCII version
                    lda       #8                  bytes to convert
                    bsr       hex2buf
                    lda       #C$CR               add CR
                    sta       ,x+
                    ldy       #25                 2 digits + 1 space per + CR
                    bsr       prbufa              print txtbuf or die in the attempt

                    *         display             3rd 8 bytes of RTC RAM from RTC time buffer
                    leay      16+rtcbuf,u         data to display
                    leax      >txtbuf,pcr         buffer to store ASCII version
                    lda       #8                  bytes to convert
                    bsr       hex2buf
                    lda       #C$CR               add CR
                    sta       ,x+
                    ldy       #25                 2 digits + 1 space per + CR
                    bsr       prbufa              print txtbuf or die in the attempt

                    *         display             4th 7 bytes of RTC RAM from RTC time buffer
                    leay      24+rtcbuf,u         data to display
                    leax      >txtbuf,pcr         buffer to store ASCII version
                    lda       #7                  bytes to convert
                    bsr       hex2buf
                    lda       #C$CR               add CR
                    sta       ,x+
                    ldy       #22                 2 digits + 1 space per + CR
                    leax      >txtbuf,pcr         where to display from
prexit              bsr       prbufb              go display it
                    clrb                          success
                    os9       F$Exit              and exit


********************************************************************
prbufa              leax      >txtbuf,pcr         where to display from
prbufb              lda       #1                  standard out
                    os9       I$Writln            print it up to CR
                    bcs       prbad
                    rts
prbad               os9       F$Exit


********************************************************************
hex2buf
*
* in:   Y binary data to convert
*       X buffer to build ASCII version
*       A number of bytes to convert
*
* out:  Y, X updated
*       A,B,CC modified
                    ldb       ,y+                 get byte
                    bsr       Byte2Hex            store ASCII version in buffer
                    ldb       #C$SPAC
                    stb       ,x+                 add trailing space
                    deca
                    bne       hex2buf
                    rts

********************************************************************
* Convert byte in B to Hex string at X (from debug.asm)
* B,X,CC altered.
Byte2Hex            pshs      b                   save copy of B on stack
                    andb      #$F0                mask upper nibble
                    lsrb                          and bring to lower nibble
                    lsrb
                    lsrb
                    lsrb
                    bsr       Nibl2Hex            convert byte in B to ASCII
                    puls      b                   get saved B
                    andb      #$0F                do lower nibble
* Convert lower nibble in B to Hex character at X
Nibl2Hex            cmpb      #$09                9?
                    bls       n@                  branch if lower/same
                    addb      #$07                else add 7
n@                  addb      #'0                 and ASCII 0
                    stb       ,x+                 save B
                    rts


********************************************************************
rd_n
* Read from a sequence of RTC locations
*
* X = number of bytes to read
* Y = where to store the read data
* A = command byte
*
* Assumes IO has been initialised.
                    pshs      x                   modified value is held on stack

                    lbsr      putcmd

rd_nxt              lbsr      getbyte             read byte into A
                    sta       ,y+                 store data byte read
                    puls      x                   recover count value
                    leax      -1,x                update count
                    pshs      x                   stash count value
                    bne       rd_nxt              go do next byte
                    bsr       endtrans            tidy up at end

                    puls      x,pc                tidy up the stack and return


********************************************************************
wr_n
* Write to a sequence of RTC locations
*
* X = number of bytes to write
* Y = where to get the write data from
* A = command byte
*
* Assumes IO has been initialised.
* Clears write protect first, sets it at end.
                    pshs      x                   modified value is held on stack
                    pshs      a

                    *         clear               the write-protect bit
                    lda       #$8e
                    lbsr      putcmd
                    clra
                    lbsr      putbyte
                    bsr       endtrans

                    puls      a
                    lbsr      putcmd

wr_nxt              lda       ,y+                 get byte to write
                    lbsr      putbyte             write it
                    puls      x                   recover count value
                    leax      -1,x                update count
                    pshs      x                   stash count value
                    bne       wr_nxt              go do next byte
                    bsr       endtrans            tidy up at end

                    *         set                 the write-protect bit
                    lda       #$8e
                    bsr       putcmd
                    lda       #$80
                    bsr       putbyte
                    bsr       endtrans

                    puls      x,pc                tidy up the stack and return


********************************************************************
* Low-level DS1302 read/write. Broken into the following parts:
*
* initio   - GPIO init
* putcmd   - write 1st (cmd) byte
* putbyte  - write 1 data byte
* getbyte  - read 1 data byte
* endtrans - end read or write transaction
*
* Leave CE and CLK permanently outputs.
* Leave DAT as input by default, make it an output when it needs
* to be but always end a routine with it set to an input. It is OK
* to float DAT because the DS1302 provides an internal pulldown.
*
* designed to be used thus:
* initio (one-time)
* putcmd putbyte [putbyte..] endtrans
* putcmd getbyte [getbyte..] endtrans
*
* Reads from and writes to clock registers *must* be done as
* bursts to take advantage of the internal buffering. Without this,
* it would be necessary to check for carries that occurred between
* accessing one location and the next.


********************************************************************
initio
*
* only need to call this once.
* in:       none
* out:      none
* modifies: A B CC, gpio state.
*
                    clrb
                    lda       #GPDAT0
                    sta       GPIOADR             select dat0
                    stb       GPIODAT             set values to 0
                    lda       #GPDDR1
                    sta       GPIOADR             select ddr1
                    incb
                    stb       GPIODAT             CE out, CLK out, DAT in.
                    rts


********************************************************************
endtrans
*
* take CE back low and wait recovery time.
* in:       none
* out:      none
* modifies: none
*
*        v-------------- send pattern ---------------------V
* CE   H LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL L
* CLK  L LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL L
* DAT  z zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz z
*      ^-assumed on entry            xsition(if any) on exit-^
*
*        -------------------------------------------------->
*        wait 4us in this state to meet recovery time
*
                    pshs      a,cc
                    lda       #GPDAT0
                    sta       GPIOADR             select dat0
                    clr       GPIODAT             falling edge on CE, keep CLK=0.

                    bsr       wait1us
                    bsr       wait1us
                    bsr       wait1us
                    bsr       wait1us
                    puls      a,cc,pc


********************************************************************
putcmd
*
* in:       A=command byte to send
* out:      none
* modifies: A B CC X
* enter with CE=0 CLK=0 DAT=0.
* exit with CE=1 and TODO timing met
*
*        v-------------- send pattern ---------------------V
* CE   L HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH H
* CLK  L LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL L
* DAT  z zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz z
*      ^-assumed on entry            xsition(if any) on exit-^
*
*        -------------------------------------------------->
*        3us
*
*        v-------------- send pattern ---------------------V
* CE   H HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH H
* CLK  L LLLHHHLLLHHHLLLHHHLLLHHHLLLHHHLLLHHHLLLHHHLLLHHHHHH L
* DAT  z 000000111111222222333333444444555555666666777777zzz z
*      ^-assumed on entry            xsition(if any) on exit-^
*
*        <-> 1us high and low time on CLK
*
                    pshs      a
                    lda       #GPDAT0
                    sta       GPIOADR             select dat0
                    lda       #RTCCE              assert CE
                    sta       GPIODAT

                    bsr       wait1us
                    bsr       wait1us
                    bsr       wait1us

                    puls      a
                    bra       putbyte


********************************************************************
putbyte
*
* in:       A=data byte to send
* out:      none
* modifies: A B CC X
*
*        v-------------- send pattern ---------------------V
* CE   H HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH H
* CLK  L LLLHHHLLLHHHLLLHHHLLLHHHLLLHHHLLLHHHLLLHHHLLLHHHHHH L
* DAT  z 000000111111222222333333444444555555666666777777zzz z
*      ^-assumed on entry            xsition(if any) on exit-^
*
*        <-> 1us high and low time on CLK
*
                    ldb       #GPDDR1
                    stb       GPIOADR             select ddr1
                    clr       GPIODAT             CE out, CLK out, DAT out.

                    ldb       #GPDAT0
                    stb       GPIOADR             select dat0

                    ldx       #8                  number of bits to send
pblop
                    tfr       a,b
                    andb      #$1                 keep LSB
                    orb       #RTCCE              LSB with CLK=0, CE=1
                    stb       GPIODAT             send out data bit with CLK=0
                    bsr       wait1us
                    eorb      #RTCCLK             set CLK=1
                    stb       GPIODAT             send out data bit with CLK=1
                    bsr       wait1us
                    rora                          put next bit in LSB position
                    leax      -1,x
                    bne       pblop               more bits?

                    ldb       #GPDDR1
                    stb       GPIOADR             select ddr1
                    ldb       #1
                    stb       GPIODAT             DAT to input ie z.
                    bsr       wait1us

                    lda       #GPDAT0
                    sta       GPIOADR             select dat0
                    lda       #RTCCE
                    sta       GPIODAT             falling edge on CLK, keep CE=1.

                    rts


********************************************************************
getbyte
*
* in:       none
* out:      A=data byte read
* modifies: A B CC X
*
*        v-------------- send pattern ------------------V
* CE   H HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH H
* CLK  L LLLHHHLLLHHHLLLHHHLLLHHHLLLHHHLLLHHHLLLHHHLLLHHH L
* DAT  z 000000111111222222333333444444555555666666777777 0
*      ^-assumed on entry         xsition(if any) on exit-^
*
* at entry falling edge has already occurred that will yield
* the first data bit.
* at exit falling edge has already occurred that will yield
* the first data bit of the next byte. It's no problem if
* no "next byte" is needed; taking CE high will stop everything
* politely.
*
                    ldb       #GPDAT0
                    stb       GPIOADR             select dat0

                    ldx       #8                  number of bits to receive
gblop
                    bsr       wait1us             wait with clock low
                    ldb       #RTCCE|RTCCLK
                    stb       GPIODAT             set CLK=1
                    ldb       GPIODAT             get DAT in LSB
                    *         first               incoming bit is bit 0 and will rotate
                    *         all                 the way down to LSB of A
                    rorb                          rotate bit from B into C
                    rora                          rotate bit from C into A
                    bsr       wait1us             wait with clock high
                    ldb       #RTCCE
                    stb       GPIODAT             set CLK=0

                    leax      -1,x
                    bne       gblop               more bits?
                    rts


********************************************************************
wait1us
*
* wait for 1us (includes call/return time)
* in:       none
* out:      none
* modifies: none
                    nop       [NAC                HACK 2015Nov13] tune..
                    nop
                    nop
                    nop
                    nop
                    rts


********************************************************************
* all done here folks
                    emod
eom                 equ       *
                    end

