********************************************************************
* VTIO - NitrOS-9 video terminal I/O driver for the Foenix F256
*
* $Id$
*
* https://wiki.osdev.org/PS2_Keyboard
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2013/08/20  Boisy G. Pitre
* Started.
*
*  2       2013/12/-6  Boisy G. Pitre
* Added SS.Joy support.

                    nam       VTIO
                    ttl       NitrOS-9 video terminal I/O driver for the Foenix F256

                    use       defsfile
                    use       f256vtio.d

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

* We can use a different MMU slot if we want.
MAPSLOT             equ       MMU_SLOT_1
MAPADDR             equ       (MAPSLOT-MMU_SLOT_0)*$2000
G.ScrStart          equ       MAPADDR

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

* Font and palette data are stored in data modules.
* These are the module names.
fontmod             fcs       /font/
palettemod          fcs       /palette/

* Initialize the F256 display.
* Note: interrupts come in already masked.
InitDisplay         pshs      u                   save important registers
                    lda       MAPSLOT             get the MMU slot we'll map to
                    pshs      a                   save it on the stack

* Put F256 graphics into text mode.
                    ldx       #TXT.Base
                    ldd       #80*256+60
                    std       V.WWidth,u
                    lda       #Mstr_Ctrl_Text_Mode_En enable text mode
                    sta       MASTER_CTRL_REG_L,x
                    clr       MASTER_CTRL_REG_H,x
                    clr       BORDER_CTRL_REG,x
                    clr       BORDER_COLOR_R,x
                    clr       BORDER_COLOR_G,x
                    clr       BORDER_COLOR_B,x
                    clr       VKY_TXT_CURSOR_CTRL_REG,x

* Initialize the gamma.
                    lda       #$C0                get the gamma MMU block
                    sta       MAPSLOT             store it in the MMU slot to map it in
                    ldd       #0                  get the clear value
x1@                 tfr       d,x                 transfer it to X
                    stb       MAPADDR,x           store at $0000 off of X
                    stb       MAPADDR+$400,x      store at $0400 off of X
                    stb       MAPADDR+$800,x      store at $0800 off of X
                    incb                          increment the counter
                    bne       x1@                 loop until complete

* Initialize the palette.
                    leax      palettemod,pcr      point to the palette module
                    lda       #Data               it's a data module
                    os9       F$Link              link to it
                    bcs       InstallFont         branch if the link failed

                    pshs      y                   save Y
                    tfr       y,x                 transfer it to X
                    ldy       #TEXT_LUT_FG        load Y with the LUT foreground
                    bsr       copypal             copy the palette data for the foreground
                    puls      x                   restore Y into X
                    ldy       #TEXT_LUT_BG        load Y with the LUT background
                    bsr       copypal             copy the palette data for the background

* Install the font.
InstallFont         leax      fontmod,pcr         point to the font module
                    lda       #Data               it's a data module
                    os9       F$Link              link to it
                    bcs       SetForeBack         branch if the link failed
                    tfr       y,x                 transfer Y to X
                    lda       #$C1                get the font MMU block
                    sta       MAPSLOT             store it in the MMU slot to map it in
                    ldy       #MAPADDR            get the address to write to
loop@               ldd       ,x++                get two bytes of font data
                    std       ,y++                and store it
                    cmpy      #MAPADDR+2048       are we at the end?
                    bne       loop@               branch if not

* Initialize the cursor.
                    ldx       #TXT.Base
                    lda       #Vky_Cursor_Enable|Vky_Cursor_Flash_Rate0|Vky_Cursor_Flash_Rate1
                    sta       VKY_TXT_CURSOR_CTRL_REG,x
                    clra
                    clrb
                    std       VKY_TXT_CURSOR_Y_REG_L,x
                    std       VKY_TXT_CURSOR_X_REG_L,x
                    lda       #'_
                    sta       VKY_TXT_CURSOR_CHAR_REG,x

* Set foreground/background character LUT values.
SetForeBack         lda       #$C3                get the foreground/background LUT MMU block
                    sta       MAPSLOT             store it in the MMU slot to map it in
                    ldd       #$10*256+$10        load D with the LUT values
                    bsr       clr                 call the clear routine

