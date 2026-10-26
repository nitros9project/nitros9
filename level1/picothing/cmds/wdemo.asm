********************************************************************
* WDemo - Pico-Thing video multi-window demo
*
* Exercises the video pico's window model as it stands (M5.1 + the
* Select/DWShow split) straight through /W0's transparent byte pipe -
* no /W driver needed yet, since vcon forwards every byte verbatim.
* It:
*   - DWSets two full-screen windows (1 and 2)
*   - writes distinct text into each with Select (output target only),
*     so window 2's text accumulates while window 1 is the one shown -
*     proving the split: a background window takes output without
*     stealing the display
*   - then alternates DWShow 1 / DWShow 2 a few times, so the panel
*     flips between the two windows' content, proving park/restore
*   - closes both windows and restores the root so the console survives
*
* Run it and watch the video screen: "WINDOW 1" and "WINDOW 2" content
* swap back and forth, each intact across the switch.  A progress line
* goes to standard output so a headless run can confirm it ran.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created for the M5 window model demo

                    nam       WDemo
                    ttl       video multi-window demo

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

Naps                equ       150       ticks to hold each window (about 3s)

                    mod       eom,name,tylg,atrv,start,size

                    org       0
path                rmb       1         open path number for the video console
                    rmb       256       working stack
size                equ       .

name                fcs       /WDemo/
                    fcb       edition

W0Name              fcs       "/W0"

* Setup: define both windows, fill each, leave window 1 on screen.
* DWSet id,type,x,y,sx,sy,fg,bg (full panel 128x30); Select id; DWShow id.
Setup               fcb       $1B,$20,$01,$00,$00,$00,$80,$1E,$00,$00 DWSet window 1
                    fcb       $1B,$20,$02,$00,$00,$00,$80,$1E,$00,$00 DWSet window 2
                    fcb       $1B,$21,$01 Select 1
                    fcc       "WINDOW 1   WINDOW 1   WINDOW 1"
                    fcb       C$CR,C$LF
                    fcc       "the first video window"
                    fcb       C$CR,C$LF
                    fcb       $1B,$21,$02 Select 2 (background)
                    fcc       "WINDOW 2   WINDOW 2   WINDOW 2"
                    fcb       C$CR,C$LF
                    fcc       "the second video window"
                    fcb       C$CR,C$LF
                    fcb       $1B,$26,$01 DWShow 1 (window 2 stays hidden)
SetupLn             equ       *-Setup

Show1               fcb       $1B,$26,$01
Show2               fcb       $1B,$26,$02
ShowLn              equ       $03

* Cleanup: close both windows, restore the root, and clear the panel.
* $0C with the root selected wipes the panel's text AND the graphics
* plane (the root is the panel), so no demo remnants or power-on screen
* are left behind; then a closing line so it does not end on black.
Cleanup             fcb       $1B,$21,$01,$1B,$24 Select 1, DWEnd
                    fcb       $1B,$21,$02,$1B,$24 Select 2, DWEnd
                    fcb       $1B,$21,$00 Select root
                    fcb       $0C       clear panel text + graphics
                    fcb       $1B,$26,$00 DWShow root
                    fcc       "wdemo complete - windows closed, console restored"
                    fcb       C$CR,C$LF
CleanupLn           equ       *-Cleanup

Msg                 fcc       "wdemo: watch /W0 flip between window 1 and 2"
                    fcb       C$CR
MsgLn               equ       *-Msg

start               leax      Msg,pcr   ; tell the operator on stdout
                    lda       #$01
                    ldy       #MsgLn
                    os9       I$Write

                    leax      W0Name,pcr ; open the video console
                    lda       #WRITE.
                    os9       I$Open
                    bcs       Exit
                    sta       <path

                    leax      Setup,pcr ; define+fill both, show window 1
                    ldy       #SetupLn
                    bsr       PutV
                    bcs       Close

* alternate the two windows a few times
                    bsr       Nap
                    leax      Show2,pcr
                    ldy       #ShowLn
                    bsr       PutV
                    bsr       Nap
                    leax      Show1,pcr
                    ldy       #ShowLn
                    bsr       PutV
                    bsr       Nap
                    leax      Show2,pcr
                    ldy       #ShowLn
                    bsr       PutV
                    bsr       Nap
                    leax      Show1,pcr
                    ldy       #ShowLn
                    bsr       PutV
                    bsr       Nap

                    leax      Cleanup,pcr ; close windows, restore root
                    ldy       #CleanupLn
                    bsr       PutV
                    clrb

Close               pshs      b         ; keep exit status across close
                    lda       <path
                    os9       I$Close
                    puls      b
Exit                os9       F$Exit

* PutV - write Y bytes at X to the video console path
PutV                lda       <path
                    os9       I$Write
                    rts

* Nap - sleep Naps ticks (about 1.5 seconds)
Nap                 pshs      x
                    ldx       #Naps
                    os9       F$Sleep
                    puls      x
                    rts

                    emod
eom                 equ       *
                    end
