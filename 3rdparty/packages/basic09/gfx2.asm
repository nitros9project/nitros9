********************************************************************
* gfx2 - CoCo 3 graphics subroutine module
* NOTE: NEED TO ADD SUPPORT FOR FILLED CIRCLE AND FILLED ELLIPSE
* Also, DRAW has undocumented feature of specifying starting X,Y
* coord
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??
* Original Tandy distribution version.
*
*   3      1990/08/16  Kevin Darling and Kent Meyers
* Enhanced, with bug fix (adds Multi-Vue windowing support commands, etc.
* and optimizations). Note: I changed the edition to 3 myself
* as the original was still set to 2 (same as the Tandy one).
*
*   4      2018/06/14  L. Curtis Boyle
* Commented source code, couple of minor optimizations, added FCircle & FEllipse commands
* (keeping to <=8 character function name limits of original). Also documented option X,Y start
* coord for DRAW command (not in manual)
*
*  5       2022/05/28  L. Curtis Boyle
* Changed OnMouse to check set BOTH MsSig & SSig (keypress & mouse button). Also minor
* optimizations. (Particularly DRAW statement and some 6309 stuff).

                    nam       gfx2
                    ttl       subroutine module

                    ifp1
                    use       os9.d
                    use       scf.d
                    use       coco3vtio.d
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $05

                    mod       eom,name,tylg,atrv,start,size

* Data size since BASIC09 subroutine modules do everything on the stack
u0000               rmb       0
size                equ       .

name                fcs       /gfx2/
                    fcb       edition

                    fcb       $00

* Offsets for parameters accessed directly (there can be more, but they are handled in loops)
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

* Function table. Please note, that on entry to these subroutines, the main temp stack is already
* allocated (33 bytes), B=# of parameters received
* Sneaky trick for end of table markers - it does a 16 bit load to get the offset to the function
*  routine. It has been purposely made so that every one of these offsets >255, so we only need a
*  single $00 byte as the high byte to designate the end of a table

FuncTbl             fdb       L03AE-FuncTbl
                    fcc       "Mouse"
                    fcb       $FF

                    fdb       L0605-FuncTbl
                    fcc       "Point"
                    fcb       $FF

                    fdb       L060D-FuncTbl
                    fcc       "Line"
                    fcb       $FF

                    fdb       L0622-FuncTbl
                    fcc       "Box"
                    fcb       $FF

                    fdb       L0626-FuncTbl
                    fcc       "Bar"
                    fcb       $FF

                    fdb       L062A-FuncTbl
                    fcc       "PutGC"
                    fcb       $FF

                    fdb       L04CF-FuncTbl
                    fcc       "Fill"
                    fcb       $FF

                    fdb       L0634-FuncTbl
                    fcc       "Circle"
                    fcb       $FF

                    fdb       FCircle-FuncTbl
                    fcc       "FCircle"
                    fcb       $FF

                    fdb       L04B1-FuncTbl
                    fcc       "DWSet"
                    fcb       $FF

                    fdb       L04E2-FuncTbl
                    fcc       "Select"
                    fcb       $FF

                    fdb       L04ED-FuncTbl
                    fcc       "OWSet"
                    fcb       $FF

                    fdb       L04F8-FuncTbl
                    fcc       "OWEnd"
                    fcb       $FF

                    fdb       L04FC-FuncTbl
                    fcc       "DWEnd"
                    fcb       $FF

                    fdb       L0500-FuncTbl
                    fcc       "CWArea"
                    fcb       $FF

                    fdb       L050B-FuncTbl
                    fcc       "DefBuff"
                    fcb       $FF

                    fdb       L0524-FuncTbl
                    fcc       "KillBuff"
                    fcb       $FF

                    fdb       L0531-FuncTbl
                    fcc       "GPLoad"
                    fcb       $FF

                    fdb       L0545-FuncTbl
                    fcc       "Get"
                    fcb       $FF

                    fdb       L0556-FuncTbl
                    fcc       "Put"
                    fcb       $FF

                    fdb       L0567-FuncTbl
                    fcc       "Pattern"
                    fcb       $FF

                    fdb       L056B-FuncTbl
                    fcc       "Logic"
                    fcb       $FF

                    fdb       L088E-FuncTbl
                    fcc       "DefCol"
                    fcb       $FF

                    fdb       L0585-FuncTbl
                    fcc       "Palette"
                    fcb       $FF

                    fdb       L0589-FuncTbl
                    fcc       "Color"
                    fcb       $FF

                    fdb       L05C1-FuncTbl
                    fcc       "Border"
                    fcb       $FF

                    fdb       L05CE-FuncTbl
                    fcc       "ScaleSw"
                    fcb       $FF

                    fdb       L05DE-FuncTbl
                    fcc       "DWProtSw"
                    fcb       $FF

                    fdb       L051C-FuncTbl
                    fcc       "GCSet"
                    fcb       $FF

                    fdb       L0520-FuncTbl
                    fcc       "Font"
                    fcb       $FF

                    fdb       L05E2-FuncTbl
                    fcc       "TCharSw"
                    fcb       $FF

                    fdb       L05E6-FuncTbl
                    fcc       "BoldSw"
                    fcb       $FF

                    fdb       L05EA-FuncTbl
                    fcc       "PropSw"
                    fcb       $FF

                    fdb       L05EE-FuncTbl
                    fcc       "SetDPtr"
                    fcb       $FF

                    fdb       L0649-FuncTbl
                    fcc       "Draw"
                    fcb       $FF

                    fdb       L07E1-FuncTbl
                    fcc       "Ellipse"
                    fcb       $FF

                    fdb       FEllipse-FuncTbl
                    fcc       "FEllipse"
                    fcb       $FF

                    fdb       L07E6-FuncTbl
                    fcc       "Arc"
                    fcb       $FF

                    fdb       L07FC-FuncTbl
                    fcc       "CurHome"
                    fcb       $FF

                    fdb       L0800-FuncTbl
                    fcc       "CurXY"
                    fcb       $FF

                    fdb       L082B-FuncTbl
                    fcc       "ErLine"
                    fcb       $FF

                    fdb       L082F-FuncTbl
                    fcc       "ErEOLine"
                    fcb       $FF

                    fdb       L0833-FuncTbl
                    fcc       "CurOff"
                    fcb       $FF

                    fdb       L083B-FuncTbl
                    fcc       "CurOn"
                    fcb       $FF

                    fdb       L0843-FuncTbl
                    fcc       "CurRgt"
                    fcb       $FF

                    fdb       L0847-FuncTbl
                    fcc       "Bell"
                    fcb       $FF

                    fdb       L084B-FuncTbl
                    fcc       "CurLft"
                    fcb       $FF

                    fdb       L084F-FuncTbl
                    fcc       "CurUp"
                    fcb       $FF

                    fdb       L0853-FuncTbl
                    fcc       "CurDwn"
                    fcb       $FF

                    fdb       L0857-FuncTbl
                    fcc       "ErEOWndw"
                    fcb       $FF

                    fdb       L085D-FuncTbl
                    fcc       "Clear"
                    fcb       $FF

                    fdb       L0861-FuncTbl
                    fcc       "CrRtn"
                    fcb       $FF

                    fdb       L0865-FuncTbl
                    fcc       "ReVOn"
                    fcb       $FF

                    fdb       L0869-FuncTbl
                    fcc       "ReVOff"
                    fcb       $FF

                    fdb       L086D-FuncTbl
                    fcc       "UndlnOn"
                    fcb       $FF

                    fdb       L0871-FuncTbl
                    fcc       "UndlnOff"
                    fcb       $FF

                    fdb       L087E-FuncTbl
                    fcc       "BlnkOn"
                    fcb       $FF

                    fdb       L0882-FuncTbl
                    fcc       "BlnkOff"
                    fcb       $FF

                    fdb       L0886-FuncTbl
                    fcc       "InsLin"
                    fcb       $FF

                    fdb       L088A-FuncTbl
                    fcc       "DelLin"
                    fcb       $FF

                    fdb       L041C-FuncTbl
                    fcc       "Tone"
                    fcb       $FF

                    fdb       L043F-FuncTbl
                    fcc       "WInfo"
                    fcb       $FF

                    fdb       L047D-FuncTbl
                    fcc       "SetMouse"
                    fcb       $FF

                    fdb       L039A-FuncTbl
                    fcc       "GetSel"
                    fcb       $FF

                    fdb       L0499-FuncTbl
                    fcc       "SBar"
                    fcb       $FF

                    fdb       L04A8-FuncTbl
                    fcc       "UMBar"
                    fcb       $FF

                    fdb       L0371-FuncTbl
                    fcc       "Item"
                    fcb       $FF

                    fdb       L033E-FuncTbl
                    fcc       "Menu"
                    fcb       $FF

                    fdb       L030A-FuncTbl
                    fcc       "Title"
                    fcb       $FF

                    fdb       L038A-FuncTbl
                    fcc       "WnSet"
                    fcb       $FF

                    fdb       L0402-FuncTbl
                    fcc       "OnMouse"
                    fcb       $FF

                    fdb       L02FD-FuncTbl
                    fcc       "ID"
                    fcb       $FF