* Clear text screen.
                    lda       #$C2                get the text MMU block
                    sta       MAPSLOT             store it in the MMU slot to map it in
                    ldd       #$20*256+$20        load D with the space character
                    bsr       clr                 call the clear routine
                    puls      a                   restore the saved map slot value
                    sta       MAPSLOT             and restore the it in the MMU
                    puls      u,pc                restore the registers and return

* Copy palette bytes from X to Y.
copypal             ldu       #64                 use a loop counter of 64 times
loop@               ldd       ,x++                get two bytes from the source
                    std       ,y++                and save it to the destination
                    ldd       ,x++                get two more bytes from the source
                    std       ,y++                and save it to the destination
                    leau      -4,u                subtract 4 from the counter
                    cmpu      #0000               are we done?
                    bne       loop@               branch if not
                    rts                           return

* Clear memory at MAPADDR with the contents of D.
clr                 ldx       #MAPADDR
loop@               std       ,x++
                    cmpx      #MAPADDR+80*61
                    bne       loop@
                    rts

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
Init                leax      DefaultHandler,pcr  get the default character processing routine
                    stx       V.EscVect,u         store it in the vector
                    ldb       #$10                assume this foreground/background
                    stb       V.FBCol,u           store it in our foreground/background color variable
                    clra                          set D..
                    clrb                          to $0000
                    std       V.CurRow,u          set the current row and column
                    lbsr      InitDisplay         initialize the display

* Tell the keyboard to start scanning.
* Do this FIRST before turning off LEDs, or else keyboard fails to respond after
* a reset. +BGP+
*
                    lda       #$FF                load the RESET command
                    lbsr       SendToPS2           send it to the keyboard
                    lda       #$AA                we expect an $AA response
                    lbsr       ReadFromPS2         read from the keyboard
                    
                    lda       #$F4                load the start scanning command
                    lbsr      SendToPS2           send it to the keyboard
                    
                    leax      ProcKeyCode,pcr     get the PS/2 key code handler routine
                    stx       V.KCVect,u          and store it as the current handler address
                    ldd       #INT_PENDING_0      get the pending interrupt pending address
                    leax      IRQPckt,pcr         point to the IRQ packet
                    leay      IRQSvc,pcr          and the service routine
                    os9       F$IRQ               install the interrupt handler
                    bcs       ErrExit             branch if we have an issue
                    lda       INT_MASK_0          else get the interrupt mask byte
                    anda      #^INT_PS2_KBD       set the PS/2 keyboard interrupt
                    sta       INT_MASK_0          and save it back

                    clrb                          clear the carry flag
                    rts                           return to the caller
ErrExit             orcc      #Carry              set the carry flag
                    rts                           return to the caller

* The F$IRQ packet.
IRQPckt             equ       *
Pkt.Flip            fcb       %00000000           the flip byte
Pkt.Mask            fcb       INT_PS2_KBD         the mask byte
                    fcb       $F1                 the priority byte

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
Read
* Check to see if there is a signal-on-data-ready set for this path.
* If so, we return E$NotRdy.
read1               lda       <V.SSigID,u         data ready signal trap set up?
                    lbne      NotReady            yes, exit with not ready error
                    leax      V.InBuf,u           point X to the input buffer
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
                    ldx       V.EscVect,u         get the escape vector address
                    jsr       ,x                  branch to it
                    pshs      d                   save D since we modify it here
                    lda       V.CurCol,u          get the current row in A
                    ldx       #TXT.Base
                    sta       VKY_TXT_CURSOR_X_REG_L,x
                    lda       V.CurRow,u          get the current row in A
                    sta       VKY_TXT_CURSOR_Y_REG_L,x
                    ldb       V.WWidth,u          and the current column in B
                    mul                           get the product
                    addb      V.CurCol,u          add it to the current column
                    adca      #0                  add in the carry in A
                    ldx       #G.ScrStart         point to the start of the screen
                    leax      d,x                 point X to the current position
                    puls      d,pc                restore register and return

DefaultHandler      cmpa      #C$SPAC             is the character a space or greater?
                    lbcs      ChkESC              branch if not; go check for escape codes
                    pshs      a                   else save the character to write
                    lda       V.CurRow,u          get the current row
                    ldb       V.WWidth,u          and the number of columns
                    mul                           calculate the row we should be on
                    addb      V.CurCol,u          add in the column
                    adca      #0                  and add in 0 with carry in case of overflow
