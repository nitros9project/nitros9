********************************************************************
* VTIO - NitrOS-9 video terminal I/O driver for Atari XE/XL
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2012/02/20  Boisy G. Pitre
* Started.

                    use       defsfile
                    use       atarivtio.d

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last

                    fcb       UPDAT.+EXEC.

name                fcs       /vtio/
                    fcb       edition

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

* Init
*
* Entry:
*    Y  = address of device descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Init                stu       >D.KbdSta           store the device memory pointer
                    pshs      u

                    leax      DefaultHandler,pcr  get the default character processing routine
                    stx       V.EscVect,u         store it in the vector

* setup static vars
                    clra                          set D..
                    clrb                          to $0000
                    std       V.CurRow,u          set the current row and column

* Clear screen memory
                    ldy       #G.ScrEnd
                    pshs      y
                    ldy       #G.ScrStart
                    ldd       #$0000
clearLoop@
                    std       ,y++
                    cmpy      ,s
                    bne       clearLoop@
                    puls      u                   G.DList address is aleady in U

* set background color
                    clra
                    sta       COLBK

* set text color
                    lda       #$0F
                    sta       COLPF1
                    lda       #$94
                    sta       COLPF2

* install keyboard ISR
                    ldd       #IRQST              POKEY IRQ status address
                    leay      IRQSvc,pcr          pointer to our service routine
                    leax      IRQPkt,pcr          F$IRQ requires a 3 byte packet
                    ldu       ,s                  use our saved device memory as ISR static storage
                    os9       F$IRQ               install the ISR
                    bcs       initex

* set POKEY to active
                    lda       #$13
                    sta       SKCTL

* tell POKEY to enable keyboard scanning
                    lda       #(IRQST.BREAKDOWN|IRQST.KEYDOWN)
                    pshs      cc
                    orcc      #IntMasks
                    ora       >D.IRQENSHDW
                    sta       >D.IRQENSHDW
                    puls      cc
                    sta       IRQEN

* clear carry and return
                    clrb
initex              puls      u,pc


* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term
                    ldx       #$0000              we want to remove the IRQ table entry
                    leay      IRQSvc,pcr          point to the interrupt service routine
                    os9       F$IRQ               call to remove it
                    clrb                          clear the carry
                    rts                           return to the caller


* Read
*
* Entry:
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    A  = character read
*    CC = carry set on error
*    B  = error code
*
Read                leax      V.InBuf,u           point X to the input buffer
                    ldb       V.IBufT,u           get the buffer tail pointer
                    orcc      #IRQMask            mask interrupts
                    cmpb      V.IBufH,u           is the tail pointer the same as the head pointer?
                    beq       nitenite@           if so, the buffer is empty, so put the reader to sleep
                    abx                           X now points to the current character to fetch from the buffer
                    lda       ,x                  get that character now
                    bsr       IncNCheck           check for tail wrap
                    stb       V.IBufT,u           store the updated tail
                    andcc     #^(IRQMask+Carry)   unmask interrupts
                    rts                           and return to the caller
* Here, the calling process gets put to sleep waiting for input.
nitenite@           lda       V.BUSY,u            get the calling process ID
                    sta       V.WAKE,u            store it in V.WAKE
                    andcc     #^IRQMask           clear interrupts
                    ldx       #$0000              we want to..
                    os9       F$Sleep             sleep forever (until we get a wakup signal)
                    clr       V.WAKE,u            we're awake... clear our process ID
                    ldx       <D.Proc             get the current process descriptor
                    ldb       <P$Signal,x         and the signal we received
                    beq       Read                branch if there was no signal
                    cmpb      #S$Window           was it the window signal?
                    bcc       Read                branch if that, or higher
                    coma                          set the carry
                    rts                           and return to the caller

* Check if we need to wrap around tail pointer to zero.
IncNCheck           incb                          increment the next character pointer
                    cmpb      #KBufSz-1           are we pointing to the end of the buffer?
                    bls       ex@                 branch if not
                    clrb                          else clear the pointer (wraps to head)
ex@                 rts                           return