* Test by sending non-existant function name
                    fcb       $00                 End of table marker

L0268               fcc       "OFF"
                    fcb       $FF
                    fcb       $00

                    fcc       "AND"
                    fcb       $FF
                    fcb       $01

                    fcc       "OR"
                    fcb       $FF
                    fcb       $02

                    fcc       "XOR"
                    fcb       $FF
                    fcb       $03

                    fcb       $00                 End of table marker

L027C               fcc       "OFF"
                    fcb       $FF
                    fcb       $00

                    fcc       "ON"
                    fcb       $FF
                    fcb       $01

                    fcb       $00                 End of table marker

stkdepth            equ       $21

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

start               leas      <-stkdepth,s        reserve bytes on stack
                    clr       ,s                  clear optional path # is BYTE or INTEGER flag
                    ldd       <stkdepth+PCount,s  get # of parameters
                    beq       L02F6               if 0, exit with parameter error
                    tsta                          if >255, exit with parameter error
                    bne       L02F6               branch if >255
                    ldd       [<stkdepth+PrmPtr1,s] get value from first parameter (optional path #)
                    ldx       <stkdepth+PrmLen1,s get length of 1st parameter
                    leax      -1,x                decrement length
                    beq       L02A3               if zero, it's a BYTE value, so save path #
                    leax      -1,x                decrement length again
                    bne       L02B0               if not INTEGER value, no optional path, 1st parameter is keyword
                    tfr       b,a                 it's an INTEGER value, so save LSB as path #
L02A3               sta       ,s                  save on stack
                    dec       <stkdepth+PCount+1,s decrement # of parameters (to skip path #)
                    ldx       <stkdepth+PrmPtr2,s X = pointer to function name we received
                    leau      <stkdepth+PrmPtr3,s U = pointer to (possible) 1st parameter for function
                    bra       L02B8

* No optional path, set path to Std Out, and point X/U to function name and 1st parameter for it.
L02B0               inc       ,s                  no optional path # specified, set path to 1 (Std Out)
                    ldx       <stkdepth+PrmPtr1,s point to function name
                    leau      <stkdepth+PrmPtr2,s point to first parameter of function
* Entry here: X=pointer to function name passed from caller
*             U=pointer to 1st parameter for function
L02B8               pshs      u,x                 save 1st parameter & function name pointers
                    leau      >FuncTbl,pcr        point to table of supported functions
L02BE               ldy       ,u++                get pointer to subroutine
                    beq       L02F0               if $0000, exit with Unimplemented Routine Error (out of functions)
                    ldx       ,s                  get pointer to function name we were sent
L02C5               lda       ,x+                 get character from caller
                    eora      ,u+                 force matching case and compare with table entry
                    anda      #$DF                set case
                    beq       L02D5               matched, skip ahead
                    leau      -1,u                bump table pointer back one
L02CF               tst       ,u+                 hi bit set on last character? ($FF check cheat)
                    bpl       L02CF               no, keep scanning till we find end of table entry text
                    bra       L02BE               check next table entry

L02D5               tst       -1,u                was hi bit set on matching character? (we hit end of function name?)
                    bpl       L02C5               no, check next character
* 6809/6309 - skip leas, change puls u below to puls u,x (faster, and we reload X anyways)
                    leas      2,s                 yes, function found. Eat copy of pointer to function name we were sent
                    tfr       y,d                 copy jump table offset to D
                    leay      >FuncTbl,pcr        point to table of supported functions again
                    leay      d,y                 add offset
                    puls      u                   get original 1st parameter pointer
                    leax      1,s                 point to temp write buffer we are building

                    lda       #$1B                start it with an ESCAPE code (most functions use this)
                    sta       ,x+                 store it in the output buffer
                    ldd       <stkdepth+PCount,s  get # of params again including path (if present) & function name pointer
                    jmp       ,y                  call function subroutine & return from there

L02F0               leas      4,s                 clean the stack
                    ldb       #E$NoRout           unimplemented routine error
                    bra       L02F8

L02F6               ldb       #E$ParmEr           parameter error
L02F8               coma                          set the carry
                    leas      <stkdepth,s         clean the stack
                    rts                           return to the caller

* For all calls from table, entry is:
*   Y=Address of routine
*   X=Output buffer pointer ($1B is preloaded)
*   U=Pointer to 1st parameter for function
*   D=# of parameters being passed (including optional path #, and function name pointer)

;;; ID - Get user ID
;;;
;;; Calling syntax: RUN GFX2([path,] "ID", id)
L02FD               os9       F$ID                get process ID # into D
                    tfr       a,b
                    clra
                    std       [,u]                save in caller's parameter 1 variable
L0305               clrb                          no error, eat temp stack & return
                    leas      <stkdepth,s
                    rts                           return to the caller

;;; TITLE - Set menu title.
;;;
;;; Calling syntax: RUN GFX2([path,] "TITLE", windesc, menuTitle)
L030A               ldy       ,u                  get pointer to parameter 1 (pointer to the window descriptor array)
                    ldx       4,u                 get pointer to parameter 2 (title - string variable)
* 6809/6309 - shouldn't we make sure parameter length <=20?
                    bsr       L0332               copy title to the window descriptor array
                    ldd       [<$08,u]            get minimum horizontal window size (parameter 3)
                    stb       <WN.XMIN,y          save it in the window descriptor
                    ldd       [<$0C,u]            get minimum vertical window size (parameter 4)
                    stb       <WN.YMIN,y          save it in the window descriptor
                    ldd       [<$10,u]            get # of menus we will have on menu bar
                    stb       <WN.NMNS,y          save it in the window descriptor
                    ldd       #$C0C0              sync bytes (WN.SYNC)
                    std       <WN.SYNC,y          save it in the window descriptor
                    leax      <WN.SIZ,y           point X to where first menu descriptor will go (after main window descriptor)
                    stx       <WN.BAR,y           save as pointer to array of menu descriptors
                    bra       L0305               return w/o error

* Copy string until high bit set ($FF marker), and change end in destination to NUL $00
L0332               pshs      y                   Save Y
L0334               lda       ,x+                 Copy string from X to Y until hi bit set on a byte ($FF marker)
                    sta       ,y+
                    bpl       L0334
                    clr       -1,y                Flag end of string with NUL in destination
                    puls      pc,y

;;; MENU - Enable/disable menu.
;;;
;;; Calling syntax: RUN GFX2([path,] "MENU", windesc, menuID, menuTitle, id, columns, items, midesc, enabled)
L033E               ldy       ,u                  Get ptr to Parm 1 (Ptr to Window descriptor array)
                    leay      <WN.SIZ,y           Point to start of array of menu descriptors
                    ldd       [<$04,u]            Get menu ID #
                    decb                          Base 0, only 8 bits
                    lda       #MN.SIZ             Calc offset to menu descriptor for menu ID #
                    mul
                    leay      d,y                 point to the specific menu descriptor we are creating
                    ldx       8,u                 get pointer to Menu title
* 6809/6309 - shouldn't we make sure parameter length <=15?
                    bsr       L0332               copy it over (to MN.TTL)
                    ldd       [<$0C,u]            get menu id # (1-255)
                    stb       MN.ID,y             save it in menu descriptor
                    ldd       [<$10,u]            get X size of pull down menu (in columns)
                    stb       <MN.XSIZ,y          save it in menu descriptor
                    ldd       [<$14,u]            get # of items in menu pull down
                    stb       <MN.NITS,y          save it in menu descriptor
                    ldd       <$18,u              get pointer to Menu item descriptor array
                    std       <MN.ITEMS,y         save it in menu descriptor
                    ldd       [<$1C,u]            get menu enabled/disabled flag
                    stb       <MN.ENBL,y          save it in menu descriptor
                    bra       L0305

;;; ITEM - Enable/disable menu item.
;;;
;;; Calling syntax: RUN GFX2([path,] "ITEM", mbdesc, menuID, enable)
L0371               ldy       ,u                  get pointer to parameter 1 (pointer to the menu bar descriptor array)
                    ldd       [<$04,u]            get menu ID #
                    decb                          base 0
                    lda       #MI.SIZ             multiply by the size of menu item descriptor
                    mul                           calculate offset to menu item we are creating
                    leay      d,y                 point Y to menu item we are creating
                    ldx       8,u                 get pointer to menu item text
* 6809/6309 - shouldn't we make sure parameter length <=15?
                    bsr       L0332               copy it over to MI.TTL
                    ldd       [<$0C,u]            get item enable/disable flag (0=disabled, 1=enabled)
                    stb       MI.ENBL,y           save it in Menu item descriptor
                    lbra      L0305

;;; WNSET - Set window type.
;;;
;;; Calling syntax: RUN GFX2([path,] "WNSET", type)
L038A               ldy       [,u]                get window type (framed, shadow, etc.)
                    ldx       4,u                 get pointer to window descriptor array (for if framed window)
                    lda       ,s                  get path
                    ldb       #SS.WnSet           set up Multi-Vue style window
                    os9       I$SetStt
                    leas      <stkdepth,s         eat temp stack & return
                    rts                           return to the caller

;;; GETSEL - Get menu selection.
;;;
;;; Calling syntax: RUN GFX2([path,] "GETSEL", selection)
L039A               lda       ,s                  get path
                    ldb       #SS.MnSel           call Multi-Vue menu handler
                    os9       I$GetStt
                    pshs      a                   save menu ID # (which menu)
                    clra                          D=item number selected from menu (if valid)
                    std       [<$04,u]            save back to caller
                    puls      b                   D=menu ID #
                    std       [,u]                save back to caller
                    lbra      L0305

;;; MOUSE - Read mouse.
;;;
;;; Calling syntax: RUN GFX2([path,] "MOUSE", valid, fire, x, y)
;;;                 RUN GFX2([path,] "MOUSE", valid, fire, x, y, area, xsize, ysize)
L03AE               cmpb      #5                  5 parameters?
                    beq       L03B8               yes, go read mouse
                    cmpb      #8                  8 parameters?
                    lbne      L02F6               No, exit with Parameter Error
L03B8               lda       ,s                  Get path #
                    leas      <-$20,s             Make 32 byte buffer on stack for Mouse packet
                    leax      ,s                  Point to buffer to receive mouse packet
                    pshs      b                   Save # of parms
                    ldb       #SS.Mouse           Read Mouse packet call
                    os9       I$GetStt            Go get mouse packet
                    puls      b                   Restore # of parms
                    bcs       L03FE               If error from reading mouse, eat temp stacks and return
                    cmpb      #5                  Just 5?
                    beq       L03E4               Yes, skip copying the other 3 vars to caller
                    ldd       <Pt.AcX,x           Get X coord of mouse on full screen (unscaled)
                    std       [<$14,u]            Save to caller
                    ldd       <Pt.AcY,x           Get Y coord of mouse on full screen (unscaled)
                    std       [<$18,u]            Save to caller
                    ldb       <Pt.Stat,x          Get mouse ptr status (0=working area, 1=menu region (non-working area), 2=off window)
                    std       [<$10,u]            Save to caller
* 4 standard parms from SS.Mouse
L03E4               clra
                    ldb       ,x                  Get Pt.Valid flag (are we on the current screen?)
                    std       [,u]                Save back to caller
                    ldb       Pt.CBSB,x           Get current button state of button #2
                    lslb                          Shift to bit 2
                    orb       Pt.CBSA,x           Merge in current button state of button #1
                    std       [<$04,u]            Save button state to caller (0=none,1=button #1,2=button #2, 3=both buttons)
                    ldd       <Pt.WRX,x           Get window relative, scaled X coord
                    std       [<$08,u]            Save back to caller
                    ldd       <Pt.WRY,x           Get window relative, scaled Y coord
                    std       [<$0C,u]            Save back to caller
                    clrb                          No error
L03FE               leas      <$41,s              Eat temp stacks & return
                    rts

* ONMOUSE
* Now sets up both MsSig (mouse button click signal) and SSig (key hit signal)
* It sets both up to do an S$Wake signal (1), so it it just wakes us from the F$Sleep
* (if entry param is 0). Currently will do same signal number (if user specified) for
* both signals - may want to change that so that they are unique in the future (will
* require one more parameter)
;;; ONMOUSE - Set up a mouse signal.
;;;
;;; Calling syntax: RUN GFX2([path,] "ONMOUSE", signal)
L0402               ldx       [,u]                Get signal # caller wants to send on mouse button press
                    bne       L0409               There is one, use it in SetStt call
                    ldx       #S$Wake             0=sleep until button pushed, use signal code 1
L0409               lda       ,s                  Get path
                    ldb       #SS.MsSig           Set up mouse button signal
                    os9       I$SetStt
                    bcs       L043B               If error, eat stack and return
                    ldb       #SS.SSig            Now set up keyboard input signal
                    os9       I$SetStt
                    bcs       L043B               If error, eat stack and return
                    leax      -1,x                Was it an S$Wake signal?
                    bne       L0419               No, skip the sleep call and return to BASIC09
                    os9       F$Sleep             Yes, sleep until signal received
                    lda       ,s                  Get path
                    ldb       #SS.Relea           Release both keyboard & mouse signals (1 will still be enabled)
                    os9       I$SetStt
L0419               clrb                          No error, eat temp stack & return
L041A               bra       L043B

;;; TONE - Generate a sound.
;;;
;;; Calling syntax: RUN GFX2([path,] "TONE", frequency, duration, volume)
L041C               cmpb      #4                  4 parameters?
                    lbne      L02F6               No, exit with Parameter Error
                    ldy       [,u]                Get frequency (0-4095)
                    ldd       [<$04,u]            Get duration (1/60th second count) 0-255
                    pshs      b                   Save it (only 8 bit)
                    ldd       [<$08,u]            Get volume (amplitude) (0-63)
                    tfr       b,a                 Move to high byte
                    puls      b                   Get duration back
                    tfr       d,x                 X is now set up for SS.Tone
                    lda       ,s                  get path
                    ldb       #SS.Tone            play tone
                    os9       I$SetStt
L043B               leas      <stkdepth,s         eat temp stack
                    rts                           return to the caller

;;; WINFO - Get window information.
;;;
;;; Calling syntax: RUN GFX2([path,] "WINFO", format, width, height, foreground, background, border)
L043F               cmpb      #7                  7 parameters?
                    lbne      L02F6               no, exit with parameter error
                    lda       ,s                  get path
                    ldb       #SS.ScTyp           get screen type system call
                    os9       I$GetStt
                    bcs       L0479               error, eat temp stack & exit
                    tfr       a,b                 D=screen type
                    clra
                    std       [,u]                save to caller
                    lda       ,s                  get path again
                    ldb       #SS.ScSiz           get screen size GetStat call
                    os9       I$GetStt
                    bcs       L0479               error, eat temp stack & exit
                    stx       [<$04,u]            save # of columns in current working area
                    sty       [<$08,u]            save # of rows in current working area
                    ldb       #SS.FBRgs           get foreground,background,border color GetStat call
                    os9       I$GetStt
                    bcs       L0479               error, eat temp stack & exit
                    pshs      a                   save foreground color on stack
                    clra                          D=background color
                    std       [<$10,u]            save to caller
                    puls      b                   D=foreground color
                    std       [<$0C,u]            save to caller
                    stx       [<$14,u]            save border color to caller
L0478               clrb                          no error, eat temp stack, & return
L0479               leas      <stkdepth,s
                    rts                           return to the caller

;;; SETMOUSE - Set the mouse scan rate.
;;;
;;; Calling syntax: RUN GFX2([path,] "SETMOUSE", rate)
L047D               ldd       [<$04,u]            get timeout value from caller
                    pshs      b                   save it (only 8 bits)
                    ldd       [,u]                mouse scan rate (# of 1/60th sec ticks between reads)
                    tfr       b,a                 move to high byte
                    puls      b                   merge with timeout
                    tfr       d,x                 mouse sample rate (high byte) and Mouse timeout (low byte)
                    ldy       [<$08,u]            get auto-follow setting from caller
                    lda       ,s                  get path
                    ldb       #SS.Mouse           set mouse parameters
                    os9       I$SetStt
                    bcc       L0478               no error, clear B, eat stack & return
                    bra       L0479               error, eat stack & return

;;; SBAR - Update the scroll bar.
;;;
;;; Calling syntax: RUN GFX2([path,] "SBAR", xpos, ypos)
L0499               ldx       [,u]                get X scroll bar position from caller
                    ldy       [<$04,u]            get Y scroll bar position from caller
                    lda       ,s                  get path
                    ldb       #SS.SBar            re-draw scroll bars
                    os9       I$SetStt
L04A6               bra       L0479               eat stack & return

;;; UMBAR - Update the menu bar.
;;;
;;; Calling syntax: RUN GFX2([path,] "UMBAR")
L04A8               lda       ,s                  get path
                    ldb       #SS.UMBar           update menu bar
                    os9       I$SetStt
                    bra       L0479

;;; DWSET - Define a device window.
;;;
;;; Calling syntax: RUN GFX2([path,] "DWSET", format, xcor, ycor, width, height, foreground, background, border)
L04B1               lda       #$20                load device window set code
                    pshs      x,d                 save output string memory pointer, # of parameters & display code
                    ldx       2,u                 get size of 1st parameter (to see if optional path #)
                    cmpx      #2                  INTEGER?
                    bne       L04C0               no, skip ahead
                    ldd       [,u]                yes, get INTEGER value
                    bra       L04C2

L04C0               lda       [,u]                get BYTE value from parameter 1
L04C2               puls      x,d                 restore output memory string pointer, # of parameters & display code (leaves CC alone)
                    ble       L04EF
                    cmpb      #9                  9 parameters?
                    bne       L0528               no, skip ahead
                    sta       ,x+                 save code to output stream
                    lbra      L0920               append next 8 parameters to output stream (either byte or integer) & write it out

;;; FILL - Fill an area with the foreground color.
;;;
;;; Calling syntax: RUN GFX2([path,] "FILL" [,xcor ,ycor])
L04CF               lda       #$4F                fill code
                    cmpb      #1                  1 parameter?
                    beq       L04E0               yes, just append fill code & write buffer out
                    cmpb      #3                  3 parameters (x,y)?
                    bne       L0528               no, exit with parameter error
                    lbsr      L05F7               yes, append SetDPtr with X,Y coords from caller
                    ldb       #$1B                ESC code
                    stb       ,x+                 save in output buffer
L04E0               bra       L04E8               append fill code & write it out

;;; SELECT - Select the active window.
;;;
;;; Calling syntax: RUN GFX2([path,] "SELECT")
L04E2               lda       #$21                Select code
L04E4               cmpb      #1                  1 parameter?
                    bne       L0528               no, exit with parameter error
L04E8               sta       ,x+                 append command code, and write output buffer out
                    lbra      L0901

;;; OWSET - Create an overlay window.
;;;
;;; Calling syntax: RUN GFX2([path,] "OWSET", save switch, xpos, ypos, xsize, ysize, foreground, background)
L04ED               lda       #$22                Overlay Window Set code
L04EF               cmpb      #8                  8 parameters?
                    bne       L0528               no, exit with parameter error
                    sta       ,x+                 append OWSet code to output buffer
                    lbra      L0922               append the next 7 parameters (BYTE or INTEGER) to the output buffer & write it out

;;; OWEND - Deallocate and destroy an overlay window.
;;;
;;; Calling syntax: RUN GFX2([path,] "OWEND")
L04F8               lda       #$23                Overlay Window End code
                    bra       L04E4               write it out or parameter error

;;; DWEND - Deallocate and destroy a window.
;;;
;;; Calling syntax: RUN GFX2([path,] "DWEND")
L04FC               lda       #$24                Device Window End code
                    bra       L04E4               write it out or parameter error

;;; CWArea - Change a window's working area.
;;;
;;; Calling syntax: RUN GFX2([path,] "CWAREA", xcor, ycor, xsize, ysize)
L0500               lda       #$25                Change Working Area code
                    cmpb      #5                  5 parameters
                    bne       L0528               no, exit with parameter error
                    sta       ,x+                 append CWArea code to output buffer
                    lbra      L0928               append the next 4 parameters (BYTE or INTEGER) to the output buffer & write it out

;;; DEFBUFF - Define a GET/PUT buffer.
;;;
;;; Calling syntax: RUN GFX2([path,] "DEFBUFF", group, buffer, size)
L050B               lda       #$29                Define Buffer code
                    cmpb      #4                  4 parameters?
                    bne       L0528               no, exit with parameter error
                    sta       ,x+                 yes, append Define Buffer code to output buffer
                    lbsr      L0932               append next parameter to output buffer (BYTE or INTEGER) - group #
                    lbsr      L0932               append next parameter to output buffer (BYTE or INTEGER) - buffer #
                    lbra      L08FF               append 16 bit length to output stream & write it out

;;; GCSET - Select a graphics cursor.
;;;
;;; Calling syntax: RUN GFX2([path,] "GCSET", group, buffer)
L051C               lda       #$39                Graphic Cursor Set code
                    bra       L0526               process

;;; FONT - Define which buffer to use for graphic text characters.
;;;
;;; Calling syntax: RUN GFX2([path,] "FONT", group, buffer)
L0520               lda       #$3A                Font code
                    bra       L0526               process

;;; KILLBUF - Deallocate a GET/PUT buffer.
;;;
;;; Calling syntax: RUN GFX2([path,] "KILLBUFF", group, buffer)
L0524               lda       #$2A                Kill Buffer code
L0526               cmpb      #3                  3 parameters?
L0528               lbne      L02F6               no, exit with parameter error
                    sta       ,x+                 yes, append code
                    lbra      L092C               append 2 BYTE/INTEGER parameters

;;; GPLOAD - Load a GET/PUT buffer with image data.
;;;
;;; Calling syntax: RUN GFX2([path,] "GPLOAD", group, buffer, format, xdim, ydim, size)
L0531               lda       #$2B                Get/Put Buffer Load code
                    cmpb      #7                  7 parameters?
                    bne       L0528               no, exit with parameter error
                    sta       ,x+                 yes, append code
                    lbsr      L0932               append BYTE/INTEGER parameter to output buffer - Group #
                    lbsr      L0932               append BYTE/INTEGER parameter to output buffer - Buffer #
                    lbsr      L0932               append BYTE/INTEGER parameter to output buffer - Type
                    lbra      L08FB               append 3 16 bit parameters (X dimension, Y dimension, size in bytes)

;;; GET - Store a portion of the window in a GET/PUT buffer.
;;;
;;; Calling syntax: RUN GFX2([path,] "GET", group, buffer, xcor, ycor, xsize, ysize)
L0545               lda       #$2C                GetBlk code
                    cmpb      #7                  7 parameters?
                    bne       L0528               no, exit with parameter error
                    sta       ,x+                 yes, append code
                    lbsr      L0932               append BYTE/INTEGER parameter to output buffer - Group #
                    lbsr      L0932               append BYTE/INTEGER parameter to output buffer - Buffer #
                    lbra      L08F9               append 4 16 bit parameters (startx, starty,sizex,sizey)

;;; PUT - Place a GET/PUT buffer on a window.
;;;
;;; Calling syntax: RUN GFX2([path,] "PUT", group, buffer, xcor, ycor)
L0556               lda       #$2D                PutBlk code
                    cmpb      #5                  5 parameters?
                    bne       L0528               no, exit with parameter error
                    sta       ,x+                 yes, append code
                    lbsr      L0932               append BYTE/INTEGER parameter to output buffer - Group #
                    lbsr      L0932               append BYTE/INTEGER parameter to output buffer - Buffer #
                    lbra      L08FD               append 2 16 bit parameters (startx,starty)

;;; PATTERN - Select a pattern buffer.
;;;
;;; Calling syntax: RUN GFX2([path,] "PATTERN", group, buffer)
L0567               lda       #$2E                PSet code
                    bra       L0526               append 3 parameters or exit with parameter error

;;; LOGIC - Set the drawing logic type.
;;;
;;; Calling syntax: RUN GFX2([path,] "LOGIC", "function")
L056B               lda       #$2F                LSet code
                    cmpb      #2                  2 parameters?
                    bne       L0528               no, exit with parameter error
                    sta       ,x+                 append code
                    pshs      y,x                 save registers
                    leay      >L0268,pcr          point to OFF,AND,OR,XOR table
L0579               ldx       ,u                  get parameter pointer for string caller sent
                    lbsr      L0892               go find match, and get code to send for that string
                    puls      y,x                 restore registers
                    bcs       L0528               no match found in table, exit with parameter error
                    lbra      L04E8               append code & write out

* Palette
L0585               lda       #$31                Palette code
                    bra       L0526               append 3 parameters or exit with parameter error

;;; COLOR - Set the window colors.
;;;
;;; Calling syntax: RUN GFX2([path,] "COLOR", foreground [,background] [,border])
L0589               cmpb      #2                  2 parameters? (foreground only, no path)
                    beq       L0597               yes, do that
                    cmpb      #3                  3 parameters? (foreground/background only)?
                    beq       L059B               yes, do that
                    cmpb      #4                  4 parameters? (foreground/background/border)?
                    bne       L0528               no, exit with parameter error
                    bra       L05A5               yes, send all 3 color setting sequences out

* Build FColor sequence & write it out
L0597               bsr       L05B6               build foreground color sequence
                    bra       L05B3               write it out

*  Build FColor and BColor command sequences & write them out
L059B               bsr       L05B6               build foreground color sequence first
                    ldb       #$1B                add ESC code
                    stb       ,x+
                    bsr       L05BA               build background color sequence
                    bra       L05B3               write it out

* Build FColor, BColor, Border
L05A5               bsr       L05B6               append foreground color sequence
                    ldb       #$1B                add ESC to output buffer
                    stb       ,x+
                    bsr       L05BA               append background color sequence
                    ldb       #$1B                add ESC to output buffer
                    stb       ,x+
                    bsr       L05CA               append Border color sequence
L05B3               lbra      L0901               write output buffer

L05B6               lda       #$32                wppend FColor code
                    bra       L05BC               and BYTE/INTEGER parameter from caller

* Build BColor
L05BA               lda       #$33                append Background Color code
L05BC               sta       ,x+
                    lbra      L0932               append background color (BYTE/INTEGER) from caller

;;; BORDER - Set the border color palette.
;;;
;;; Calling syntax: RUN GFX2([path,] "BORDER" , color)
L05C1               cmpb      #2                  2 parameters?
                    bne       L062E               no, exit with parameter error
                    bsr       L05CA               add Border color sequence
                    lbra      L0901               write output buffer

L05CA               lda       #$34                append Border color
                    bra       L05BC

;;; SCALESW - Set/reset the draw scaling switch.
;;;
;;; Calling syntax: RUN GFX2([path,] "SCALESW", "switch")
L05CE               lda       #$35                ScaleSw code
L05D0               cmpb      #2                  2 parameters?
                    bne       L062E               no, exit with parameter error
                    sta       ,x+                 append code to output buffer
                    pshs      y,x                 save registers
                    leay      >L027C,pcr          point to OFF/ON table
                    bra       L0579               append proper code depending on caller's ON/OFF parameter, or error

;;; DWPROTSW - Set/reset the device window protection switch.
;;;
;;; Calling syntax: RUN GFX2([path,] "DWPROTSW", "switch")
L05DE               lda       #$36                Device Window Protect Switch code
                    bra       L05D0               get switch value & write out, or return with error

;;; TCHARSW - Set/reset the transparent character switch.
;;;
;;; Calling syntax: RUN GFX2([path,] "TCHARSW", "switch")
L05E2               lda       #$3C                Transparent Character Switch code
                    bra       L05D0               get switch value & write out, or return with error

;;; BOLDSW - Set/reset the bold text switch.
;;;
;;; Calling syntax: RUN GFX2([path,] "BOLDSW", "switch")
L05E6               lda       #$3D                Bold Switch code
                    bra       L05D0               get switch value & write out, or return with error

;;; PROPSW - Set/reset the proportional text switch.
;;;
;;; Calling syntax: RUN GFX2([path,] "PROPSW", "switch")
L05EA               lda       #$3F                Proportional character Switch code
                    bra       L05D0               get switch value & write out, or return with error

;;; SETDPTR - Position the drawing pointer.
;;;
;;; Calling syntax: RUN GFX2([path,] "SETDPTR" ,xcor, ycor)
L05EE               cmpb      #3                  3 parameters?
                    bne       L062E               no, exit with parameter error
                    bsr       L05F7               yes, do SetDPTr with x,y coords
                    lbra      L0901               write sequence out

* Entry: U=pointer to current parameter pointer
*        X=pointer to current position in output buffer
* Do SetDPtr (Set Draw Pointer) to x,y coord specified by next two parameters
L05F7               pshs      a                   save A (original display code)
                    lda       #$40                append display code for SetDPPtr
                    sta       ,x+
                    lbsr      L08CE               append X coord
                    lbsr      L08CE               append Y coord
                    puls      pc,a                restore original display code & return

;;; POINT - Set a point to the current foreground color.
;;;
;;; Calling syntax: RUN GFX2([path,] "POINT" [,xcor, ycor])
L0605               lda       #$42                point code
                    cmpb      #3                  3 parameters?
                    bne       L062E               no, exit with parameter error
                    bra       L061D               append code, and two 16 bit parameters for X,Y


;;; LINEM - Draw a line and move the draw pointer.
;;;
;;; Calling syntax: RUN GFX2([path,] "LINEM" [,xcor1, ycor1], xcor2, ycor2))
L060D               lda       #$46                LineM code
L060F               cmpb      #3                  3 parameters?
                    beq       L061D               yes, process (just end point)
                    cmpb      #5                  5 parameters?
                    bne       L062E               no, exit with parameter error
                    bsr       L05F7               yes, do SetDPtr (Set Draw Pointer) first and then draw line
                    ldb       #$1B                ESC code
                    stb       ,x+                 append to output buffer
L061D               sta       ,x+                 save code in output buffer
                    lbra      L08FD               append two 16 bit parameters from caller (X endpoint, Y endpoint)

;;; BOX - Draw a rectangle.
;;;
;;; Calling syntax: RUN GFX2([path,] "BOX" [,xcor1, ycor1], xcor2, ycor2))
L0622               lda       #$48                Box code
                    bra       L060F               process

;;; BAR - Draw a filled rectangle.
;;;
;;; Calling syntax: RUN GFX2([path,] "BAR" [,xcor1, ycor1], xcor2, ycor2))
L0626               lda       #$4A                Bar code (filled box)
                    bra       L060F               process

;;; PUTGC - Put a graphics cursor.
;;;
;;; Calling syntax: RUN GFX2([path,] "PUTGC", xcor, ycor)
L062A               lda       #$4E                Put Graphics Cursor code
                    cmpb      #3                  3 parameters?
L062E               lbne      L02F6               no, exit with parameter error
                    bra       L061D               yes, add X,Y coords from caller & write out


;;; FCIRCLE - Draw a filled circle.
;;;
;;; Calling syntax: RUN GFX2([path,] "FCIRCLE" [,xcor, ycor], xrad, yrad))
FCircle             lda       #$53                FCircle code
                    fcb       $8c                 skip 2 bytes (CMPX)

