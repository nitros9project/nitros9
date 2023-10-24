********************************************************************
* Co42 - Hi-Res 42x24 Graphics Console Output Subroutine for VTIO
* Based from CoHR
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
*          2017/04/23  Felipe Antoniosi
* Create this driver as 42x24 column
*
*          2018/01/20  David Ladd
* Moved Driver Entry Table closer to Term to allow fall through.
* This is to save bytes and cycles.  Changed lbra Write to bra
* Write to save cyrcles each time characters are written to screen.
* Also changed lda and ldb to a ldd to save cycle(s) and space.
* Also a few other optimizations to code.
*

                    nam       Co42
                    ttl       Hi-Res 42x24 Graphics Console Output Subroutine for VTIO

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

name                fcs       /Co42/
                    fcb       edition

Init                pshs      u,a
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
                    orb       #ModCo42            * set to Co42 found (?)

                    leax      FlashCursor,pcr     * Get address of cursor flash routine
                    stx       V.Flash,u

InitSaveExit
                    stb       V.COLoad,u
                    clrb
                    lda       #$FF
                    sta       V.CColr,u           * Flag Cursor as not hidden

InitExit
                    puls      pc,u,a

* InitFlag fcb   $00

start               lbra      Init
                    bra       Write
                    nop
                    lbra      GetStat
                    lbra      SetStat

Term                pshs      y,x
                    pshs      u                   * save U
                    ldd       #ScreenSize         * Graphics memory size
                    ldu       V.51ScrnA,u         * get pointer to memory
                    os9       F$SRtMem            * return to system
                    puls      u                   * restore U
                    ldb       V.COLoad,u
                    andb      #~ModCo42           * Set CoHR unot loaded
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
                    clrb
                    stb       V.NoFlash,u         * Allow cursor to flash
L0139               rts


CheckForNormal
                    cmpa      #$20
                    blo       DoCtrlChar          * Control charater ?
                    cmpa      #$7F
                    blo       DoNormalChar

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
*         pshs  y,a
*         lbsr  DoEraseCursor
*         puls  y,a
                    inc       V.51CursorChanged,u
                    bsr       DrawCharacter
                    lda       V.51UnderlineFlag,u * Are we underlining ?
                    beq       L0185               * no : update cursor
                    lda       #$FC                * Yes : do underline, then update cursor
                    leay      <-$20,y
                    lbsr      L0236

L0185               lda       V.51XPos,u          * Get current X pos
                    inca                          * increment it
                    cmpa      #42                 * past end of line ?
                    bcs       L01A2               * no : continue
                    clr       V.51XPos,u          * Yes reset x=0
                    lda       V.51YPos,u          * increment y pos
                    inca
                    cmpa      #24                 * Past last line ?
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
*         clrb             * Flag no error
*         rts              * Return to caller

*
* Draw the normal character $20..$7f, in the a register
* at position stored in V.51Xpos,V.51Ypos
*

DrawCharacter
                    tfr       a,b
                    subb      #$20                * Make b an offset into table
                    lda       #5
                    leax      >CharacterShapes,pcr * point to character shape table
                    mul                           * Multiply by 5 (5 bytes / character)
                    leax      d,x                 * Point X at required character's bitmap
                    ldb       #$06                * Work out pixel X co-ordinate of current cursor
                    lda       V.51XPos,u
                    mul
                    pshs      b                   * Save pixel x
                    lsra                          * Divide pixel-x by 8, to get byte offset into line
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    lda       ,s
                    anda      #$07                * Calculate offset within byte where character begins
                    stb       ,s
*         puls  a          * restore pixel X
*         anda  #$07       * Calculate offset within byte where character begins
*         pshs  b
                    sta       V.51BytePixOffset,u
                    tst       V.51XORFlag,u
                    bne       L01FF
                    tfr       a,b                 * Calculate a mask for character data
                    lda       #$FC                * shifts $fc right b times
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
*         lda   #$08       * get character data byte count, 8 bytes
*         pshs  a
                    inc       V.51CursorChanged,u * flag character at cursor being changed

* The caracters are packed in 5-bytes following the order
* 00000111
* 11222223
* 33334444
* 45555566
* 66677777

