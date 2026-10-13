********************************************************************
* wildspeed - CPU speed meter for the Wildbits machines
*
* Method (edition 3): fixed-time, counted-work, per bus-cycle CLASS.
* For each class, align on an RTC second edge, then run calibrated
* chunks of a cycle-counted inner loop, counting chunks until the RTC
* reaches the edge exactly TESTSECS seconds later. The effective MHz
* of that class follows from chunks completed:
*
*   MHz*100 = hi16( chunks * FACTOR + $8000 )   (rounded)
*   FACTOR  = round( 65536 * cycles/chunk / (TESTSECS*10000) )
*
* Classes (what the inner loop's bus cycles are made of):
*   fetch   nop/nop/leay/bne         opcode fetches + internal cycles
*   RAM rd  8 x lda ,x               RAM data reads (plus fetches)
*   RAM wr  8 x sta ,x               RAM data writes (plus fetches)
*   IO rd   8 x lda >MATH_MUL_A      fixed-IO reads (full-length frames)
*   IO wr   8 x sta >MATH_MUL_A      fixed-IO writes (same value back)
*   RTC rd  8 x lda ,x  (RTC_SEC)    external-bus reads (RDY-stretched)
*   intern  8 x mul                  internal (dead) cycles: 10 of MUL's 11
*                                    cycles never touch the bus, so this class
*                                    approaches the core's internal-cycle rate
*
* A stock core runs every bus cycle in a 32-tick frame (6.29 MHz), so all
* seven classes read 6.29. Turbo cores shorten some frame types (coast,
* pure-RAM read, pure-RAM write) and leave the rest at 32 ticks; the
* per-class numbers show which. "Perceived" is a weighted blend for a
* typical instruction mix: fetch 45%, RAM rd 25%, RAM wr 12%, IO rd 6%,
* IO wr 4%, RTC 3%, internal (mul) 5%.
*
* IRQs are MASKED for each window, so no tick/driver ISR time pollutes
* the count - the OS software clock ends ~6*TESTSECS s slow
* (setime/ntptime to resync). Remaining error: one-chunk edge
* quantization (~0.2%) plus the RTC crystal itself. The IO classes read
* and write MATH_MUL_A (the multiplier's operand, no side effect).
* Edition 6 (2026-10-10): they used the interrupt mask, but the interrupt
* controller drops any event in the clock of a write to $FE20-$FE2F
* (IRQ_Controller_Jr.v), and the Jr2 PS/2 keyboard interrupt is one
* pulse per FIFO empty->non-empty: a lost one left the keyboard out of
* sync after the run. The K2's keyboard interrupt is a level and recovers.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      2026/08/21  fixed-time counted-work rewrite; r2: exact
*                      epilogue accounting + IRQ-masked window
*   3      2026/09/03  per-class benchmark (fetch, RAM r/w, IO r/w,
*                      RTC) + weighted perceived-speed blend
*   4      2026/10/07  internal-cycle class (8 x mul), measured like
*                      the others; not part of the perceived blend
*   5      2026/10/07  internal class joins the perceived blend at 5%
*                      (fetch 50% -> 45%)
                nam       wildspeed
                ttl       wildspeed

                ifp1
                use       defsfile
                endc

tylg            set       Prgrm+Objct
atrv            set       ReEnt+rev
rev             set       $00
edition         set       6

TESTSECS        equ       3                   RTC seconds per class window
NCLASS          equ       7

* Epilogue (identical for every class, counted once):
*   ldd 5 + addd 4 + std 5 + ldx 3 + lda 5 + ora 2 + sta 5 + lda 5
*   + ldb 5 + andb 2 + stb 5 + cmpa 4 + bne 3 = 53
EPI             equ       53

* ---- per-class chunk geometry: iterations, cycles/iteration, prologue cycles
* fetch : ldy #N (4) | nop 2 nop 2 leay 5 bne 3 = 12
I_FET           equ       2333
C_FET           equ       I_FET*12+4+EPI
* RAM rd: leax Scratch,u (5) ldy #N (4) | 8 x lda ,x (4) + leay 5 + bne 3 = 40
I_RAM           equ       700
C_RAM           equ       I_RAM*40+9+EPI
* RAM wr: same geometry as RAM rd
* IO rd : ldy #N (4) | 8 x lda >ext (5) + 8 = 48
I_IO            equ       583
C_IORD          equ       I_IO*48+4+EPI
* IO wr : lda >ext (5) ldy #N (4) | 8 x sta >ext (5) + 8 = 48
C_IOWR          equ       I_IO*48+9+EPI
* RTC rd: ldx #RTC_SEC (3) ldy #N (4) | 8 x lda ,x (4) + 8 = 40
C_RTC           equ       I_RAM*40+7+EPI
* intern: ldy #N (4) | 8 x mul (11) + leay 5 + bne 3 = 96
I_MUL           equ       292
C_MUL           equ       I_MUL*96+4+EPI

* FACTOR = round(65536*C/(TESTSECS*10000)); lwasm evaluates in 32 bits
F_FET           equ       (65536*C_FET+(TESTSECS*5000))/(TESTSECS*10000)
F_RAM           equ       (65536*C_RAM+(TESTSECS*5000))/(TESTSECS*10000)
F_IORD          equ       (65536*C_IORD+(TESTSECS*5000))/(TESTSECS*10000)
F_IOWR          equ       (65536*C_IOWR+(TESTSECS*5000))/(TESTSECS*10000)
F_RTC           equ       (65536*C_RTC+(TESTSECS*5000))/(TESTSECS*10000)
F_MUL           equ       (65536*C_MUL+(TESTSECS*5000))/(TESTSECS*10000)

* perceived-speed weights (sum 100)
W_FET           equ       45
W_RAMRD         equ       25
W_RAMWR         equ       12
W_IORD          equ       6
W_IOWR          equ       4
W_RTC           equ       3
W_MUL           equ       5

                mod     eom,name,tylg,atrv,start,size

Scratch         rmb     1                   RAM byte for the rd/wr classes (8-bit offset from U)
StartSec        rmb     1                   RTC second at aligned start (BCD)
TargetSec       rmb     1                   BCD second that ends the run
Chunks          rmb     2                   completed chunk count
Result          rmb     2*NCLASS            MHz*100 per class
Acc             rmb     4                   32-bit accumulator (blend)
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

* ================= class 0: fetch / internal =================
                lbsr    Align
chunk0@         ldy     #I_FET              4
inner0@         nop                         2
                nop                         2
                leay    -1,y                5
                bne     inner0@             3  => 12/iteration
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
                cmpa    <TargetSec          4
                bne     chunk0@             3
                ldx     #F_FET
                lbsr    Finish
                std     <Result+0

* ================= class 1: RAM read =================
                lbsr    Align
chunk1@         leax    Scratch,u           5
                ldy     #I_RAM              4
inner1@         lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                leay    -1,y                5
                bne     inner1@             3  => 40/iteration
                ldd     <Chunks
                addd    #1
                std     <Chunks
                ldx     #$FE40
                lda     RTC_CTRL,x
                ora     #(RTC_UTI|RTC_24HR)
                sta     RTC_CTRL,x
                lda     RTC_SEC,x
                ldb     RTC_CTRL,x
                andb    #^(RTC_UTI)
                stb     RTC_CTRL,x
                cmpa    <TargetSec
                bne     chunk1@
                ldx     #F_RAM
                lbsr    Finish
                std     <Result+2

* ================= class 2: RAM write =================
                lbsr    Align
chunk2@         leax    Scratch,u           5
                ldy     #I_RAM              4
inner2@         sta     ,x                  4
                sta     ,x                  4
                sta     ,x                  4
                sta     ,x                  4
                sta     ,x                  4
                sta     ,x                  4
                sta     ,x                  4
                sta     ,x                  4
                leay    -1,y                5
                bne     inner2@             3  => 40/iteration
                ldd     <Chunks
                addd    #1
                std     <Chunks
                ldx     #$FE40
                lda     RTC_CTRL,x
                ora     #(RTC_UTI|RTC_24HR)
                sta     RTC_CTRL,x
                lda     RTC_SEC,x
                ldb     RTC_CTRL,x
                andb    #^(RTC_UTI)
                stb     RTC_CTRL,x
                cmpa    <TargetSec
                bne     chunk2@
                ldx     #F_RAM
                lbsr    Finish
                std     <Result+4

* ================= class 3: fixed-IO read =================
                lbsr    Align
chunk3@         ldy     #I_IO               4
inner3@         lda     >MATH_MUL_A         5
                lda     >MATH_MUL_A         5
                lda     >MATH_MUL_A         5
                lda     >MATH_MUL_A         5
                lda     >MATH_MUL_A         5
                lda     >MATH_MUL_A         5
                lda     >MATH_MUL_A         5
                lda     >MATH_MUL_A         5
                leay    -1,y                5
                bne     inner3@             3  => 48/iteration
                ldd     <Chunks
                addd    #1
                std     <Chunks
                ldx     #$FE40
                lda     RTC_CTRL,x
                ora     #(RTC_UTI|RTC_24HR)
                sta     RTC_CTRL,x
                lda     RTC_SEC,x
                ldb     RTC_CTRL,x
                andb    #^(RTC_UTI)
                stb     RTC_CTRL,x
                cmpa    <TargetSec
                bne     chunk3@
                ldx     #F_IORD
                lbsr    Finish
                std     <Result+6

* ================= class 4: fixed-IO write (MATH_MUL_A, its own value back) =================
                lbsr    Align
chunk4@         lda     >MATH_MUL_A         5  its current value
                ldy     #I_IO               4
inner4@         sta     >MATH_MUL_A         5
                sta     >MATH_MUL_A         5
                sta     >MATH_MUL_A         5
                sta     >MATH_MUL_A         5
                sta     >MATH_MUL_A         5
                sta     >MATH_MUL_A         5
                sta     >MATH_MUL_A         5
                sta     >MATH_MUL_A         5
                leay    -1,y                5
                bne     inner4@             3  => 48/iteration
                ldd     <Chunks
                addd    #1
                std     <Chunks
                ldx     #$FE40
                lda     RTC_CTRL,x
                ora     #(RTC_UTI|RTC_24HR)
                sta     RTC_CTRL,x
                lda     RTC_SEC,x
                ldb     RTC_CTRL,x
                andb    #^(RTC_UTI)
                stb     RTC_CTRL,x
                cmpa    <TargetSec
                bne     chunk4@
                ldx     #F_IOWR
                lbsr    Finish
                std     <Result+8

* ================= class 5: RTC read (external bus, RDY-stretched) =================
                lbsr    Align
chunk5@         ldx     #$FE40+RTC_SEC      3
                ldy     #I_RAM              4
inner5@         lda     ,x                  4  (bus-stretched by the RTC RDY)
                lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                lda     ,x                  4
                leay    -1,y                5
                bne     inner5@             3  => 40/iteration (nominal)
                ldd     <Chunks
                addd    #1
                std     <Chunks
                ldx     #$FE40
                lda     RTC_CTRL,x
                ora     #(RTC_UTI|RTC_24HR)
                sta     RTC_CTRL,x
                lda     RTC_SEC,x
                ldb     RTC_CTRL,x
                andb    #^(RTC_UTI)
                stb     RTC_CTRL,x
                cmpa    <TargetSec
                bne     chunk5@
                ldx     #F_RTC
                lbsr    Finish
                std     <Result+10

* ================= class 6: internal (dead) cycles =================
                lbsr    Align
chunk6@         ldy     #I_MUL              4
inner6@         mul                         11
                mul                         11
                mul                         11
                mul                         11
                mul                         11
                mul                         11
                mul                         11
                mul                         11
                leay    -1,y                5
                bne     inner6@             3  => 96/iteration
                ldd     <Chunks
                addd    #1
                std     <Chunks
                ldx     #$FE40
                lda     RTC_CTRL,x
                ora     #(RTC_UTI|RTC_24HR)
                sta     RTC_CTRL,x
                lda     RTC_SEC,x
                ldb     RTC_CTRL,x
                andb    #^(RTC_UTI)
                stb     RTC_CTRL,x
                cmpa    <TargetSec
                bne     chunk6@
                ldx     #F_MUL
                lbsr    Finish
                std     <Result+12

* ================= report =================
                leay    L_fet,pcr
                ldd     <Result+0
                lbsr    Line
                leay    L_ramrd,pcr
                ldd     <Result+2
                lbsr    Line
                leay    L_ramwr,pcr
                ldd     <Result+4
                lbsr    Line
                leay    L_iord,pcr
                ldd     <Result+6
                lbsr    Line
                leay    L_iowr,pcr
                ldd     <Result+8
                lbsr    Line
                leay    L_rtc,pcr
                ldd     <Result+10
                lbsr    Line
                leay    L_mul,pcr
                ldd     <Result+12
                lbsr    Line

* perceived = sum(w_i * mhz100_i) / 100, accumulated in 32 bits
                clra
                clrb
                std     <Acc
                std     <Acc+2
                ldd     <Result+0
                ldx     #W_FET
                lbsr    AccMul
                ldd     <Result+2
                ldx     #W_RAMRD
                lbsr    AccMul
                ldd     <Result+4
                ldx     #W_RAMWR
                lbsr    AccMul
                ldd     <Result+6
                ldx     #W_IORD
                lbsr    AccMul
                ldd     <Result+8
                ldx     #W_IOWR
                lbsr    AccMul
                ldd     <Result+10
                ldx     #W_RTC
                lbsr    AccMul
                ldd     <Result+12
                ldx     #W_MUL
                lbsr    AccMul
* divide the 32-bit Acc by 100 (result < 65536): repeated subtraction, quotient in X
                ldx     #0
div@            ldd     <Acc+2
                subd    #100
                std     <Acc+2
                lda     <Acc+1
                sbca    #0
                sta     <Acc+1
                lda     <Acc
                sbca    #0
                sta     <Acc
                bcs     divdone@            went negative: X holds the quotient
                leax    1,x
                bra     div@
divdone@        tfr     x,d
                leay    L_perc,pcr
                lbsr    Line
                leay    L_note,pcr
                lbsr    tobuf
                lbsr    wrbuf

                clrb
                os9     F$Exit

* =============================================
* Align: mask IRQs, spin to an RTC second edge, set TargetSec, zero Chunks.
Align               orcc    #IntMasks
                    lbsr    GetRTCraw           A = current RTC second, BCD
                    sta     <StartSec
al@                 lbsr    GetRTCraw
                    cmpa    <StartSec
                    beq     al@                 spin until the second rolls
                    sta     <StartSec           this instant is t=0
                    lbsr    bcd2binA            B = binary seconds
                    addb    #TESTSECS
                    cmpb    #60
                    blo     tgt@
                    subb    #60
tgt@                tfr     b,a
                    lbsr    bin2bcd             A = target as BCD
                    sta     <TargetSec
                    clra
                    clrb
                    std     <Chunks
                    rts

* Finish: IRQs back on; D = round( Chunks * X / 65536 ) = MHz*100
Finish              andcc   #^IntMasks
                    ldd     <Chunks
                    lbsr    Mul16               D = hi16 of the product
                    pshs    d
                    ldd     <Prod+2             low word decides rounding
                    cmpd    #$8000
                    puls    d
                    blo     nornd@
                    addd    #1
nornd@              rts

* AccMul: Acc += D * X (product < 2^24)
AccMul              lbsr    Mul16               Prod = 32-bit product
                    ldd     <Prod+2
                    addd    <Acc+2
                    std     <Acc+2
                    ldd     <Prod
                    adcb    <Acc+1
                    stb     <Acc+1
                    adca    <Acc
                    sta     <Acc
                    rts

* Line: print label at Y then D (MHz*100) as "nn.nn MHz"
Line                pshs    d
                    lbsr    tobuf
                    puls    d
                    tfr     d,x
                    lda     #100
                    lbsr    Div16x8             X = integer MHz, B = fraction
                    pshs    b
                    tfr     x,d
                    tfr     b,a
                    lbsr    Byte2Dig
                    ldd     <DecBuf
                    std     <IntBuf
                    puls    a
                    lbsr    Byte2Dig            DecBuf = fraction digits
                    lda     <IntBuf
                    cmpa    #$30                suppress a leading zero
                    bne     tens@
                    lda     #$20
tens@               lbsr    bufchr
                    lda     <IntBuf+1
                    lbsr    bufchr
                    lda     #$2E
                    lbsr    bufchr
                    lda     <DecBuf
                    lbsr    bufchr
                    lda     <DecBuf+1
                    lbsr    bufchr
                    leay    mhztxt,pcr
                    lbsr    tobuf
                    lbra    wrbuf

* =============================================
* Read raw BCD RTC seconds into A; preserves X.
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
BDDone  adda    #$30
        sta     <DecBuf+1               ones
        tfr     b,a
        adda    #$30
        sta     <DecBuf                 tens
        rts

* =============================================
* Data
Banner  fcc     "=== Wildbits 6809 speed meter, ed."
        fcb     '0+edition          the module edition (1-9)
        fcc     ": per bus-cycle class ==="
        fcb     $0D
BannerLen equ   *-Banner
MsgRunning fcc  "Seven classes x 3 RTC seconds each, IRQs masked (about 29 s)..."
        fcb     $0D
MsgRunningLen equ *-MsgRunning

L_fet   fcs     "fetch/internal (nop,nop,leay,bne) : "
L_ramrd fcs     "RAM read       (8 x lda ,x)       : "
L_ramwr fcs     "RAM write      (8 x sta ,x)       : "
L_iord  fcs     "IO read        (8 x lda >FEE0)    : "
L_iowr  fcs     "IO write       (8 x sta >FEE0)    : "
L_rtc   fcs     "RTC/ext-bus rd (8 x lda RTC_SEC)  : "
L_mul   fcs     "internal       (8 x mul)          : "
L_perc  fcs     "perceived (45/25/12/6/4/3/5 blend): "
L_note  fcs     "(software clock is now ~21 s slow: setime or ntptime to resync)"
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