;;; CIRCLE - Draw an circle.
;;;
;;; Calling syntax: RUN GFX2([path,] "CIRCLE" [,xcor, ycor], xrad, yrad))
L0634               lda       #$50                Circle code
                    cmpb      #2                  2 parameters? (Just radius)
                    beq       L0644               yes, skip ahead
                    cmpb      #4                  4 parameters (X,Y center coords)?
                    bne       L062E               no, exit with parameter error
                    bsr       L05F7               yes, do SetDPtr first
                    ldb       #$1B                ESC
                    stb       ,x+                 append to output buffer
L0644               sta       ,x+                 add code to output buffer
                    lbra      L08FF               append one 16 bit value (radius) from caller to output buffer & write out

* Draw - This adds new start x,y coords not mentioned in the manual
* So now RUN Gfx2([#path][,start X,start Y],draw string)
* Also - I think the commas between commands (not coords) are optional. Test.
L0649               cmpb      #2                  2 parameters?
                    beq       L0663               yes, get draw string from caller and build output buffer based on it
                    cmpb      #4                  4 parameters (start x,y coord added)?
                    bne       L062E               no, exit with parameter error
                    pshs      u,x,d               save registers
                    ldd       #$1B40              add esc sequence for SetDPPtr
                    std       ,x++
                    lbsr      L08DA               append 16 bit X start coord from caller
                    lbsr      L08DA               append 16 bit Y start coord from caller
                    lbsr      L07CD               send SetDPPtr sequence, and reset output buffer pointer to beginning
                    bra       L0665               now process draw string

* 6809/6309 - may be able to move some draw routine stuff around to make more short branches?
L0663               pshs      u,x,d               save registers (D is just to reserve 2 bytes on the stack-contents not preserved)
L0665               ldu       ,u                  get pointer to string data from caller
                    clr       1,s                 clear 2 bytes on stack (allocated by D in the PSHS above)
                    clr       ,s                  (angle # 0-3 from 'A'xis command. Defaults to 0)
L066B               lda       ,u+                 get byte from draw string
                    cmpa      #',                 comma?
                    beq       L066B               yes, skip to next character
                    cmpa      #$FF                End of string?
                    beq       L069B               yes, exit
                    anda      #$DF                force to uppercase
                    cmpa      #'A                 axis rotate?
                    beq       L06A3               yes, process
                    cmpa      #'B                 blank line (move gfx draw pointer w/o drawing)?
                    beq       L06AA               yes, process
                    cmpa      #'U                 relative vector draw?
                    beq       L06BF               yes, process
                    cmpa      #'N                 north (up) draw?
                    beq       L06C6               yes, process
                    cmpa      #'S                 south (down) draw?
                    beq       L06FE               yes, process
                    cmpa      #'E                 east (right) draw?
                    lbeq      L072C               yes, process
                    cmpa      #'W                 west (left) draw?
                    lbeq      L0735               yes, process
L0697               leas      6,s                 eat 2ndary temp stack
                    bra       L062E               exit with parameter error

L069B               leas      2,s                 eat temp 16 bit variable
                    puls      u,x                 restore registers
                    leas      <stkdepth,s         eat temp stack & return
                    rts                           return to the caller

* 'A'xis rotate
L06A3               lbsr      L0745               get signed parameter value into D
                    std       ,s                  save value as angle 0-3
                    bra       L066B               continue processing draw string

* 'B'lank line move (moves cursor, doesn't draw). Offsets draw pointer by values specified
L06AA               ldd       #$1B41              RSetDPtr (Relative Set Draw Ptr)
                    std       ,x++                append to temp buffer
L06AF               lbsr      L0745               get signed parameter value into D
                    std       ,x++                save signed X offset in output buffer
                    lda       ,u+                 get next byte from DRAW string
                    cmpa      #',                 comma?
                    bne       L0697               no, since no Y coord offset, exit with parameter error
                    lbsr      L0745               get signed Y offset into D
                    bra       L06E8               append to output buffer

* 'U' draw relative vector w/o updating draw pointer position
L06BF               ldd       #$1B45              RLine (Relative Draw Line)
                    std       ,x++                append to output buffer
                    bra       L06AF               process/append X,Y offsets

* 'N' North (up) draw
L06C6               ldd       #$1B47              RLineM (Relative Draw Line and Move)
                    std       ,x++                append to output buffer
                    lda       ,u                  get next byte from draw string
                    anda      #$DF                force case
                    cmpa      #'E                 east (right)?
                    beq       L06DF               yes, NE so skip ahead (up and to right)
                    cmpa      #'W                 west (left)?
                    beq       L06F3               yes, NW so skip ahead (up and to left)
                    clra                          straight up, so X offset=0
                    clrb
                    std       ,x++                append to output buffer
                    bsr       L0745               get signed Y offset caller specified
                    bra       L06E5               use negative value of that as Y offset

* 'NE' (northeast, up and right)
L06DF               leau      1,u                 bump up source string pointer
                    bsr       L0745               get signed X offset caller specified
                    std       ,x++                append X offset to output buffer
L06E5               lbsr      L07C8               NEGD
L06E8               std       ,x++                append Y offset to output buffer
L06EA               lbsr      L078E               adjust X,Y coords based on current ANGLE setting (if <>0)
                    lbsr      L07CD               write output buffer
                    lbra      L066B               process next DRAW command sequence

* 'NW' (northwest, up and left)
L06F3               leau      1,u                 bump up source string pointer
                    bsr       L0745               get signed X offset caller specified
                    IFNE      H6309
                    negd
                    ELSE
                    bsr       L07C8               NEGD
                    ENDC
L06FA               std       ,x++                append X offset to output buffer
                    bra       L06E8               append same value as Y offset to output buffer, write it out & continue

* S (south, down)
L06FE               ldd       #$1B47              RLineM (Relative Draw Line and Move)
                    std       ,x++                append to output buffer
                    lda       ,u                  get next character from draw string
                    anda      #$DF                force case
                    cmpa      #'E                 east (Right?)
                    beq       L0717               yes, SE so skip ahead (down and right)
                    cmpa      #'W                 west (Left?)
                    beq       L071D               yes, SW so skip ahead (down and left)
                    clra                          X offset=0
                    clrb
                    std       ,x++                append to output buffer
                    bsr       L0745               get signed Y offset caller specified
                    bra       L06E8               append to output buffer, adjust for ANGLE (if needed), write it out

L0717               leau      1,u                 bump up source string pointer
                    bsr       L0745               get signed offset from caller
                    bra       L06FA               append as both X & Y offsets

* SW (southwest, down and left)
L071D               leau      1,u                 bump up source string ptr
                    bsr       L0745               get signed offset caller specified
                    std       2,x                 save as Y offset
                    IFNE      H6309
                    negd
                    ELSE
                    bsr       L07C8               NEGD
                    ENDC
                    std       ,x                  save as X offset
                    leax      4,x                 bump up output buffer ptr
                    bra       L06EA

* E (East, right)
L072C               ldd       #$1B47              RLineM (Relative Draw Line and Move)
                    std       ,x++                append to output buffer
                    bsr       L0745
                    bra       L073F

* W (West, left)
L0735               ldd       #$1B47              RLineM (Relative Draw Line and Move)
                    std       ,x++                append to output buffer
                    bsr       L0745               get signed offset caller specified
                    IFNE      H6309
                    negd
                    ELSE
                    bsr       L07C8               NEGD
                    ENDC
L073F               std       ,x++                append X offset to output buffer
                    clra                          Y offset=0
                    clrb
                    bra       L06E8               append to output buffer and write it out

* 6809 - May be able to this up so more use BSR instead of LBSR (faster/shorter)
                    IFEQ      H6309
* NegD
L07C8               nega                          NEGD
                    negb
                    sbca      #$00
                    rts
                    ENDC

******************
* Process parameter for a specific DRAW command. Gets numeric string, converts to signed
*   16 bit #. Stops on first non-numeric character encountered (decimal only)
* Entry: U=pointer to start of parameter section of current DRAW string command
* Exit:  D=signed binary version of parameter
* Change to use MUL * 10. This will work up to 2550 and then give inaccurate results,
*  but that high is illegal anyways.
L0745               clra                          Init running total to 0
                    clrb
                    pshs      u,d                 Save that & start of current DRAW substring ptr
                    ldb       ,u+                 Get 1st byte of DRAW command parameter
                    cmpb      #'-                 Negative sign?
                    bne       L0753               No, use current byte as numeric data byte
* Also - using MUL (previous result by 10 or 100) and adding new may be faster
* Negatives are post processed in L0776, so that shouldn't affect this either
* the current routine will allow 1000's and I think even 10000's, which are illegal for
* every parameter that comes in here (I think)
L0751               ldb       ,u+                 Get parameter byte (String)
L0753               subb      #'0                 Subtract ASCII to make binary value
                    bcs       L0776               If wrapped negative, done processing numeric
                    cmpb      #9                  Outside of 0-9?
                    bhi       L0776               Yes, done processing numeric
                    clra                          make 16 bit for adds below
                    pshs      d                   Save numeric value of current digit
                    ldb       2+1,s               5 Get LSB of current cumulative value into B (32 cyc to next save)
                    lda       #10                 2 Multiply by 10 (shift digits over)
                    mul                           11
                    addd      ,s++                9 Add current digit value
                    std       ,s                  5 Save new cumulative value
                    bra       L0751               Check next char

* parm char from draw string is not '0'-'9'
L0776               leau      -1,u                Point back to last legit char
                    cmpu      2,s                 Are we at beginning of current draw string command's parameters?
                    beq       L0789               Yes, no parameters, so eat temp stack & exit with Parameter Error
                    lda       [<$02,s]            Get first char from current draw string command's parameters again
                    cmpa      #'-                 Was it a dash (negative)?
                    puls      d                   Get current binary version of number string we processed
                    bne       L0786               Not negative, skip ahead
                    IFNE      H6309
                    negd
                    ELSE
                    bsr       L07C8               NEGD
                    ENDC
L0786               leas      2,s                 Eat start string ptr & return
                    rts

L0789               leas      $C,s                Eat temp stack, return with Parameter Error
                    lbra      L02F6

* Adjust draw command based on Axis angle (0=no rotate/no changes)
* 1,2,3 make adjustments. All other values leave coords alone
L078E               ldd       2,s                 get Axis angle
                    beq       L07AC               if 0 (normal), return
                    tsta                          if >255, exit
                    bne       L07AC
                    decb                          1 (90 degrees)?
                    beq       L07AD               yes, skip ahead
                    decb                          2 (180 degrees)?
                    beq       L07BC               yes, skip ahead
                    decb                          3 (270 degrees)?
                    bne       L07AC               no, return
* 270 degree rotate
                    ldd       -4,x                Get original X value from output buffer
                    IFNE      H6309
                    negd
                    ELSE
                    bsr       L07C8               NEGD
                    ENDC
                    pshs      d                   Save on stack
                    ldd       -2,x                Get original Y value from output buffer
                    std       -4,x                Save overtop original X
                    puls      d                   Get negated X back
L07AA               std       -2,x                Save overtop original Y & return
L07AC               rts

* 90 degree rotate
L07AD               ldd       -2,x                Get original X value from output buffer
                    IFNE      H6309
                    negd
                    ELSE
                    bsr       L07C8               NEGD
                    ENDC
                    pshs      d                   Save on stack
                    ldd       -4,x                Get original y coord
                    std       -2,x                Save over original X coord
                    puls      d                   Get negated X value back
                    std       -4,x                Save over original Y coord
                    rts

* 180 degree rotate
L07BC               ldd       -4,x                Get original X coord
                    IFNE      H6309
                    negd
                    ELSE
                    bsr       L07C8               NEGD
                    ENDC
                    std       -4,x                Save overtop original X coord
                    ldd       -2,x                Get original Y coord
                    IFNE      H6309
                    negd
                    ELSE
                    bsr       L07C8               NEGD
                    ENDC
                    bra       L07AA               Save overtop original Y & return

* Write output buffer based on current output buffer ptr (for DRAW commands)
* Entry: X=current output buffer position ptr
*        2,s = output buffer start ptr
*        4,s = output buffer end ptr (used to calculate buffer write size)
L07CD               pshs      y                   Preserve Y
                    IFNE      H6309
                    leay      ,x                  Y=end buffer ptr
                    ldx       6,s                 Get start buffer ptr
                    subr      x,y                 Y=size of buffer to write
                    ELSE
                    tfr       x,d                 Move current position in output buffer ptr to D
                    subd      6,s                 Calc size of string to write
                    tfr       d,y                 Move for I$Write
                    ldx       6,s                 Get ptr to start of output buffer
                    ENDC
                    lda       $A,s                Get path
                    os9       I$Write             Write it out
                    ldx       6,s                 Get start of output buffer ptr back & return
                    puls      y,pc                Restore Y & return

;;; FELLIPSE - Draw a filled ellipse.
;;;
;;; Calling syntax: RUN GFX2([path,] "FELLIPSE", [,xcor, ycor], xrad, yrad))
FEllipse            lda       #$54                FEllipse code
                    fcb       $8c                 skip 2 bytes (CMPX)

;;; ELLIPSE - Draw an ellipse.
;;;
;;; Calling syntax: RUN GFX2([path,] "ELLIPSE", [,xcor, ycor], xrad, yrad))
L07E1               lda       #$51                Ellipse code
                    lbra      L060F               process for 3 or 5 parameters

;;; ARC - Draw an arc.
;;;
;;; Calling syntax: RUN GFX2([path,] "ARC" [,mx, my], xrad, yrad, xcor1, ycor1, xcor2, ycor2)
L07E6               lda       #$52                Arc code
                    cmpb      #7                  7 parameters?
                    beq       L07F7               yes, skip setting center coords
                    cmpb      #9                  9 parameters?
                    bne       L0804               no, exit with parameter error
                    lbsr      L05F7               yes, append SetDPtr with callers center X,Y coord to output buffer
                    ldb       #$1B                append ESC code
                    stb       ,x+
L07F7               sta       ,x+                 append ARC code
                    lbra      L08F5               process remaining 6 16 bit parameters (X radius, Y radius, startx, starty, endx,endy)

;;; CURHOME - Home the cursor.
;;;
;;; Calling syntax: RUN GFX2([path,] "CURHOME")
L07FC               lda       #$01                Home Cursor code
                    bra       L0859               overwrite default ESC code in output buffer with new code, write it out

;;; CURXY - Move the cursor to a column and row.
;;;
;;; Calling syntax: RUN GFX2([path,] "CURXY", column, row)
L0800               lda       #$02                CurXY code
                    cmpb      #3                  3 parameters?
L0804               lbne      L02F6               no, exit with parameter error
                    sta       -1,x                yes, overwrite original ESC code in output buffer
                    bsr       L0811               append X coord from caller (with $20 offset)
                    bsr       L0811               append Y coord from caller (with $20 offset)
                    lbra      L0901               write output buffer

* Process text coord from caller. Handles BYTE or INTEGER, and adds +$20 offset needed for CurXY
L0811               pshs      y,d                 save registers
                    ldd       [,u++]              get coord from caller (INTEGER)
                    adda      #$20                offset for CurXY
                    sta       ,x+                 save in output buffer
                    pulu      y                   get size of coord variable from caller
                    leay      -1,y                BYTE type?
                    beq       L0829               yes, we are done, restore registers & exit
                    leay      -1,y                INTEGER type?
                    lbne      L091B               no, eat temp stack, return with parameter error
                    addb      #$20                replace coord in output buffer with LSB of INTEGER parameter
                    stb       -1,x
L0829               puls      pc,y,d              return to the caller

;;; ERLINE - Delete the line of text the cursor is on.
;;;
;;; Calling syntax: RUN GFX2([path,] "ERLINE")
L082B               lda       #$03                Erase Line code
                    bra       L0859               overwrite default ESC code in output buffer with new code, write it out

;;; EREOLINE - Delete text from the cursor to the end of the current line.
;;;
;;; Calling syntax: RUN GFX2([path,] "EREOLINE")
L082F               lda       #$04                Erase to End of Line code
                    bra       L0859               overwrite default ESC code in output buffer with new code, write it out

;;; CUROFF - Make the cursor invisible
;;;
;;; Calling syntax: RUN GFX2([path,] "CUROFF")
L0833               lda       #5                  Cursor on/off code
                    sta       -1,x                save over original ESC
                    lda       #$20                off value
                    bra       L087B               append to output buffer, write it out

;;; CURON - Make the cursor visible
;;;
;;; Calling syntax: RUN GFX2([path,] "CURON")
L083B               lda       #5                  Cursor on/off code
                    sta       -1,x                save over original ESC
                    lda       #$21                on value
                    bra       L087B               append to output buffer, write it out

;;; CURRGT - Move the cursor one character to the right.
;;;
;;; Calling syntax: RUN GFX2([path,] "CURRGT")
L0843               lda       #6                  Cursor Right code
                    bra       L0859               overwrite default ESC code in output buffer with new code, write it out

;;; BELL - Produce a beep through the terminal's speaker.
;;;
;;; Calling syntax: RUN GFX2([path,] "BELL")
L0847               lda       #7                  Bell code
                    bra       L0859               overwrite default ESC code in output buffer with new code, write it out

;;; CURLFT - Move the cursor one character to the left.
;;;
;;; Calling syntax: RUN GFX2([path,] "CURLFT")
L084B               lda       #8                  Cursor Left code
                    bra       L0859               overwrite default ESC code in output buffer with new code, write it out

;;; CURUP - Move the cursor one line up.
;;;
;;; Calling syntax: RUN GFX2([path,] "CURUP")
L084F               lda       #9                  Cursor Right code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

;;; CURDWN - Move the cursor one line down.
;;;
;;; Calling syntax: RUN GFX2([path,] "CURDWN")
L0853               lda       #$A                 Cursor Down code
                    bra       L0859               overwrite default ESC code in output buffer with new code, write it out

;;; EREOWNDW - Delete text from the current cursor position to the end of the window.
;;;
;;; Calling syntax: RUN GFX2([path,] "EREOWNDW")
L0857               lda       #$B                 Erase to end of Window code
L0859               leax      -1,x                bump back output buffer pointer
                    bra       L087B               overwrite default ESC code in output buffer with new code, write it out

;;; Clear - Clear the screen.
;;;
;;; Calling syntax: RUN GFX2([path,] "CLEAR")
L085D               lda       #$C                 Clear window code
                    bra       L0859               overwrite default ESC code in output buffer with new code, write it out

;;; CRRTN - Send a carriage return.
;;;
;;; Calling syntax: RUN GFX2([path,] "CRRTN")
L0861               lda       #$D                 Carriage return code
                    bra       L0859               overwrite default ESC code in output buffer with new code, write it out

;;; REVON - Turn on reverse video characters.
;;;
;;; Calling syntax: RUN GFX2([path,] "REVON")
L0865               lda       #$20                Reverse video ON sub-code for $1F code
                    bra       L0873               append both to output buffer & write out

;;; REVOFF - Turn off reverse video characters.
;;;
;;; Calling syntax: RUN GFX2([path,] "REVOFF")
L0869               lda       #$21                Reverse video OFF sub-code for $1F code
                    bra       L0873               append both to output buffer & write out

;;; UNDLNON - Turn on underlined video characters.
;;;
;;; Calling syntax: RUN GFX2([path,] "UNDLNON")
L086D               lda       #$22                Underline ON sub-code for $1F code
                    bra       L0873               append both to output buffer & write out

;;; UNDLNOFF - Turn off underlined video characters.
;;;
;;; Calling syntax: RUN GFX2([path,] "UNDLNOFF")
L0871               lda       #$23                Underline OFF sub-code for $1F code
L0873               pshs      a                   save sub-code
                    lda       #$1F                put $1F code overtop original ESC first
                    sta       -1,x
                    puls      a                   get sub-code back
L087B               lbra      L04E4               append to output buffer & write out

;;; BLNKON - Turn on blinking video characters.
;;;
;;; Calling syntax: RUN GFX2([path,] "BLNKON")
L087E               lda       #$24                Blink ON sub-code for $1F code
                    bra       L0873               append both to output buffer & write out

;;; BLNKOFF - Turn off blinking video characters.
;;;
;;; Calling syntax: RUN GFX2([path,] "BLNKOFF")
L0882               lda       #$25                Blink OFF sub-code for $1F code
                    bra       L0873               append both to output buffer & write out

;;; INSLIN - Insert a blank line at the current cursor.
;;;
;;; Calling syntax: RUN GFX2([path,] "INSLIN")
L0886               lda       #$30                Insert Line sub-code for $1F code
                    bra       L0873               append both to output buffer & write out

;;; DELLIN - Delete the line at the current cursor.
;;;
;;; Calling syntax: RUN GFX2([path,] "DELLIN")
L088A               lda       #$31                Delete Line sub-code for $1FG code
                    bra       L0873               append both to output buffer & write out

;;; DEFCOL - Set palette registers to the default values.
;;;
;;; Calling syntax: RUN GFX2([path,] "DEFCOL")
L088E               lda       #$30                Default color code
                    bra       L087B               append to output buffer & write out

* Compare string from caller to string in table (used for ON, OFF, etc) case insensitive
* Entry: X=pointer to string from caller
*        Y=pointer in table for strings we are checking against
* Exit: Carry clear, A=code to send that corresponds to table string entry
*       or carry set if no match in table
L0892               pshs      x                   save pointer to start of string from caller
L0894               lda       ,y+                 get character from table
                    beq       L08BF               NUL (end of table), exit with error
L0898               eora      ,x+                 force case
                    anda      #$DF
                    bne       L08AE               different, skip to next entry
                    tst       ,y                  hi bit ($FF cheat) set on matching character from table (ie end of name?)
                    bmi       L08AA               yes, check if end of caller's string
                    tst       ,x                  no, was hi bit ($FF cheat) set on character from caller?
                    bmi       L08AE               yes, skip to next entry
                    lda       ,y+                 no, matches so far, check next character
                    bra       L0898

L08AA               tst       ,x                  end of table string, is it end of caller string too?
                    bmi       L08BA               yes, found match, skip ahead
L08AE               leay      -1,y                no, bump table pointer back 1
L08B0               tst       ,y+                 skip to end of table string
                    bpl       L08B0
                    ldx       ,s                  get pointer to start of string from caller again
                    leay      1,y                 bump table pointer to next entry
                    bra       L0894

L08BA               clra                          clear carry
                    lda       1,y                 get table byte entry
                    bra       L08C0

L08BF               coma                          no match found, exit with carry set
L08C0               puls      pc,x                return to the caller

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer
AppendParam         pshs      y,d                 save registers
                    bsr       L08E8               append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6               if 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y                2 byte value (INTEGER) from caller?
                    bne       L091B               not BYTE or INTEGER, exit with parameter error
                    bra       L08E4               if INTEGER, append to output buffer and return

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer (and eat 9 byte temp stack)
L08CE               pshs      y,d                 save registers
                    bsr       L08E8               append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6               if 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y                2 byte value (INTEGER) from caller?
                    bne       L0919               not BYTE or INTEGER, exit with parameter error (& eat 9 byte temp stack)
                    bra       L08E4               If INTEGER, append to output buffer & return

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer (and eat 15 byte temp stack)
L08DA               pshs      y,d                 save registers
                    bsr       L08E8               append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6               if 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y                2 byte value (INTEGER) from caller?
                    bne       L0917               not BYTE or INTEGER, exit with parameter error (& eat 15 byte temp stack)
L08E4               std       ,x++                append value to output buffer
L08E6               puls      pc,y,d              return to the caller

* Append 16 bit value from caller to output buffer. Original from caller is unsigned, can be BYTE or INTEGER
L08E8               ldd       [,u++]              get 16 bit value from caller (INTEGER)
                    pulu      y                   get size of variable form caller
                    leay      -1,y                INTEGER?
                    bne       L08F4               yes, return
                    sta       1,x                 no, BYTE, save BYTE as 16 bit value (note: NOT SIGNED)
                    clr       ,x++
L08F4               rts                           return to the caller

L08F5               bsr       AppendParam         append 16 bit value to output buffer (6 16 bit parameters)
                    bsr       AppendParam         append 16 bit value to output buffer
L08F9               bsr       AppendParam         append 16 bit value to output buffer (4 16 bit parameters)
L08FB               bsr       AppendParam         append 16 bit value to output buffer (3 16 bit parameters)
L08FD               bsr       AppendParam         append 16 bit value to output buffer (2 16 bit parameters)
L08FF               bsr       AppendParam         append 16 bit value to output buffer (1 16 bit parameter)
L0901               bsr       L0907               write output buffer out
                    leas      <stkdepth,s         eat main temp stack & return
                    rts                           return to the caller

* Write output buffer out
                    IFNE      H6309
L0907               leay      ,x                  4 Y=end buffer ptr
                    leax      3,s                 5 Point to start of buffer to write out
                    subr      x,y                 4 Calc size of write
                    ELSE
L0907               tfr       x,d                 4 Move buffer end ptr to write out to D
                    leax      3,s                 5 Point to buffer to write out
                    pshs      x                   6 Save start of buffer
                    subd      ,s++                7 End buffer ptr-Start buffer ptr=length
                    tfr       d,y                 4 Move length to Y for Write
                    ENDC
                    lda       2,s                 Get path, write out buffer
                    os9       I$Write
                    rts                           return to the caller

L0917               leas      6,s                 eat extra temp stack (15 bytes)
L0919               leas      3,s                 eat extra temp stack (9 bytes)
L091B               leas      6,s                 eat extra temp stack  (6 bytes)
                    lbra      L02F6               exit with parameter error

L0920               bsr       L0932               append BYTE or INTEGER parameter to output stream (append 8 parameters)
L0922               bsr       L0932               append BYTE or INTEGER parameter to output stream (append 7 parameters)
                    bsr       L0932               append BYTE or INTEGER parameter to output stream (append 6 parameters)
                    bsr       L0932               append BYTE or INTEGER parameter to output stream (append 5 parameters)
L0928               bsr       L0932               append BYTE or INTEGER parameter to output stream (append 4 parameters)
                    bsr       L0932               append BYTE or INTEGER parameter to output stream (append 3 parameters)
L092C               bsr       L0932               append BYTE or INTEGER parameter to output stream (append 2 parameters)
                    bsr       L0932               append BYTE or INTEGER parameter to output stream (append 1 parameter)
                    bra       L0901               write the output buffer out

* Append next parameter value to output stream (either INTEGER or BYTE)
* Entry: U=pointer to current parameter pointer and size
*        X=pointer to current position in output buffer
L0932               pshs      y,d                 save registers
                    ldd       [,u++]              get next parameter value (BYTE)
                    sta       ,x+                 append to output stream
                    pulu      y                   Y=parameter size & bump U to next parameter
                    leay      -1,y
                    beq       L0944               if it was a BYTE, we are done
                    leay      -1,y
                    bne       L091B               not an INTEGER either, return with parameter error
                    stb       -1,x                save LSB overtop original one (which would have been 0 to get here)
L0944               puls      pc,y,d              return to the caller

                    emod
eom                 equ       *
                    end