* Write
*
* Entry:
*    A  = character to write
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Write
* Hide cursor.
                    pshs      a
                    bsr       calcloc
                    lda       V.CurChr,u
                    sta       ,x
                    puls      a

                    ldx       V.EscVect,u         get the escape vector address
                    jsr       ,x                  branch to it

* Draw cursor.
                    bsr       calcloc
                    lda       ,x
                    sta       V.CurChr,u
                    tst       <V.CrsrOff,u        is the cursor off?
                    bne       ex@
                    lda       #$80
                    sta       ,x
ex@                 clrb
                    rts

DefaultHandler      cmpa      #C$SPAC             is the character a space or greater?
                    lbcs      ChkESC              branch if not; go check for escape codes
                    bsr       CalcLoc             get the current character position
                    suba      #$20                adjust for Atari character set
                    sta       ,x                  save the character there
                    ldd       V.CurRow,u          get the current row and column
                    incb                          increment the column
                    cmpb      #G.Cols             compare it against the number of columns
                    blt       ok                  branch if we're less than
                    clrb                          else the column goes to 0
incrow              inca                          and we increment the row
                    cmpa      #G.Rows             compare it against the number of rows
                    blt       clrline             branch if we're less than (clear the new line we're on)
SCROLL              equ       1
                    ifne      SCROLL
                    deca                          set A to V.WHeight - 1
                    ldx       #G.ScrStart         get the start of the screen memory
                    pshs      d                   save D
                    lda       #G.Cols             get screen width in A
                    ldb       #G.Rows             get height in B
                    decb                          decrement height by 1
                    mul                           get the product (bytes to copy)
                    tfr       d,y                 set Y to the size of the screen minus the last row
                    puls      d                   restore D
scroll_loop1@       ldb       #G.Cols
                    ldd       b,x
                    std       ,x++                store on this row
                    leay      -2,y                decrement Y
                    bne       scroll_loop1@       branch if not 0
                    lda       #G.Rows-1
                    clrb
                    else
                    clra                          just clear the row (goes to top)
                    endc
* clear line
clrline             std       V.CurRow,u          save the current row/column value
                    lbsr      EraseLine           erase the line
                    rts                           and return to the caller
ok                  std       V.CurRow,u          save the current row/column value
ret                 rts                           and return to the caller


* Calculate the cursor location in screen memory.
*
* Exit: X = Address of the cursor.
CalcLoc
                    pshs      d                   save D since we modify it here
                    lda       V.CurRow,u          get the current row in A
                    ldb       #G.Cols             and the current column in B
                    mul                           get the product
                    addb      V.CurCol,u          add it to the current column
                    adca      #0                  add in the carry in A
                    ldx       #G.ScrStart         point to the start of the screen
                    leax      d,x                 point X to the current position
                    puls      d,pc                restore register and return

;;; CurOn
;;;
;;; Turns the cursor on.
;;;
;;; Code: 05 21
CurOn               clr       V.CrsrOff,u         clear the cursor off flag
                    rts

;;; CurOff
;;;
;;; Turns the cursor off.
;;;
;;; Code: 05 20
CurOff              lda       #1
                    sta       V.CrsrOff,u         set the cursor off flag
                    rts

ChkESC              cmpa      #$1B                is the character ESC?
                    lbeq      EscHandler          if so, handle it
                    cmpa      #$1F                is this the 1F handler?
                    lbeq      OneEffHandler       if so, handle it
                    cmpa      #C$CR               is it a carriage return?
                    bhi       ret                 branch if higher than that
                    leax      <DCodeTbl,pcr       else deal with screen codes
                    lsla                          adjust A for the table entry size
                    ldd       a,x                 get the address offset to handle the character in D
                    jmp       d,x                 and jump to routine

