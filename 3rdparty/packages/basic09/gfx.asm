********************************************************************
* GFX - CoCo 2 graphics subroutine module
*
* NOTE: GCOLR is mentioned in the level 2 manual (in the index of level 1
*   Basic09 text/graphics functions), but there is no manual specific page
*   for it. Should add in to new version of manual.
* Finish Fill (with startx,starty) options, and optimize similar to GFX2,if possible.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   2      2018/04/16-2018/??/??
* Added FFill command (no parameters, uses current graphics cursor location and
*   current foreground color), minor optimizations (LCB)


                    nam       GFX
                    ttl       CoCo 2 graphics subroutine module

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size
u0000               rmb       0
size                equ       .

name                fcs       /GFX/
                    fcb       edition

* Offsets for parameters accessed directly (there can be more, but they are handled in loops).
                    org       0
Return              rmb       2                   $00 Return address of caller
PCount              rmb       2                   $02 # of parameters following
PrmPtr1             rmb       2                   $04 pointer to 1st parameter data
PrmLen1             rmb       2                   $06 length of 1st parameter
PrmPtr2             rmb       2                   $08 pointer to 2nd parameter data
PrmLen2             rmb       2                   $0A length of 2nd parameter
PrmPtr3             rmb       2                   $0C pointer to 3rd parameter data
PrmLen3             rmb       2                   $0E length of 3rd parameter
PrmPtr4             rmb       2                   $10 pointer to 4th parameter data
PrmLen4             rmb       2                   $12 length of 4th parameter
PrmPtr5             rmb       2                   $14 pointer to 5th parameter data
PrmLen5             rmb       2                   $16 length of 5th parameter
PrmPtr6             rmb       2                   $18 pointer to 6th parameter data
PrmLen6             rmb       2                   $1A length of 6th parameter

FuncTbl             fdb       Alpha-FuncTbl
                    fcc       "Alpha"
                    fcb       $FF

                    fdb       Circle-FuncTbl
                    fcc       "Circle"
                    fcb       $FF

                    fdb       Clear-FuncTbl
                    fcc       "Clear"
                    fcb       $FF

                    fdb       CColor-FuncTbl
                    fcc       "Color"
                    fcb       $FF

                    fdb       GColr-FuncTbl
                    fcc       "GColr"
                    fcb       $FF

                    fdb       GLoc-FuncTbl
                    fcc       "GLoc"
                    fcb       $FF

                    fdb       JoyStk-FuncTbl
                    fcc       "JoyStk"
                    fcb       $FF

                    fdb       Line-FuncTbl
                    fcc       "Line"
                    fcb       $FF

                    fdb       Mode-FuncTbl
                    fcc       "Mode"
                    fcb       $FF

                    fdb       Move-FuncTbl
                    fcc       "Move"
                    fcb       $FF

                    fdb       Point-FuncTbl
                    fcc       "Point"
                    fcb       $FF

                    fdb       Quit-FuncTbl
                    fcc       "Quit"
                    fcb       $FF

* Added Flood Fill - LCB
                    fdb       Fill-FuncTbl
                    fcc       "Fill"
                    fcb       $FF
                    fdb       $0000

stkdepth            set       9

* All functions (from the call table) are entered with the following parameters:
*   Y = pointer to function subroutine
*   X = pointer to "stkdepth" byte scratch variable area (same as stack pointer, which has allocated that extra memory)
*   U = pointer to 2nd parameter (first parameter after name itself)
*   D = # of parameters (NOTE: function name itself is always parameter 1)

* Stack on entry to every function routine (with stkdepth set to 9):
*   $00-$08 / 00-08,s - temporary scratch var area
*   $09-$0A / 09-10,s - RTS address to BASIC09/RUNB
*   $0B-$0C / 11-12,s - # of parameters (including function name itself)
*   $0D-$0E / 13-14,s - pointer to 1st parameter's data (function name)
*   $0F-$10 / 15-16,s - length of first parameter
* From here on is optional, depending on the function being called, there can be up to 9 parameter pairs
* (pointer/value and length).
* The temporary stack uses 0,s as the path #, and 1,s + as the output buffer.

