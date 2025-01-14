********************************************************************
* foenix - Foenix Basic09 subroutine module
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/03/13  Boisy Gene Pitre
* Created.

                  IFP1
                    use       os9.d
                    use       scf.d
                    use       f256vtio.d
                  ENDC

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $05

                    mod       eom,name,tylg,atrv,start,size

* Data size since BASIC09 subroutine modules do everything on the stack
u0000               rmb       0
size                equ       .

name                fcs       /foenix/
                    fcb       edition

                    fcb       $00

* Offsets for parameters accessed directly (there can be more, but they are handled in loops)
                    org       0
Return              rmb       2         $00 Return address of caller
PCount              rmb       2         $02 # of parameters following
PrmPtr1             rmb       2         $04 pointer to 1st parameter data
PrmLen1             rmb       2         $06 length of 1st parameter
PrmPtr2             rmb       2         $08 pointer to 2nd parameter data
PrmLen2             rmb       2         $0A length of 2nd parameter
PrmPtr3             rmb       2         $0C pointer to 3rd parameter data
PrmLen3             rmb       2         $0E length of 3rd parameter
PrmPtr4             rmb       2         $10 pointer to 4th parameter data
PrmLen4             rmb       2         $12 length of 4th parameter
PrmPtr5             rmb       2         $14 pointer to 5th parameter data
PrmLen5             rmb       2         $16 length of 5th parameter
PrmPtr6             rmb       2         $18 pointer to 6th parameter data
PrmLen6             rmb       2         $1A length of 6th parameter
PrmPtr7             rmb       2         $1C pointer to 7th parameter data
PrmLen7             rmb       2         $1E length of 7th parameter
PrmPtr8             rmb       2         $20 pointer to 8th parameter data
PrmLen8             rmb       2         $22 length of 8th parameter
PrmPtr9             rmb       2         $24 pointer to 9th parameter data
PrmLen9             rmb       2         $26 length of 9th parameter
stkdepth            equ       .

* Function table. Please note, that on entry to these subroutines, the main temp stack is already
* allocated (33 bytes), B=# of parameters received
* Sneaky trick for end of table markers - it does a 16 bit load to get the offset to the function
*  routine. It has been purposely made so that every one of these offsets >255, so we only need a
*  single $00 byte as the high byte to designate the end of a table

FuncTbl
                    fdb       Random-FuncTbl
                    fcc       "Random"
                    fcb       $FF

                    fdb       Seed-FuncTbl
                    fcc       "Seed"
                    fcb       $FF

                    fdb       DWSet-FuncTbl
                    fcc       "DWSet"
                    fcb       $FF

                    fdb       Palette-FuncTbl
                    fcc       "Palette"
                    fcb       $FF

                    fdb       Color-FuncTbl
                    fcc       "Color"
                    fcb       $FF

                    fdb       CurHome-FuncTbl
                    fcc       "CurHome"
                    fcb       $FF

                    fdb       CurXY-FuncTbl
                    fcc       "CurXY"
                    fcb       $FF

                    fdb       ErLine-FuncTbl
                    fcc       "ErLine"
                    fcb       $FF

                    fdb       ErEOLine-FuncTbl
                    fcc       "ErEOLine"
                    fcb       $FF

                    fdb       CurOff-FuncTbl
                    fcc       "CurOff"
                    fcb       $FF

                    fdb       CurOn-FuncTbl
                    fcc       "CurOn"
                    fcb       $FF

                    fdb       CurRgt-FuncTbl
                    fcc       "CurRgt"
                    fcb       $FF

                    fdb       Bell-FuncTbl
                    fcc       "Bell"
                    fcb       $FF

                    fdb       CurLft-FuncTbl
                    fcc       "CurLft"
                    fcb       $FF

                    fdb       CurUp-FuncTbl
                    fcc       "CurUp"
                    fcb       $FF

                    fdb       CurDwn-FuncTbl
                    fcc       "CurDwn"
                    fcb       $FF

                    fdb       ErEOWndw-FuncTbl
                    fcc       "ErEOWndw"
                    fcb       $FF

                    fdb       Clear-FuncTbl
                    fcc       "Clear"
                    fcb       $FF

                    fdb       CrRtn-FuncTbl
                    fcc       "CrRtn"
                    fcb       $FF

                    fdb       InsLin-FuncTbl
                    fcc       "InsLin"
                    fcb       $FF

                    fdb       DelLin-FuncTbl
                    fcc       "DelLin"
                    fcb       $FF

                    fdb       Tone-FuncTbl
                    fcc       "Tone"
                    fcb       $FF

                    fdb       WInfo-FuncTbl
                    fcc       "WInfo"
                    fcb       $FF

                    fdb       ID-FuncTbl
                    fcc       "ID"
                    fcb       $FF

