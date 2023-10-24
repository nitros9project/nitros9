********************************************************************
* CoHR - Hi-Res 51x24 Graphics Console Output Subroutine for VTIO
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??
* Original Dragon distribution version
*
*          2003/09/22  Rodney Hamilton
* Recoded fcb arrays, added labels & some comments
*
*          2004/11/15  P.Harvey-Smith
* Added code to turn off the drives on the Dragon Alpha.
*
*	   2004/12/01  P.Harvey-Smith
* Began converting drvr51 to CoHR, removed all keyboard
* related code, added symbolic defines for a lot of things.
*
*          2004/12/02  P.Harvey-Smith
* Finished converting to c051 driver, moved all variable
* storage into ccio module (defined in cciodefs).
*
*          2005/04/09  P.Harvey-Smith
* Replaced all ; comment chars with * for benefit of native
* asm. Re-implemented (hopefully) non-destructive cursor which
* is XORed onto the screen. Commented character drawing routines
* and replaced the V51xx names with more meaningful ones.
*
*          2005/04/24  P.Harvey-Smith
* Addded routines to flash the cursor, this is as it was in the
* Dragon Data 51 column driver.
*
                    nam       CoHR
                    ttl       Hi-Res 51x24 Graphics Console Output Subroutine for VTIO

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

size                equ       .

                    fcb       UPDAT.


ScreenSize          equ       $1800               * Screen Size in Bytes

name                fcs       /CoHR/
                    fcb       edition

start               lbra      Init
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

Init
                    pshs      u,a
                    ldd       #ScreenSize+$100    * Request a screenful of ram + $100 bytes
                    os9       F$SRqMem
                    bcs       InitExit            * Error : exit
                    tfr       u,d
                    ldu       $01,s               * Restore saved u
                    tfr       d,x
                    bita      #$01                * Check that memory block starts at even page
                    beq       L0066               * Yes base of screen = base of memory block
                    leax      >$0100,x            * no Move to next page
                    bra       L0068
L0066               adda      #$18
L0068               stx       V.51ScrnA,u
                    tfr       d,u
                    ldd       #$0100
                    os9       F$SRtMem            * Return unneeded page to OS
                    ldu       $01,s

                    clr       V.51CursorOn,u      * Flag cursor off
                    lbsr      DoHome
                    lbsr      DoReverseOff
                    lbsr      DoCLS
                    ldb       V.COLoad,u
                    orb       #ModCoHR            * set to CoHR found (?)

                    leax      FlashCursor,pcr     * Get address of cursor flash routine
                    stx       V.Flash,u

InitSaveExit
                    stb       V.COLoad,u
                    clrb
                    lda       #$FF
                    sta       V.CColr,u           * Flag Cursor as not hidden

InitExit
                    puls      pc,u,a

InitFlag            fcb       $00

Term                pshs      y,x
                    pshs      u                   * save U
                    ldd       #ScreenSize         * Graphics memory size
                    ldu       V.51ScrnA,u         * get pointer to memory
                    os9       F$SRtMem            * return to system
                    puls      u                   * restore U
                    ldb       V.COLoad,u
                    andb      #~ModCoHR           * Set CoHR unot loaded
                    bra       InitSaveExit

* Write
* Entry: A = char to write
*        Y = path desc ptr

Write

L012C               inc       V.Noflash,u         * Flag do not flash cursor
                    ldb       V.51EscSeq,u
                    bne       L0165
                    cmpa      #$1B                * escape?
                    bne       CheckForNormal
                    inc       V.51EscSeq,u        * flag ESC seq

WriteExit2
                    clr       V.NoFlash,u         * Allow cursor to flash
                    clrb
L0139               rts


CheckForNormal
                    cmpa      #$20
                    bcs       DoCtrlChar          * Control charater ?
                    cmpa      #$7F
                    bcc       DoCtrlChar          * or upper bit set
                    bra       DoNormalChar

DoCtrlChar
                    leax      >CtrlCharDispatch,pcr
L0148               tst       ,x
                    bne       L0150
CancelEscSequence
                    clr       V.51EscSeq,u
WriteExit
                    clr       V.NoFlash,u
                    rts

L0150               cmpa      ,x+
                    bne       L0161
                    ldd       ,x
                    leax      >CtrlCharDispatch,pcr
                    leax      d,x
                    stx       V.51CtrlDispatch,u
                    jsr       ,x
                    bra       WriteExit

L0161               leax      $02,x
                    bra       L0148

L0165               inc       V.51EscSeq,u
                    leax      >EscCharDispatch,pcr
                    cmpb      #$01
                    beq       L0148
                    jmp       [V.51CtrlDispatch,u]

DoNormalChar
                    pshs      y,a