start               leas      -stkdepth,s         allocate room on the stack
                    ldd       PCount+stkdepth,s   get parameter count
                    beq       BadFunc             branch if no parameters
                    tsta                          parameter count greater than 255?
                    bne       BadFunc             yep, branch to error
                    leau      >FuncTbl,pcr        point to function pointer table
nextentry           ldy       ,u++                get pointer to function
                    beq       NoFunc              branch if zero (end of table)

* Compare the passed function name to our list.
                    ldx       PrmPtr1+stkdepth,s  get the parameter 1 pointer
nextchar@           lda       ,x+                 get the passed parameter character
                    eora      ,u+                 XOR it with compared parameter character
                    anda      #$DF                make case same
                    beq       equal@              branch if equal
                    leau      -1,u                back up one
skip@               tst       ,u+                 test the character
                    bpl       skip@               branch if hi bit not set (i.e. not $FF in table)
                    bra       nextentry           go get next name
equal@              tst       -1,u                test previous character
                    bpl       nextchar@           branch of high bit not set
* We found the function.
                    tfr       y,d                 put function pointer in D
                    leay      >FuncTbl,pcr        point Y to table
                    leay      d,y                 get function address
                    leax      ,s                  point X to stack
                    leau      <PrmPtr2+stkdepth,s point U to parameter 2 pointer
                    ldd       PCount+stkdepth,s   put parameter count in D
                    jmp       ,y                  go execute function

NoFunc              ldb       #E$NoRout           non-existent routine
                    bra       err@                go return error
BadFunc             ldb       #E$ParmEr           parameter error
err@                coma                          set carry
                    leas      stkdepth,s          reset S
                    rts                           return to the caller

* Each subroutine enters with the following parameters:
*    B = parameter count
*    X = temporary stack
*    U = pointer to size of first parameter

;;; MODE - Set the graphics mode.
;;;
;;; Calling syntax: RUN GFX("Mode",Format,Color)
;;;
;;; MODE switches the screen from alphanumeric to graphics display mode,
;;; and selects the screen mode and color code. "Format" determines
;;; between two-color (Format= 0), or four-color (Format= 1) graphics
;;; modes. "Color" is the initial color code that specifies the
;;; foreground color and color set.
;;;
;;; This command must be given before any other graphics command is
;;; used. The first time MODE is called, it requests 6KB of memory
;;; from OS-9 for use as the graphics display memory. MODE will return
;;; an error if sufficient free memory is not available.
;;;
;;; This example selects four-color mode graphics with a red foreground
;;; color.
;;;
;;;    RUN GFX("Mode",1,3)
Mode                lda       #$0F                load the function code
                    bra       ThreeParms          process the parameters

;;; MOVE - Move the graphics cursor.
;;;
;;; Calling syntax: RUN GFX("Move",X,Y)
;;;
;;; MOVE positions the invisible graphics cursor to the specified
;;; location without changing the display. X and Y are the coordinates
;;; of the new position.
;;;
;;; This example positions the cursor in the lower left-hand corner.
;;;
;;;   RUN GFX("Move",0,0)
Move                lda       #$15                load the "get graphics cursor" code
ThreeParms          cmpb      #$03                this number of parameters?
                    bne       BadFunc             branch if not (error out)
                    bra       StoreAppend2Write   write it out

;;; COLOR - Set the foreground color.
;;;
;;; Calling syntax: RUN GFX("Color",Color)
;;;
;;; COLOR changes the current foreground color (and possibly the color
;;; set). The current graphics mode and cursor position are not
;;; changed.
;;;
;;; This example changes the foreground color to green in four-color format (or black
;;; in two-color format):
;;;
;;;    RUN GFX("Color",O)
CColor              lda       #$11                load the "color" code
                    bra       TwoParms            process two parameters

;;; POINT - Set a pixel at a point.
;;;
;;; Calling syntax: RUN GFX("Point",X,Y)
;;;                 RUN GFX("Point",X,Y,Color)
;;;
;;; POINT moves the graphics cursor to the specified X,Y coordinate and
;;; sets the pixel at that coordinate to the current foreground color.
;;; If the optional "Color" is specified, the current foreground color
;;; is set to the given "Color".
;;;
;;; This example moves the cursor to the upper left-hand corner and changes the
;;; foreground color to green in two-color format, or it changes the
;;; color to yellow in the four-color format.
;;;
;;;    RUN GFX("Point",0,192,1)
Point               cmpb      #$03                this number of parameters?
                    beq       setpoint@           branch if so
                    cmpb      #$04                this number of parameters?
                    bne       BadFunc             branch if not (error out)
                    leau      <PrmPtr4+stkdepth,s point to the 4th parameter
                    lbsr      SetColorAndAppend   set the color
                    leau      <PrmPtr2+stkdepth,s point to the 2nd parameter
