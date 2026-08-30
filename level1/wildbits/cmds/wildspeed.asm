********************************************************************
* wildspeed - CPU speed meter for the Wildbits machines
*
* Method (edition 2): fixed-time, counted-work. Align on an RTC second
* edge, then run calibrated 4096-iteration chunks of a 12-cycle inner
* loop, counting chunks until the RTC reaches the edge exactly 5
* seconds later. MHz follows from chunks completed:
*
*   cycles/chunk = 4096*12 + 56 (exact, cycle-counted epilogue) = 49208
*   MHz*100      = hi16( chunks * 64498 + $8000 )   (rounded)
*                  (64498 = round(65536*49208/50000))
*
* Timing edges: RTC seconds register, raw BCD compares (fixed-cost
* hardware poll, no syscalls, no data-dependent conversion in the
* loop). IRQs are MASKED for the whole 5s window, so no tick/driver
* ISR time pollutes the count - the OS software clock ends ~5s slow
* (setime/ntptime to resync). Remaining error: one-chunk edge
* quantization (~0.16%) plus the RTC crystal itself.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      2026/08/21  fixed-time counted-work rewrite; r2: exact
*                      epilogue accounting + IRQ-masked window
                nam       wildspeed
                ttl       wildspeed

                ifp1
                use       defsfile
                endc

tylg            set       Prgrm+Objct
atrv            set       ReEnt+rev
rev             set       $00
edition         set       2

CHUNKITER       equ       4096                inner iterations per chunk
* cycles/chunk = 4096*12 inner + 56 exact overhead (counted below) = 49208
* MHZFACTOR    = round(65536*49208/50000) = 64498
MHZFACTOR       equ       64498
TESTSECS        equ       5

                mod     eom,name,tylg,atrv,start,size

StartSec        rmb     1                   RTC second at aligned start (BCD)
TargetSec       rmb     1                   BCD second that ends the run
Chunks          rmb     2                   completed chunk count
MulA            rmb     2                   multiplicand scratch
MulB            rmb     2                   multiplier scratch
Prod            rmb     4                   32-bit product
Rem             rmb     1                   Div16x8 remainder scratch
DecBuf          rmb     2                   two ASCII digits (Byte2Dig out)
IntBuf          rmb     2                   integer-part ASCII digits
bufstrt         rmb     2
bufcur          rmb     2
linebuf         rmb     80
                rmb     250                 stack
size            equ     .

name            fcs     /wildspeed/
                fcb     edition

start           leax    linebuf,u           output buffer address
                stx     <bufstrt
                stx     <bufcur

                leax    Banner,pcr
                lda     #1
                ldy     #BannerLen
                os9     I$WritLn

                leax    MsgRunning,pcr
                lda     #1
                ldy     #MsgRunningLen
                os9     I$WritLn

* --- measure with IRQs masked: no tick/driver ISR time in the count.
* The RTC runs in hardware regardless. The OS misses ~TESTSECS*60 ticks,
* so its software clock ends ~5s slow (setime/ntptime to resync).
                orcc    #IntMasks

* --- align on an RTC second edge (raw BCD compares) ---
                lbsr    GetRTCraw           A = current RTC second, BCD
                sta     <StartSec
align@          lbsr    GetRTCraw
                cmpa    <StartSec
                beq     align@              spin until the second rolls
                sta     <StartSec           this instant is t=0
* target = (start + TESTSECS) mod 60, in binary, then back to BCD
                lbsr    bcd2binA            B = binary seconds
                addb    #TESTSECS
                cmpb    #60
                blo     tgt@
                subb    #60
tgt@            tfr     b,a
                lbsr    bin2bcd             A = target as BCD
                sta     <TargetSec

                clra
                clrb
                std     <Chunks

* --- counted work: 12-cycle inner loop, CHUNKITER iterations/chunk ---
* Chunk overhead is EXACT and folded into MHZFACTOR - keep in sync:
*   ldx 3 + 4096*12 + ldd 5 + addd 4 + std 5 + ldx 3 + lda 5 + ora 2
*   + sta 5 + lda 5 + ldb 5 + andb 2 + stb 5 + cmpa 4 + bne 3 = 49208
chunk@          ldx     #CHUNKITER          3
inner@          nop                         2 cycles
                nop                         2
                leax    -1,x                5
                bne     inner@              3  => 12 cycles/iteration
                ldd     <Chunks             5
                addd    #1                  4
                std     <Chunks             5
                ldx     #$FE40              3
                lda     RTC_CTRL,x          5
                ora     #(RTC_UTI|RTC_24HR) 2  latch registers
                sta     RTC_CTRL,x          5
                lda     RTC_SEC,x           5  BCD seconds
                ldb     RTC_CTRL,x          5
                andb    #^(RTC_UTI)         2  unlatch
                stb     RTC_CTRL,x          5
                cmpa    <TargetSec          4  raw BCD compare
                bne     chunk@              3  not 5 seconds yet
                andcc   #^IntMasks          measurement done: IRQs back on

* --- MHz*100 = hi16( Chunks * MHZFACTOR ), rounded ---
                ldd     <Chunks
                ldx     #MHZFACTOR
                lbsr    Mul16               D = hi16 of the product
                pshs    d
                ldd     <Prod+2             low word decides rounding
                cmpd    #$8000
                puls    d
                blo     nornd@
                addd    #1                  round the hi word up