*         lbsr  DoEraseCursor
                    puls      y,a
                    inc       V.51CursorChanged,u
                    bsr       DrawCharacter
                    tst       V.51UnderlineFlag,u * Are we underlining ?
                    beq       L0185               * no : update cursor
                    lda       #$F8                * Yes : do underline, then update cursor
                    leay      <-$40,y
                    lbsr      L0236

L0185               lda       V.51XPos,u          * Get current X pos
                    inca                          * increment it
                    cmpa      #$33                * past end of line ?
                    bcs       L01A2               * no : continue
                    clr       V.51XPos,u          * Yes reset x=0
                    lda       V.51YPos,u          * increment y pos
                    inca
                    cmpa      #$18                * Past last line ?
                    bcs       L019D               * No : continue
                    lbsr      SoScrollScreen      * Yes : scroll screen one line
                    bra       L01A5
L019D               sta       V.51YPos,u          * Ypdate Y pos
                    bra       L01A5

L01A2               sta       V.51XPos,u          * Update X pos
L01A5
                    ldd       V.51XPos,u          * Update old Cursor pos
                    std       V.51OldCursorPosX,u
                    dec       V.51CursorChanged,u
                    clr       V.51CursorOn,u
*         lbsr  DoDisplayCursor * Display cursor

                    lbra      WriteExit2
                    clrb                          * Flag no error
                    rts                           * Return to caller

*
* Draw the normal character $20..$7f, in the a register
* at position stored in V.51Xpos,V.51Ypos
*

DrawCharacter
                    tfr       a,b
                    subb      #$20                * Make b an offset into table
                    clra
                    leax      >CharacterShapes,pcr * point to character shape table
                    lslb                          * Multiply b by 4 into d (4 bytes/character)
                    rola
                    lslb
                    rola
                    leax      d,x                 * Point X at required character's bitmap
                    ldb       #$05                * Work out pixel X co-ordinate of current cursor
                    lda       V.51XPos,u
                    mul
                    pshs      b                   * Save pixel x
                    lsra                          * Divide pixel-x by 8, to get byte offset into line
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    puls      a                   * restore pixel X
                    anda      #$07                * Calculate offset within byte where character begins
                    pshs      b
                    sta       V.51BytePixOffset,u
                    tst       V.51XORFlag,u
                    bne       L01FF
                    tfr       a,b                 * Calculate a mask for character data
                    lda       #$F8                * shifts $f8 right b times
                    tstb
                    beq       L01FA               * Done all bits ?
L01E5               lsra                          * shift mask right
                    decb                          * decrement count
                    bhi       L01E5               * done all ?
                    bne       L01EE               * have we shifted any mask bits off right hand end ?
                    rorb
                    bra       L01FA

L01EE               pshs      b                   * Save count on stack
                    ldb       #$80                * start to build mask for second byte as well
L01F2               lsra                          * shift bits from bottom of a to top of b
                    rorb
                    dec       ,s                  * decrement count
                    bne       L01F2               * if any shifts left loop again
                    leas      $01,s               * drop count

* When we reach here we should have a pair of bytes in d which indicate where exactly the
* character should be drawn, this may be partly in each

L01FA               coma
                    comb
                    std       V.51ScreenMask1,u   * Save screen mask

* The code below works out the offset of the character cell to be updated, this works because
* the y co ordinate is loaded into the high byte of d, effectivley multiplying it by 256, since
* each screen line is 32 bytes wide, and each character is 8 pixels tall this works out as 8x32=256

L01FF               ldy       V.51ScrnA,u         * Point y at screen memory address
                    lda       V.51YPos,u
                    ldb       ,s+                 * Retrieve byte offset from stack
                    leay      d,y                 * calculate screen address.
                    lda       #$04                * get character data byte count, 4 bytes of 8 nibbles
                    pshs      a
                    inc       V.51CursorChanged,u * flag character at cursor being changed

L0211               lda       ,x                  * get a byte from character data
                    anda      #$F0                * mask out even line
                    bsr       L0236               * update screen
                    lda       ,x+                 * Get again
                    anda      #$0F                * mask out odd line
                    bsr       L0227               * update screen
                    dec       ,s                  * Decrement character data byte counter
                    bne       L0211               * all done ?
                    dec       V.51CursorChanged,u * Flag character update finished
                    clrb                          * flag no error
                    puls      pc,b                * return to caller


L0227               ldb       V.51BytePixOffset,u
                    subb      #$04
                    bhi       L023B
                    beq       L0250
L0230               lsla
                    incb
                    bne       L0230
                    bra       L0250

L0236               ldb       V.51BytePixOffset,u * Retrieve byte pixel offset
                    beq       L0250

L023B               lsra                          * manipulate character data into correct position
                    decb                          * in a similar way to the mask above
                    bhi       L023B
                    bne       L0244
                    rorb
                    bra       L0250