L0211               lda       ,x                  * row 0
                    anda      #$F8                * mask out character
                    bsr       L0236               * update screen

                    lda       ,x+                 * row 1
                    ldb       ,x
                    lsra
                    rorb
                    lsra
                    rorb
                    lsra
                    rorb
                    tfr       b,a
                    anda      #$F8                * mask out character
                    bsr       L0236               * update screen

                    lda       ,x                  * row 2
                    lsla
                    lsla
                    anda      #$F8                * mask out character
                    bsr       L0236               * update screen

                    lda       ,x+                 * row 3
                    ldb       ,x
                    lsra
                    rorb
                    tfr       b,a
                    anda      #$F8                * mask out character
                    bsr       L0236               * update screen

                    lda       ,x+                 * row 4
                    ldb       ,x
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    anda      #$F8                * mask out character
                    bsr       L0236               * update screen

                    lda       ,x                  * row 5
                    lsla
                    anda      #$F8                * mask out character
                    bsr       L0236               * update screen

                    lda       ,x+                 * row 6
                    ldb       ,x
                    lsra
                    rorb
                    lsra
                    rorb
                    tfr       b,a
                    anda      #$F8                * mask out character
                    bsr       L0236               * update screen

                    lda       ,x                  * row 7
                    lsla
                    lsla
                    lsla
                    anda      #$F8                * mask out character
                    bsr       L0236               * update screen

*         dec   ,s         * Decrement character data byte counter
*         bne   L0211      * all done ?
                    dec       V.51CursorChanged,u * Flag character update finished
                    clrb                          * flag no error
                    rts                           * return to caller


*L0227    ldb   V.51BytePixOffset,u
*         subb  #$04
*         bhi   L023B
*         beq   L0250
*L0230    lsla
*         incb
*         bne   L0230
*         bra   L0250

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
                    lda       #41
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
*       lbsr  DoDisplayCursor
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
                    ldd       #$0603
*         lda   #$06
*         ldb   #$03
                    bsr       L0305
                    lda       V.51ScrnA,u
                    lsra
                    ldb       #$07
                    bsr       L0305
                    clr       V.51CursorOn,u      * Flag cursor is off
**        lbsr  DoDisplayCursor * Display cursor
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
                    stb       V.51CursorOn,u
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
                    lda       #$06
                    mul
                    bra       L03F3
L03CB               lda       #$01
                    pshs      a
L03CF               lda       #$20
                    lbsr      DrawCharacter
                    lda       V.51XPos,u
                    inca
                    sta       V.51XPos,u
                    cmpa      #42
                    bcs       L03E3
                    leas      $01,s
                    bra       L040D
L03E3               dec       ,s
                    bpl       L03CF
                    lda       V.51XPos,u
                    ldb       #$06
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
*         lbsr  DoDisplayCursor
                    lbra      CancelEscSequence

*
*$0b - (cursor home)
*
DoHome
                    lbsr      DoEraseCursor
                    clr       V.51XPos,u
                    clr       V.51YPos,u
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
                    cmpa      #42
                    bcs       L044B
                    lda       #41
L044B               sta       V.51XPos,u
L044D               clrb
                    rts
L0450               cmpa      #24
                    bcs       L0456
                    lda       #23
L0456               sta       V.51YPos,u
L0459
                    clr       V.51CursorOn,u
*         lbsr  DoDisplayCursor
                    lbra      L02A6

*
* $1b43 - (cursor right)
*
DoCursorRight
                    lbsr      DoEraseCursor
                    inc       V.51XPos,u
                    lda       V.51XPos,u
                    cmpa      #42
                    bcs       L0459
                    clr       V.51XPos,u
                    lbra      DoLineFeed
*
* $1b46 - reverse on
*
DoReverseOn
                    clra
