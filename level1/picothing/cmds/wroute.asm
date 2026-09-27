********************************************************************
* WRoute - Pico-Thing video console keyboard input routing test
*
* Proves the unified video console input model: one keyboard stream is
* routed to the FOCUSED window, and the function keys switch focus - F1
* to the root/panel (/V0), F2..F8 to the overlays /W1../W7.
*
* It opens /V0, /W1 and /W2, reads two characters from each in turn, and
* reports what each received on standard output (the serial console).
* Feed it, cycle-scheduled, with:
*
*   F1  a b  F2  c d  F3  e f
*
* (F1 = $80, F2 = $81, F3 = $82).  F1 focuses the root so its read
* collects "ab"; F2 focuses window 1 -> "cd"; F3 focuses window 2 ->
* "ef".  A byte only reaches a window while that window is focused, so a
* correct run prints:
*
*   V0 got: ab
*   W1 got: cd
*   W2 got: ef
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created as the /W input routing test
*
                    nam       WRoute
                    ttl       video console input routing test

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
path0               rmb       1         open path for /V0 (root)
path1               rmb       1         open path for /W1
path2               rmb       1         open path for /W2
buf                 rmb       2         two-character read buffer
                    rmb       200       working stack
size                equ       .

name                fcs       /WRoute/
                    fcb       edition

V0Name              fcs       "/V0"
W1Name              fcs       "/W1"
W2Name              fcs       "/W2"
Msg0                fcc       "V0 got: "
Msg0Ln              equ       *-Msg0
Msg1                fcc       "W1 got: "
Msg1Ln              equ       *-Msg1
Msg2                fcc       "W2 got: "
Msg2Ln              equ       *-Msg2
NL                  fcb       C$CR

start               leax      V0Name,pcr ; open the root/panel for reading
                    lda       #READ.
                    os9       I$Open
                    lbcs      Exit
                    sta       <path0
                    leax      W1Name,pcr ; open window 1 for reading
                    lda       #READ.
                    os9       I$Open
                    lbcs      Exit
                    sta       <path1
                    leax      W2Name,pcr ; open window 2 for reading
                    lda       #READ.
                    os9       I$Open
                    lbcs      Exit
                    sta       <path2

                    lda       <path0    ; collect two chars from the root
                    lbsr      Read2
                    lbcs      Exit
                    leax      Msg0,pcr  ; report what the root received
                    ldy       #Msg0Ln
                    lbsr      Report

                    lda       <path1    ; collect two chars from window 1
                    lbsr      Read2
                    lbcs      Exit
                    leax      Msg1,pcr
                    ldy       #Msg1Ln
                    lbsr      Report

                    lda       <path2    ; collect two chars from window 2
                    lbsr      Read2
                    lbcs      Exit
                    leax      Msg2,pcr
                    ldy       #Msg2Ln
                    lbsr      Report

Exit                clrb
                    os9       F$Exit

* Read2 - read two bytes from the path in A into buf.  Carry set on error.
Read2               leax      buf,u     ; the read buffer (data area, U-based)
                    ldy       #$0002    ; two bytes
                    os9       I$Read
                    rts

* Report - write the label at X (length Y) then the two-char buffer and
* a newline to standard output.
Report              lda       #$01      ; standard output
                    os9       I$Write   ; the label
                    leax      buf,u     ; the two characters read
                    ldy       #$0002
                    lda       #$01
                    os9       I$Write
                    leax      NL,pcr    ; a carriage return
                    ldy       #$0001
                    lda       #$01
                    os9       I$Write
                    rts

                    emod
eom                 equ       *
                    end