L0244               pshs      b
                    ldb       #$80
L0248               lsra
                    rorb
                    dec       ,s
                    bne       L0248
                    leas      $01,s

L0250               tst       V.51XORFlag,u       * are we XORing data direct to screen ?
                    bne       L0273               * Yes : just do it
                    tst       V.51ReverseFlag,u   * are we in reverse mode ?
                    beq       L0262               * no : just output data
                    coma                          * set mask up for reverse mode
                    comb
                    eora      V.51ScreenMask1,u
                    eorb      V.51ScreenMask2,u

L0262               pshs      b,a                 * combine mask and screen data
                    ldd       V.51ScreenMask1,u
                    anda      ,y
                    andb      $01,y
                    addd      ,s++

L026D               std       ,y                  * screen update
                    leay      <$20,y
                    rts

L0273               eora      ,y                  * XOR onto screen
                    eorb      $01,y
                    bra       L026D

*
* $07 - BEL (ding!)
*

DoBell
                    ldx       #$FF20
                    ldb       #$64
L027E               lda       ,x
                    eora      #$C0
                    sta       ,x
                    lda       #$19
L0286               deca
                    nop
                    nop
                    bne       L0286
                    decb
                    bne       L027E
                    lbra      CancelEscSequence
*
* $08 - BS (left arrow)
*
DoBackspace
                    lbsr      DoEraseCursor
                    dec       V.51XPos,u
                    bpl       DoBSUpdateCursor
                    lda       #$32
                    sta       V.51XPos,u
                    bra       DoCursorUp1
*
* $1b44 - (cursor up)
*
DoCursorUp
                    lbsr      DoEraseCursor
DoCursorUp1
                    dec       V.51YPos,u
                    bpl       L02A6
                    clr       V.51YPos,u
                    lbsr      L035E
L02A6               lbsr      L0484
                    lbra      CancelEscSequence

DoBSUpdateCursor
                    lbsr      L0484
                    clr       V.51CursorOn,u
*         lbsr  DoDisplayCursor
                    rts

*
* $0a, $1b45 - LF, (cursor down)
*

DoLineFeed
                    lbsr      DoEraseCursor
                    lda       V.51YPos,u
                    inca
                    cmpa      #$18
                    bcs       L02B9
                    lbsr      SoScrollScreen
                    bra       L02BC
L02B9               sta       V.51YPos,u
L02BC
                    clr       V.51CursorOn,u
*        lbsr  DoDisplayCursor
                    bra       L02A6

*
* $0d - CR (return)
*

DoCarrageReturn
                    lbsr      DoEraseCursor
                    clr       V.51XPos,u
                    bra       L02A6

*
* $0c - FF (clear screen)
*
DoCLS
                    ldy       V.51ScrnA,u
                    leay      >$0080,y
                    lda       #$18
                    pshs      a
                    inc       V.51CursorChanged,u
L02D2               bsr       L0314
                    dec       ,s
                    bne       L02D2
                    leas      $01,s
                    clra
                    clrb
                    std       V.51OldCursorPosX,u
                    std       V.51XPos,u
                    dec       V.51CursorChanged,u
                    ldx       #$FF20
                    lda       $02,x
                    ora       #$F0
                    sta       $02,x
                    ldx       #$FFC0
                    lda       #$06
                    ldb       #$03
                    bsr       L0305
                    lda       V.51ScrnA,u
                    lsra
                    ldb       #$07
                    bsr       L0305
                    clr       V.51CursorOn,u      * Flag cursor is off
*         lbsr  DoDisplayCursor * Display cursor
                    lbra      CancelEscSequence

L0305               lsra
                    bcc       L030E
                    leax      $01,x
                    sta       ,x+
                    bra       L0310
L030E               sta       ,x++
L0310               decb
                    bne       L0305
                    rts

L0314               lda       #$10
L0316               pshs      a
                    lda       V.51ReverseFlag,u
                    tfr       a,b
L031D               std       <-$80,y
                    std       <-$60,y
                    std       <-$40,y
                    std       <-$20,y
                    std       <$20,y
                    std       <$40,y
                    std       <$60,y
                    std       ,y++
                    dec       ,s
                    bne       L031D
                    leay      >$00E0,y
                    puls      pc,b

SoScrollScreen
                    ldy       V.51ScrnA,u
                    inc       V.51CursorChanged,u
                    pshs      u
                    leau      >$0100,y
                    lda       #$10
                    bsr       L037C
                    puls      u
                    dec       V.51OldCursorPosY,u

L0354               leay      >$0080,y
                    bsr       L0314
                    dec       V.51CursorChanged,u
                    rts

