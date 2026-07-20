************************************************************
* MODE - Multi-purpose setting utility
*
* By: Boisy G. Pitre
*     Southern Station, Box 8455
*     Hattiesburg, MS  39406-8455
*     Internet:  bgpitre@seabass.st.usm.edu
*
* UPDATE LOG
*
* 01/26/92       Optimized code

* 06/23/91       Added GetStt call to get window colors
*                for complete restoration upon 40/80 column changes
*
* 07/07/91       Added 'D' option and expanded Window types from 40 and 80
*                to text and graphics types (1, 2, 5, 6, 7, 8)

                    nam       Mode
                    ttl       Multi-purpose setting utility

                    ifp1
                    use       defsfile
                    endc

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Fin

Name                fcs       /Mode/
                    fcb       $06

Helpmess            fdb       C$LF,C$CR
                    fcc       /Mode - (C) 1992 Boisy G. Pitre/
                    fdb       C$LF,C$CR
                    fcc       /  Usage:  MODE <opts>/
                    fdb       C$LF,C$CR
                    fcc       /       D - Display settings/
                    fdb       C$LF,C$CR
                    fcc       /       R - RGB/
                    fdb       C$LF,C$CR
                    fcc       /       C - Composite/
                    fdb       C$LF,C$CR
                    fcc       /       M - Monochrome/
                    fdb       C$LF,C$CR
                    fcc       /       F - Fast CPU/
                    fdb       C$LF,C$CR
                    fcc       /       S - Slow CPU/
                    fdb       C$LF,C$CR
                    fcc       /       # - Window type/
                    fdb       C$LF,C$CR
Type1               fcc       /Type 1 - 40 x 24 text/
CR                  fdb       C$LF,C$CR
Type2               fcc       /Type 2 - 80 x 24 text/
                    fdb       C$LF,C$CR
Type5               fcc       /Type 5 - 640 x 192, 2  color graphics/
                    fdb       C$LF,C$CR
Type6               fcc       /Type 6 - 320 x 192, 4  color graphics/
                    fdb       C$LF,C$CR
Type7               fcc       /Type 7 - 640 x 192, 4  color graphics/
                    fdb       C$LF,C$CR
Type8               fcc       /Type 8 - 320 x 192, 16 color graphics/
                    fdb       C$LF,C$CR
Helplen             equ       *-Helpmess

Fastmess            fdb       C$LF,C$CR
                    fcc       /CPU is set to FAST (1.78Mhz)/
                    fdb       C$LF,C$CR

Slowmess            fdb       C$LF,C$CR
                    fcc       /CPU is set to SLOW (0.89Mhz)/
                    fdb       C$LF,C$CR

BadParm             fcc       /: Bad parameter/
                    fcb       C$CR

VDG                 fcc       /32 x 16 VDG text screen/
                    fdb       C$LF,C$CR

W1                  fcb       $1b,$24,$1b,$20,$01,$00,$00,$28,$18
W2                  fcb       $1b,$24,$1b,$20,$02,$00,$00,$50,$18
W5                  fcb       $1b,$24,$1b,$20,$05,$00,$00,$50,$18
W6                  fcb       $1b,$24,$1b,$20,$06,$00,$00,$28,$18
W7                  fcb       $1b,$24,$1b,$20,$07,$00,$00,$50,$18
W8                  fcb       $1b,$24,$1b,$20,$08,$00,$00,$28,$18
Select              fdb       $1b21

Colors              rmb       4
Stack               rmb       200
Parms               rmb       200
Fin                 equ       .

Start               decb                          Decrement B
                    beq       Help                if no params, show help

* Parsing routine

Parse2              lda       ,x+                 load A with next char.
Parse3              cmpa      #C$CR               is it a CR?
                    lbeq      Done                Yep, done
                    cmpa      #C$SPAC             is it a space?
                    beq       Parse2              yep, get next char
                    cmpa      #'1                 Check for window types...
                    lbeq      Win1
                    cmpa      #'2
                    lbeq      Win2
                    cmpa      #'5
                    lbeq      Win5
                    cmpa      #'6
                    lbeq      Win6
                    cmpa      #'7
                    lbeq      Win7
                    cmpa      #'8
                    lbeq      Win8
                    anda      #$DF                Mask to uppercase
                    cmpa      #'D                 Check other opts...
                    lbeq      Query
                    cmpa      #'R
                    beq       RGB
                    cmpa      #'C
                    beq       CMP
                    cmpa      #'M
                    beq       MONO
                    cmpa      #'F
                    lbeq      Fast
                    cmpa      #'S
                    lbeq      Slow