* Display functions dispatch table.
DCodeTbl            fdb       NoOp-DCodeTbl       $00:no-op (null)
                    fdb       CurHome-DCodeTbl    $01:HOME cursor
                    fdb       CurXY-DCodeTbl      $02:CURSOR XY
                    fdb       EraseLine-DCodeTbl  $03:ERASE LINE
                    fdb       ErEOLine-DCodeTbl   $04:CLEAR TO EOL
                    fdb       CurOnOff-DCodeTbl   $05:CURSOR CONTROL
                    fdb       CurRght-DCodeTbl    $06:CURSOR RIGHT
                    fdb       Bell-DCodeTbl       $07:Bell
                    fdb       CurLeft-DCodeTbl    $08:CURSOR LEFT
                    fdb       CurUp-DCodeTbl      $09:CURSOR UP
                    fdb       CurDown-DCodeTbl    $0A:CURSOR DOWN
                    fdb       ErEOScrn-DCodeTbl   $0B:ERASE TO EOS
                    fdb       ClrScrn-DCodeTbl    $0C:CLEAR SCREEN
                    fdb       Retrn-DCodeTbl      $0D:RETURN

;;; EraseLin
;;;
;;; Erase the current line.
;;;
;;; Code: 03
EraseLine           clrb                          start erasing at column 0
                    lda       V.CurRow,u          of the current row
* Entry:  A = The row to erase.
*         B = The column to start erasing on.
EraseLineCore       pshs      b                   save the number of columns
                    ldb       #G.Cols
                    mul                           get the product
                    addb      ,s                  add the column to start erasing from
                    adca      #0                  consider the carry
                    ldx       #G.ScrStart         get the screen base address
                    leax      d,x                 move X to the current row
                    lda       #G.Cols             get the number of columns
                    suba      ,s+                 subtract the column to start erasing from
clrloop@            clr       ,x+                 clear the value there
                    deca                          decrement the loop value
                    bne       clrloop@            branch if not done
                    rts                           return

;;; ClrScrn
;;;
;;; Clears the entire screen and homes the cursor.
;;;
;;; Code: 0C
ClrScrn             lda       #G.Rows             get the number of rows
                    deca                          minus 1
                    sta       V.CurRow,u          store it in the current row variable
clrloop@            bsr       EraseLine           go erase the line
                    dec       V.CurRow,u          decrement the current row variable
                    bpl       clrloop@            branch if >=0

;;; CurHome
;;;
;;; Moves the cursor to the home location.
;;;
;;; Code: 01
;;;
;;; The home location is column 0, row 0.
CurHome             clr       V.CurCol,u
                    clr       V.CurRow,u
                    rts

;;; CurUp
;;;
;;; Moves the cusor up one line.
;;;
;;; Code: 09
;;;
;;; If the cursor is at the top-most line, it stays at its current position.
CurUp               lda       V.CurRow,u
                    deca
                    bmi       ex@
                    sta       V.CurRow,u
ex@                 rts

;;; CurRght
;;;
;;; Moves the cursor to the right.
;;;
;;; Code: 06
;;;
;;; If the cursor is at the last column, it moves to the first column of the next line.
;;; If the cursor is at the last column of the last line, it stays there.
CurRght             ldd       V.CurRow,u
                    incb                          increment the column
                    cmpb      #G.Cols             is it >= the number of columns?
                    bgt       nextrow@
ex@                 std       V.CurRow,u
bye@                rts
nextrow@            ldb       #G.Rows
                    decb
                    pshs      b
                    cmpa      ,s+                 are we at the last row?
                    bge       bye@                yep, nothing to change.
                    clrb                          else clear the column
                    inca                          increment the row
                    bra       ex@                 save and return

;;; ErEOLine
;;;
;;; Erase from the current cursor position to the end of the line.
;;;
;;; Code: 04
ErEOLine            ldd       <V.CurRow,u         get the current row and column
                    bra       EraseLineCore       go erase from that point to the end of line

;;; ErEOScrn
;;;
;;; Erase from the current cursor position to the end of the screen.
;;;
;;; Code: 0B
ErEOScrn            bsr       ErEOLine            erase from the curent position to the end of line
                    lda       V.CurRow,u          get the current row
l@                  clrb                          clear the column
                    inca                          increment row
                    cmpa      #G.Rows             are we at the end?
                    bge       ex@                 branch if so
                    pshs      a                   save our row counter
                    lbsr      EraseLineCore       go erase the line
                    puls      a                   recover our row counter
                    bra       l@                  go erase more