* Test by sending non-existant function name
                    fcb       $00       end of table marker

* All functions (from the call table) are entered with the following parameters:
*   Y = pointer to function subroutine
*   X = pointer to "stkdepth" byte scratch variable area (same as stack pointer, which has allocated that extra memory)
*   U = pointer to 2nd parameter (first parameter after name itself)
*   D = # of parameters (NOTE: function name itself is always parameter 1)

* Stack on entry to every function routine (with stkdepth set to 9):
*   $00-$08 / 00-08,s - temporary scratch variable area
*   $09-$0A / 09-10,s - RTS address to BASIC09/RUNB
*   $0B-$0C / 11-12,s - # of parameters (including function name itself)
*   $0D-$0E / 13-14,s - pointer to 1st parameter's data (function name)
*   $0F-$10 / 15-16,s - length of first parameter
* From here on is optional, depending on the function being called, there can be up to 9 parameter pairs
* (pointer/value and length).
* The temporary stack uses 0,s as the path #, and 1,s + as the output buffer.

start               leas      <-stkdepth,s reserve bytes on stack
                    clr       ,s        clear optional path # is BYTE or INTEGER flag
                    ldd       <stkdepth+PCount,s get # of parameters
                    beq       ParamErr  if 0, exit with parameter error
                    tsta                if >255, exit with parameter error
                    bne       ParamErr  branch if >255
                    ldd       [<stkdepth+PrmPtr1,s] get value from first parameter (optional path #)
                    ldx       <stkdepth+PrmLen1,s get length of 1st parameter
                    leax      -1,x      decrement length
                    beq       byte@     if zero, it's a BYTE value, so save path #
                    leax      -1,x      decrement length again
                    bne       nopath@   if not INTEGER value, no optional path, 1st parameter is keyword
                    tfr       b,a       it's an INTEGER value, so save LSB as path #
byte@               sta       ,s        save on stack
                    dec       <stkdepth+PCount+1,s decrement # of parameters (to skip path #)
                    ldx       <stkdepth+PrmPtr2,s X = pointer to function name we received
                    leau      <stkdepth+PrmPtr3,s U = pointer to (possible) 1st parameter for function
                    bra       L02B8
* No optional path, set path to Std Out, and point X/U to function name and 1st parameter for it.
nopath@             inc       ,s        no optional path # specified, set path to 1 (Std Out)
                    ldx       <stkdepth+PrmPtr1,s point to function name
                    leau      <stkdepth+PrmPtr2,s point to first parameter of function
* Entry here: X=pointer to function name passed from caller
*             U=pointer to 1st parameter for function
L02B8               pshs      u,x       save 1st parameter & function name pointers
                    leau      >FuncTbl,pcr point to table of supported functions
L02BE               ldy       ,u++      get pointer to subroutine
                    beq       L02F0     if $0000, exit with Unimplemented Routine Error (out of functions)
                    ldx       ,s        get pointer to function name we were sent
L02C5               lda       ,x+       get character from caller
                    eora      ,u+       force matching case and compare with table entry
                    anda      #$DF      set case
                    beq       L02D5     matched, skip ahead
                    leau      -1,u      bump table pointer back one
L02CF               tst       ,u+       hi bit set on last character? ($FF check cheat)
                    bpl       L02CF     no, keep scanning till we find end of table entry text
                    bra       L02BE     check next table entry

L02D5               tst       -1,u      was hi bit set on matching character? (we hit end of function name?)
                    bpl       L02C5     no, check next character
* 6809/6309 - skip leas, change puls u below to puls u,x (faster, and we reload X anyways)
                    leas      2,s       yes, function found. Eat copy of pointer to function name we were sent
                    tfr       y,d       copy jump table offset to D
                    leay      >FuncTbl,pcr point to table of supported functions again
                    leay      d,y       add offset
                    puls      u         get original 1st parameter pointer
                    leax      1,s       point to temp write buffer we are building

                    lda       #$1B      start it with an ESCAPE code (most functions use this)
                    sta       ,x+       store it in the output buffer
                    ldd       <stkdepth+PCount,s get # of params again including path (if present) & function name pointer
                    jmp       ,y        call function subroutine & return from there

L02F0               leas      4,s       clean the stack
                    ldb       #E$NoRout unimplemented routine error
                    bra       L02F8

ParamErr            ldb       #E$ParmEr parameter error
L02F8               coma                set the carry
                    leas      <stkdepth,s clean the stack
                    rts                 return to the caller

* For all calls from table, entry is:
*   Y = The address of routine.
*   X = Output buffer pointer ($1B is preloaded).
*   U = Pointer to 1st parameter for function.
*   D = # of parameters being passed (including optional path #, and function name pointer).

;;; ID - Get the calling process' user ID.
;;;
;;; Calling syntax: RUN FOENIX([path,] "ID", id)
ID                  os9       F$ID      get process ID # into D
                    tfr       a,b       put process ID in B
                    clra                and clear A (D = process ID)
                    std       [,u]      save it in caller's parameter 1 variable
L0305               clrb                no error
                    leas      <stkdepth,s eat temporary stack
                    rts                 return to the caller

;;; TONE - Generate a sound.
;;;
;;; Calling syntax: RUN FOENIX([path,] "TONE", frequency, duration, volume)
Tone                cmpb      #4        4 parameters?
                    lbne      ParamErr  no, exit with Parameter Error
                    ldy       [,u]      get frequency (0-1023)
                    ldd       [<$04,u]  get duration (1/60th second count) 0-255
                    pshs      b         save it (only 8 bit)
                    ldd       [<$08,u]  get volume (amplitude) (0-15)
                    tfr       b,a       move to high byte
                    puls      b         get duration back
                    tfr       d,x       X is now set up for SS.Tone
                    lda       ,s        get path
                    ldb       #SS.Tone  load tone code
                    os9       I$SetStt  perform the command
L043B               leas      <stkdepth,s eat temporary stack
                    rts                 return to the caller

;;; WINFO - Get window information.
;;;
;;; Calling syntax: RUN FOENIX([path,] "WINFO", format, width, height, foreground, background, border)
WInfo               cmpb      #7        7 parameters?
                    lbne      ParamErr  no, exit with parameter error
                    lda       ,s        get path
                    ldb       #SS.ScTyp get screen type system call
                    os9       I$GetStt
                    bcs       L0479     error, eat temp stack & exit
                    tfr       a,b       D=screen type
                    clra
                    std       [,u]      save to caller
                    lda       ,s        get path again
                    ldb       #SS.ScSiz load screen size code
                    os9       I$GetStt  perform the command
                    bcs       L0479     error, eat temporary stack & exit
                    stx       [<$04,u]  save # of columns in current working area
                    sty       [<$08,u]  save # of rows in current working area
                    ldb       #SS.FBRgs load foreground/background/border color call
                    os9       I$GetStt  perform the command
                    bcs       L0479     error, eat temporary stack & exit
                    pshs      a         save foreground color on stack
                    clra                D=background color
                    std       [<$10,u]  save to caller
                    puls      b         D=foreground color
                    std       [<$0C,u]  save to caller
                    stx       [<$14,u]  save border color to caller
L0478               clrb                no error
L0479               leas      <stkdepth,s eat temporary stack
                    rts                 return to the caller

;;; DWSET - Define a device window.
;;;
;;; Calling syntax: RUN FOENIX([path,] "DWSET", format, xcor, ycor, width, height, foreground, background, border)
DWSet               lda       #$20      load device window set code
                    pshs      x,d       save output string memory pointer, # of parameters & display code
                    ldx       2,u       get size of 1st parameter (to see if optional path #)
                    cmpx      #2        INTEGER?
                    bne       L04C0     no, skip ahead
                    ldd       [,u]      yes, get INTEGER value
                    bra       L04C2

L04C0               lda       [,u]      get BYTE value from parameter 1
L04C2               puls      x,d       restore output memory string pointer, # of parameters & display code (leaves CC alone)
                    ble       L04EF
                    cmpb      #9        9 parameters?
                    bne       L0528     no, skip ahead
                    sta       ,x+       save code to output stream
                    lbra      L0920     append next 8 parameters to output stream (either byte or integer) & write it out

L04E4               cmpb      #1        1 parameter?
                    bne       L0528     no, exit with parameter error
L04E8               sta       ,x+       append command code, and write output buffer out
                    lbra      L0901

L04EF               cmpb      #8        8 parameters?
                    bne       L0528     no, exit with parameter error
                    sta       ,x+       append OWSet code to output buffer
                    lbra      L0922     append the next 7 parameters (BYTE or INTEGER) to the output buffer & write it out

L0526               cmpb      #3        3 parameters?
L0528               lbne      ParamErr  no, exit with parameter error
                    sta       ,x+       yes, append code
                    lbra      L092C     append 2 BYTE/INTEGER parameters

L0579               ldx       ,u        get parameter pointer for string caller sent
                    lbsr      L0892     go find match, and get code to send for that string
                    puls      y,x       restore registers
                    bcs       L0528     no match found in table, exit with parameter error
                    lbra      L04E8     append code & write out

* Palette
Palette             lda       #$31      palette code
                    bra       L0526     append 3 parameters or exit with parameter error

;;; COLOR - Set the window colors.
;;;
;;; Calling syntax: RUN FOENIX([path,] "COLOR", foreground [,background] [,border])
Color               cmpb      #2        2 parameters? (foreground only, no path)
                    beq       color2@   yes, do that
                    cmpb      #3        3 parameters? (foreground/background only)?
                    beq       color3@   yes, do that
                    cmpb      #4        4 parameters? (foreground/background/border)?
                    bne       L0528     no, exit with parameter error
                    bra       color4@   yes, send all 3 color setting sequences out
* Build FColor sequence & write it out
color2@             bsr       L05B6     build foreground color sequence
                    bra       L05B3     write it out
*  Build FColor and BColor command sequences & write them out
color3@             bsr       L05B6     build foreground color sequence first
                    ldb       #$1B      add ESC code
                    stb       ,x+
                    bsr       L05BA     build background color sequence
                    bra       L05B3     write it out
* Build FColor, BColor, Border
color4@             bsr       L05B6     append foreground color sequence
                    ldb       #$1B      add ESC to output buffer
                    stb       ,x+
                    bsr       L05BA     append background color sequence
                    ldb       #$1B      add ESC to output buffer
                    stb       ,x+
                    bsr       L05CA     append border color sequence
L05B3               lbra      L0901     write output buffer

L05B6               lda       #$32      append foreground color code
                    bra       L05BC     and BYTE/INTEGER parameter from caller

* Build BColor
L05BA               lda       #$33      append background color code
L05BC               sta       ,x+
                    lbra      L0932     append background color (BYTE/INTEGER) from caller

L05CA               lda       #$34      append border color
                    bra       L05BC

* Entry: U=pointer to current parameter pointer
*        X=pointer to current position in output buffer
* Do SetDPtr (Set Draw Pointer) to x,y coord specified by next two parameters
L05F7               pshs      a         save A (original display code)
                    lda       #$40      append display code for SetDPPtr
                    sta       ,x+
                    lbsr      L08CE     append X coord
                    lbsr      L08CE     append Y coord
                    puls      pc,a      restore original display code & return

;;; SEED - Seeds the hardware-based random number.
;;;
;;; Calling syntax: RUN FOENIX([path,] "SEED" ,value)
Seed
                    lda       3,u       get the length of the 1st parameter
                    cmpa      #2        is it an integer?
                    lbne      ParamErr  no, return an error
                    ldx       #$FE00    load the base address
                    lda       #1        load the start flag
                    sta       6,x       enable the random number generator
                    ldd       [,u]      get seed from the caller
                    exg       a,b       swap bytes
                    std       4,x       store in hardware
                    clrb                no error, eat temp stack & return
                    leas      <stkdepth,s
                    rts                 return to the caller

;;; RANDOM - Returns a hardware-based random number.
;;;
;;; Calling syntax: RUN FOENIX([path,] "RANDOM" ,value)
Random
                    lda       3,u       get the length of the 1st parameter
                    cmpa      #2        is it an integer?
                    lbne      ParamErr  no, return an error
                    ldx       #$FE00    load the base address
                    lda       #1        load the start flag
                    sta       6,x       enable the random number generator
                    ldd       4,x       get bits 7-0 in A, 15-8 in B
                    exg       a,b       swap 'em
                    std       [,u]      save in caller's parameter 1 variable
                    clrb                no error, eat temp stack & return
                    leas      <stkdepth,s
                    rts                 return to the caller
L060F               cmpb      #3        3 parameters?
                    beq       L061D     yes, process (just end point)
                    cmpb      #5        5 parameters?
                    bne       L062E     no, exit with parameter error
                    bsr       L05F7     yes, do SetDPtr (Set Draw Pointer) first and then draw line
                    ldb       #$1B      ESC code
                    stb       ,x+       append to output buffer
L061D               sta       ,x+       save code in output buffer
                    lbra      L08FD     append two 16 bit parameters from caller (X endpoint, Y endpoint)

L062E               lbne      ParamErr  no, exit with parameter error
                    bra       L061D     yes, add X,Y coords from caller & write out

;;; CURHOME - Home the cursor.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURHOME")
CurHome             lda       #$01      home cursor code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CURXY - Move the cursor to a column and row.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURXY", column, row)
CurXY               lda       #$02      CurXY code
                    cmpb      #3        3 parameters?
L0804               lbne      ParamErr  no, exit with parameter error
                    sta       -1,x      yes, overwrite original ESC code in output buffer
                    bsr       L0811     append X coord from caller (with $20 offset)
                    bsr       L0811     append Y coord from caller (with $20 offset)
                    lbra      L0901     write output buffer

* Process text coord from caller. Handles BYTE or INTEGER, and adds +$20 offset needed for CurXY
L0811               pshs      y,d       save registers
                    ldd       [,u++]    get coord from caller (INTEGER)
                    adda      #$20      offset for CurXY
                    sta       ,x+       save in output buffer
                    pulu      y         get size of coord variable from caller
                    leay      -1,y      BYTE type?
                    beq       L0829     yes, we are done, restore registers & exit
                    leay      -1,y      INTEGER type?
                    lbne      L091B     no, eat temp stack, return with parameter error
                    addb      #$20      replace coord in output buffer with LSB of INTEGER parameter
                    stb       -1,x
L0829               puls      pc,y,d    return to the caller

;;; ERLINE - Delete the line of text the cursor is on.
;;;
;;; Calling syntax: RUN FOENIX([path,] "ERLINE")
ErLine              lda       #$03      erase line code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; EREOLINE - Delete text from the cursor to the end of the current line.
;;;
;;; Calling syntax: RUN FOENIX([path,] "EREOLINE")
ErEOLine            lda       #$04      erase to end of Line code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CUROFF - Make the cursor invisible
;;;
;;; Calling syntax: RUN FOENIX([path,] "CUROFF")
CurOff              lda       #5        cursor on/off code
                    sta       -1,x      save over original ESC
                    lda       #$20      off value
                    bra       L087B     append to output buffer, write it out

;;; CURON - Make the cursor visible
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURON")
CurOn               lda       #5        cursor on/off code
                    sta       -1,x      save over original ESC
                    lda       #$21      on value
                    bra       L087B     append to output buffer, write it out

;;; CURRGT - Move the cursor one character to the right.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURRGT")
CurRgt              lda       #6        cursor Right code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; BELL - Produce a beep through the terminal's speaker.
;;;
;;; Calling syntax: RUN FOENIX([path,] "BELL")
Bell                lda       #7        bell code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CURLFT - Move the cursor one character to the left.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURLFT")
CurLft              lda       #8        cursor Left code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CURUP - Move the cursor one line up.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURUP")
CurUp               lda       #9        cursor Right code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CURDWN - Move the cursor one line down.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CURDWN")
CurDwn              lda       #$A       cursor Down code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; EREOWNDW - Delete text from the current cursor position to the end of the window.
;;;
;;; Calling syntax: RUN FOENIX([path,] "EREOWNDW")
ErEOWndw            lda       #$B       erase to end of Window code
L0859               leax      -1,x      bump back output buffer pointer
                    bra       L087B     overwrite default ESC code in output buffer with new code, write it out

;;; Clear - Clear the screen.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CLEAR")
Clear               lda       #$C       clear window code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

;;; CRRTN - Send a carriage return.
;;;
;;; Calling syntax: RUN FOENIX([path,] "CRRTN")
CrRtn               lda       #C$CR     carriage return code
                    bra       L0859     overwrite default ESC code in output buffer with new code, write it out

L0873               pshs      a         save sub-code
                    lda       #$1F      put $1F code overtop original ESC first
                    sta       -1,x
                    puls      a         get sub-code back
L087B               lbra      L04E4     append to output buffer & write out

;;; INSLIN - Insert a blank line at the current cursor.
;;;
;;; Calling syntax: RUN FOENIX([path,] "INSLIN")
InsLin              lda       #$30      insert Line sub-code for $1F code
                    bra       L0873     append both to output buffer & write out

;;; DELLIN - Delete the line at the current cursor.
;;;
;;; Calling syntax: RUN FOENIX([path,] "DELLIN")
DelLin              lda       #$31      delete Line sub-code for $1FG code
                    bra       L0873     append both to output buffer & write out

;;; DEFCOL - Set palette registers to the default values.
;;;
;;; Calling syntax: RUN FOENIX([path,] "DEFCOL")
L088E               lda       #$30      default color code
                    bra       L087B     append to output buffer & write out

* Compare string from caller to string in table (used for ON, OFF, etc) case insensitive
* Entry: X=pointer to string from caller
*        Y=pointer in table for strings we are checking against
* Exit: Carry clear, A=code to send that corresponds to table string entry
*       or carry set if no match in table
L0892               pshs      x         save pointer to start of string from caller
L0894               lda       ,y+       get character from table
                    beq       L08BF     NUL (end of table), exit with error
L0898               eora      ,x+       force case
                    anda      #$DF
                    bne       L08AE     different, skip to next entry
                    tst       ,y        hi bit ($FF cheat) set on matching character from table (ie end of name?)
                    bmi       L08AA     yes, check if end of caller's string
                    tst       ,x        no, was hi bit ($FF cheat) set on character from caller?
                    bmi       L08AE     yes, skip to next entry
                    lda       ,y+       no, matches so far, check next character
                    bra       L0898

L08AA               tst       ,x        end of table string, is it end of caller string too?
                    bmi       L08BA     yes, found match, skip ahead
L08AE               leay      -1,y      no, bump table pointer back 1
L08B0               tst       ,y+       skip to end of table string
                    bpl       L08B0
                    ldx       ,s        get pointer to start of string from caller again
                    leay      1,y       bump table pointer to next entry
                    bra       L0894

L08BA               clra                clear carry
                    lda       1,y       get table byte entry
                    bra       L08C0

L08BF               coma                no match found, exit with carry set
L08C0               puls      pc,x      return to the caller

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer
AppendParam         pshs      y,d       save registers
                    bsr       L08E8     append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6     if 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y      2 byte value (INTEGER) from caller?
                    bne       L091B     not BYTE or INTEGER, exit with parameter error
                    bra       L08E4     if INTEGER, append to output buffer and return

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer (and eat 9 byte temp stack)
L08CE               pshs      y,d       save registers
                    bsr       L08E8     append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6     if 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y      2 byte value (INTEGER) from caller?
                    bne       L0919     not BYTE or INTEGER, exit with parameter error (& eat 9 byte temp stack)
                    bra       L08E4     if INTEGER, append to output buffer & return

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer (and eat 15 byte temp stack)
L08DA               pshs      y,d       save registers
                    bsr       L08E8     append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6     if 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y      2 byte value (INTEGER) from caller?
                    bne       L0917     not BYTE or INTEGER, exit with parameter error (& eat 15 byte temp stack)
L08E4               std       ,x++      append value to output buffer
L08E6               puls      pc,y,d    return to the caller

* Append 16 bit value from caller to output buffer. Original from caller is unsigned, can be BYTE or INTEGER
L08E8               ldd       [,u++]    get 16 bit value from caller (INTEGER)
                    pulu      y         get size of variable form caller
                    leay      -1,y      INTEGER?
                    bne       L08F4     yes, return
                    sta       1,x       no, BYTE, save BYTE as 16 bit value (note: NOT SIGNED)
                    clr       ,x++
L08F4               rts                 return to the caller

L08F5               bsr       AppendParam append 16 bit value to output buffer (6 16 bit parameters)
                    bsr       AppendParam append 16 bit value to output buffer
L08F9               bsr       AppendParam append 16 bit value to output buffer (4 16 bit parameters)
L08FB               bsr       AppendParam append 16 bit value to output buffer (3 16 bit parameters)
L08FD               bsr       AppendParam append 16 bit value to output buffer (2 16 bit parameters)
L08FF               bsr       AppendParam append 16 bit value to output buffer (1 16 bit parameter)
L0901               bsr       L0907     write output buffer out
                    leas      <stkdepth,s eat main temp stack & return
                    rts                 return to the caller

* Write output buffer out
                  IFNE    H6309
L0907               leay      ,x        4 Y=end buffer ptr
                    leax      3,s       5 Point to start of buffer to write out
                    subr      x,y       4 Calc size of write
                  ELSE
L0907               tfr       x,d       4 Move buffer end ptr to write out to D
                    leax      3,s       5 Point to buffer to write out
                    pshs      x         6 Save start of buffer
                    subd      ,s++      7 End buffer ptr-Start buffer ptr=length
                    tfr       d,y       4 Move length to Y for Write
                  ENDC
                    lda       2,s       Get path, write out buffer
                    os9       I$Write
                    rts                 return to the caller

L0917               leas      6,s       eat extra temp stack (15 bytes)
L0919               leas      3,s       eat extra temp stack (9 bytes)
L091B               leas      6,s       eat extra temp stack  (6 bytes)
                    lbra      ParamErr  exit with parameter error

L0920               bsr       L0932     append BYTE or INTEGER parameter to output stream (append 8 parameters)
L0922               bsr       L0932     append BYTE or INTEGER parameter to output stream (append 7 parameters)
                    bsr       L0932     append BYTE or INTEGER parameter to output stream (append 6 parameters)
                    bsr       L0932     append BYTE or INTEGER parameter to output stream (append 5 parameters)
L0928               bsr       L0932     append BYTE or INTEGER parameter to output stream (append 4 parameters)
                    bsr       L0932     append BYTE or INTEGER parameter to output stream (append 3 parameters)
L092C               bsr       L0932     append BYTE or INTEGER parameter to output stream (append 2 parameters)
                    bsr       L0932     append BYTE or INTEGER parameter to output stream (append 1 parameter)
                    bra       L0901     write the output buffer out

* Append next parameter value to output stream (either INTEGER or BYTE)
* Entry: U=pointer to current parameter pointer and size
*        X=pointer to current position in output buffer
L0932               pshs      y,d       save registers
                    ldd       [,u++]    get next parameter value (BYTE)
                    sta       ,x+       append to output stream
                    pulu      y         Y=parameter size & bump U to next parameter
                    leay      -1,y
                    beq       L0944     if it was a BYTE, we are done
                    leay      -1,y
                    bne       L091B     not an INTEGER either, return with parameter error
                    stb       -1,x      save LSB overtop original one (which would have been 0 to get here)
L0944               puls      pc,y,d    return to the caller

                    emod
eom                 equ       *
                    end