* Here, D has the location in the screen where the next character goes.
                    ldx       #G.ScrStart         get the start of the screen in X
                    leax      d,x                 advance X to where the next character goes
                    puls      a                   get the character to write
                    pshs      cc                  save CC
                    ldb       MAPSLOT             get the MMU block number for the slot
                    pshs      b                   save it
                    ldb       #$C2                get the text MMU block number
                    orcc      #IntMasks           mask interrupts
                    stb       MAPSLOT             set the block number to text
                    sta       ,x                  save the character there
                    ldb       #$C3                get the text attributes MMU block number
                    stb       MAPSLOT             set the MMU block number to the text attributes block
                    lda       V.FBCol,u           get the current foreground/background color
                    sta       ,x                  save it at the same location in the text attributes
                    lda       ,s+                 recover the initial MMU slot value
                    sta       MAPSLOT             and restore it
                    puls      cc                  recover CC (this may unmask interrupts)
                    ldd       V.CurRow,u          get the current row and column
                    incb                          increment the column
                    cmpb      V.WWidth,u          compare it against the number of columns
                    blt       ok                  branch if we're less than
                    clrb                          else the column goes to 0
incrow              inca                          and we increment the row
                    cmpa      V.WHeight,u         compare it against the number of rows
                    blt       clrline             branch if we're less than (clear the new line we're on)
SCROLL              equ       1
                    ifne      SCROLL
                    deca                          set A to V.WHeight - 1
                    ldx       #G.ScrStart         get the start of the screen memory
                    pshs      d                   save D
                    ldd       V.WWidth,u          get screen width in A and height in B
                    decb                          decrement height by 1
                    mul                           get the product (bytes to copy)
                    tfr       d,y                 set Y to the size of the screen minus the last row
                    puls      d                   restore D
                    pshs      cc,d                save off the row/column and CC
                    lda       MAPSLOT             get the current MMU slot
                    pshs      a                   save it on the stack
                    orcc      #IntMasks           mask interrupts
scroll_loop1@       lda       #$C2                get the text block #
                    sta       MAPSLOT             and map it in
                    ldb       V.WWidth,u
                    ldd       b,x
                    std       ,x                  store on this row
                    lda       #$C3                get the text attributes block #
                    sta       MAPSLOT             and map it in
                    ldb       V.WWidth,u          get the bytes at the width
                    ldd       b,x
                    std       ,x++                and store it
                    leay      -2,y                decrement Y
                    bne       scroll_loop1@       branch if not 0
                    puls      a                   recover the original slot
                    sta       MAPSLOT             and restore it
                    puls      cc,d                recover CC and the row/column
                    else
                    clra                          just clear the row (goes to top)
                    endc
* clear line
clrline             std       V.CurRow,u          save the current row/column value
                    lbsr      EraseLine           erase the line
                    rts                           and return to the caller
ok                  std       V.CurRow,u          save the current row/column value
ret                 rts                           and return to the caller

;;; CurOn
;;;
;;; Turns the cursor on.
;;;
;;; Code: 05 21
CurOn               ldx       #TXT.Base
                    lda       VKY_TXT_CURSOR_CTRL_REG,x
                    ora       #Vky_Cursor_Enable
                    sta       VKY_TXT_CURSOR_CTRL_REG,x
                    rts

;;; CurOff
;;;
;;; Turns the cursor off.
;;;
;;; Code: 05 20
CurOff              ldx       #TXT.Base
                    ldb       VKY_TXT_CURSOR_CTRL_REG,x
                    andb      #~Vky_Cursor_Enable
                    stb       VKY_TXT_CURSOR_CTRL_REG,x
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
                    ldb       V.WWidth,u
                    mul                           get the product
                    addb      ,s                  add the column to start erasing from
                    adca      #0                  consider the carry
                    ldx       #G.ScrStart         get the screen base address
                    leax      d,x                 move X to the current row
                    lda       V.WWidth,u          get the number of columns
                    suba      ,s+                 subtract the column to start erasing from
                    pshs      cc                  save CC
                    orcc      #IntMasks           mask interrupts
                    ldb       MAPSLOT             get the MMU slot value
                    pshs      b                   save it
