********************************************************************
* CO80 - CRT9128 80 Column Co-Driver for VTIO
*
* $Id$
*
* This driver came with OS-9 Level One V2.00, but is not
* written for the 6845-based WordPak RS (I/II).
* It works with a rare CRT9128-based PBJ WordPak prototype.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00
*
*          2003/09/22  Rodney Hamilton
* recoded dispatch table fcbs

                    nam       CO80
                    ttl       Mysterious 80 column co-driver for VTIO

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       0
size                equ       .
                    fcb       $06

name                fcs       /CO80/
                    fcb       edition

start               equ       *
                    lbra      Init
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

* Init
Init                ldx       <V.PORT,u           HW Base Address
                    lda       #$06                Vertical Displayed Rows
                    sta       $01,x
                    sta       ,x
                    lda       #$08                Mode Control
                    sta       $01,x
                    clr       ,x
                    lda       #$0E                Cursor Position Address
                    sta       $01,x
                    clr       ,x
                    lbsr      CurHome
                    lbsr      CurOn
                    ldd       #80*25
                    lbsr      L0189
                    ldb       <V.COLoad,u
                    orb       #ModCoWP
                    bra       L004F
* Term
Term                ldb       <V.COLoad,u
                    andb      #~ModCoWP
L004F               stb       <V.COLoad,u
                    clrb
                    rts
* GetStat
GetStat             cmpa      #SS.Cursr
                    bne       SetStat
                    ldy       R$Y,y
                    clra
                    ldb       <V.C80X,u
                    addb      #$20
                    std       $06,y
                    ldb       <V.C80Y,u
                    addb      #$20
                    std       R$X,y
                    ldx       <V.PORT,u
                    lda       #$0D                Display Start Address
                    sta       $01,x
                    lbsr      WaitBUSY
                    lda       ,x
                    lbsr      WaitBUSY
                    lda       ,x
                    sta       $01,y
* no operation entry point
NoOp                clrb
                    rts
* SetStat
SetStat             ldb       #E$UnkSvc
                    coma
                    rts
* Write
Write               ldx       <V.PORT,u           get HW addr in X
                    cmpa      #$0E                $0E?
                    bcs       L00B6               branch if less than
                    cmpa      #$1E                $1E?
                    bcs       NoOp                branch if less than
                    cmpa      #C$SPAC             space?
                    lbcs      Check1F             branch if less than
                    cmpa      #$7F                $7F?
                    bcs       ChrOut              ASCII char, branch if less than
                    cmpa      #$C0                $C0?
                    bls       L00A6               branch if lower or same
                    anda      #$1F
                    suba      #$01
                    cmpa      #$19
                    bhi       L00B2
                    bra       ChrOut
L00A6               cmpa      #$AA                $AA?
                    bcs       L00B2               branch if less than
                    ora       #$10
                    anda      #$1F
                    cmpa      #$1A
                    bcc       ChrOut
L00B2               lda       #$7F
                    bra       ChrOut

L00B6               leax      >FuncTbl,pcr
                    lsla
                    ldd       a,x
                    leax      d,x
                    pshs      x
                    ldx       <V.PORT,u
                    rts

* display functions dispatch table
FuncTbl             fdb       NoOp-FuncTbl        $00:no-op (null)
                    fdb       CurHome-FuncTbl     $01:HOME cursor
                    fdb       CurXY-FuncTbl       $02:CURSOR XY
                    fdb       ErLine-FuncTbl      $03:ERASE LINE
                    fdb       ErEOL-FuncTbl       $04:ERASE TO EOL
                    fdb       CurOnOff-FuncTbl    $05:CURSOR ON/OFF
                    fdb       CurRgt-FuncTbl      $06:CURSOR RIGHT
                    fdb       NoOp-FuncTbl        $07:no-op (bel:handled in VTIO)
                    fdb       CurLft-FuncTbl      $08:CURSOR LEFT
                    fdb       CurUp-FuncTbl       $09:CURSOR UP
                    fdb       CurDown-FuncTbl     $0A:CURSOR DOWN
                    fdb       ErEOS-FuncTbl       $0B:ERASE TO EOS
                    fdb       ClrScrn-FuncTbl     $0C:CLEAR SCREEN
                    fdb       CrRtn-FuncTbl       $0D:RETURN

* $08 - cursor left
CurLft              ldd       <V.C80X,u           get CO80 X/Y
                    bne       L00E8               branch if not at start
                    clrb
                    rts
L00E8               decb
                    bge       L00EE
                    ldb       #79
                    deca
L00EE               std       <V.C80X,u
                    bra       L014F

* $09 - cursor up
CurUp               lda       <V.C80X,u
                    beq       L00FF
                    deca
                    sta       <V.C80X,u
                    lbra      L01CC
L00FF               clrb
                    rts

* $0D - move cursor to start of line (carriage return)
CrRtn               clr       <V.C80Y,u
                    bra       L014C