L035E               ldy       V.51ScrnA,u
                    leay      >$17F0,y
                    inc       V.51CursorChanged,u
                    pshs      u
                    leau      >-$0100,y
                    lda       #$F0
                    bsr       L037C
                    leay      ,u
                    puls      u
                    inc       V.51OldCursorPosY,u
                    bra       L0354

L037C               ldb       #$17
                    pshs      b
L0380               ldb       #$10

L0382               ldx       ,u
                    stx       ,y
                    ldx       $02,u
                    stx       $02,y
                    ldx       $04,u
                    stx       $04,y
                    ldx       $06,u
                    stx       $06,y
                    ldx       $08,u
                    stx       $08,y
                    ldx       $0A,u
                    stx       $0A,y
                    ldx       $0C,u
                    stx       $0C,y
                    ldx       $0E,u
                    stx       $0E,y
                    leay      a,y
                    leau      a,u
                    decb
                    bne       L0382
                    dec       ,s
                    bne       L0380
                    puls      pc,b

DelLine
                    clrb
                    stb       V.51XPos,u
                    clr       V.51CursorOn,u
*         lbsr  DoDisplayCursor
*
* $1b42 - clear to end of line
*
DoClrEOL
                    inc       V.51CursorChanged,u
                    bsr       L03BA
                    dec       V.51CursorChanged,u
                    lbra      CancelEscSequence
L03BA
                    ldb       V.51XPos,u
                    pshs      b
                    bitb      #$07
                    bne       L03CB
                    lda       #$05
                    mul
                    bra       L03F3
L03CB               lda       #$01
                    pshs      a
L03CF               lda       #$20
                    lbsr      DrawCharacter
                    lda       V.51XPos,u
                    inca
                    sta       V.51XPos,u
                    cmpa      #$33
                    bcs       L03E3
                    leas      $01,s
                    bra       L040D
L03E3               dec       ,s
                    bpl       L03CF
                    lda       V.51XPos,u
                    ldb       #$05
                    mul
                    bitb      #$08
                    bne       L03CF
                    leas      $01,s
L03F3               lsrb
                    lsrb
                    lsrb
                    ldy       V.51ScrnA,u
                    lda       V.51YPos,u
                    leay      d,y
                    leay      >$0080,y
                    lda       #$20
                    pshs      b
                    suba      ,s+
                    lsra
                    lbsr      L0316
L040D               puls      a
                    sta       V.51XPos,u
                    clr       V.51CursorOn,u
*         lbsr  DoDisplayCursor
                    rts
*
* $1b4A - clear to end of screen
*
DoClearEOS
                    inc       V.51CursorChanged,u
                    bsr       L03BA
                    lda       #$17
                    suba      V.51YPos,u
                    bls       L042A
                    pshs      a
L0421               lbsr      L0314
                    dec       ,s
                    bne       L0421
                    leas      $01,s
L042A               dec       V.51CursorChanged,u
                    clr       V.51CursorOn,u
                    *         lbsr                DoDisplayCursor
                    lbra      CancelEscSequence

*
*$0b - (cursor home)
*
DoHome
                    lbsr      DoEraseCursor
                    clr       V.51XPos,u
                    clr       V.51YPos,u
                    clr       V.51CursorOn,u
                    clr       V.51CursorOn,u
*         lbsr  DoDisplayCursor
                    lbra      L02A6

*
* $05 XX - set cursor off/on/color per XX-32 from COVDG (only on/off supported)
*
SetCrsr             ldb       #$01                need additional byte
                    leax      <CrsrSw,pcr
                    bra       L01E5V
CrsrSw              lda       <V.NChr2,u          get next char
                    suba      #C$SPAC             take out ASCII space
                    bne       L01BBV              branch if not zero - show cursor
                    clr       V.CColr,u
                    lbra      CancelEscSequence
L01BBV
                    ldb       #$FF
                    stb       V.CColr,u
                    lbra      CancelEscSequence

*
* $02 XX YY - move cursor to col XX-32, row YY-32 from COVDG
*
CurXY               ldb       #$02                we want to claim next two chars
                    leax      <DoCurXY,pcr        point to processing routine
L01E5V              stx       <V.RTAdd,u          store routine to return to
                    stb       <V.NGChr,u          get two more chars
                    clrb
                    rts

DoCurXY             lbsr      DoEraseCursor       hide cursor
                    ldb       <V.NChr2,u          get ASCII Y-pos
                    subb      #C$SPAC             take out ASCII space
                    stb       V.51YPos,u
                    ldb       <V.NChar,u          get X-pos
                    subb      #C$SPAC             take out ASCII space
                    stb       V.51XPos,u
                    clr       V.51CursorOn,u
*         lbsr  DoDisplayCursor
                    lbra      L02A6

*
* $1b41xxyy - move cursor to col xx (0-50) row yy (0-23)
*
DoGotoXY
                    lbsr      DoEraseCursor
                    ldb       V.51EscSeq,u
                    subb      #$02
                    bne       L0442
                    clrb
                    rts