clrloop@            ldb       #$C2                get the text MMU block
                    stb       MAPSLOT             store it in the MMU slot
                    clr       ,x                  clear the value there
                    ldb       #$C3                get the text attributes MMU block
                    stb       MAPSLOT             store it in the MMU slot
                    ldb       V.FBCol,u           get the curent foreground/background color
                    stb       ,x+                 store it and increment the index register
                    deca                          decrement the loop value
                    bne       clrloop@            branch if not done
                    puls      b                   restore the MMU slot value
                    stb       MAPSLOT             into the hardware
                    puls      cc,pc               restore CC and return

;;; ClrScrn
;;;
;;; Clears the entire screen and homes the cursor.
;;;
;;; Code: 0C
ClrScrn             lda       V.WHeight,u         get the number of rows
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
                    cmpb      V.WWidth,u          is it >= the number of columns?
                    bgt       nextrow@
ex@                 std       V.CurRow,u
bye@                rts
nextrow@            ldb       V.WHeight,u
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
                    cmpa      V.WHeight,u         are we at the end?
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
                    cmpa      V.WWidth,u
                    blt       s1@
                    lda       V.WWidth,u
                    deca
s1@                 sta       V.CurCol,u
                    leax      CurXYChar2,pcr
                    bra       c@
CurXYChar2          suba      #$20
                    cmpa      V.WHeight,u
                    blt       s2@
                    lda       V.WHeight,u
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
crate@              leax      CurRate,pcr
                    bra       c@
cchar@              leax      CurChar,pcr
                    bra       c@
                    bne       ResetHandler
hide@               lbsr      CurOff
                    bra       ResetHandler
show@               lbsr      CurOn
                    bra       ResetHandler

;;; CurRate
;;;
;;; Change the cursor flashing rate.
;;;
;;; Code: 05 23
;;;
;;; Parameter: BYT
;;;
;;;   XXXXX1XX = cursor flashing disabled
;;;   XXXXX000 = 1 second flash interval
;;;   XXXXX001 = .5 second flash interval
;;;   XXXXX010 = .25 second flash interval
;;;   XXXXX011 = .2 second flash interval
CurRate             ldx       #TXT.Base
                    ldb       VKY_TXT_CURSOR_CTRL_REG,x
                    andb      #$01                preserve the cursor enable bit
                    lsla                          shift bits to the left
                    pshs      a                   save the value to OR in on the stack
                    orb       ,s+                 OR it in with the contents of the register
                    stb       VKY_TXT_CURSOR_CTRL_REG,x save it to the hardware
                    bra       ResetHandler        reset the handler

;;; CurChar
;;;
;;; Change the cursor character.
;;;
;;; Code: 05 22
;;;
;;; Parameter: CHR
;;;
;;; CHR can be any character from 0 - 255.
CurChar             ldx       #TXT.Base
                    sta       VKY_TXT_CURSOR_CHAR_REG,x
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
                    ldb       V.WWidth,u          get the number of columns
                    decb                          minus 1
                    deca                          decrement the counter
                    bpl       EraseChar           branch until done
                    clra                          clear A

* Entry:  A = The row of the character to erase.
*         B = The column of the character to erase.
EraseChar           std       V.CurRow,u          save D to the current row and column
                    ldb       V.WWidth,u          get the number of columns
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
DWSet               lda       V.DWType,u
                    cmpa      #$01                40x30?
                    bne       IsIt80x30
                    bsr       SetWin40x30
                    bra       setcols@
IsIt80x30           cmpa      #$02
                    bne       IsIt80x60
                    bsr       SetWin80x30
                    bra       setcols@
IsIt80x60           bsr       SetWin80x60
setcols@            lda       V.DWFore,u
                    lbsr      SetForeColor
                    lda       V.DWBack,u
                    lbsr      SetBackColor
                    lda       V.DWBorder,u
                    lbsr      SetBorderColor
                    lbsr      ClrScrn
                    lbra      ResetHandler

SetWin40x30         ldb       #DBL_Y|DBL_X
                    ldx       #40*256+30
SetWin              stx       V.WWidth,u
                    pshs      b
                    ldx       #TXT.Base
                    ldb       MASTER_CTRL_REG_H,x
                    andb      #~(DBL_Y|DBL_X|CLK_70)
                    orb       ,s+
                    stb       MASTER_CTRL_REG_H,x
                    rts

SetWin80x30         ldb       #DBL_Y
                    ldx       #80*256+30
                    bra       SetWin