nornd@          equ     *

* split into integer and fraction
                tfr     d,x
                lda     #100
                lbsr    Div16x8             X = integer MHz, B = fraction
                pshs    b                   save fraction (0-99)
                tfr     x,d
                tfr     b,a                 integer MHz (shown as 2 digits)
                lbsr    Byte2Dig
                ldd     <DecBuf
                std     <IntBuf
                puls    a
                lbsr    Byte2Dig            DecBuf = fraction digits

                lda     <IntBuf
                cmpa    #'0'                suppress a leading zero
                beq     ones@
                lbsr    bufchr
ones@           lda     <IntBuf+1
                lbsr    bufchr
                lda     #'.'
                lbsr    bufchr
                lda     <DecBuf
                lbsr    bufchr
                lda     <DecBuf+1
                lbsr    bufchr
                leay    mhztxt,pcr
                lbsr    tobuf
                lbsr    wrbuf

                clrb
                os9     F$Exit

* =============================================
* Read raw BCD RTC seconds into A; preserves X.
* Toggle UTI to latch the external registers, read, untoggle.
GetRTCraw           pshs      x,b
                    ldx       #$FE40              RTC base address
                    lda       RTC_CTRL,x
                    ora       #(RTC_UTI|RTC_24HR) UTI on: latch registers
                    sta       RTC_CTRL,x
                    ldb       RTC_SEC,x           BCD seconds
                    lda       RTC_CTRL,x
                    anda      #^(RTC_UTI)         UTI off again
                    sta       RTC_CTRL,x
                    tfr       b,a
                    puls      x,b,pc

* Convert BCD in A to binary in B.
bcd2binA            clrb
loop@               cmpa      #$10
                    bcs       out@
                    addd      #$F00A              A -= $10, B += 10
                    bra       loop@
out@                pshs      a
                    addb      ,s+
                    rts

* Convert binary A (0-59) to BCD in A.
bin2bcd             pshs      b
                    clrb
b2loop@             cmpa      #10
                    bcs       b2out@
                    suba      #10
                    addb      #$10                bump tens nibble
                    bra       b2loop@
b2out@              pshs      b
                    adda      ,s+
                    puls      b,pc

* =============================================
* Mul16: D * X -> 32-bit product in Prod; returns hi 16 bits in D.
Mul16
        std     <MulA
        stx     <MulB
        clr     <Prod
        clr     <Prod+1
        lda     <MulA+1
        ldb     <MulB+1
        mul                             lo*lo
        std     <Prod+2
        lda     <MulA
        ldb     <MulB+1
        mul                             hi*lo -> middle
        addd    <Prod+1
        std     <Prod+1
        bcc     m1@
        inc     <Prod
m1@     lda     <MulA+1
        ldb     <MulB
        mul                             lo*hi -> middle
        addd    <Prod+1
        std     <Prod+1
        bcc     m2@
        inc     <Prod
m2@     lda     <MulA
        ldb     <MulB
        mul                             hi*hi -> top
        addd    <Prod
        std     <Prod
        ldd     <Prod                   D = hi16
        rts

* =============================================
* Div16x8: divide 16-bit X by 8-bit A.
* Returns: X = quotient, B = remainder.
Div16x8
        pshs    a                       save divisor
        clr     <Rem
        ldb     #16
DivLoop
        pshs    x
        lsl     1,s                     shift low byte left
        rol     0,s                     rotate high byte left
        puls    x
        rol     <Rem                    old MSB of X into remainder
        lda     <Rem
        cmpa    ,s
        blo     DivSkip
        suba    ,s
        sta     <Rem
        leax    1,x                     set quotient bit
DivSkip
        decb
        bne     DivLoop
        ldb     <Rem
        puls    a,pc

* =============================================
* Byte2Dig: A (0-99) -> two ASCII digits in DecBuf (tens, ones).
Byte2Dig
        clrb
BD10    cmpa    #10
        blo     BDDone
        suba    #10
        incb
        bra     BD10
BDDone  adda    #'0'
        sta     <DecBuf+1               ones
        tfr     b,a
        adda    #'0'
        sta     <DecBuf                 tens
        rts

* =============================================
* Data
Banner  fcc     "=== Foenix F256 FNX6809 MHz Meter (5s counted-work) ==="
        fcb     $0D
BannerLen equ   *-Banner

MsgRunning fcc  "Counting for 5 RTC seconds (tick ISR time included)..."
        fcb     $0D
MsgRunningLen equ *-MsgRunning

mhztxt  fcs     / MHz/

* Store A at next position in output buffer.
bufchr              pshs      x
                    ldx       <bufcur
                    sta       ,x+
                    stx       <bufcur
                    puls      pc,x

* Append CR to the output buffer then print the output buffer.
wrbuf               pshs      y,x,a
                    lda       #C$CR
                    bsr       bufchr
                    ldx       <bufstrt
                    stx       <bufcur
                    ldy       #80
                    lda       #$01
                    os9       I$WritLn
                    puls      pc,y,x,a

* Append string at Y to output buffer.  Terminated by MSB=1.
tobuf               pshs      a
bufloop             lda       ,y
                    anda      #$7F
                    bsr       bufchr
                    tst       ,y+
                    bpl       bufloop
                    puls      a
                    rts

                emod
eom             equ *
                end