L0442               decb
                    bne       L0450
                    cmpa      #51
                    bcs       L044B
                    lda       #50
L044B               sta       V.51XPos,u
L044D               clrb
                    rts
L0450               cmpa      #24
                    bcs       L0456
                    lda       #23
L0456               sta       V.51YPos,u
L0459               clr       V.51CursorOn,u
*        lbsr  DoDisplayCursor
                    lbra      L02A6

*
* $1b43 - (cursor right)
*
DoCursorRight
                    lbsr      DoEraseCursor
                    inc       V.51XPos,u
                    lda       V.51XPos,u
                    cmpa      #$33
                    bcs       L0459
                    clr       V.51XPos,u
                    lbra      DoLineFeed
*
* $1b46 - reverse on
*
DoReverseOn
                    lda       #$FF
                    coma
L046F               sta       V.51ReverseFlag,u
                    lbra      CancelEscSequence

*
* $1b47 - reverse off
*
DoReverseOff
                    lda       #$FF
                    bra       L046F

*
* $1b48 - underline on
*
DoUnderlineOn
                    lda       #$FF
L047B               sta       V.51UnderlineFlag,u
                    lbra      CancelEscSequence

*
* $1b49 - underline off
*
DoUnderlineOff
                    clra
                    bra       L047B


L0484               ldd       V.51XPos,u
                    inc       V.51CursorChanged,u
                    std       V.51OldCursorPosX,u
                    bra       L04B9

L0494               pshs      b,a
                    ldd       V.51OldCursorPosX,u
                    inc       V.51XORFlag,u
                    tstb
                    bmi       L04AB
                    cmpb      #$18
                    bcc       L04AB
                    std       V.51XPos,u
                    lda       #$7F
                    lbsr      DrawCharacter

L04AB               puls      b,a
                    std       V.51XPos,u
                    std       V.51OldCursorPosX,u
                    dec       V.51XORFlag,u
L04B9               dec       V.51CursorChanged,u
                    clrb
                    rts

*
* Display and Erase cursor routines, work by xoring cursor character onto the
* screen, the variable V.51CursorOn, is implemented such that it prevents
* multiple calls to these routines from acting as an inverse, so that they
* may be called from any code, irispective of if the cursor is already on/off.
*

*
* Display Cursor.
*
DoDisplayCursor
                    tst       V.CColr,u
                    beq       NoCrsr
                    inc       V.NoFlash,u         * Flag in flash
                    tst       V.51CursorOn,u      * Get cursor on flag
                    bne       DoCursorOnEnd       * Yes : don't re-display
                    bsr       DoCursorCommon      * Display cursor
                    inc       V.51CursorOn,u      * Flag cursor on
DoCursorOnEnd
                    dec       V.NoFlash,u         * Flag flash done
NoCrsr              rts
*
* Erase cursor
*
DoEraseCursor
                    inc       V.NoFlash,u         * Flag in Flash
                    tst       V.51Cursoron,u      * Get cursor on flag
                    beq       DoEraseCursorEnd    * no : don't atempt to turn off
                    bsr       DoCursorCommon      * Hide cursor
                    clr       V.51CursorOn,u      * Flag cursor off
DoEraseCursorEnd
                    dec       V.NoFlash,u         * Flag Flash done
                    rts

DoCursorCommon
                    lda       #$7f                * Cursor character $7f = block
                    inc       V.51XORFlag,u       * Flag xor on screen
                    lbsr      DrawCharacter       * Draw it
                    dec       V.51XORFlag,u       * Flag no xor on screen
                    rts

L04CA               clrb
                    rts
GetStat
                    cmpa      #$06
                    beq       L04CA
                    cmpa      #$02
                    bne       SetStat
                    ldx       $06,y
                    ldd       V.51ScrnA,u
                    std       $04,x
                    clrb
                    rts

SetStat             comb
                    ldb       #E$UnkSvc
                    rts

*
* Flash cursor, called by IRQ routine from VTIO
*

FlashCursor
                    tst       V.NoFlash,u         * Should we flash ?
                    bne       FlashExit           * No: just return
                    tst       V.51CursorOn,u      * Is cursor on ?
                    bne       FlashOff            * Yep : turn off
                    bra       DoDisplayCursor     * Else turn it on
FlashOff
                    bra       DoEraseCursor
FlashExit
                    rts