SetWin80x60         clrb
                    ldx       #80*256+60
                    bra       SetWin

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
                    beq       NotReady            if there's no data in keyboard buffer, return the "not ready" error
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
                    ldb       V.WWidth,u          get the column count
                    std       R$X,x               save it in X
                    ldb       V.WHeight,u         get the row count
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
SSJoy               lda       VIA.Base+VIA_ORA_IRA get the joystick value
                    ldx       #0                  initialize left/top value in X
                    ldy       #255                initialize right/bottom value in Y
                    lsra                          shift out UP
                    bcc       s1@                 branch if carry clear
                    stx       R$Y,u               else store left value in caller's Y
s1@                 lsra                          shift out DOWN
                    bcc       s2@                 branch if carry clear
                    sty       R$Y,u               else store right value in caller's Y
s2@                 lsra                          shift out LEFT
                    bcc       s3@                 branch if carry clear
                    stx       R$X,u               else store up value in caller's X
s3@                 lsra                          shift out RIGHT
                    bcc       s4@                 branch if carry clear
                    sty       R$X,u               else store right value in caller's X
* A now contains (BUTTON 2 | BUTTON 1 | BUTTON 0) in lower 3 bits
s4@                 sta       R$A,u               store buttons in caller's A
                    clrb                          clear carry
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
SS.DMAFill          equ       $B0
SetStat             ldx       PD.RGS,y            get caller's regsiters in X
                    cmpa      #SS.SSig            send signal on data ready?
                    beq       SSSig               yes, go process
                    cmpa      #SS.Relea           release signal on data ready?
                    beq       SSRelea             yes, go process
                    cmpa      #SS.DMAFill         DMA Fill?
                    beq       SSDMAFill
                    comb                          set the carry
                    ldb       #E$UnkSvc           load the "unknown service" error
                    rts                           return

* SS.DMAFill - fill memory
DMF$DstAddrHi       equ       0
DMF$DstAddrMid      equ       1
DMF$DstAddrLow      equ       2
DMF$DstSizeHi       equ       3
DMF$DstSizeMid      equ       4
DMF$DstSizeLow      equ       5
DMF$FillValue       equ       6

SSDMAFill           ldy       #DMA.Base
                    lda       #DMA_CTRL_Fill|DMA_CTRL_Start_Trf
                    sta       DMA_CTRL_REG,y
                    ldx       R$X,x               get pointer to the DMA control block
                    ldd       DMF$DstAddrHi,x
                    sta       DMA_DEST_ADDR_H,y
                    stb       DMA_DEST_ADDR_M,y
                    lda       DMF$DstAddrLow,x
                    stb       DMA_DEST_ADDR_L,y
                    ldd       DMF$DstSizeHi,x
                    sta       DMA_SIZE_1D_H,y
                    stb       DMA_SIZE_1D_M,y
                    ldd       DMF$DstSizeLow,x
                    sta       DMA_SIZE_1D_L,y
                    stb       DMA_DATA_2_WRITE
                    lda       DMA_CTRL_REG,y
                    ora       #DMA_CTRL_Start_Trf
                    sta       DMA_CTRL_REG,y
* The CPU halts here until the transfer is complete.
                    rts

* SS.SSig - send signal on data ready
SSSig               pshs      cc                  save interrupt status
                    lda       V.IBufH,u           get get the buffer tail ptr
                    suba      V.IBufT,u           A = the number of characters ready to read
                    pshs      a                   save it temporarily
                    bsr       GetCPR              get current process ID
                    tst       ,s+                 anything in buffer?
                    bne       SendSig             yes, go send the signal
                    std       <V.SSigID,u         save process ID & signal
                    puls      pc,cc               restore interrupts & return

GetCPR              orcc      #IntMasks           disable interrupts
                    lda       PD.CPR,y            get curr proc #
                    ldb       R$X+1,x             get user signal code
                    rts                           return

SendSig             puls      cc                  restore interrupts
                    os9       F$Send              send the signal
                    rts                           return

* SS.Relea - release a path from SS.SSig
SSRelea             lda       PD.CPR,y            get the current process ID
                    cmpa      <V.SSigID,u         is it the same as the keyboard?
                    bne       ex@                 branch if not
                    clr       <V.SSigID,u         else clear process the ID
ex@                 rts