* Bad parameter message

                    pshs      x
                    ldy       #1
                    leax      -1,x
                    lda       #2
                    os9       I$Write
                    bcs       Error
                    leax      BadParm,pcr
                    ldy       #25
                    os9       I$WritLn
                    bcs       Error
                    puls      x
                    bra       Parse2

Help                leax      Helpmess,pcr
                    ldy       #Helplen
                    lda       #1
                    os9       I$Write
                    bra       Done

RGB                 pshs      x
                    ldx       #$0001
                    bra       Monitor

CMP                 pshs      x
                    ldx       #$0000
                    bra       Monitor

MONO                pshs      x
                    ldx       #$0002

Monitor             lda       #1
                    ldb       #$92
                    os9       I$SetStt
                    bcs       Error
                    puls      x
                    lbra      Parse2

* Exit routine

Done                clrb
Error               os9       F$Exit

Win1                pshs      x
                    bsr       Prepare
                    leax      W1,pcr
                    bra       SendOut

Win2                pshs      x
                    bsr       Prepare
                    leax      W2,pcr
                    bra       SendOut

Win5                pshs      x
                    bsr       Prepare
                    leax      W5,pcr
                    bra       SendOut

Win6                pshs      x
                    bsr       Prepare
                    leax      W6,pcr
                    bra       SendOut

Win7                pshs      x
                    bsr       Prepare
                    leax      W7,pcr
                    bra       SendOut

Win8                pshs      x
                    bsr       Prepare
                    leax      W8,pcr
                    bra       SendOut

Prepare             bsr       GetColor
                    lda       #1
                    rts

SendOut             ldy       #9
                    os9       I$Write
                    bcs       Error
                    ldy       #3
                    leax      Colors,u
                    os9       I$Write
                    bcs       Error
                    leax      Select,pcr
                    ldy       #2
                    os9       I$Write
                    bcs       Error
                    puls      x
                    lbra      Parse2

GetColor            ldb       #$96
                    clra
                    os9       I$GetStt
                    bcs       Error
                    sta       Colors,u
                    stx       Colors+1,u
                    stb       Colors+1,u
                    rts

Fast                pshs      x
                    clr       $FFD9
                    leax      Fastmess,pcr
                    bra       SpeedM

Slow                pshs      x
                    clr       $FFD8
                    leax      Slowmess,pcr

SpeedM              ldy       #32
                    lda       #1
                    os9       I$Write
                    lbcs      Error
                    puls      x
                    lbra      Parse2

Query               pshs      x
                    leax      CR,pcr
                    lda       #1
                    ldy       #1
                    os9       I$Write
                    lbcs      Error

WinType             lda       #1
                    ldb       #$93
                    os9       I$GetStt
                    bcc       Compare
                    cmpb      #208
                    lbne      Error
                    leax      VDG,pcr
                    bra       WriteIt

Compare             cmpa      #1
                    beq       T1
                    cmpa      #2
                    beq       T2
                    cmpa      #5
                    beq       T5
                    cmpa      #6
                    beq       T6
                    cmpa      #7
                    beq       T7

T8                  leax      Type8,pcr
                    bra       WriteIt
T1                  leax      Type1,pcr
                    bra       WriteIt
T2                  leax      Type2,pcr
                    bra       WriteIt
T5                  leax      Type5,pcr
                    bra       WriteIt
T6                  leax      Type6,pcr
                    bra       WriteIt
T7                  leax      Type7,pcr

WriteIt             lda       #1
                    ldy       #50
                    os9       I$WritLn
                    lbcs      Error
                    puls      X
                    lbra      Parse2

                    emod
Size                equ       *
                    end