*         lda   #$FF
*         coma
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

                    fcb       $00,$00,$00,$00,$00 ' '
                    fcb       $21,$08,$40,$00,$80 '!'
                    fcb       $52,$94,$00,$00,$00 '"'
                    fcb       $52,$be,$af,$a9,$40 '#'
                    fcb       $23,$e8,$e2,$f8,$80 '$'
                    fcb       $c6,$44,$44,$4c,$60 '%'
                    fcb       $45,$11,$59,$4d,$80 '&'
                    fcb       $11,$10,$00,$00,$00 '''
                    fcb       $11,$10,$84,$10,$40 '('
                    fcb       $41,$04,$21,$11,$00 ')'
                    fcb       $25,$5c,$47,$54,$80 '*'
                    fcb       $01,$09,$f2,$10,$00 '+'
                    fcb       $00,$00,$00,$10,$88 ','
                    fcb       $00,$00,$f0,$00,$00 '-'
                    fcb       $00,$00,$00,$31,$80 '.'
                    fcb       $00,$02,$22,$22,$00 '/'
                    fcb       $74,$67,$5c,$c5,$c0 '0'
                    fcb       $23,$28,$42,$13,$e0 '1'
                    fcb       $74,$42,$26,$43,$e0 '2'
                    fcb       $74,$42,$60,$c5,$c0 '3'
                    fcb       $11,$95,$2f,$88,$40 '4'
                    fcb       $fc,$38,$20,$8b,$80 '5'
                    fcb       $32,$21,$e8,$c5,$c0 '6'
                    fcb       $fc,$44,$42,$10,$80 '7'
                    fcb       $74,$62,$e8,$c5,$c0 '8'
                    fcb       $74,$62,$f0,$89,$80 '9'
                    fcb       $00,$08,$00,$10,$00 ':'
                    fcb       $00,$08,$00,$10,$88 ';'
                    fcb       $19,$99,$86,$18,$60 '<'
                    fcb       $00,$3e,$0f,$80,$00 '='
                    fcb       $c3,$0c,$33,$33,$00 '>'
                    fcb       $74,$42,$22,$00,$80 '?'
                    fcb       $74,$42,$da,$d5,$c0 '@'
                    fcb       $22,$a3,$1f,$c6,$20 'A'
                    fcb       $f2,$52,$e4,$a7,$c0 'B'
                    fcb       $32,$61,$08,$24,$c0 'C'
                    fcb       $e2,$92,$94,$ab,$80 'D'
                    fcb       $fc,$21,$e8,$43,$e0 'E'
                    fcb       $fc,$21,$e8,$42,$00 'F'
                    fcb       $74,$61,$78,$c5,$c0 'G'
                    fcb       $8c,$63,$f8,$c6,$20 'H'
                    fcb       $71,$08,$42,$11,$c0 'I'
                    fcb       $38,$84,$29,$49,$80 'J'
                    fcb       $8c,$a9,$8a,$4a,$20 'K'
                    fcb       $84,$21,$08,$43,$e0 'L'
                    fcb       $8e,$eb,$58,$c6,$20 'M'
                    fcb       $8e,$73,$59,$ce,$20 'N'
                    fcb       $74,$63,$18,$c5,$c0 'O'
                    fcb       $f4,$63,$e8,$42,$00 'P'
                    fcb       $74,$63,$1a,$c9,$a0 'Q'
                    fcb       $f4,$63,$ea,$4a,$20 'R'
                    fcb       $74,$60,$e0,$c5,$c0 'S'
                    fcb       $f9,$08,$42,$10,$80 'T'
                    fcb       $8c,$63,$18,$c5,$c0 'U'
                    fcb       $8c,$63,$15,$28,$80 'V'
                    fcb       $8c,$63,$5a,$ee,$20 'W'
                    fcb       $8c,$54,$45,$46,$20 'X'
                    fcb       $8c,$62,$e2,$10,$80 'Y'
                    fcb       $f8,$44,$44,$43,$e0 'Z'
                    fcb       $72,$10,$84,$21,$c0 '['
                    fcb       $00,$20,$82,$08,$20 '\'
                    fcb       $70,$84,$21,$09,$c0 ']'
                    fcb       $22,$a2,$00,$00,$00 '^'
                    fcb       $00,$00,$00,$03,$e0 '_'
                    fcb       $41,$04,$00,$00,$00 '`'
                    fcb       $00,$1c,$17,$c5,$e0 'a'
                    fcb       $84,$2d,$98,$e6,$c0 'b'
                    fcb       $00,$1d,$18,$45,$c0 'c'
                    fcb       $08,$5b,$38,$cd,$a0 'd'
                    fcb       $00,$1d,$1f,$c1,$c0 'e'
                    fcb       $11,$49,$f2,$10,$80 'f'
                    fcb       $00,$1b,$39,$b4,$2e 'g'
                    fcb       $84,$3d,$18,$c6,$20 'h'
                    fcb       $20,$18,$42,$11,$c0 'i'
                    fcb       $10,$0c,$21,$0a,$4c 'j'
                    fcb       $42,$12,$a6,$29,$20 'k'
                    fcb       $61,$08,$42,$11,$c0 'l'
                    fcb       $00,$35,$5a,$d6,$a0 'm'
                    fcb       $00,$2d,$98,$c6,$20 'n'
                    fcb       $00,$1d,$18,$c5,$c0 'o'
                    fcb       $00,$2d,$9c,$da,$10 'p'
                    fcb       $00,$1b,$39,$b4,$21 'q'
                    fcb       $00,$2d,$98,$42,$00 'r'
                    fcb       $00,$1f,$0f,$07,$c0 's'
                    fcb       $42,$3c,$84,$24,$c0 't'
                    fcb       $00,$25,$29,$49,$a0 'u'
                    fcb       $00,$23,$18,$a8,$80 'v'
                    fcb       $00,$23,$5a,$d5,$40 'w'
                    fcb       $00,$22,$a2,$2a,$20 'x'
                    fcb       $00,$23,$19,$b4,$2e 'y'
                    fcb       $00,$3e,$22,$23,$e0 'z'
                    fcb       $19,$08,$82,$10,$60 '{'
                    fcb       $21,$08,$02,$10,$80 '|'
                    fcb       $c1,$08,$22,$13,$00 '}'
                    fcb       $45,$44,$00,$00,$00 '~'
                    fcb       $ff,$ff,$ff,$ff,$ff 'cursor'

                    emod
eom                 equ       *
                    end
