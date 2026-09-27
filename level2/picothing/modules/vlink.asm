********************************************************************
* VLink - video Pico link loopback test (Pico-Thing bring-up, M0)
*
* Proves the 6809 to video Pico link end to end.  It waits for the
* video Pico to report READY, turns on its loopback mode, sends all
* 256 byte values through VID.Data using TDRE flow control, reads
* each one back using the one read per RDRF discipline, and checks
* it matches.  The result line is written to standard output, so it
* can be run from the console during bring-up.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created for the video console bring-up

                    nam       VLink
                    ttl       video Pico link loopback test

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

WBOuter             equ       200       patient wait outer count

                    mod       eom,name,tylg,atrv,start,size

                    org       0
                    rmb       256       work and stack space
size                equ       .

name                fcs       /VLink/
                    fcb       edition

* wait for the video pico, then sweep all byte values through loopback
start               ldb       #VID.RDY  ; is the video pico alive
                    lbsr      WaitBit
                    lbcs      NotRdy    ; no, report it and quit
                    lda       #VID.Loop ; echo transmitted bytes back
                    sta       >VID.Stat
                    clra                ; first test value
LoopB               tfr       a,b       ; keep the send value in b
                    pshs      b
                    ldb       #VID.TDRE ; wait for transmit space
                    lbsr      WaitBit
                    puls      b
                    bcs       LinkTO
                    stb       >VID.Data ; transmit the byte
                    pshs      b
                    ldb       #VID.RDRF ; wait for the echo
                    lbsr      WaitBit
                    puls      b
                    bcs       LinkTO
                    lda       >VID.Data ; read it back exactly once
                    pshs      b
                    cmpa      ,s+       ; same value we sent
                    bne       Bad
                    tfr       b,a       ; recover the counter
                    inca
                    bne       LoopB     ; carry on until it wraps to zero
                    bsr       LoopOff   ; all 256 matched
                    leax      >mOk,pcr
                    ldy       #mOkL
                    bra       PrOut
Bad                 bsr       LoopOff
                    leax      >mBad,pcr
                    ldy       #mBadL
                    bra       PrErr
LinkTO              bsr       LoopOff
                    leax      >mTO,pcr
                    ldy       #mTOL
                    bra       PrErr
NotRdy              leax      >mRdy,pcr
                    ldy       #mRdyL

* write the line at x (length y) to standard output and exit
PrErr               lda       #$01
                    os9       I$WritLn
                    ldb       #$01      ; non zero exit status
                    os9       F$Exit
PrOut               lda       #$01
                    os9       I$WritLn
                    clrb
                    os9       F$Exit

* clear loopback and flush the fifos
LoopOff             lda       #VID.Rset
                    sta       >VID.Stat
                    rts

* WaitBit - wait patiently for (VID.Stat and b) to become nonzero
* entry b = status bit mask
* exit  carry clear = bit seen, carry set = timed out, b preserved
WaitBit             pshs      u,x,a,b
                    ldu       #WBOuter
WB1                 ldx       #$0000
WB2                 lda       >VID.Stat
                    pshs      b
                    anda      ,s+
                    bne       WBok
                    leax      -$01,x
                    bne       WB2
                    leau      -$01,u
                    bne       WB1
                    orcc      #Carry    ; gave up waiting
                    puls      a,b,x,u,pc
WBok                andcc     #^Carry   ; the bit is present
                    puls      a,b,x,u,pc

mOk                 fcc       "vlink loopback ok - 256 bytes"
                    fcb       C$CR
mOkL                equ       *-mOk
mBad                fcc       "vlink loopback failed - byte mismatch"
                    fcb       C$CR
mBadL               equ       *-mBad
mRdy                fcc       "vlink - video pico not ready"
                    fcb       C$CR
mRdyL               equ       *-mRdy
mTO                 fcc       "vlink - link timeout"
                    fcb       C$CR
mTOL                equ       *-mTO

                    emod
eom                 equ       *
                    end