ex@                 rts                           return

;;; CurXY
;;;
;;; Positions the cursor at the specified coordinates.
;;;
;;; Code: 02
;;;
;;; Parameter: LCX LCY
;;;
;;; LCX is the desired column position + 32.
;;; LCY is the desired row position + 32.
CurXY               leax      CurXYChar1,pcr
c@                  stx       V.EscVect,u
                    rts
CurXYChar1          suba      #$20
                    cmpa      #G.Cols
                    blt       s1@
                    lda       #G.Cols
                    deca
s1@                 sta       V.CurCol,u
                    leax      CurXYChar2,pcr
                    bra       c@
CurXYChar2          suba      #$20
                    cmpa      #G.Rows
                    blt       s2@
                    lda       #G.Rows
                    deca
s2@                 sta       V.CurRow,u
                    lbra      ResetHandler

CurOnOff            leax      Do05XX,pcr
c@                  stx       V.EscVect,u
                    rts
Do05XX              cmpa      #$20
                    beq       hide@
                    cmpa      #$21
                    beq       show@
                    cmpa      #$22
                    beq       cchar@
                    cmpa      #$23
                    beq       crate@
                    bra       ResetHandler
crate@
                    bra       c@
cchar@              leax      CurChar,pcr
                    bra       c@
                    bne       ResetHandler
hide@               lbsr      CurOff
                    bra       ResetHandler
show@               lbsr      CurOn
                    bra       ResetHandler

;;; CurChar
;;;
;;; Change the cursor character.
;;;
;;; Code: 05 22
;;;
;;; Parameter: CHR
;;;
;;; CHR can be any character from 0 - 255.
CurChar
                    bra       ResetHandler

Bell
NoOp
                    rts

;;; CurLeft
;;;
;;; Moves the cursor to the left.
;;;
;;; Code: 09
;;;
;;; If the cursor is at the first column, it moves to the last column of the previous line.
CurLeft             ldd       V.CurRow,u          get the current row and column values
                    beq       leave               branch if they're zero
                    decb                          decrement the column value
                    bpl       EraseChar           erase the character
                    ldb       #G.Cols             get the number of columns
                    decb                          minus 1
                    deca                          decrement the counter
                    bpl       EraseChar           branch until done
                    clra                          clear A

* Entry:  A = The row of the character to erase.
*         B = The column of the character to erase.
EraseChar           std       V.CurRow,u          save D to the current row and column
                    ldb       #G.Cols             get the number of columns
                    mul                           calculate the product
                    addb      V.CurCol,u          add in the current column
                    adca      #0                  add in the carry bit
                    ldx       #G.ScrStart         point to the start of the screen
                    leax      d,x                 advance to the calculated osition
                    clr       1,x                 erase the character
leave               rts                           return

CurDown             ldd       V.CurRow,u          get the current row and column
                    lbra      incrow              increment the row

Retrn               clr       V.CurCol,u          clear the current column
                    rts                           return

* We don't do anything with $1F codes currently.
OneEffHandler       leax      OneEffHandler2,pcr  point to the 1F handler to the 2nd character
                    stx       V.EscVect,u         store it in the vector
                    rts                           return

* 1F 20	Turns on reverse video
* 1F 21	Turns off reverse video
* 1F 22	Turns on underlining.
* 1F 23	Turns off underlining.
* 1F 24	Turns on blinking.
* 1F 25	Turns off blinking.
* 1F 30	Inserts a line at the current cursor position.
* 1F 31	Deletes the current line.
OneEffHandler2
                    cmpa      #$20
                    beq       revon
                    cmpa      #$21
                    beq       revoff
ResetHandler        leax      DefaultHandler,pcr
                    bra       SetHandler
revoff              tst       V.Reverse,u         is reverse already off?
                    beq       SetHandler          branch if so
                    com       V.Reverse,u
                    bra       DoReverse
revon               tst       V.Reverse,u         is reverse already on?
                    bne       SetHandler          branch if so
                    com       V.Reverse,u
