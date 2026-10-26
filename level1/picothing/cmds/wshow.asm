********************************************************************
* WShow - Pico-Thing video window showcase (VID-016 acceptance demo)
*
* A paced tour of the video pico's window model, driven straight through
* /W0's transparent byte pipe so it exercises the firmware, not the
* driver.  Each scene holds for a few seconds so it can be watched:
*
*   1  M5.1  text confined to a full-panel window (wrap + scroll)
*   2  M5.1  text confined to a SMALL window (wraps at its own edge)
*   3  M5.2  graphics clipped to that small window - a box, a line and
*            a bar all drawn far beyond the window, cut at its edges
*   4  M5.3  DWProtSw off - the same graphics now escape the window
*   5  M5.3  CWArea - drawing confined to a sub-rectangle of the window
*   6         the split + DWShow: a third window filled off-screen, then
*            revealed, then flipped back and forth (park/restore)
*   7         DWEnd and restore the root so the console survives
*
* Window geometry is in character cells (CHAR_W=8, CHAR_H=16); graphics
* coordinates are window-relative pixels, 16-bit big-endian, X then Y.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created as the VID-016 acceptance demo

                    nam       WShow
                    ttl       video window showcase

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

Hold                equ       200       ticks per scene (about 4 seconds)

                    mod       eom,name,tylg,atrv,start,size

                    org       0
path                rmb       1         /W0 path
                    rmb       300       working stack
size                equ       .

name                fcs       /WShow/
                    fcb       edition

W0Name              fcs       "/W0"

* ---- Scene 1: full-panel window, text confined, wraps and scrolls ----
Sc1                 fcb       $1B,$20,$01,$00,$00,$00,$80,$1E,$00,$00 DWSet 1 full 128x30
                    fcb       $1B,$21,$01 Select 1
                    fcb       $1B,$26,$01 DWShow 1
                    fcb       $0C       clear the window
                    fcc       "SCENE 1  --  M5.1 text in a full window"
                    fcb       C$CR,C$LF,C$LF
                    fcc       "This text is confined to window 1, which fills the "
                    fcc       "whole 128-column panel, so it wraps at the panel edge "
                    fcc       "and scrolls the panel rows - a plain glass console."
                    fcb       C$CR,C$LF
Sc1Ln               equ       *-Sc1

* ---- Scene 2: a small window, text confined to its own rectangle ----
* window 2 at col 16, row 5, 48 wide, 16 tall
Sc2                 fcb       $1B,$20,$02,$00,$10,$05,$30,$10,$00,$00 DWSet 2 small
                    fcb       $1B,$21,$02 Select 2
                    fcb       $1B,$26,$02 DWShow 2
                    fcb       $0C
                    fcc       "SCENE 2 - M5.1 in a SMALL window"
                    fcb       C$CR,C$LF
                    fcc       "This text wraps at THIS window's own right edge, not "
                    fcc       "the panel's, and scrolls only this window's rows.  It "
                    fcc       "cannot spill outside the box no matter how much I write."
                    fcb       C$CR,C$LF
Sc2Ln               equ       *-Sc2

* ---- Scene 3: graphics clipped to window 2 (M5.2) ----
* window 2 is 48x16 cells = 384x256 px; draw well beyond it, watch it clip
Sc3                 fcb       $1B,$31,$01,$36 palette 1 = yellow
                    fcb       $1B,$31,$02,$09 palette 2 = blue
                    fcb       $1B,$32,$01 foreground = yellow
                    fcb       $1B,$40,$00,$00,$00,$00 draw pointer to 0,0
                    fcb       $1B,$48,$02,$58,$01,$F4 box to 600,500 (clips)
                    fcb       $1B,$40,$00,$00,$01,$00 pointer to 0,256
                    fcb       $1B,$44,$02,$58,$00,$00 line to 600,0 (clips)
                    fcb       $1B,$32,$02 foreground = blue
                    fcb       $1B,$40,$00,$32,$00,$32 pointer to 50,50
                    fcb       $1B,$4A,$02,$BC,$01,$90 bar to 700,400 (clips)
Sc3Ln               equ       *-Sc3

* ---- Scene 4: DWProtSw off - graphics now escapes the window (M5.3) ----
Sc4                 fcb       $1B,$36,$00 protect off
                    fcb       $1B,$32,$01 foreground = yellow
                    fcb       $1B,$40,$00,$00,$00,$00 pointer to 0,0
                    fcb       $1B,$48,$02,$58,$01,$F4 same box, now unclipped
                    fcb       $1B,$36,$01 protect back on
Sc4Ln               equ       *-Sc4