***
* IRQ routine for keyboard
*
* INPUT:  A = flipped and masked device status byte
*         U = keyboard data area address
*
* OUTPUT:
*          CC Carry clear
*          D, X, Y, and U registers may be altered
*
* ERROR OUTPUT:  none
*

RAW_KEYBOARD        equ       0

                    ifne      RAW_KEYBOARD
* Input: A = byte to convert to hex
* Output: A = ASCII character of first digit
*         B = ASCII character of second digit
cvt2hex             pshs      a
                    lsra
                    lsra
                    lsra
                    lsra
                    cmpa      #9
                    bgt       hex@
                    adda      #$30
                    bra       afthex@
hex@                adda      #$37
afthex@
                    ldb       ,s+
                    andb      #$0F
                    cmpb      #9
                    bgt       hex2@
                    addb      #$30
                    bra       afterhex2@
hex2@               addb      #$37
afterhex2@          rts
                    endc

* Send a byte to the PS/2 keyboard.
*
* Entry: A = The byte to send to the keyboard.
SendToPS2           sta       PS2_OUT             send the byte out to the keyboard
                    lda       #K_WR               load the "write" bit
                    sta       PS2_CTRL            send it to the control register
                    clr       PS2_CTRL            then clear the bit in the control register
                    lda       #$FA
* Entry: A = Response to expect from the keyboard.
* Destroys X.
ReadFromPS2         ldx       #$0000
                    pshs      a,x
l@                  ldx       1,s
                    leax      -1,x
                    stx       1,s
                    cmpx      #$0000
                    beq       e@
                    lda       KBD_IN              load a byte from the keyboard
                    cmpa      ,s                  is it what we expect?
                    bne       l@                  branch if not
                    clra                          clear carry
                    puls      a,x,pc              return
e@                  comb
                    puls      a,x,pc              return

IRQSvc              ldb       #INT_PS2_KBD        get the PS/2 keyboard interrupt flag
                    stb       INT_PENDING_0       clear the interrupt
getcode             lda       KBD_IN              get the key code
                    beq       IRQExit             if it's a zero, ignore

* These next two lines get around an issue where an interrupt occurs even after
* clearing it and reading all data from the keyboard at initialization.
* This may be a hardware issue.
                    cmpa      #$FA                is it the acknowledge byte?
                    beq       IRQExit             branch if so

                    ifne      RAW_KEYBOARD
                    bsr       cvt2hex             convert the key code to hexadecimal
                    pshs      b                   save the hexadecimal character
                    bsr       BufferChar          buffer it
                    puls      a                   get the character
                    bsr       BufferChar          buffer it
                    bra       CheckSig            wake up any sleeping process waiting on input
                    endc

* A = key code
* point Y to appropriate key table (SHIFT vs Non-SHIFT)
                    tst       V.SHIFT,u           is the SHIFT key down?
                    bne       shift@              branch of so
                    leay      ScanMap,pcr         else point to the non-SHIFT scan map
                    bra       pastshift@          and branch
shift@              leay      SHIFTScanMap,pcr    point to the SHIFT scan map
pastshift@          ldx       V.KCVect,u          get the current key code handler
                    jsr       ,x                  branch into it
                    bcs       IRQExit             if the carry is set, don't wake process
                    ldb       #S$Intrpt           get the interrupt signal
                    cmpa      V.INTR,u            is our character same as the interrupt signal?
                    beq       getlproc@           branch if it's the same
                    ldb       #S$Abort            get the abort signal
                    cmpa      V.QUIT,u            is our character same as the abort signal?
                    bne       CheckSig            branch if it isn't
getlproc@           lda       V.LPRC,u            else get the ID of the last process to use this device
                    bra       noproc@             branch
CheckSig            lda       <V.SSigID,u         send signal on data ready?
                    beq       WakeIt              no, just go wake up the process
                    ldb       <V.SSigSg,u         else get the signal code
                    clr       <V.SSigID,u         clear signal ID
                    bra       send@
* Wake up any process if it's sleeping waiting for input.
WakeIt              ldb       #S$Wake             get the wake signal
                    lda       V.WAKE,u            is there a process asleep waiting for input?
noproc@             beq       IRQExit             branch if not
                    clr       V.WAKE,u            else clear the wake flag