setpoint@           lda       #$18                load the "set point" code
                    bra       StoreAppend2Write   write it out

;;; CLEAR - Reset all points on the screen.
;;;
;;; Calling syntax: RUN GFX("Clear")
;;;                 RUN GFX("Clear", color)
;;;
;;; CLEAR resets all points on the screen to the background color, or if the optional
;;; color is given, presets the screen to that color. The current graphics cursor is
;;; reset to (0,0).
Clear               cmpb      #$01                this number of parameters?
                    beq       got1@               branch if so
                    lda       #$10                else load this function code
TwoParms            cmpb      #$02                is the parameter count two?
                    bne       BadFunc             branch if not (error out)
                    bra       StoreAppend1Write   write it out
got1@               lda       #$13                load the function code
                    bra       StoreAndWrite       store it and write it

;;; LINE - Draw a line.
;;;
;;; Calling syntax: RUN GFX("Line",x2,y2)
;;;                 RUN GFX("Line",x2,y2,Color)
;;;                 RUN GFX("Line,xl,yl,x2,y2)
;;;                 RUN GFX("Line,xl,yl,x2,y2,Color)
;;;
;;; LINE draws lines in various ways. If one coordinate is given, the
;;; line will be drawn from the current graphics cursor position to the
;;; coordinates specified, If two sets of coordinates are given, they
;;; are used as the start and end points of the line. The line will be
;;; drawn in the current foreground color unless a new color is given as
;;; a parameter. After the line is drawn the graphics cursor will be
;;; positioned at x2,y2.
;;;
;;; This example draws a line from (O,O) to (0,192):
;;;
;;;    RUN GFX("Line",0,0,0,192)
;;;
;;; This example draws a blue line (4-color mode) to point 24,65:
;;;
;;;    RUN GFX("line",24,65,2)
Line                cmpb      #$06                this number of parameters?
                    bhi       BadFunc             branch if higher (error out)
                    cmpb      #$03                this number of parameters?
                    bcs       XBadFunc            branch if lower than (error out)
                    bitb      #$01                3 or 4?
                    bne       check4@             branch if so
                    leau      <PrmPtr4+stkdepth,s get 4th parameter
                    cmpb      #$04                is parameter count four?
                    beq       got4@               branch if so
                    leau      <PrmPtr6+stkdepth,s get 6th parameter
got4@               bsr       SetColorAndAppend   set the color
                    leau      <PrmPtr2+stkdepth,s get 2nd parameter
check4@             cmpb      #$04                is parameter count 4?
                    bls       got4orless@         branch if same or lower
                    bsr       SetGraphicsCursor   set the graphics cursor
got4orless@         lda       #$16                load the "draw line" code
StoreAppend2Write   sta       ,x+                 store function code in our output buffer
                    bsr       AppendParameter     append the parameter
                    bsr       AppendParameter     append the next parameter
                    bra       WriteAndRecover     go write it

;;; CIRCLE - Draw a circle.
;;;
;;; Calling syntax: RUN GFX("Circle",Radius)
;;;                 RUN GFX("Circle",Radius,Color)
;;;                 RUN GFX("Circle",X,Y,Radius)
;;;                 RUN GFX("Circle",X,Y,Radius,Color)
;;;
;;; CIRCLE draws a circle of the given radius. The current graphics
;;; cursor position is assumed if no X,Y value is given. The current
;;; foreground color is assumed if the Color parameter is not used. The
;;; center of the circle must be on the screen.
Circle              cmpb      #$05                this number of parameters?
                    bhi       XBadFunc            branch if higher (error out)
                    cmpb      #$02                this number of parameters?
                    bcs       XBadFunc            branch if lower (error out)
                    bitb      #$01                2 or 3 parameters?
                    beq       is3@                branch if set
                    leau      <PrmPtr3+stkdepth,s get 3rd parameter
                    cmpb      #$03                is parameter count 3?
                    beq       got3@               branch if so
                    leau      <PrmPtr5+stkdepth,s get 5th parameter
got3@               bsr       SetColorAndAppend   set the color
                    leau      <PrmPtr2+stkdepth,s get 2nd parameter
is3@                cmpb      #$03                is parameter count 3?
                    bls       circle@             branch if same or lower
                    bsr       SetGraphicsCursor   set the graphics cursor
circle@             lda       #$1A                load "circle" code
StoreAppend1Write   sta       ,x+                 store it in our output buffer
                    bsr       AppendParameter     append the next parameter
                    bra       WriteAndRecover     write it

;;; ALPHA - Put screen in alphanumeric mode.
;;;
;;; Calling syntax: RUN GFX("Alpha")
;;;
;;; ALPHA is a quick, convenient way of getting the screen back to
;;; alphanumeric mode. When graphics mode is entered again, the screen
;;; will show the previous unchanged graphics display.
Alpha               lda       #$0E                load the function code
                    bra       StoreAndWrite       write it

;;; QUIT - Return to alphanumeric mode and return graphics memory.
;;;
;;; Calling syntax: RUN GFX("Quit")
;;;
;;; QUIT switches the screen back to alpha mode and returns the 6KB
;;; graphics display memory to OS-9.
Quit                lda       #$12                load the function code
StoreAndWrite       sta       ,x+                 store the code in the buffer
WriteAndRecover     bsr       WriteItOut          write it
                    leas      stkdepth,s          recover the stack
                    rts                           return to the caller

WriteItOut          tfr       x,d                 move the output buffer pointer into D
                    leax      2,s                 point ahead in the stack
                    pshs      x                   push X on the stack
                    subd      ,s++                subtract X from D to get length to write
                    tfr       d,y                 transfer the count to Y
                    lda       #1                  standard output
                    os9       I$Write             write the bytes
                    rts                           return to the caller

RecoverAndBadFunc   leas      $06,s               adjust the stack (X, Y, return PC)
XBadFunc            lbra      BadFunc             error out
SetColorAndAppend   lda       #$11                load the "color" code
                    sta       ,x+                 store it in our output bufer
                    bra       AppendParameter     append the next parameter

SetGraphicsCursor   puls      y                   recover return PC from stack
                    lda       #$15                load the "set graphics cursor" code
                    sta       ,x+                 add it to the output buffer
                    bsr       AppendParameter     append the next parameter
                    pshs      y                   restore return PC to stack

* Append the next parameter value to output stream (either INTEGER or BYTE).
*
* Entry: U = Pointer to the current parameter pointer and size.
*        X = Pointer to the current position in the output buffer.
AppendParameter     pshs      y,b,a               save off registers
                    ldd       [,u++]              get parameter size
                    sta       ,x+                 store the high byte in our output buffer
                    pulu      y                   get the size of the next parameter in Y
                    leay      -1,y                BYTE type?
                    beq       ret@                branch if so
                    leay      -1,y                INTEGER type?
                    bne       RecoverAndBadFunc   branch if not (abort)
                    tsta                          is integer greater than 255?
                    bne       RecoverAndBadFunc   branch if so (abort)
                    stb       -1,x                store the byte in our output buffer
ret@                puls      pc,y,b,a            restore registers and return to the caller

;;; GLOC - Get the address of video memory.
;;;
;;; Calling syntax: RUN GFX("Gloc",Vdisp)
;;;
;;; GLOC returns the address of the video display RAM as an integer
;;; number. This address may be used in subsequent PEEK and POKE
;;; operations to access the video display directly. GLOC can be used
;;; to create special functions that are not available in the graphics
;;; module.
GLoc                cmpb      #$02                correct number of parameters?
                    bne       XBadFunc            branch if not (error out)
                    ldx       <PrmLen2+stkdepth,s get parameter 2 length
                    leax      -$02,x              INTEGER?
                    bne       XBadFunc            branch if not (error out)
                    lda       #1                  standard out
                    ldb       #SS.DStat           load the call code
                    os9       I$GetStt            get the status
                    bcs       RecoverAndRTS       branch if error
                    stx       [<PrmPtr2+stkdepth,s] else save off the display status
RecoverAndRTS       leas      stkdepth,s          recover the stack
                    rts                           return to the caller

;;; GCOLR - Get a pixel color at the current graphics cursor.
;;;
;;; Calling syntax: RUN GFX("Gcolr",Color)
;;;                 RUN GFX("Gcolr",X,Y,Color)
;;;
;;; GCOLR is used to read the color of the pixel at the current graphics
;;; cursor position, or from the coordinates X,Y. The parameter "Color"
;;; may be an integer or a byte variable in which the color code is
;;; returned.
GColr               cmpb      #2                  this number of parameters?
                    beq       got2@               branch if so
                    cmpb      #$04                this number of parameters?
                    bne       XBadFunc            branch if not (error out)
                    bsr       SetGraphicsCursor   set the graphics cursor
                    bsr       WriteItOut          write it
                    bcs       RecoverAndRTS       branch if an error occurred
got2@               lda       #1                  standard output
                    ldb       #SS.DStat           load the call code
                    os9       I$GetStt            get the status
                    bcs       RecoverAndRTS       branch if error
                    tfr       a,b                 transfer BYTE value to B
                    bra       SaveBYTEandRTS      save it and return

SaveBYTEParam       leau      4,u                 advance to next parameter
                    pshs      u,x                 save registers
                    ldx       -2,u                get the previous parameter length
                    ldu       -4,u                and the previous parameter pointer
                    leax      -1,x                BYTE type?
                    beq       ret@                branch if so
                    leax      -$01,x              INTEGER type?
                    bne       RecoverAndBadFunc   branch if not (error out)
                    clr       ,u+                 clear upper 8 bits
ret@                stb       ,u+                 and store B in lower 8 bits
                    puls      pc,u,x              restore and return to the caller

;;; JOYSTK - Read the joystick values.
;;;
;;; Calling syntax: RUN GFX("Joystk",Stick,Fire,X,Y)
;;;
;;; JOYSTK returns the status of the specified joystick's Fire button,
;;; and returns the X,Y position of the joystick. The Fire button may
;;; be read as a BYTE, INTEGER, or a BOOLEAN value. Non-zero (TRUE)
;;; means the button was pressed. The X,Y values returned may be BYTE
;;; or INTEGER variables, and they will be in the range 0 to 63. The
;;; Stick parameter may be either BYTE or INTEGER, and should be 0 for
;;; RIGHT, or 1 for LEFT, depending on whether the RIGHT to the LEFT
;;; joystick is to be tested.
;;;
;;; Example:
;;;
;;;    RUN GFX("JoyStk",l,leftfire,leftx,lefty)
JoyStk              cmpb      #5                  this number of parameters?
                    bne       XBadFunc            branch if not (error out)
                    clr       ,x+
                    bsr       AppendParameter     append the next parameter
                    ldx       -2,x                get pointer to parameter (left or right joystick)
                    lda       #1                  standard out
                    ldb       #SS.Joy             load the call code
                    os9       I$GetStt            get the status
                    bcs       RecoverAndRTS       branch if error
                    tfr       a,b                 get fire button status in B
                    bsr       SaveBYTEParam       save it in the parameter
                    tfr       x,d                 get X coordinate value in D
                    bsr       SaveBYTEParam       save it in the parameter
                    tfr       y,d                 get Y coordinate value in D
SaveBYTEandRTS      bsr       SaveBYTEParam       save it in the parameter
                    leas      stkdepth,s          recover the stack
                    rts                           return to the caller

*
* ("FILL") Fill (with current foreground color) overtop adjacent pixels
*   that are the same color as under the gfx cursor
* Later, we will add optional X,Y gfx cursor set, and maybe setting foreground color
Fill                cmpb      #1                  Just FILL parm itself?
*         beq   Fill.2       Yes, go do  (START OF CODE FOR SETTING POSITION AND COLOR-NOT DONE YET)
*         cmpb  #2+1         2 parms (xcor,ycor) additional?
                    lbne      BadFunc             neither, exit with Parameter Error
Fill.2              lda       #$1D                FILL display code
                    lbra      StoreAndWrite       Send it

                    emod
eom                 equ       *
                    end