* control characters dispatch table
CtrlCharDispatch
                    fcb       $01
                    fdb       DoHome-CtrlCharDispatch * COVDG CurHome
                    fcb       $02
                    fdb       CurXY-CtrlCharDispatch * COVDG CURSOR XY
                    fcb       $03
                    fdb       DelLine-CtrlCharDispatch * COVDG ERASE LINE
                    fcb       $04
                    fdb       DoClrEOL-CtrlCharDispatch * COVDG ErEOLine
                    fcb       $05
                    fdb       SetCrsr-CtrlCharDispatch * COVDG CURSOR ON/OFF
                    fcb       $06
                    fdb       DoCursorRight-CtrlCharDispatch * COVDG CurRght
                    fcb       $07                 BEL 		* (beep)
                    fdb       DoBell-CtrlCharDispatch $FC0B
                    fcb       $08                 BS 		* (left arrow)
                    fdb       DoBackspace-CtrlCharDispatch * $FC23
                    fcb       $09
                    fdb       DoCursorUp-CtrlCharDispatch * COVDG CurUp
                    fcb       $0A                 LF 		* (down arrow)
                    fdb       DoLineFeed-CtrlCharDispatch * $FC3E
                    fcb       $0D                 CR 		* (return)
                    fdb       DoCarrageReturn-CtrlCharDispatch *$FC50
                    fcb       $0C                 FF 		* (clear screen)
                    fdb       DoCLS-CtrlCharDispatch $FC55
                    fcb       $0B                 * (cursor home)
* Since few applications use CoHR $0B, support COVDG $0B instead
*        fdb   DoHome-CtrlCharDispatch $FDC2    * Was CoHR DoHome
                    fdb       DoClearEOS-CtrlCharDispatch * COVDG ErEOScrn
                    fcb       $00

* escape sequences dispatch table
EscCharDispatch
                    fcb       $41                 * cursor xy
                    fdb       DoGotoXY-CtrlCharDispatch * $FDCB
                    fcb       $42                 * clear EOL
                    fdb       DoClrEOL-CtrlCharDispatch * $FD41
                    fcb       $43                 * cursor right
                    fdb       DoCursorRight-CtrlCharDispatch * $FDEE
                    fcb       $44                 * cursor up
                    fdb       DoCursorUp-CtrlCharDispatch * $FC2D
                    fcb       $45                 * cursor down
                    fdb       DoLineFeed-CtrlCharDispatch * $FC3E
                    fcb       $46                 * reverse on
                    fdb       DoReverseOn-CtrlCharDispatch * $FDFE
                    fcb       $47                 * reverse off
                    fdb       DoReverseOff-CtrlCharDispatch * $FE07
                    fcb       $48                 * underline on
                    fdb       DoUnderlineOn-CtrlCharDispatch * $FE0B
                    fcb       $49                 * underline off
                    fdb       DoUnderlineOff-CtrlCharDispatch * $FE13
                    fcb       $4A                 * clear EOS
                    fdb       DoClearEOS-CtrlCharDispatch * $FDA5
                    fcb       $00

CharacterShapes
* 4x8 bitmap table for characters $20-$7f
* each nibble represents a row of 4 dots
* chars 20-27
                    fcb       $00,$00,$00,$00     ....  .@..  .@.@  .@@.  ..@.  @..@  .@..  .@..
                    fcb       $44,$40,$40,$00     ....  .@..  .@.@  @@@@  .@@@  ...@  @.@.  .@..
                    fcb       $55,$00,$00,$00     ....  .@..  ....  .@@.  @...  ..@.  .@..  ....
                    fcb       $6F,$6F,$60,$00     ....  ....  ....  @@@@  .@@.  .@..  @.@.  ....
                    fcb       $27,$86,$1E,$20     ....  .@..  ....  .@@.  ...@  @...  @@.@  ....
                    fcb       $91,$24,$89,$00     ....  ....  ....  ....  @@@.  @..@  ....  ....
                    fcb       $4A,$4A,$D0,$00     ....  ....  ....  ....  ..@.  ....  ....  ....
                    fcb       $44,$00,$00,$00     ....  ....  ....  ....  ....  ....  ....  ....
* chars 29-2f
                    fcb       $24,$44,$20,$00     ..@.  .@..  @..@  .@..  ....  ....  ....  ....
                    fcb       $42,$22,$40,$00     .@..  ..@.  .@@.  .@..  ....  ....  ....  ...@
                    fcb       $96,$F6,$90,$00     .@..  ..@.  @@@@  @@@.  ....  @@@@  ....  ..@.
                    fcb       $44,$E4,$40,$00     .@..  ..@.  .@@.  .@..  ..@.  ....  .@@.  .@..
                    fcb       $00,$02,$24,$00     ..@.  .@..  @..@  .@..  ..@.  ....  .@@.  @...
                    fcb       $00,$F0,$00,$00     ....  ....  ....  ....  .@..  ....  ....  ....
                    fcb       $00,$06,$60,$00     ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $01,$24,$80,$00     ....  ....  ....  ....  ....  ....  ....  ....