send@               os9       F$Send              and send the signal in B
IRQExit             lsr       PS2_STAT            shift the PS/2 status bit 0 into the carry
                    bcc       getcode             branch if the carry is 0 (meaning there's more key data to read)
ex@                 clrb                          else the clear carry
ex2@                rts                           return

* Entry:  A = PS/2 key code
*
* Exit:  CC = carry clear: wake up a sleeping process waiting on input
*             carry set: don't wake up a sleeping process waiting on input
ProcKeyCode         cmpa      #$E0                is it the $E0 preface byte?
                    beq       ProcE0              branch if so
                    cmpa      #$F0                is it the $F0 preface byte?
                    beq       ProcF0              branch if so
                    lda       a,y                 else pull the key character from the scan code table
                    bmi       SpecialDown         if the high bit is set, handle this special case
* Check for the CTRL key.
                    tst       V.CTRL,u            is the CTRL key down?
                    beq       CheckCAPSLock       branch if not
                    suba      #$60                else subtract $60 from the character in A
CheckCAPSLock       tst       V.CAPSLck,u         is the CAPS Lock on?
                    beq       BufferChar          branch if not
                    cmpa      #'a                 else compare the character to lowercase "a"
                    blt       BufferChar          branch if the character is less than
                    suba      #$20                else make the character uppercase
* Advance the circular buffer one character.
BufferChar          ldb       V.IBufH,u           get buffer head pointer in B
                    leax      V.InBuf,u           point X to the input buffer
                    abx                           X now holds address of the head pointer
                    lbsr      IncNCheck           increment the pointer and check for tail wrap
                    cmpb      V.IBufT,u           is B at the tail? (if so, the input buffer is full)
                    beq       bye@                branch if the input buffer is full (drop the character)
                    stb       V.IBufH,u           update the buffer head pointer
                    sta       ,x                  place the character in the buffer
bye@                clrb                          clear carry
                    rts                           return

SpecialDown         cmpa      #$F0                is this the CAPS Lock key?
                    blt       next@               branch if not
                    beq       DoCapsDown          branch if it is
                    cmpa      #$F1                is this the SHIFT key?
                    beq       DoSHIFTDown         branch if it is
                    cmpa      #$F2                is this the CTRL key?
                    beq       DoCTRLDown          branch if it is
DoALTDown           sta       V.ALT,u             it must be the ALT key then
                    comb                          clear the carry so that the read routine just returns
                    rts                           return
DoCTRLDown          sta       V.CTRL,u            it's the CTRL key
                    comb                          clear the carry so that the read routine just returns
                    rts                           return
DoCapsDown
                    lda       #$ED                get the PS/2 keyboard LED command
                    lbsr      SendToPS2           send it to the PS/2
                    lda       V.PS2LED,u          get the PS/2 LED flags in static memory
                    com       V.CAPSLck,u         complement the CAPS lock flag in our static memory
                    beq       ledoff@             branch if the result is 0 (LED should be turned off)
                    ora       #$04                set the CAPS Lock LED bit
                    bra       send@               and send it to the keyboard
ledoff@             anda      #^$04               clear the CAPS Lock LED bit
send@               lbsr      SendToPS2           send the byte to the keyboard
                    comb                          clear the carry so that the read routine just returns
                    rts                           return
DoSHIFTDown         sta       V.SHIFT,u           its the SHIFT key
                    comb                          clear the carry so that the read routine just returns
                    rts                           return
next@               anda      #^$80               clear the high bit
                    bra       BufferChar          go store the character

ProcE0              leax      E0Handler,pcr       get the $E0 handler routine
                    stx       V.KCVect,u          store it in the vector
                    comb
                    rts                           return

ProcF0              leax      F0Handler,pcr       get the $F0 handler routine
                    stx       V.KCVect,u          store it in the vector
                    comb                          clear the carry so that the read routine handles other work
                    rts                           return

* A = key code
* Y = scan table
E0Handler           cmpa      #$F0                is this the $F0 key code?
                    beq       ProcF0              branch if so
                    leax      ProcKeyCode,pcr     else point to the key code processor
                    stx       V.KCVect,u          store it in the vector
                    cmpa      #$11                is this the right ALT key?
                    beq       DoALTDown           if so, handle the ALT key
                    cmpa      #$14                is this the right CTRL key?
                    beq       DoCTRLDown          if so, handle the CTRL key
                    cmpa      #$75                is this the up arrow key?
                    beq       DoUpArrowDown       if so, handle it
                    cmpa      #$6B                is this the left arrow key?
                    beq       DoLeftArrowDown     if so, handle it
                    cmpa      #$72                is this the down arrow key?
                    beq       doDownArrowDown     if so, handle it
                    cmpa      #$74                is this the right arrow key?
                    beq       doRightArrowDown    if so, handle it
                    comb                          else set the carry
                    rts                           return
DoUpArrowDown       lda       #$0C                load up arrow character
                    lbra      BufferChar          add it to the input buffer
DoDownArrowDown     lda       #$0A                load down arrow character
                    lbra      BufferChar          add it to the input buffer
DoLeftArrowDown     lda       #$08                load left arrow character
                    lbra      BufferChar          add it to the input buffer
DoRightArrowDown    lda       #$09                load right arrow character
                    lbra      BufferChar          add it to the input buffer
E0HandlerUp         cmpa      #$11                is this the right ALT key going up?
                    beq       DoALTUp             if so, handle that case
                    cmpa      #$14                is this the right CTRL key going up?
                    beq       DoCTRLUp            if so, handle that case
                    bra       SetDefaultHandler   set the default handler
F0Handler           lda       a,y                 get the routine
                    bmi       SpecialUp           and perform key up processing
SetDefaultHandler
                    leax      ProcKeyCode,pcr     point to default key code processor
                    stx       V.KCVect,u          save it in the key code vector
                    comb
                    rts
SpecialUp           cmpa      #$F1                is this the SHIFT key going up?
                    beq       DoSHIFTUp           branch if so
                    cmpa      #$F2                is this the CTRL key going up?
                    bne       SetDefaultHandler   branch if not
DoCTRLUp            clr       V.CTRL,u            clear the CTRL key state
                    bra       SetDefaultHandler   and branch to set the default handler
DoSHIFTUp           clr       V.SHIFT,u           clear the SHIFT key state
                    bra       SetDefaultHandler   and branch to set the default handler
DoALTUp             clr       V.ALT,u             clear the ALT key state
                    bra       SetDefaultHandler   and branch to set the default handler

* These tables map PS/2 key codes to characters in both non-SHIFT and SHIFT cases.
* If the high bit of a character is set, it is a special flag and therefore
* is handled differently. The special flags are:
*     $F0 = CAPS Lock key pressed
*     $F1 = SHIFT key pressed
*     $F2 = CTRL key pressed
*     $F3 = ALT key pressed
ScanMap             fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,'`,0
                    fcb       0,$F3,$F1,0,$F2,'q,'1,0,0,0,'z,'s,'a,'w,'2,0
                    fcb       0,'c,'x,'d,'e,'4,'3,0,0,C$SPAC,'v,'f,'t,'r,'5,0
                    fcb       0,'n,'b,'h,'g,'y,'6,0,0,0,'m,'j,'u,'7,'8,0
                    fcb       0,C$COMA,'k,'i,'o,'0,'9,0,0,'.,'/,'l,';,'p,'-,0
                    fcb       0,0,'',0,'[,'=,0,0,$F0,$F1,C$CR,'],0,'\,0,0
                    fcb       0,0,0,0,0,0,$88,0,0,'1,0,'4,'7,0,0,0
                    fcb       '0,'.,'2,'5,'6,'8,$05,0,0,'+,'3,'-,'*,'9,0,0

SHIFTScanMap        fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,'~,0
                    fcb       0,$F3,$F1,0,$F2,'Q,'!,0,0,0,'Z,'S,'A,'W,'@,0
                    fcb       0,'C,'X,'D,'E,'$,'#,0,0,C$SPAC,'V,'F,'T,'R,'%,0
                    fcb       0,'N,'B,'H,'G,'Y,'^,0,0,0,'M,'J,'U,'&,'*,0
                    fcb       0,'<,'K,'I,'O,'),'(,0,0,'>,'?,'L,':,'P,'_,0
                    fcb       0,0,'",0,'{,'+,0,0,$F0,$F1,C$CR,'},0,'|,0,0
                    fcb       0,0,0,0,0,0,$98,0,0,'1,0,'4,'7,0,0,0
                    fcb       '0,'.,'2,'5,'6,'8,$05,0,0,'+,'3,'-,'*,'9,0,0

                    emod
eom                 equ       *
                    end
