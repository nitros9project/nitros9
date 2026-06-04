********************************************************************
* xsidstat - Phase A test program for SIDIRQ driver
*
* Opens /sid, samples the tick counter twice across an F$Sleep(180),
* and prints the delta to stdout as 4-digit hex.  Closes /sid, exits.
*
* Expected behavior: the delta should be approximately 180 (the number
* of 60Hz ticks slept).  If the IRQ install succeeded and the IRQ is
* firing every tick, we see ~$00B4 (180 in hex).
*
* Run after booting SpaceQuest 0 with SHIFT held during boot (which
* skips AutoEx) - lands at OS9: prompt - then "xsidstat" runs this.
*
* Edt/Rev  YYYY/MM/DD  Modified by
*   0      2026/06/03  Copilot CLI + sspiller
*     Initial.
********************************************************************

                    nam       xsidstat
                    ttl       SID driver tick-counter probe

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

* Driver-private SS codes (must match sidirq.asm)
SS.SidCnt           equ       $90
SS.SidClr           equ       $91
SS.SidChrp          equ       $92

SLEEP_TICKS         equ       180                 3 seconds at 60Hz
CHIRP_TICKS         equ       240                 4 seconds of beeping

                    mod       eom,name,tylg,atrv,start,size

                    org       0
sidpath             rmb       1
cnt0                rmb       2
cnt1                rmb       2
hexbuf              rmb       6                   "XXXX",CR,LF
stk                 rmb       80
size                equ       .

name                fcs       /xsidstat/
                    fcb       edition

devname             fcs       "/sid"
oerr                fcc       "can't open SID"
                    fcb       C$LF
oerr_len            equ       *-oerr
gerr                fcc       "SS.SidCnt failed"
                    fcb       C$LF
gerr_len            equ       *-gerr
serr                fcc       "SS.SidChrp failed"
                    fcb       C$LF
serr_len            equ       *-serr
cmsg                fcc       "chirping 4s..."
                    fcb       C$LF
cmsg_len            equ       *-cmsg

********************************************************************
* start - main entry
********************************************************************
start               equ       *
* Open /sid for update
                    lda       #UPDAT.
                    leax      devname,pcr
                    os9       I$Open
                    bcs       opfail
                    sta       sidpath

* First sample of tick counter
                    lda       sidpath
                    ldb       #SS.SidCnt
                    os9       I$GetStt
                    bcs       gsfail
                    stx       cnt0                returned in caller's X

* Sleep 3 seconds
                    ldx       #SLEEP_TICKS
                    os9       F$Sleep

* Second sample
                    lda       sidpath
                    ldb       #SS.SidCnt
                    os9       I$GetStt
                    bcs       gsfail
                    stx       cnt1

* Compute delta = cnt1 - cnt0
                    ldd       cnt1
                    subd      cnt0
* Render to hexbuf as "XXXX",CR,LF
                    leax      hexbuf,u
                    pshs      d
                    lda       ,s                  high byte (A)
                    lbsr      hex2
                    lda       1,s                 low byte (B)
                    lbsr      hex2
                    puls      d
                    lda       #C$CR
                    sta       ,x+
                    lda       #C$LF
                    sta       ,x+

* Write hexbuf to stdout (path 1)
                    lda       #1
                    leax      hexbuf,u
                    ldy       #6
                    os9       I$Write
                    bcs       wrfail

* Phase B: enable chirp on voice 3, sleep ~4s, disable.
                    lda       #2                  stderr (unbuffered)
                    leax      cmsg,pcr
                    ldy       #cmsg_len
                    os9       I$Write

                    lda       sidpath
                    ldb       #SS.SidChrp
                    ldx       #$0001              bit 0 = enable
                    os9       I$SetStt
                    bcs       sefail

                    ldx       #CHIRP_TICKS
                    os9       F$Sleep

                    lda       sidpath
                    ldb       #SS.SidChrp
                    ldx       #$0000              bit 0 = disable + silence v3
                    os9       I$SetStt
                    bcs       sefail

* Close
                    lda       sidpath
                    os9       I$Close

                    clrb
                    os9       F$Exit

opfail              leax      oerr,pcr
                    ldy       #oerr_len
                    bra       errmsg
gsfail              lda       sidpath
                    os9       I$Close
                    leax      gerr,pcr
                    ldy       #gerr_len
                    bra       errmsg
sefail              lda       sidpath
                    os9       I$Close
                    leax      serr,pcr
                    ldy       #serr_len
                    bra       errmsg
wrfail              lda       sidpath
                    os9       I$Close
                    bra       fail
errmsg              pshs      b                   save error code
                    lda       #2                  stderr
                    os9       I$WritLn
                    puls      b
fail                comb
                    os9       F$Exit

********************************************************************
* hex2 - convert byte in A to two ASCII hex chars at X (post-incremented)
* Preserves B, U.  Clobbers A.
********************************************************************
hex2                pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    bsr       hex1
                    puls      a
                    anda      #$0F
hex1                cmpa      #10
                    blo       dec1
                    adda      #'A'-10-'0'
dec1                adda      #'0'
                    sta       ,x+
                    rts

                    emod
eom                 equ       *
                    end