* chars 30-37
                    fcb       $69,$BD,$60,$00     .@@.  ..@.  .@@.  @@@.  ..@.  @@@@  .@@@  @@@@
                    fcb       $26,$22,$70,$00     @..@  .@@.  @..@  ...@  .@@.  @...  @...  ...@
                    fcb       $69,$2C,$F0,$00     @.@@  ..@.  ..@.  .@@.  @.@.  @@@.  @@@.  ..@.
                    fcb       $E1,$61,$E0,$00     @@.@  ..@.  @@..  ...@  @@@@  ...@  @..@  .@..
                    fcb       $26,$AF,$20,$00     .@@.  .@@@  @@@@  @@@.  ..@.  @@@.  .@@.  .@..
                    fcb       $F8,$E1,$E0,$00     ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $78,$E9,$60,$00     ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $F1,$24,$40,$00     ....  ....  ....  ....  ....  ....  ....  ....
* chars 38-3f
                    fcb       $69,$69,$60,$00     .@@.  .@@.  ....  ....  ..@.  ....  .@..  .@@.
                    fcb       $69,$71,$60,$00     @..@  @..@  ....  ....  .@..  @@@@  ..@.  @..@
                    fcb       $00,$40,$40,$00     .@@.  .@@@  .@..  ..@.  @...  ....  ...@  ..@.
                    fcb       $00,$20,$24,$00     @..@  ...@  ....  ....  .@..  @@@@  ..@.  ..@.
                    fcb       $24,$84,$20,$00     .@@.  .@@.  .@..  ..@.  ..@.  ....  .@..  ....
                    fcb       $0F,$0F,$00,$00     ....  ....  ....  .@..  ....  ....  ....  ..@.
                    fcb       $42,$12,$40,$00     ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $69,$22,$02,$00     ....  ....  ....  ....  ....  ....  ....  ....
* chars 40-47
                    fcb       $69,$BB,$87,$00     .@@.  .@@.  @@@.  .@@@  @@@.  @@@@  @@@@  .@@@
                    fcb       $69,$F9,$90,$00     @..@  @..@  @..@  @...  @..@  @...  @...  @...
                    fcb       $E9,$E9,$E0,$00     @.@@  @@@@  @@@.  @...  @..@  @@@.  @@@.  @.@@
                    fcb       $78,$88,$70,$00     @.@@  @..@  @..@  @...  @..@  @...  @...  @..@
                    fcb       $E9,$99,$E0,$00     @...  @..@  @@@.  .@@@  @@@.  @@@@  @...  .@@@
                    fcb       $F8,$E8,$F0,$00     .@@@  ....  ....  ....  ....  ....  ....  ....
                    fcb       $F8,$E8,$80,$00     ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $78,$B9,$70,$00     ....  ....  ....  ....  ....  ....  ....  ....
* chars 48-4f
                    fcb       $99,$F9,$90,$00     @..@  @@@.  @@@@  @..@  @...  @@@@  @..@  .@@.
                    fcb       $E4,$44,$E0,$00     @..@  .@..  ..@.  @.@.  @...  @@.@  @@.@  @..@
                    fcb       $F2,$2A,$40,$00     @@@@  .@..  ..@.  @@..  @...  @@.@  @.@@  @..@
                    fcb       $9A,$CA,$90,$00     @..@  .@..  @.@.  @.@.  @...  @..@  @..@  @..@
                    fcb       $88,$88,$F0,$00     @..@  @@@.  .@..  @..@  @@@@  @..@  @..@  .@@.
                    fcb       $FD,$D9,$90,$00     ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $9D,$B9,$90,$00     ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $69,$99,$60,$00     ....  ....  ....  ....  ....  ....  ....  ....
* chars 50-57
                    fcb       $E9,$E8,$80,$00     @@@.  .@@.  @@@.  .@@@  @@@.  @..@  @..@  @..@
                    fcb       $69,$9B,$70,$00     @..@  @..@  @..@  @...  .@..  @..@  @..@  @..@
                    fcb       $E9,$EA,$90,$00     @@@.  @..@  @@@.  .@@.  .@..  @..@  @..@  @@.@
                    fcb       $78,$61,$E0,$00     @...  @.@@  @.@.  ...@  .@..  @..@  .@@.  @@.@
                    fcb       $E4,$44,$40,$00     @...  .@@@  @..@  @@@.  .@..  .@@.  .@@.  @@@@
                    fcb       $99,$99,$60,$00     ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $99,$96,$60,$00     ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $99,$DD,$F0,$00     ....  ....  ....  ....  ....  ....  ....  ....
