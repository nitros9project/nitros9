********************************************************************
* WinTest - Pico-Thing video window (M5.1) exercise
*
* Drives the video pico's window sub-codes through /W0 to check the
* M5.1 window model from the 6809 side: DWSet an inland device window
* (id 1) at col 8, row 4, 48x12 cells, and write text into it so it
* wraps at the window's right edge.  A screenshot shows the text
* confined to the 48x12 window rather than the 128x30 panel.
*
* vcon is a transparent byte pipe, so every byte reaches VID.Data
* verbatim; only id/x/y/sx/sy are acted on in M5.1 (type/fg/bg ignored).
* Structured like gfxtest: DP holds the path, all data lives in the
* module body and is reached by pcr.  A "wt" marker is written to
* standard output on success so a headless run can confirm completion.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created to exercise the M5.1 window model

                    nam       WinTest
                    ttl       video window M5.1 exercise

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
path                rmb       1         open path number for the video console
                    rmb       256       working stack
size                equ       .

name                fcs       /WinTest/
                    fcb       edition

W0Name              fcs       "/W0"

* DWSet window 1: ESC $20, id, type, col, row, width, height, fg, bg
DWSet1              fcb       $1B,$20,$01,$00,$08,$04,$30,$0C,$00,$00
DWSetLn             equ       *-DWSet1
* text to write into the window - longer than 48 columns so it wraps
Text                fcc       "0123456789wintest0123456789wintest0123456789wintest0123456789"
TextLn              equ       *-Text
* completion marker for a headless run (standard output)
Mark                fcc       "wt ok"
                    fcb       C$CR
MarkLn              equ       *-Mark

start               leax      W0Name,pcr ; the video console device
                    lda       #WRITE.   ; open it for output
                    os9       I$Open
                    bcs       Exit      ; give up if it will not open
                    sta       <path     ; remember the path number

                    lda       <path     ; send DWSet window 1
                    leax      DWSet1,pcr
                    ldy       #DWSetLn
                    os9       I$Write
                    bcs       Close

                    lda       <path     ; write text into the window
                    leax      Text,pcr
                    ldy       #TextLn
                    os9       I$Write
                    bcs       Close

                    lda       #$01      ; say so on standard output
                    leax      Mark,pcr
                    ldy       #MarkLn
                    os9       I$Write
                    clrb                ; success

Close               pshs      b         ; keep exit status across close
                    lda       <path
                    os9       I$Close
                    puls      b
Exit                os9       F$Exit

                    emod
eom                 equ       *
                    end
