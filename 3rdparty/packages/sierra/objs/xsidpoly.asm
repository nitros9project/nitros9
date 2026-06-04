********************************************************************
* xsidpoly - Phase C test program for SIDIRQ driver
*
* Loads a small embedded 3-voice stream into the driver via the new
* SS.SidLoad SetStt code, starts playback, polls SS.SidActv until
* the driver auto-stops (all voices reached terminator), then
* closes and exits.
*
* Stream content: a C-E-G major triad held for 3 seconds.
*   v1: C4 (181 Hz reg=$1126)  180 ticks (3s)  triangle, sustain=F
*   v2: E4 ($159A)             180 ticks       triangle, sustain=F
*   v3: G4 ($19B1)             180 ticks       triangle, sustain=F
*
* If polyphony is working: clear chord during the 3-second hold,
* then silence and the program exits.  If the driver loads but
* nothing plays: probably SidPolySetup or per-voice SID writes
* aren't reaching the chip.  If the program never exits: the
* IRQ-driven auto-stop didn't fire.
********************************************************************

                    nam       xsidpoly
                    ttl       Phase C polyphony test

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

SS.SidLoad          equ       $93
SS.SidStart         equ       $94
SS.SidStop          equ       $95
SS.SidActv          equ       $96

POLL_TICKS          equ       6                   100ms polling interval
MAX_POLLS           equ       80                  8s max wait then bail

                    mod       eom,name,tylg,atrv,start,size

                    org       0
sidpath             rmb       1
polln               rmb       1
actv                rmb       2
stk                 rmb       80
size                equ       .

name                fcs       /xsidpoly/
                    fcb       edition

devname             fcs       "/sid"

oerr                fcc       "can't open SID"
                    fcb       C$LF
oerr_len            equ       *-oerr
lderr               fcc       "SS.SidLoad failed"
                    fcb       C$LF
lderr_len           equ       *-lderr
sterr               fcc       "SS.SidStart failed"
                    fcb       C$LF
sterr_len           equ       *-sterr
gterr               fcc       "SS.SidActv failed"
                    fcb       C$LF
gterr_len           equ       *-gterr
pmsg                fcc       "playing C-E-G chord..."
                    fcb       C$LF
pmsg_len            equ       *-pmsg
dmsg                fcc       "done"
                    fcb       C$LF
dmsg_len            equ       *-dmsg

* --- Embedded SID stream (29 bytes) ---
* Header (8 bytes): v1off=8, v2off=15, v3off=22, pad=0
stream              fdb       $0008
                    fdb       $000F
                    fdb       $0016
                    fdb       $0000
* V1 (7 bytes): C4 for 180 ticks, terminator
                    fdb       $00B4
                    fcb       $26,$11
                    fcb       $F1
                    fdb       $FFFF
* V2 (7 bytes): E4 for 180 ticks, terminator
                    fdb       $00B4
                    fcb       $9A,$15
                    fcb       $F1
                    fdb       $FFFF
* V3 (7 bytes): G4 for 180 ticks, terminator
                    fdb       $00B4
                    fcb       $B1,$19
                    fcb       $F1
                    fdb       $FFFF
streamlen           equ       *-stream

********************************************************************
start
                    lda       #UPDAT.
                    leax      devname,pcr
                    os9       I$Open
                    lbcs      opfail
                    sta       sidpath

* Load embedded stream
                    lda       sidpath
                    ldb       #SS.SidLoad
                    leax      stream,pcr
                    ldy       #streamlen
                    os9       I$SetStt
                    lbcs      ldfail

* Announce
                    lda       #2
                    leax      pmsg,pcr
                    ldy       #pmsg_len
                    os9       I$Write

* Start playback
                    lda       sidpath
                    ldb       #SS.SidStart
                    os9       I$SetStt
                    lbcs      stfail

* Poll SS.SidActv every 100ms until LoadState != 2 or timeout
                    lda       #MAX_POLLS
                    sta       polln
pollloop            ldx       #POLL_TICKS
                    os9       F$Sleep
                    lda       sidpath
                    ldb       #SS.SidActv
                    os9       I$GetStt
                    lbcs      gtfail
                    stx       actv
                    cmpx      #2
                    bne       pollend
                    dec       polln
                    bne       pollloop
* timeout -> force stop
                    lda       sidpath
                    ldb       #SS.SidStop
                    os9       I$SetStt
pollend
                    lda       #2
                    leax      dmsg,pcr
                    ldy       #dmsg_len
                    os9       I$Write

                    lda       sidpath
                    os9       I$Close

                    clrb
                    os9       F$Exit

opfail              leax      oerr,pcr
                    ldy       #oerr_len
                    bra       errmsg
ldfail              lda       sidpath
                    pshs      a
                    leax      lderr,pcr
                    ldy       #lderr_len
                    bsr       errmsg2
                    puls      a
                    os9       I$Close
                    bra       fail
stfail              lda       sidpath
                    pshs      a
                    leax      sterr,pcr
                    ldy       #sterr_len
                    bsr       errmsg2
                    puls      a
                    os9       I$Close
                    bra       fail
gtfail              lda       sidpath
                    pshs      a
                    leax      gterr,pcr
                    ldy       #gterr_len
                    bsr       errmsg2
                    puls      a
                    os9       I$Close
                    bra       fail
errmsg              lda       #2
                    os9       I$WritLn
                    bra       fail
errmsg2             pshs      b
                    lda       #2
                    os9       I$WritLn
                    puls      b
                    rts
fail                comb
                    os9       F$Exit

                    emod
eom                 equ       *
                    end
