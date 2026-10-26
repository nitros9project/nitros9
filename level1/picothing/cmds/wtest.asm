********************************************************************
* WTest - Pico-Thing /W window-driver test
*
* Exercises the VConW driver through the real window devices: opens /W1
* and /W2 as separate paths and writes distinct text to each, so the
* driver itself does the DWSet (first write) and Select (output target)
* for each window - unlike wdemo, which hand-emitted the sub-codes to
* /W0.  It then reveals each window with DWShow (sent through /W0, since
* visibility is display-only), pausing on each so a screenshot catches
* it, and finally restores the root as target and display so the /W0
* console survives.
*
* Proves: /W1 and /W2 are real devices, each write lands in its own
* window's buffer, and the two buffers are independent.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created for the /W driver test (M5 phase 1)

                    nam       WTest
                    ttl       /W window-driver test

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

Naps                equ       400       ticks to hold each window (about 8s)

                    mod       eom,name,tylg,atrv,start,size

                    org       0
pw1                 rmb       1         /W1 path
pw2                 rmb       1         /W2 path
pw0                 rmb       1         /W0 path (for DWShow)
                    rmb       256       working stack
size                equ       .

name                fcs       /WTest/
                    fcb       edition

W1Name              fcs       "/W1"
W2Name              fcs       "/W2"
W0Name              fcs       "/W0"

Text1               fcc       "=====  /W1  window one  ====="
                    fcb       C$CR,C$LF
                    fcc       "written through the VConW driver"
                    fcb       C$CR,C$LF
Text1Ln             equ       *-Text1
Text2               fcc       "=====  /W2  window two  ====="
                    fcb       C$CR,C$LF
                    fcc       "a separate device and buffer"
                    fcb       C$CR,C$LF
Text2Ln             equ       *-Text2

Show1               fcb       $1B,$26,$01
Show2               fcb       $1B,$26,$02
ShowLn              equ       $03
* restore root as both output target (Select 0) and display (DWShow 0)
Restore             fcb       $1B,$21,$00,$1B,$26,$00
RestoreLn           equ       *-Restore

Msg                 fcc       "wtest: /W1 then /W2 on the video screen"
                    fcb       C$CR
MsgLn               equ       *-Msg

start               leax      Msg,pcr   ; announce on stdout
                    lda       #$01
                    ldy       #MsgLn
                    os9       I$Write

                    leax      W1Name,pcr ; open /W1
                    lda       #WRITE.
                    os9       I$Open
                    bcs       Exit
                    sta       <pw1
                    leax      W2Name,pcr ; open /W2
                    lda       #WRITE.
                    os9       I$Open
                    bcs       Exit
                    sta       <pw2
                    leax      W0Name,pcr ; open /W0 for DWShow
                    lda       #WRITE.
                    os9       I$Open
                    bcs       Exit
                    sta       <pw0

                    lda       <pw1      ; fill /W1 (driver DWSets+Selects 1)
                    leax      Text1,pcr
                    ldy       #Text1Ln
                    os9       I$Write
                    lda       <pw2      ; fill /W2 (driver DWSets+Selects 2)
                    leax      Text2,pcr
                    ldy       #Text2Ln
                    os9       I$Write

                    lda       <pw0      ; show window 1
                    leax      Show1,pcr
                    ldy       #ShowLn
                    os9       I$Write
                    bsr       Nap
                    lda       <pw0      ; show window 2
                    leax      Show2,pcr
                    ldy       #ShowLn
                    os9       I$Write
                    bsr       Nap

                    lda       <pw0      ; restore root target + display
                    leax      Restore,pcr
                    ldy       #RestoreLn
                    os9       I$Write

                    lda       <pw1      ; close everything
                    os9       I$Close
                    lda       <pw2
                    os9       I$Close
                    lda       <pw0
                    os9       I$Close
                    clrb
Exit                os9       F$Exit

Nap                 pshs      x
                    ldx       #Naps
                    os9       F$Sleep
                    puls      x
                    rts

                    emod
eom                 equ       *
                    end