* ---- Scene 5: CWArea - confine to a sub-rectangle of the window (M5.3) ----
* working area at col 6, row 4 of the window, 30 wide, 6 tall
Sc5                 fcb       $1B,$25,$06,$04,$1E,$06 CWArea within window 2
                    fcb       $0C       clear the working area
                    fcc       "CWArea: this text and its clear are confined to a "
                    fcc       "narrow working area inside window 2, tighter than the "
                    fcc       "window itself."
                    fcb       C$CR,C$LF
                    fcb       $1B,$25,$00,$00,$30,$10 reset CWArea to whole window
Sc5Ln               equ       *-Sc5

* ---- Scene 6a: fill a third window off-screen (the split) ----
Sc6a                fcb       $1B,$20,$03,$00,$00,$00,$80,$1E,$00,$00 DWSet 3 full
                    fcb       $1B,$21,$03 Select 3 (window 2 still shown)
                    fcb       $0C
                    fcc       "SCENE 6  --  window 3 was filled while window 2 was "
                    fcc       "on screen: writing here changed nothing you saw.  That "
                    fcc       "is the split - a background window takes output without "
                    fcc       "stealing the display.  Now revealing it with DWShow..."
                    fcb       C$CR,C$LF
Sc6aLn              equ       *-Sc6a
* ---- Scene 6b..6e: reveal window 3, then flip 2 <-> 3 ----
Show3               fcb       $1B,$26,$03
Show2               fcb       $1B,$26,$02
ShowLn              equ       $03

* ---- Scene 7: close windows, restore the root, and clear the panel ----
* Selecting the root and clearing it wipes the panel's text AND the shared
* graphics plane (the root IS the panel), so no demo remnants or power-on
* screen are left behind; then a closing line so it does not end on black.
Sc7                 fcb       $1B,$21,$03,$1B,$24 Select 3, DWEnd
                    fcb       $1B,$21,$02,$1B,$24 Select 2, DWEnd
                    fcb       $1B,$21,$01,$1B,$24 Select 1, DWEnd
                    fcb       $1B,$21,$00 Select root
                    fcb       $0C       clear panel text + graphics
                    fcb       $1B,$26,$00 DWShow root
                    fcc       "wshow complete - windows closed, console restored"
                    fcb       C$CR,C$LF
Sc7Ln               equ       *-Sc7

Msg                 fcc       "wshow: watch the video screen - 7 scenes, ~4s each"
                    fcb       C$CR
MsgLn               equ       *-Msg

start               leax      Msg,pcr   ; announce on stdout
                    lda       #$01
                    ldy       #MsgLn
                    os9       I$Write

                    leax      W0Name,pcr ; open the video console
                    lda       #WRITE.
                    os9       I$Open
                    lbcs      Exit
                    sta       <path

                    leax      Sc1,pcr   ; scene 1
                    ldy       #Sc1Ln
                    lbsr      PutV
                    lbsr      Wait
                    leax      Sc2,pcr   ; scene 2
                    ldy       #Sc2Ln
                    lbsr      PutV
                    lbsr      Wait
                    leax      Sc3,pcr   ; scene 3
                    ldy       #Sc3Ln
                    lbsr      PutV
                    lbsr      Wait
                    leax      Sc4,pcr   ; scene 4
                    ldy       #Sc4Ln
                    lbsr      PutV
                    lbsr      Wait
                    leax      Sc5,pcr   ; scene 5
                    ldy       #Sc5Ln
                    lbsr      PutV
                    lbsr      Wait
                    leax      Sc6a,pcr  ; scene 6: fill window 3 off-screen
                    ldy       #Sc6aLn
                    lbsr      PutV
                    lbsr      Wait
                    leax      Show3,pcr ; reveal window 3
                    ldy       #ShowLn
                    lbsr      PutV
                    lbsr      Wait
                    leax      Show2,pcr ; flip to window 2
                    ldy       #ShowLn
                    lbsr      PutV
                    lbsr      Wait
                    leax      Show3,pcr ; back to window 3
                    ldy       #ShowLn
                    lbsr      PutV
                    lbsr      Wait
                    leax      Sc7,pcr   ; scene 7: close, restore root
                    ldy       #Sc7Ln
                    lbsr      PutV
                    clrb

Close               pshs      b
                    lda       <path
                    os9       I$Close
                    puls      b
Exit                os9       F$Exit

* PutV - write Y bytes at X to the video console
PutV                lda       <path
                    os9       I$Write
                    rts

* Wait - hold the current scene
Wait                pshs      x
                    ldx       #Hold
                    os9       F$Sleep
                    puls      x
                    rts

                    emod
eom                 equ       *
                    end