* chars 58-5f
                    fcb       $99,$69,$90,$00     @..@  @..@  @@@@  @@@.  ....  .@@@  .@@.  ....
                    fcb       $99,$71,$E0,$00     @..@  @..@  ...@  @...  @...  ...@  @..@  ....
                    fcb       $F1,$68,$F0,$00     .@@.  .@@@  .@@.  @...  .@..  ...@  ....  ....
                    fcb       $E8,$88,$E0,$00     @..@  ...@  @...  @...  ..@.  ...@  ....  ....
                    fcb       $08,$42,$10,$00     @..@  @@@.  @@@@  @@@.  ...@  .@@@  ....  ....
                    fcb       $71,$11,$70,$00     ....  ....  ....  ....  ....  ....  ....  @@@@
                    fcb       $69,$00,$00,$00     ....  ....  ....  ....  ....  ....  ....  ....
                    fcb       $00,$00,$0F,$00     ....  ....  ....  ....  ....  ....  ....  ....
* chars 60-67
                    fcb       $22,$00,$00,$00     ..@.  ....  @...  ....  ...@  ....  ..@@  ....
                    fcb       $07,$99,$70,$00     ..@.  .@@@  @@@.  .@@@  .@@@  .@@@  .@..  .@@.
                    fcb       $8E,$99,$E0,$00     ....  @..@  @..@  @...  @..@  @.@.  @@@@  @..@
                    fcb       $07,$88,$70,$00     ....  @..@  @..@  @...  @..@  @@..  .@..  @..@
                    fcb       $17,$99,$70,$00     ....  .@@@  @@@.  .@@@  .@@@  .@@@  .@..  .@@@
                    fcb       $07,$AC,$70,$00     ....  ....  ....  ....  ....  ....  ....  ...@
                    fcb       $34,$F4,$40,$00     ....  ....  ....  ....  ....  ....  ....  @@@.
                    fcb       $06,$99,$71,$E0     ....  ....  ....  ....  ....  ....  ....  ....
* chars 68-6f
                    fcb       $8E,$99,$90,$00     @...  .@..  ..@.  @...  .@..  ....  ....  ....
                    fcb       $40,$44,$40,$00     @@@.  ....  ....  @.@.  .@..  .@@@  .@@@  .@@.
                    fcb       $20,$22,$22,$C0     @..@  .@..  ..@.  @@..  .@..  @@.@  @..@  @..@
                    fcb       $8A,$CA,$90,$00     @..@  .@..  ..@.  @.@.  .@..  @@.@  @..@  @..@
                    fcb       $44,$44,$40,$00     @..@  .@..  ..@.  @..@  .@..  @..@  @..@  .@@.
                    fcb       $0E,$DD,$90,$00     ....  ....  ..@.  ....  ....  ....  ....  ....
                    fcb       $0E,$99,$90,$00     ....  ....  @@..  ....  ....  ....  ....  ....
                    fcb       $06,$99,$60,$00     ....  ....  ....  ....  ....  ....  ....  ....
* chars 70-77
                    fcb       $0E,$99,$E8,$80     ....  ....  ....  ....  .@..  ....  ....  ....
                    fcb       $07,$99,$71,$10     @@@.  .@@@  .@@@  .@@@  @@@@  @..@  @..@  @..@
                    fcb       $07,$88,$80,$00     @..@  @..@  @...  @@..  .@..  @..@  @..@  @@.@
                    fcb       $07,$C3,$E0,$00     @..@  @..@  @...  ..@@  .@..  @..@  .@@.  @@.@
                    fcb       $4F,$44,$30,$00     @@@.  .@@@  @...  @@@.  ..@@  .@@@  .@@.  .@@.
                    fcb       $09,$99,$70,$00     @...  ...@  ....  ....  ....  ....  ....  ....
                    fcb       $09,$96,$60,$00     @...  ...@  ....  ....  ....  ....  ....  ....
                    fcb       $09,$DD,$60,$00     ....  ....  ....  ....  ....  ....  ....  ....
* chars 78-7f
                    fcb       $09,$66,$90,$00     ....  ....  ....  ..@@  .@..  @@..  ....  @@@@
                    fcb       $09,$99,$71,$E0     @..@  @..@  @@@@  .@..  .@..  ..@.  .@.@  @@@@
                    fcb       $0F,$24,$F0,$00     .@@.  @..@  ..@.  @@..  ....  ..@@  @.@.  @@@@
                    fcb       $34,$C4,$30,$00     .@@.  @..@  .@..  .@..  .@..  ..@.  ....  @@@@
                    fcb       $44,$04,$40,$00     @..@  .@@@  @@@@  ..@@  .@..  @@..  ....  @@@@
                    fcb       $C2,$32,$C0,$00     ....  ...@  ....  ....  ....  ....  ....  @@@@
                    fcb       $05,$A0,$00,$00     ....  @@@.  ....  ....  ....  ....  ....  @@@@
                    fcb       $FF,$FF,$FF,$F0     ....  ....  ....  ....  ....  ....  ....  ....

                    emod
eom                 equ       *
                    end