DoReverse
* swap foreground and background color bits
                    lda       V.FBCol,u           else get the fore/background color
                    lsra                          shift all...
                    lsra                          of the foreground..
                    lsra                          color bits into the...
                    lsra                          lower nibble
                    pshs      a
                    lda       V.FBCol,u
                    lsla                          shift all...
                    lsla                          of the background...
                    lsla                          color bits into the...
                    lsla                          upper nibble
                    ora       ,s+
                    sta       V.FBCol,u
                    bra       ResetHandler

EscHandler          leax      Do1B,pcr            point to the handler to the 2nd character
SetHandler          stx       V.EscVect,u         store it in the vector
                    rts                           return

* Window mode handler
Do1B20              sta       V.DWType,u
                    leax      Do1B20TT,pcr
                    bra       SetHandler

Do1B20TT            sta       V.DWStartX,u
                    leax      Do1B20TTXX,pcr
                    bra       SetHandler

Do1B20TTXX          sta       V.DWStartY,u
                    leax      Do1B20TTXXYY,pcr
                    bra       SetHandler

Do1B20TTXXYY        sta       V.DWWidth,u
                    leax      Do1B20TTXXYYWW,pcr
                    bra       SetHandler

Do1B20TTXXYYWW      sta       V.DWHeight,u
                    leax      Do1B20TTXXYYWWHH,pcr
                    bra       SetHandler

Do1B20TTXXYYWWHH    sta       V.DWFore,u
                    leax      Do1B20TTXXYYWWHHFF,pcr
                    bra       SetHandler

Do1B20TTXXYYWWHHFF  sta       V.DWBack,u
                    leax      Do1B20TTXXYYWWHHFFBB,pcr
                    bra       SetHandler

Do1B20TTXXYYWWHHFFBB
                    sta       V.DWBorder,u

;;; DWSet
;;;
;;; Set a device window.
;;;
;;; Code: 1B 20
;;;
;;; Parameters: STY CPX CPY SZX SZY PRN1 PRN2 PRN3
;;;
;;; STY = screen type: $01 = 40x30, $02 = 80x30, $03 = 80x60.
;;; CPX = starting position X.
;;; CPY = starting position Y.
;;; SZX = width starting at X.
;;; SZY = height starting at Y.
;;; PRN1 = foreground color.
;;; PRN2 = background color.
;;; PRN3 = border color.
DWSet               lbsr      ClrScrn

* These do nothing for now.
DefColr
DWSelect
DWEnd               lbra      ResetHandler

Do1B                cmpa      #$20                is it the window mode?
                    bne       IsIt21              branch if not
                    leax      Do1B20,pcr          else point to the vector
                    lbra      SetHandler          and set the handler
IsIt21              cmpa      #$21                is it DWSelect?
                    bne       IsIt24              branch if not
                    lbra      DWSelect
IsIt24              cmpa      #$24                is it DWEnd?
                    bne       IsIt30              branch if not
                    lbra      DWEnd
IsIt30              cmpa      #$30                is it DefColr?
                    bne       IsIt32              branch if not
                    lbra      DefColr
IsIt32              cmpa      #$32                is it the foreground color code?
                    bne       IsIt33              branch if not
                    leax      FColor,pcr          else point to the vector
                    lbra      SetHandler          and set the handler
IsIt33              cmpa      #$33                is it the background color code?
                    bne       IsIt34              branch if not
                    leax      BColor,pcr          else point to the vector
                    lbra      SetHandler          and set the handler
IsIt34              cmpa      #$34                is it the foreground color code?
                    lbne      IsIt3D
                    leax      Border,pcr          else point to the vector
                    lbra      SetHandler          and set the handler
IsIt3D              cmpa      #$3D                is it the foreground color code?
                    lbne      ResetHandler        if not, reset the handler
                    leax      BoldSw,pcr          else point to the vector
                    lbra      SetHandler          and set the handler

* Foreground/background/border color handlers
FColor              bsr       SetForeColor
                    lbra      ResetHandler        reset the handler
BColor              bsr       SetBackColor
                    lbra      ResetHandler        reset the handler
Border              bsr       SetBorderColor
                    lbra      ResetHandler        reset the handler