* ChrOut - output a readable character
* Entry: A = ASCII value of character to output
ChrOut              ora       <V.Invers,u         add inverse video flag
                    pshs      a                   save char
                    bsr       WaitBUSY            wait for HW
                    puls      a                   restore char
                    ldb       #$0D                Display Start Address
                    stb       $01,x
                    sta       ,x                  write character

* $06 - cursor right
CurRgt              inc       <V.C80Y,u
                    lda       <V.C80Y,u
                    cmpa      #79
                    ble       L014C
                    bsr       CrRtn

* $0A - cursor down (line feed)
CurDown             lda       <V.C80X,u
                    cmpa      #23
                    bge       L012E
                    inca
                    sta       <V.C80X,u
                    bra       L014F
L012E               ldd       <V.Co80X,u
                    lbsr      L01DC
                    ldd       <V.Co80X,u
                    addd      #80
                    bsr       L0161
                    std       <V.Co80X,u
                    bsr       L018E
                    ldd       <V.Co80X,u
                    bsr       L016B
                    lda       #$08                Mode Control
                    sta       $01,x
                    stb       ,x
L014C               lda       <V.C80X,u
L014F               lbra      L01CC

* $01 - home cursor
CurHome             clr       <V.C80X,u
                    clr       <V.C80Y,u
                    ldd       <V.Co80X,u
                    std       <V.ColPtr,u
                    lbra      L01DC
L0161               cmpd      #80*25
                    blt       L016A
                    subd      #80*25
L016A               rts
L016B               lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    rts

* X = address of WordPak
WaitBUSY            lda       $01,x
                    bpl       WaitBUSY
                    rts

* $03 - erase line
ErLine              bsr       CrRtn               do a CR
ErEOL               lda       <V.C80X,u
                    inca
                    ldb       #80                 line length
                    mul
                    bra       L0189

* $0C - clear screen
ClrScrn             bsr       CurHome             do home cursor, then erase to EOS

* $0B - erase to end of screen
ErEOS               ldd       #80*24
L0189               addd      <V.Co80X,u
                    bsr       L0161
L018E               bsr       L016B
                    bsr       WaitBUSY
                    lda       #$0B                Cursor End Line
                    sta       $01,x
                    stb       ,x
                    lda       #$0D                Display Start Address
                    sta       $01,x
                    lda       #$20
                    sta       ,x
L01A0               clrb
                    rts

* $02 XX YY - move cursor to col XX-32, row YY-32
CurXY               leax      >L01B0,pcr
                    ldb       #$02
L01A8               stx       <V.RTAdd,u
                    stb       <V.NGChr,u
                    clrb
                    rts
L01B0               ldx       <V.PORT,u           get HW address
                    lda       <V.NChr2,u          get char2 in A
                    ldb       <V.NChar,u          and char1 in B
                    subb      #32                 subtract 32 from B
                    blt       L01A0               if less than 0, we're done
                    cmpb      #79                 compare against greatest column
                    bgt       L01A0               branch if >79
                    suba      #32                 else subtract 32 from A
                    blt       L01A0               if less than 0, we're done
                    cmpa      #23                 compare against greatest row
                    bgt       L01A0               branch if >23
                    std       <V.C80X,u           else store A/B in new col/row position
L01CC               ldb       #80                 multiply A*80 to find new row
                    mul
                    addb      <V.C80Y,u
                    adca      #$00
                    addd      <V.Co80X,u
                    bsr       L0161
                    std       <V.ColPtr,u
L01DC               pshs      b,a
                    bsr       WaitBUSY
                    lda       #$0A                Cursor Start Line
                    sta       $01,x
                    lda       ,s+
                    sta       ,x
                    lda       #$09                Number of Scan Lines
                    sta       $01,x
                    lda       ,s+
                    sta       ,x
                    clrb
                    rts

Check1F             cmpa      #$1F
                    bne       WritErr
                    lda       <V.NChr2,u
                    cmpa      #$21
                    beq       InvOn
                    cmpa      #$20
                    beq       InvOff
WritErr             comb
                    ldb       #E$Write
                    rts

InvOn               lda       #$80
                    sta       <V.Invers,u
                    clrb
                    rts

InvOff              clr       <V.Invers,u
L020F               clrb
                    rts

* $05 XX - set cursor off/on/color per XX-32
CurOnOff            leax      >L0219,pcr
                    ldb       #$01
                    bra       L01A8
L0219               ldx       <V.PORT,u
                    lda       <V.NChr2,u          get next character
                    cmpa      #$20                cursor code valid?
                    blt       WritErr             no, error
                    beq       L022D
                    cmpa      #$2A                color code in range?
                    bgt       L020F               no, ignore
CurOn               lda       #$05                cursor on (all colors=on)
                    bra       L022F
L022D               lda       #$45                cursor off
L022F               ldb       #$0C
                    stb       $01,x
                    sta       ,x
                    clrb
                    rts

                    emod
eom                 equ       *
                    end
