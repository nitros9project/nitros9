********************************************************************
* linetest - TinyVicky line-drawing engine: which pixels go missing? (2026-09-22)
*
* Allocates a bitmap screen (SS.AScrn), clears its first two blocks (rows 0-50 of a 320-byte-a-row
* bitmap), DISPLAYS it with the text overlaid (SS.DScrn, dmashow's flags - vtio points BM0 at it), turns
* the line engine on ($FFCA b0) and draws five lines with the engine (regs at I/O page $C0 offset $1080:
* ctrl, color, X0.hi, X0.lo, X1.hi, X1.lo, Y0, Y1; ctrl b0 enable, b1 go, b4 FIFO reset; b7 reads 1 when
* the Bresenham pass is DONE, +2/+3 read the pixel FIFO count - the pixels land later, on odd scan lines):
*   corner to corner (0,0)-(319,239) first (cls before and after), then
*   horizontal (0,49)-(319,49)   vertical (100,0)-(100,47)   diagonal 45 deg (0,0)-(45,45)
*   shallow 1:4 (120,20)-(220,45)   steep 4:1 (280,0)-(292,48)   - none crosses another
* then reads the bytes back through the CPU's map and prints, per line, found/expected pixels and, when
* short, how many are missing and the first missing pixel's x,y. The set runs FOUR times:
* in the 320-wide 8-bit mode and again in the 640-wide 4-bit mode (VKY_GFX_MODE b0 HIRES4: the engine
* writes one nibble per logical pixel on rc17_line_5), each with PASS A (the CPU polls
* the registers while the engine draws) and PASS B (the CPU sleeps). Every wait is bounded in time.
* Exact expectation: a Bresenham line has max(|dx|,|dy|)+1 pixels.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* ------------------------------------------------------------------
*   1      2026/09/22  Claude
* Created (user: 'the cores have a bug in line drawing? missing pixels').
*   2      2026/09/22  Claude
* dec16 compared a runtime address with an assembly-time offset (a hang); bounded FIFO wait.
*   4      2026/09/23  Codex
* True 640-pixel endpoints and per-nibble readback for rc17_line_5.
*   3      2026/09/23  Claude
* The screen is displayed (text overlaid); vtio sets BM0 up; waits bounded in TIME for both
* passes (the sleeping pass could run 17 minutes); the 640-wide HIRES4 mode added (user).
* ed.3b: the map loops loaded X with a coordinate while X was the line-buffer pointer mark writes
* through - the marks went to addresses 0-319 of the process (a crash). D carries the coordinates.

                    nam       linetest
                    ttl       line-drawing engine pixel-loss test

                    ifp1
                    use       defsfile
                    endc

IOBLK               equ       $C0                 the I/O page holding VICKY's line registers
CLUTBLK             equ       $C1                 the I/O page holding CLUT 0 at offset $1000 (B,G,R,A an entry)
CLUT0               equ       $1000
LDREGS              equ       $1080               the line engine: ctrl, color, x0h, x0l, x1h, x1l, y0, y1
LD_CTRL             equ       0
LD_COLOR            equ       1
LD_FIFOH            equ       2                   read: FIFO pixel count [12:8]
LD_FIFOL            equ       3                   read: FIFO pixel count [7:0]
LD_X0H              equ       2                   write
LD_X0L              equ       3
LD_X1H              equ       4
LD_X1L              equ       5
LD_Y0               equ       6
LD_Y1               equ       7
LD_ENABLE           equ       $01
LD_GO               equ       $02
LDMASTER            equ       $FFCA               TXT.Base+$0A: b0 = the line engine enable (VKY_DRAWLINE_CTRL on wb/nitrobotics)
GFXMODE             equ       $FFCB               VKY_GFX_MODE_REG: b0 = HIRES4, 640 x 240 at four bits a dot
INK                 equ       $77                 8bpp ink $77; 4bpp engine uses its low nibble (7)
ROWBYTES            equ       320
POLLHI              equ       16                  pass A: x 65536 polling laps (~2.7 s) before a wait gives up
SLEEPS              equ       120                 pass B: one-tick sleeps (2 s) before a wait gives up

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       4

                    mod       eom,name,tylg,atrv,start,size

                    org       0
bmblock             rmb       2                   the screen's first physical block (word: X)
bmmap               rmb       2                   the CPU view of two of its blocks (chunk,u says which)
chunk               rmb       1                   which pair of blocks bmmap shows: 0 = blocks 0-1 (rows 0-51) .. 4 = blocks 8-9
iomap               rmb       2                   the CPU view of I/O page $C0
clutmap             rmb       2                   the CPU view of I/O page $C1 (CLUT 0)
oldclut             rmb       8                   CLUT 0 entries 7 and $77 as found
oldmaster           rmb       1
oldlayers           rmb       2
oldline             rmb       1
oldgfx              rmb       1
screenno            rmb       2
owned               rmb       1
pass                rmb       1                   'A' polling, 'B' sleeping
width               rmb       2                   320 or 640 logical pixels
mode                rmb       1                   0 = 320 8-bit, 1 = 640 HIRES4
found               rmb       2
want                rmb       2
polls               rmb       1
laps                rmb       2
x0                  rmb       2
y0                  rmb       1
x1                  rmb       2
y1                  rmb       1
cx                  rmb       2                   scan scratch
cy                  rmb       1
firstx              rmb       2                   the first missing pixel of the line, $FFFF = none
firsty              rmb       1
dflag               rmb       1                   dec16
dig                 rmb       1
dcnt                rmb       1
colcnt              rmb       640                 the corner line: pixels found in each column
line                rmb       90
stack               rmb       300
size                equ       .

name                fcs       /linetest/
                    fcb       edition

t0                  fcc       /linetest ed.4: five engine lines into a fresh bitmap, read back by the CPU/
                    fcb       C$CR
t0l                 equ       *-t0
tm320               fcc       /== 320 x 240, 8 bits a dot ==/
                    fcb       C$CR
tm320l              equ       *-tm320
tm640               fcc       /== 640 x 240, 4 bits a dot (HIRES4) ==/
                    fcb       C$CR
tm640l              equ       *-tm640
tpa                 fcc       /PASS A: the CPU polls the registers while the engine draws/
                    fcb       C$CR
tpal                equ       *-tpa
tpb                 fcc       /PASS B: the CPU sleeps while the engine draws/
                    fcb       C$CR
tpbl                equ       *-tpb
tH6                 fcc       /horizontal (0,49)-(639,49): /
tH6l                equ       *-tH6
tH                  fcc       /horizontal (0,49)-(319,49): /
tHl                 equ       *-tH
tV                  fcc       /vertical (100,0)-(100,47): /
tVl                 equ       *-tV
tD1                 fcc       /diagonal 45 deg (0,0)-(45,45): /
tD1l                equ       *-tD1
tD2                 fcc       /shallow 1:4 (120,20)-(220,45): /
tD2l                equ       *-tD2
tD3                 fcc       /steep 4:1 (280,0)-(292,48): /
tD3l                equ       *-tD3
textra              fcc       / pixels - EXTRA /
textral             equ       *-textra
tcorner             fcc       /corner to corner (0,0)-(319,239): /
tcornerl            equ       *-tcorner
tcorner6            fcc       /corner to corner (0,0)-(639,239): /
tcorner6l           equ       *-tcorner6
tcornerk            fcc       /-- the corner line is on the screen: press a key for the five lines --/
                    fcb       C$CR
tcornerkl           equ       *-tcornerk
tof                 fcc       / of /
tofl                equ       *-tof
tpix                fcc       / pixels/
                    fcb       C$CR
tpixl               equ       *-tpix
tmiss               fcc       / pixels - MISSING /
tmissl              equ       *-tmiss
tfirst              fcc       /, the first at x=/
tfirstl             equ       *-tfirst
tcomma              fcc       / y=/
tcommal             equ       *-tcomma
tsetup              fcc       /setup: line-engine master $FFCA=$/
tsetupl             equ       *-tsetup
tgfx                fcc       / gfx mode $FFCB=$/
tgfxl               equ       *-tgfx
tnodone             fcc       /  (no DONE: ctrl=$/
tnodonel            equ       *-tnodone
tnodrain            fcc       /  (FIFO did not drain: ctrl=$/
tnodrainl           equ       *-tnodrain
tfifo               fcc       / fifo=$/
tfifol              equ       *-tfifo
tclose              fcc       /)/
                    fcb       C$CR
tclosel             equ       *-tclose
tnoscr              fcc       /no bitmap screen could be allocated (SS.AScrn)/
                    fcb       C$CR
tnoscrl             equ       *-tnoscr
tdscrn              fcc       /SS.DScrn error $/
tdscrnl             equ       *-tdscrn
tvid                fcc       /video: master $FFC0=$/
tvidl               equ       *-tvid
tlay                fcc       / layers $FFC2=$/
tlayl               equ       *-tlay
tkey                fcc       /press a key to restore the text screen and exit/
                    fcb       C$CR
tkeyl               equ       *-tkey
tnext               fcc       /-- the lines are on the screen: press a key for the next pass --/
                    fcb       C$CR
tnextl              equ       *-tnext
tstart              fcc       /press a key to draw the corner-to-corner line in this mode/
                    fcb       C$CR
tstartl             equ       *-tstart
tcls                fcb       $0C                 the text screen cleared
tdone               fcc       /done: registers restored, the screen released./
                    fcb       C$CR
tdonel              equ       *-tdone
hexch               fcc       /0123456789ABCDEF/
pow10               fdb       10000,1000,100,10

* ---- set-up ----------------------------------------------------------
start               clr       owned,u
                    clra
                    clrb
                    std       clutmap,u
                    std       iomap,u
                    std       bmmap,u
                    leax      t0,pcr
                    ldy       #t0l
                    lbsr      puts
                    lda       >TXT.Base
                    sta       oldmaster,u
                    ldd       >VKY_LAYER_CTRL_0
                    std       oldlayers,u
                    lda       >LDMASTER
                    sta       oldline,u
                    lda       >GFXMODE
                    sta       oldgfx,u
* a bitmap screen from vtio (dmashow's idiom): X = its first physical block
                    ldy       #0
try@                sty       screenno,u
                    ldx       #0
                    clra
                    ldb       #SS.AScrn
                    os9       I$SetStt
                    bcc       got@
                    cmpb      #E$WADef
                    lbne      noscreen
                    ldy       screenno,u
                    leay      1,y
                    cmpy      #3
                    blo       try@
                    lbra      noscreen
got@                inc       owned,u
                    stx       bmblock,u
* the CPU's view of the first two blocks
                    lda       #0
                    lbsr      mapchunk
                    lbcs      noscreen
                    lbsr      wipe
* the I/O page
                    ldx       #IOBLK
                    ldb       #1
                    pshs      u
                    os9       F$MapBlk
                    tfr       u,x
                    puls      u
                    lbcs      noscreen
                    stx       iomap,u
* the ink visible: CLUT 0 entries 7 (a HIRES4 nibble) and $77 (the 8-bit index) white for the run
                    ldx       #CLUTBLK
                    ldb       #1
                    pshs      u
                    os9       F$MapBlk
                    tfr       u,x
                    puls      u
                    lbcs      noscreen
                    stx       clutmap,u
                    leax      CLUT0+7*4,x
                    ldd       ,x
                    std       oldclut,u
                    ldd       2,x
                    std       oldclut+2,u
                    ldd       #$FFFF
                    std       ,x
                    ldd       #$FF00
                    std       2,x
                    ldx       clutmap,u
                    leax      CLUT0+$77*4,x
                    ldd       ,x
                    std       oldclut+4,u
                    ldd       2,x
                    std       oldclut+6,u
                    ldd       #$FFFF
                    std       ,x
                    ldd       #$FF00
                    std       2,x
* show the screen: graphics with the text overlaid (dmashow's flags) - vtio points BM0 at it
                    ldx       #FX_BM+FX_GRF+FX_OVR+FX_TXT
                    ldy       #FT_OMIT
                    lda       #0
                    ldb       #SS.DScrn
                    os9       I$SetStt
                    bcc       shown@
                    pshs      b
                    lbsr      lbeg
                    leay      tdscrn,pcr
                    ldb       #tdscrnl
                    lbsr      copy
                    puls      b
                    lbsr      hexb
                    lbsr      flush
shown@              lbsr      lbeg
                    leay      tvid,pcr
                    ldb       #tvidl
                    lbsr      copy
                    ldb       >TXT.Base
                    lbsr      hexb
                    leay      tlay,pcr
                    ldb       #tlayl
                    lbsr      copy
                    ldb       >VKY_LAYER_CTRL_0
                    lbsr      hexb
                    ldb       >VKY_LAYER_CTRL_0+1
                    lbsr      hexb
                    lbsr      flush
                    lda       #1
                    sta       >LDMASTER           the line engine on
                    ldx       iomap,u
                    leax      LDREGS,x
                    lda       #LD_ENABLE
                    sta       LD_CTRL,x
                    lda       #INK
                    sta       LD_COLOR,x

* ---- the two modes, two passes each --------------------------------------
                    clr       mode,u
mode@               ldd       #320
                    tst       mode,u
                    beq       widthset@
                    ldd       #640
widthset@           std       width,u
                    leax      tcls,pcr
                    ldy       #1
                    lda       #1
                    os9       I$Write             a fresh text screen for the mode
                    lda       oldgfx,u
                    anda      #^GFX_HIRES4
                    tst       mode,u
                    beq       m320@
                    ora       #GFX_HIRES4
m320@               sta       >GFXMODE
                    leax      tm320,pcr
                    ldy       #tm320l
                    tst       mode,u
                    beq       m1@
                    leax      tm640,pcr
                    ldy       #tm640l
m1@                 lbsr      puts
                    lbsr      lbeg
                    leay      tsetup,pcr
                    ldb       #tsetupl
                    lbsr      copy
                    ldb       >LDMASTER
                    lbsr      hexb
                    leay      tgfx,pcr
                    ldb       #tgfxl
                    lbsr      copy
                    ldb       >GFXMODE
                    lbsr      hexb
                    lbsr      flush
                    lbsr      wipe
                    leax      tstart,pcr
                    ldy       #tstartl
                    lbsr      puts
                    lbsr      getkey
                    lda       #'A
                    sta       pass,u
                    lbsr      corner
                    leax      tcornerk,pcr
                    ldy       #tcornerkl
                    lbsr      puts
                    lbsr      getkey
                    lbsr      wipe
                    leax      tpa,pcr
                    ldy       #tpal
                    lbsr      puts
                    lbsr      onepass
                    lda       #'B
                    sta       pass,u
                    lbsr      wipe
                    leax      tpb,pcr
                    ldy       #tpbl
                    lbsr      puts
                    lbsr      onepass
                    inc       mode,u
                    lda       mode,u
                    cmpa      #2
                    lbne      mode@
* the lines stay on show until a key
                    leax      tkey,pcr
                    ldy       #tkeyl
                    lbsr      puts
                    lbsr      getkey
                    lbra      cleanup

* onepass: the five lines drawn, then verified and reported
onepass             pshs      u
* horizontal, row 49
                    ldd       #0
                    std       x0,u
                    ldd       width,u
                    subd      #1
                    std       x1,u
                    lda       #49
                    sta       y0,u
                    sta       y1,u
                    lbsr      drawline
* vertical, x = 100, rows 0..47
                    ldd       #100
                    std       x0,u
                    std       x1,u
                    clr       y0,u
                    lda       #47
                    sta       y1,u
                    lbsr      drawline
* diagonal 45 deg
                    ldd       #0
                    std       x0,u
                    ldd       #45
                    std       x1,u
                    clr       y0,u
                    lda       #45
                    sta       y1,u
                    lbsr      drawline
* shallow 1:4
                    ldd       #120
                    std       x0,u
                    ldd       #220
                    std       x1,u
                    lda       #20
                    sta       y0,u
                    lda       #45
                    sta       y1,u
                    lbsr      drawline
* steep 4:1
                    ldd       #280
                    std       x0,u
                    ldd       #292
                    std       x1,u
                    clr       y0,u
                    lda       #48
                    sta       y1,u
                    lbsr      drawline
* let the last writes land: three frames
                    ldx       #3
                    os9       F$Sleep

* ---- verify H: row 10, x 0..319, four rows of 80 -----------------------
                    leay      tH,pcr
                    ldb       #tHl
                    tst       mode,u
                    beq       hlabel@
                    leay      tH6,pcr
                    ldb       #tH6l
hlabel@             lbsr      label
                    ldd       width,u
                    std       want,u
                    lbsr      scanbeg
                    ldd       #0
                    std       cx,u
h1@                 lda       #49
                    sta       cy,u
                    lbsr      tally
                    ldd       cx,u
                    addd      #1
                    std       cx,u
                    cmpd      width,u
                    bne       h1@
                    lbsr      saycount

* ---- verify V: column 100, rows 0..50 ----------------------------------
                    leay      tV,pcr
                    ldb       #tVl
                    lbsr      label
                    ldd       #48
                    std       want,u
                    lbsr      scanbeg
                    ldd       #100
                    std       cx,u
                    clr       cy,u
v1@                 lbsr      tally
                    inc       cy,u
                    lda       cy,u
                    cmpa      #48
                    bne       v1@
                    lbsr      saycount

* ---- verify D1: (i,i), i 0..50 -----------------------------------------
                    leay      tD1,pcr
                    ldb       #tD1l
                    lbsr      label
                    ldd       #46
                    std       want,u
                    lbsr      scanbeg
                    clr       cy,u
d1a@                ldb       cy,u
                    clra
                    std       cx,u
                    lbsr      tally
                    inc       cy,u
                    lda       cy,u
                    cmpa      #46
                    bne       d1a@
                    lbsr      saycount

* ---- D2: the box x 0..100, y 20..45: 101 pixels expected ---------------
                    leay      tD2,pcr
                    ldb       #tD2l
                    lbsr      label
                    ldd       #101
                    std       want,u
                    ldd       #120
                    std       x0,u
                    ldd       #220
                    std       x1,u
                    lda       #20
                    sta       y0,u
                    lda       #45
                    sta       y1,u
                    lbsr      boxcount
                    lbsr      saycount

* ---- D3: the box x 200..212, y 0..48: 49 pixels expected ---------------
                    leay      tD3,pcr
                    ldb       #tD3l
                    lbsr      label
                    ldd       #49
                    std       want,u
                    ldd       #280
                    std       x0,u
                    ldd       #292
                    std       x1,u
                    clr       y0,u
                    lda       #48
                    sta       y1,u
                    lbsr      boxcount
                    lbsr      saycount
* the pass's lines stay on the screen until a key
                    leax      tnext,pcr
                    ldy       #tnextl
                    lbsr      puts
                    lbsr      getkey
                    puls      u,pc

* getkey: one key from the keyboard (path 0), not echoed back into the report. X, Y kept.
getkey              pshs      x,y
                    leax      line,u
                    ldy       #1
                    clra
                    os9       I$Read
                    puls      x,y,pc

* ---- the engine ------------------------------------------------------
* drawline: x0/y0/x1/y1,u -> the registers, go, wait for DONE (ctrl b7), go back to 0, wait for the
* FIFO to drain. Both waits are bounded (waitset/waitlap); a wait that gives up is reported and the
* run goes on - the verify then shows what did land.
drawline            pshs      x
                    ldx       iomap,u
                    leax      LDREGS,x
                    lda       x0,u
                    sta       LD_X0H,x
                    lda       x0+1,u
                    sta       LD_X0L,x
                    lda       x1,u
                    sta       LD_X1H,x
                    lda       x1+1,u
                    sta       LD_X1L,x
                    lda       y0,u
                    sta       LD_Y0,x
                    lda       y1,u
                    sta       LD_Y1,x
                    lda       #LD_ENABLE+LD_GO
                    sta       LD_CTRL,x
                    lbsr      waitset
dw1@                lbsr      lapwait
                    lda       LD_CTRL,x
                    bmi       dw3@                DONE
                    lbsr      waitlap
                    bcc       dw1@
                    leay      tnodone,pcr
                    ldb       #tnodonel
                    lbsr      sayregs
dw3@                lda       #LD_ENABLE
                    sta       LD_CTRL,x           go back to 0
                    lbsr      waitset
dw4@                lbsr      lapwait
                    lda       LD_FIFOH,x
                    ora       LD_FIFOL,x
                    beq       dw9@                drained
                    lbsr      waitlap
                    bcc       dw4@
                    leay      tnodrain,pcr
                    ldb       #tnodrainl
                    lbsr      sayregs
dw9@                puls      x,pc

* lapwait: pass B sleeps a tick between looks; pass A looks again at once. X kept.
lapwait             lda       pass,u
                    cmpa      #'B
                    bne       lw9@
                    pshs      x
                    ldx       #1
                    os9       F$Sleep
                    puls      x
lw9@                rts
* waitset: arm a bounded wait - pass A POLLHI x 65536 laps, pass B SLEEPS sleeps.
waitset             clra
                    clrb
                    std       laps,u
                    lda       #POLLHI
                    ldb       pass,u
                    cmpb      #'B
                    bne       ws1@
                    lda       #SLEEPS
ws1@                sta       polls,u
                    rts
* waitlap: one lap of a bounded wait; carry set = the wait has run out
waitlap             pshs      a,b
                    lda       pass,u
                    cmpa      #'B
                    beq       wl2@
                    ldd       laps,u
                    subd      #1
                    std       laps,u
                    bne       wl0@
wl2@                dec       polls,u
                    beq       wl9@
wl0@                puls      a,b
                    andcc     #^Carry
                    rts
wl9@                puls      a,b
                    orcc      #Carry
                    rts
* sayregs: Y = the text, B = its length; then "ctrl=$xx fifo=$xxxx)" from the registers at X
sayregs             pshs      x
                    lbsr      lbeg
                    lbsr      copy
                    ldy       ,s
                    ldb       LD_CTRL,y
                    lbsr      hexb
                    leay      tfifo,pcr
                    ldb       #tfifol
                    lbsr      copy
                    ldy       ,s
                    ldb       LD_FIFOH,y
                    lbsr      hexb
                    ldy       ,s
                    ldb       LD_FIFOL,y
                    lbsr      hexb
                    leay      tclose,pcr
                    ldb       #tclosel
                    lbsr      copy
                    lbsr      flushln
                    puls      x,pc

* wipe: the whole screen (ten blocks, five chunks of two) back to 0; chunk 0 mapped on return
wipe                pshs      x,y
                    lda       #4
wp0@                pshs      a
                    lbsr      mapchunk
                    ldx       bmmap,u
                    ldy       #$4000
                    clra
wp@                 sta       ,x+
                    leay      -1,y
                    bne       wp@
                    puls      a
                    deca
                    bpl       wp0@
                    puls      x,y,pc

* mapchunk: A = 0..4 -> bmmap = the CPU view of blocks 2A and 2A+1 of the screen (the previous view
* released). Carry set = F$MapBlk failed. X, Y kept; U kept.
mapchunk            pshs      x,y,a
                    ldx       bmmap,u
                    beq       mc1@
                    pshs      u
                    tfr       x,u
                    ldb       #2
                    os9       F$ClrBlk
                    puls      u
                    clra
                    clrb
                    std       bmmap,u
mc1@                lda       ,s
                    sta       chunk,u
                    lsla                          x 2
                    ldb       bmblock+1,u
                    pshs      a
                    addb      ,s+
                    clra
                    tfr       d,x                 the first block of the pair
                    ldb       #2
                    pshs      u
                    os9       F$MapBlk
                    tfr       u,x
                    puls      u
                    bcs       mc9@
                    stx       bmmap,u
                    andcc     #^Carry
mc9@                puls      x,y,a,pc

* corner: draw across the full logical width and count individual pixels.
* Each mapped byte contributes one 8bpp pixel or two independent 4bpp pixels.
corner              lbsr      wipe
                    ldd       #0
                    std       x0,u
                    ldd       width,u
                    subd      #1
                    std       x1,u
                    clr       y0,u
                    lda       #239
                    sta       y1,u
                    lbsr      drawline
                    ldx       #3
                    os9       F$Sleep
                    leax      colcnt,u
                    ldy       #640
cz@                 clr       ,x+
                    leay      -1,y
                    bne       cz@
                    lbsr      scanbeg
                    ldd       #0
                    std       cx,u
                    lda       #0
co1@                pshs      a
                    lbsr      mapchunk
                    ldx       bmmap,u
                    ldy       #$4000
co2@                lda       ,x+
                    tst       mode,u
                    beq       cbyte@
                    pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    lbsr      cornerpixel
                    puls      a
                    anda      #$0F
cbyte@              lbsr      cornerpixel
                    leay      -1,y
                    bne       co2@
                    puls      a
                    inca
                    cmpa      #5
                    blo       co1@
                    lda       #0
                    lbsr      mapchunk
                    ldd       width,u
                    std       want,u
                    leax      colcnt,u
                    ldd       #0
co5@                tst       ,x+
                    bne       co6@
                    std       firstx,u
                    clr       firsty,u
                    bra       co7@
co6@                addd      #1
                    cmpd      width,u
                    blo       co5@
co7@                leay      tcorner,pcr
                    ldb       #tcornerl
                    tst       mode,u
                    beq       co8@
                    leay      tcorner6,pcr
                    ldb       #tcorner6l
co8@                lbsr      label
                    lbra      saycount

* A = pixel value; X/Y and stack preserved. Advance logical column.
cornerpixel         pshs      x
                    tsta
                    beq       cpnext@
                    ldd       found,u
                    addd      #1
                    std       found,u
                    ldd       cx,u
                    leax      colcnt,u
                    leax      d,x
                    inc       ,x
cpnext@             ldd       cx,u
                    addd      #1
                    cmpd      width,u
                    blo       cpstore@
                    ldd       #0
cpstore@            std       cx,u
                    puls      x,pc

* ---- reading back ----------------------------------------------------
* pixel: cx,cy -> A = one logical pixel, Z set when zero; X/B preserved.
* Small test lines use chunk 0; 640 mode divides X by two and selects a nibble.
pixel               pshs      x,b
                    ldd       cx,u
                    tst       mode,u
                    beq       pxbyte@
                    lsra
                    rorb
pxbyte@             pshs      a,b
                    lda       cy,u
                    ldb       #ROWBYTES/2
                    mul
                    lslb
                    rola
                    addd      ,s++
                    addd      bmmap,u
                    tfr       d,x
                    lda       ,x
                    tst       mode,u
                    beq       pxret@
                    ldb       cx+1,u
                    bitb      #1
                    bne       pxlow@
                    lsra
                    lsra
                    lsra
                    lsra
pxlow@              anda      #$0F
pxret@              puls      x,b
                    tsta
                    rts

* boxcount: found,u = the non-zero bytes inside x0..x1 (inclusive), y0..y1; firstx/firsty = the first
* row of the box holding no pixel at all (a Bresenham line touches every row of a steep box and every
* column of a shallow one, so an empty row or column is a loss)
boxcount            lbsr      scanbeg
                    lda       y0,u
                    sta       cy,u
bc1@                ldd       x0,u
                    std       cx,u
                    clr       dig,u               pixels in this row
bc2@                lbsr      pixel
                    beq       bc3@
                    ldd       found,u
                    addd      #1
                    std       found,u
                    inc       dig,u
bc3@                ldd       cx,u
                    addd      #1
                    std       cx,u
                    cmpd      x1,u
                    bls       bc2@
                    tst       dig,u
                    bne       bc4@                the row had a pixel
                    ldd       firstx,u
                    cmpd      #$FFFF
                    bne       bc4@                a loss was already noted
                    ldd       x0,u
                    std       firstx,u
                    lda       cy,u
                    sta       firsty,u
bc4@                lda       cy,u
                    inca
                    sta       cy,u
                    cmpa      y1,u
                    bls       bc1@
                    rts

* scanbeg: found = 0, no missing pixel noted yet
scanbeg             clra
                    clrb
                    std       found,u
                    ldd       #$FFFF
                    std       firstx,u
                    rts
* tally: the pixel at cx,cy counted; the first missing one remembered
tally               lbsr      pixel
                    beq       ta1@
                    ldd       found,u
                    addd      #1
                    std       found,u
                    rts
ta1@                ldd       firstx,u
                    cmpd      #$FFFF
                    bne       ta9@
                    ldd       cx,u
                    std       firstx,u
                    lda       cy,u
                    sta       firsty,u
ta9@                rts

* ---- output ----------------------------------------------------------
* label: Y = the text, B = its length, printed without a line end
label               lbsr      lbeg
                    lbsr      copy
                    lbra      flushnc
* saycount: "found of want pixels" + CR, or "... pixels - MISSING n, the first at x=.. y=.." when short
saycount            lbsr      lbeg
                    ldd       found,u
                    lbsr      dec16
                    leay      tof,pcr
                    ldb       #tofl
                    lbsr      copy
                    ldd       want,u
                    lbsr      dec16
                    ldd       found,u
                    cmpd      want,u
                    bne       sc1@
                    leay      tpix,pcr
                    ldb       #tpixl
                    lbsr      copy
                    lbra      flushln
sc1@                ldd       found,u
                    cmpd      want,u
                    blo       sc3@
                    leay      textra,pcr
                    ldb       #textral
                    lbsr      copy
                    ldd       found,u
                    subd      want,u
                    lbsr      dec16
                    lbra      flush
sc3@                leay      tmiss,pcr
                    ldb       #tmissl
                    lbsr      copy
                    ldd       want,u
                    subd      found,u
                    lbsr      dec16
                    ldd       firstx,u
                    cmpd      #$FFFF
                    beq       sc2@
                    leay      tfirst,pcr
                    ldb       #tfirstl
                    lbsr      copy
                    ldd       firstx,u
                    lbsr      dec16
                    leay      tcomma,pcr
                    ldb       #tcommal
                    lbsr      copy
                    ldb       firsty,u
                    clra
                    lbsr      dec16
sc2@                lbra      flush
puts                lda       #1
                    os9       I$WritLn
                    rts
hexb                pshs      b
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    bsr       hexn
                    puls      b
                    andb      #$0F
hexn                pshs      x
                    leax      hexch,pcr
                    lda       b,x
                    puls      x
                    sta       ,x+
                    rts
lbeg                leax      line,u
                    rts
copy                lda       ,y+
                    sta       ,x+
                    decb
                    bne       copy
                    rts
* dec16: D in decimal at X, no leading zeros (four digit places counted, then the units)
dec16               pshs      y
                    pshs      a,b
                    leay      pow10,pcr
                    clr       dflag,u
                    lda       #4
                    sta       dcnt,u
                    puls      a,b
d1@                 clr       dig,u
d2@                 cmpd      ,y
                    blo       d3@
                    subd      ,y
                    inc       dig,u
                    bra       d2@
d3@                 tst       dig,u
                    bne       d4@
                    tst       dflag,u
                    beq       d5@
d4@                 pshs      a,b
                    ldb       dig,u
                    addb      #'0
                    stb       ,x+
                    inc       dflag,u
                    puls      a,b
d5@                 leay      2,y
                    dec       dcnt,u
                    bne       d1@
                    addb      #'0
                    stb       ,x+
                    puls      y,pc

flush               lda       #C$CR
                    sta       ,x+
flushln             bsr       linelen
                    lda       #1
                    os9       I$WritLn
                    rts
flushnc             bsr       linelen
                    lda       #1
                    os9       I$Write
                    rts
linelen             tfr       x,d
                    subd      #line
                    pshs      u
                    subd      ,s++
                    tfr       d,y
                    leax      line,u
                    rts

* ---- the ends ----------------------------------------------------------
noscreen            leax      tnoscr,pcr
                    ldy       #tnoscrl
                    lbsr      puts
* the exit is dmashow's: the bitmap bit off in the master register, the screen freed, then the layers
* and the master register as found (no SS.DScrn back to text - vtio has no such call)
cleanup             lda       oldline,u
                    sta       >LDMASTER
                    lda       oldgfx,u
                    sta       >GFXMODE
                    lda       oldmaster,u
                    anda      #^Mstr_Ctrl_Bitmap_En
                    sta       >TXT.Base
                    ldx       iomap,u
                    beq       cu1@
                    pshs      u
                    tfr       x,u
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u
cu1@                ldx       clutmap,u
                    beq       cu1b@
                    leax      CLUT0+7*4,x
                    ldd       oldclut,u
                    std       ,x
                    ldd       oldclut+2,u
                    std       2,x
                    ldx       clutmap,u
                    leax      CLUT0+$77*4,x
                    ldd       oldclut+4,u
                    std       ,x
                    ldd       oldclut+6,u
                    std       2,x
                    ldx       clutmap,u
                    pshs      u
                    tfr       x,u
                    ldb       #1
                    os9       F$ClrBlk
                    puls      u
cu1b@               ldx       bmmap,u
                    beq       cu2@
                    pshs      u
                    tfr       x,u
                    ldb       #2
                    os9       F$ClrBlk
                    puls      u
cu2@                tst       owned,u
                    beq       cu3@
                    ldy       screenno,u
                    clra
                    ldb       #SS.FScrn
                    os9       I$SetStt
cu3@                ldd       oldlayers,u
                    std       >VKY_LAYER_CTRL_0
                    lda       oldmaster,u
                    sta       >TXT.Base
                    leax      tdone,pcr
                    ldy       #tdonel
                    lbsr      puts
                    clrb
                    os9       F$Exit

                    emod
eom                 equ       *