* BoldSw - do nothing.
BoldSw              lbra      ResetHandler        reset the handler

SetForeColor        lsla                          A = A / 2
                    lsla                          A = A / 2
                    lsla                          A = A / 2
                    lsla                          A = A / 2
                    pshs      a                   save the register
                    ldb       V.FBCol,u           load the foreground/background color
                    andb      #$0F                mask out the upper 4 bits
doout@              orb       ,s+                 OR in the foreground color bits
                    stb       V.FBCol,u           save the updated color
SetBorderColor      rts                           return
SetBackColor        anda      #$0F                mask out the upper 4 bits
                    pshs      a                   save the register
                    ldb       V.FBCol,u           load the foreground/background color
                    andb      #$F0                mask out the lower 4 bits
                    bra       doout@              and do the OR

* GetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
****************************
* Get status entry point
* Entry: A=Function call #
GetStat             cmpa      #SS.EOF             is this the EOF call?
                    beq       SSEOF               yes, exit without error
                    ldx       PD.RGS,y            else get the pointer to caller's registers (all other calls require this)
                    cmpa      #SS.Ready           is this the data ready call? (keyboard buffer)
                    beq       SSReady             branch if so
                    cmpa      #SS.ScSiz           get screen size?
                    beq       SSScSiz             branch if so
                    cmpa      #SS.Joy             get joystick position?
                    beq       SSJoy               branch if so
                    cmpa      #SS.Palet           get palettes?
                    beq       SSPalet             yes, go process
                    cmpa      #SS.FBRgs           get colors?
                    lbeq      SSFBRgs             yes, go process
                    cmpa      #SS.DfPal           get default colors?
                    beq       SSDfPal             yes, go process
                    comb                          set the carry
                    ldb       #E$UnkSvc           load the "unknown service" error
                    rts                           return

;;; SS.Ready
;;;
;;; Tests for data available on SCF-supported devices.
;;;
;;; Entry:  A = The path number.
;;;         B = SS.Ready ($01)
;;;
;;; Exit:   B = The number of characters ready to read.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = E$NotRdy if there are no bytes ready to read.
;;;        CC = Carry flag set to indicate error.
SSReady             lda       V.IBufH,u           else get get the buffer tail ptr
                    suba      V.IBufT,u           A = the number of characters ready to read
                    sta       R$B,x               save in the caller's B
                    lbeq      NotReady            if there's no data in keyboard buffer, return the "not ready" error
SSEOF               clrb                          clear the error code and carry
                    rts                           return
NotReady            comb                          set the carry
                    ldb       #E$NotRdy           load the "not ready" error
                    rts                           return

;;; SS.ScSiz
;;;
;;; Return the screen size.
;;;
;;; Entry:  A = The path number.
;;;         B = SS.ScSiz ($26)
;;;
;;; Exit:   X = The number of columns on the screen.
;;;         Y = The number of rows on the screen.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
;;;
;;; Use this call to determine the size of a the screen. The returnedvalues depend on the device in use.
;;; For non-VTIO devices, the call returns the values following the XON/XOFF bytes in the device descriptor.
;;; For VTIO devices, the call returns the size of the window or screen in use by the specified device.
;;; For window devices, the call returns the size of the current working area of the window.
SSScSiz             clra                          clear the upper 8 bits of D
                    ldb       #G.Cols             get the column count
                    std       R$X,x               save it in X
                    ldb       #G.Rows             get the row count
                    std       R$Y,x               save it in Y
;;; SS.Joy
;;;
;;; Returns the joystick information.
;;;
;;; Entry:  X = Joystick to read.
;;;         B = SS.Joy ($13)
;;;
;;; Exit:   A = Button state.
;;;         X = Horizontal position (0 = left, 255 = right).
;;;         Y = Vertical position (0 = top, 255 = bottom).
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
SSJoy               clrb                          clear carry
                    rts                           return

;;; SS.Palet
;;;
;;; Return palette information.
SSPalet

;;; SS.FBRGs
;;;
;;; Returns the foreground, background, and border palette registers for a window.
;;;
;;; Entry:  A = The path number.
;;;         B = SS.FBRgs ($96)
;;;
;;; Exit:   A = The foreground palette register number.
;;;         B = The background palette register number.
;;;         X = The least significant byte of the border paletter register number.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.
SSFBRGs

;;; SS.DfPal
;;;
;;; Returns the foreground, background, and border palette registers for a window.
;;;
;;; Entry:  A = The path number.
;;;         B = SS.DfPal ($97)
;;;         X = A pointer to user-provided 16-byte palette data.
;;;
;;; Exit:   X = The default palette data moved to user space.
;;;        CC = Carry flag clear to indicate success.
;;;
;;; Error:  B = A non-zero error code.
;;;
;;; Use this call to find the values of the default palette registers when a new screen is allocated.
;;; The corresponding SetStat alters the default registers. This is for system configuration utilities
;;; and shouldn't be used by general applications.
SSDfPal

                    clrb                          no error
                    rts                           return

*
* SetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
SetStat
                    cmpa      #SS.SSig            send signal on data ready?
                    beq       SSSig               yes, go process
                    comb                          set the carry
                    ldb       #E$UnkSvc           load the "unknown service" error
                    rts                           return

* SS.SSig - send signal on data ready
SSSig               pshs      cc                  save interrupt status
                    lda       V.IBufH,u           get get the buffer tail ptr
                    suba      V.IBufT,u           A = the number of characters ready to read
                    pshs      a                   save it temporarily
                    bsr       GetCPR              get current process ID
                    tst       ,s+                 anything in buffer?
                    bne       SendSig             yes, go send the signal
*               std       <V.SSigID,u         save process ID & signal
                    puls      pc,cc               restore interrupts & return

GetCPR              orcc      #IntMasks           disable interrupts
                    lda       PD.CPR,y            get curr proc #
                    ldb       R$X+1,x             get user signal code
                    rts                           return

SendSig             puls      cc                  restore interrupts
                    os9       F$Send              send the signal
                    rts                           return


IRQPkt              equ       *
Pkt.Flip            fcb       (IRQST.BREAKDOWN|IRQST.KEYDOWN) flip byte
Pkt.Mask            fcb       (IRQST.BREAKDOWN|IRQST.KEYDOWN) mask byte
                    fcb       $0A                 priority


*
* IRQ routine for Atari keyboards.
*
IRQSvc
* check if BREAK key pressed; if so, it's a C$QUIT char
                    ldb       IRQST               get the IRQ status byte
                    bitb      #IRQST.BREAKDOWN    is the BREAK key down?
                    bne       getcode             branch if not
                    lda       #C$QUIT             else load the QUIT character
                    bra       noctrl@             and continue
getcode
                    ldb       KBCODE              get the keyboard code from POKEY
gotcode
                    pshs      b                   save the code
                    andb      #$7F                mask out a potential CTRL key
                    leax      ATASCII,pcr         point to the ATASCII table
                    lda       b,x                 fetch the character for the code
                    tst       ,s+                 is the CTRL key down?
                    bpl       noctrl@             branch if not
                    cmpa      #$40                is the character at A or greater?
                    bcs       noctrl@             branch if not
                    anda      #$5F                else make the character uppercase
                    suba      #$40                and subtract to get the CTRL value
noctrl@
* check for caps lock
                    cmpa      #$82                is this CAPS Lock?
                    bne       tst4caps@           branch if not
                    tst       V.CapsLck,u         is the CAPS Lock off?
                    beq       turnon@             yes, go turn it on
                    clra                          else turn it off
turnon@             sta       V.CapsLck,u         set the CAPS Lock state
                    bra       KeyLeave            and leave
tst4caps@
                    tst       V.CapsLck,u         is the CAPS Lock state on?
                    beq       goon@               branch if not
                    cmpa      #$61                is this lowercase?
                    blt       goon@               branch if not
                    cmpa      #$7a                are we in lowercase range?
                    bgt       goon@               branch if not
                    suba      #$20                else make lowercase
goon@
                    ldb       V.IBufH,u           get head pointer in B
                    leax      V.InBuf,u           point X to input buffer
                    abx                           X now holds address of head
                    lbsr      IncNCheck           check for tail wrap
                    cmpb      V.IBufT,u           B at tail?
                    beq       L012F               branch if so
                    stb       V.IBufH,u           store the pointer in the head
L012F               sta       ,x                  store our char at ,X
                    beq       WakeIt              if nul, do wake-up
                    cmpa      V.PCHR,u            pause character?
                    bne       L013F               branch if not
                    ldx       V.DEV2,u            else get dev2 statics
                    beq       WakeIt              branch if none
                    sta       V.PAUS,x            else set pause request
                    bra       WakeIt              go wake up
L013F               ldb       #S$Intrpt           get interrupt signal
                    cmpa      V.INTR,u            our char same as intr?
                    beq       L014B               branch if same
                    ldb       #S$Abort            get abort signal
                    cmpa      V.QUIT,u            our char same as QUIT?
                    bne       WakeIt              branch if not
L014B               lda       V.LPRC,u            get ID of last process to get this device
                    bra       L0153               go for it
WakeIt              ldb       #S$Wake             get wake signal
                    lda       V.WAKE,u            get process to wake
L0153               beq       L0158               branch if none
                    os9       F$Send              else send wakeup signal
L0158               clr       V.WAKE,u            clear process to wake flag

* Update the shadow register then the real register to disable and
* re-enable the keyboard interrupt
KeyLeave
                    pshs      cc                  save CC
                    orcc      #IntMasks           mask interrupts
                    lda       >D.IRQENShdw        get the IRQ shadow register
                    tfr       a,b                 copy it into B
                    anda      #^(IRQST.BREAKDOWN|IRQST.KEYDOWN) clear the BREAK and KEY down bits in B
                    orb       #(IRQST.BREAKDOWN|IRQST.KEYDOWN) or them in A
                    sta       IRQEN               update the hardware to show the interrupts have been serviced
                    stb       >D.IRQENShdw        store the final value in the shadow
                    stb       IRQEN               and re-enable the bits in the hardware
                    puls      cc,pc               restore CC and return

ATASCII             fcb       $6C,$6A,$3B,$80,$80,$6B,$2B,$2A ;LOWER CASE
                    fcb       $6F,$80,$70,$75,$0D,$69,$2D,$3D

                    fcb       $76,$80,$63,$80,$80,$62,$78,$7A
                    fcb       $34,$80,$33,$36,$1B,$35,$32,$31

                    fcb       $2C,$20,$2E,$6E,$80,$6D,$2F,$81
                    fcb       $72,$80,$65,$79,$7F,$74,$77,$71

                    fcb       $39,$80,$30,$37,$08,$38,$3C,$3E
                    fcb       $66,$68,$64,$80,$82,$67,$73,$61


                    fcb       $4C,$4A,$3A,$80,$80,$4B,$5C,$5E ;UPPER CASE
                    fcb       $4F,$80,$50,$55,$9B,$49,$5F,$7C

                    fcb       $56,$80,$43,$80,$80,$42,$58,$5A
                    fcb       $24,$80,$23,$26,$1B,$25,$22,$21

                    fcb       $5B,$20,$5D,$4E,$80,$4D,$3F,$81
                    fcb       $52,$80,$45,$59,$9F,$54,$57,$51

                    fcb       $28,$80,$29,$27,$9C,$40,$7D,$9D
                    fcb       $46,$48,$44,$80,$83,$47,$53,$41


*		fcb	$0C,$0A,$7B,$80,$80,$0B,$1E,$1F ;CONTROL
*		fcb	$0F,$80,$10,$15,$9B,$09,$1C,$1D

*		fcb	$16,$80,$03,$80,$80,$02,$18,$1A
*		fcb	$80,$80,$85,$80,$1B,$80,$FD,$80

*		fcb	$00,$20,$60,$0E,$80,$0D,$80,$81
*		fcb	$12,$80,$05,$19,$9E,$14,$17,$11

*		fcb	$80,$80,$80,$80,$FE,$80,$7D,$FF
*		fcb	$06,$08,$04,$80,$84,$07,$13,$01

                    emod
eom                 equ       *
                    end
