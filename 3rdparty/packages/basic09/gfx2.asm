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
*   3      1990/08/16 - Kevin Darling and Kent Meyers Enhanced, with
*          bug fix (adds Multi-Vue windowing support commands, etc.
*          and optimizations). Note: I changed the edition to 3 myself
*          as the original was still set to 2 (same as the Tandy one)
*   4      2018/06/14 - 2018/06/18 - LCB - commented source code, couple
*          of minor optimizations, added FCircle & FEllipse commands
*          (keeping to <=8 char function name limits of original). Also
*          documented option X,Y start coord for DRAW command (not in manual)

                    nam       gfx2
                    ttl       subroutine module

* Disassembled 2018/06/13 23:49:42 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       os9.d
                    use       scf.d
                    use       coco3vtio.d
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $01
edition             set       $04                 4 is Kevin Darling/Kent Meyers updates plus LCB's FCircle / FEllipse

                    mod       eom,name,tylg,atrv,start,size

* Data size since BASIC09 subroutine modules do everything on the stack
u0000               rmb       0
size                equ       .

name                fcs       /gfx2/
                    fcb       edition

                    fcb       $00

* Offsets for parameters accessed directly (there can be more, but they are handled in loops)
                    org       0
Return              rmb       2                   0 Return address of caller
PCount              rmb       2                   2 # of params following
PrmPtr1             rmb       2                   4 Ptr to 1st param data
PrmLen1             rmb       2                   6 Len of 1st param
PrmPtr2             rmb       2                   8 Ptr to 2nd param data
PrmLen2             rmb       2                   A Len of 2nd param
PrmPtr3             rmb       2                   C Ptr to 3rd param data
PrmLen3             rmb       2                   E Len of 3rd param

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

* Test by sending non-existant function name - this may have to be an FDB
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

* All functions (from the call table) are entered with the following parameters:
* Y=Ptr to function subroutine
* X=Ptr to 9 byte scratch variable area (same as stack ptr, which has allocated that extra memory)
* U=Ptr to 2nd parameter (first parameter after name itself)
* D=# of parameters (NOTE: Function name itself is always parameter 1)

* Stack on entry to every function routine:
*$00-$08 / 00-08,s - Temp scratch var area
*$09-$0A / 09-10,s - RTS address to BASIC09/RUNB
*$0B-$0C / 11-12,s - # of parameters (including function name itself)
*$0D-$0E / 13-14,s - Ptr to 1st parameter's data (function name)
*$0F-$10 / 15-16,s - Length of first parameter
* From here on is optional, depending on the function being called, there can be up to 9 parameter pairs
* (ptr/value and length)
* The temp stack used 0,s as the path #, and 1,s + as the output buffer

start               leas      <-$21,s             reserve 33 bytes on stack
                    clr       ,s                  Clear optional path # is BYTE or INTEGER flag
                    ldd       <$21+PCount,s       $23 Get # of parameters
                    beq       L02F6               If 0, exit with parameter error
                    tsta                          If >255, exit with parameter error
                    bne       L02F6
                    ldd       [<$21+PrmPtr1,s]    $25 ??? Get value from first parm (optional path #)
                    ldx       <$21+PrmLen1,s      $27 Get length of 1st parm
                    leax      -1,x
                    beq       L02A3               If BYTE value, save path #
                    leax      -1,x
                    bne       L02B0               If not INTEGER value, no optional path, 1st parm is keyword
                    tfr       b,a                 If INTEGER value, save LSB as path #
L02A3               sta       ,s                  Save on stack
                    dec       <$21+PCount+1,s     $24 Dec # of parms (to skip path #)
                    ldx       <$21+PrmPtr2,s      $29 X=Ptr to function name we received
                    leau      <$21+PrmPtr3,s      $2D U=Ptr to (possible) 1st parm for function
                    bra       L02B8

* No optional path, set path to Std Out, and point X/U to function name and 1st parm for it
L02B0               inc       ,s                  No optional path # specified, set path to 1 (Std Out)
                    ldx       <$21+PrmPtr1,s      Point to function name
                    leau      <$21+PrmPtr2,s      Point to first parm of function
* Entry here: X=Ptr to function name passed from caller
*             U=Ptr to 1st parameter for function
L02B8               pshs      u,x                 Save 1st parm & function name ptrs
                    leau      >FuncTbl,pcr        Point to table of supported functions
L02BE               ldy       ,u++                Get ptr to subroutine
                    beq       L02F0               If $0000, exit with Unimplemented Routine Error (out of functions)
                    ldx       ,s                  Get ptr to function name we were sent
L02C5               lda       ,x+                 Get char from caller
                    eora      ,u+                 Force matching case and compare with table entry
                    anda      #$DF
                    beq       L02D5               Matched, skip ahead
                    leau      -1,u                Bump tbl ptr back one
L02CF               tst       ,u+                 Hi bit set on last char? ($FF check cheat)
                    bpl       L02CF               No, keep scanning till we find end of table entry text
                    bra       L02BE               Check next table entry

L02D5               tst       -1,u                Was hi bit set on matching char? (We hit end of function name?)
                    bpl       L02C5               No, check next char
* 6809/6309 - skip leas, change puls u below to puls u,x (faster, and we reload X anyways)
                    leas      2,s                 Yes, function found. Eat copy of ptr to function name we were sent
                    tfr       y,d                 Copy jump table offset to D
                    leay      >FuncTbl,pcr        Point to table of supported functions again
                    leay      d,y                 Add offset
                    puls      u                   Get original 1st parm ptr
                    leax      1,s                 Point to temp write buffer we are building

                    lda       #$1B                Start it with an ESCAPE code (most functions use this)
                    sta       ,x+
                    ldd       <$21+PCount,s       Get # of params again (including path (if present) & function name ptr
                    jmp       ,y                  Call function subroutine & return from there

L02F0               leas      4,s
                    ldb       #E$NoRout           Unimplemented Routine error
                    bra       L02F8

L02F6               ldb       #E$ParmEr           Parameter Error
L02F8               coma
                    leas      <$21,s
                    rts

* For all calls from table, entry is:
* Y=address of routine
* X=Output buffer ptr ($1B is preloaded)
* U=Ptr to 1st parameter for function
* D=# of parameters being passed (including optional path #, and function name ptr)

* ID
L02FD               os9       F$ID                Get process ID # into D
                    tfr       a,b
                    clra
                    std       [,u]                Save in caller's parameter 1 var
L0305               clrb                          No error, eat temp stack & return
                    leas      <$21,s
                    rts

* Title
L030A               ldy       ,u                  Get ptr to Parm 1 (Ptr to Window descriptor array)
                    ldx       4,u                 Get ptr to Parm 2 (Title - string var)
* 6809/6309 - shouldn't we make sure Parm length <=20?
                    bsr       L0332               Copy Title to Window descriptor array
                    ldd       [<$08,u]            Get minimum horizontal window size (Parm 3)
                    stb       <WN.XMIN,y          Save it in Window descriptor
                    ldd       [<$0C,u]            Get minimum vertical window size (Parm 4)
                    stb       <WN.YMIN,y          Save it in Window descriptor
                    ldd       [<$10,u]            Get # of menus we will have on menu bar
                    stb       <WN.NMNS,y          Save it in Window descriptor
                    ldd       #$C0C0              Sync bytes (WN.SYNC)
                    std       <WN.SYNC,y          Save it in Window descriptor
                    leax      <WN.SIZ,y           Point X to where first menu descriptor will go (after main window descriptor)
                    stx       <WN.BAR,y           Save as ptr to array of menu descriptors
                    bra       L0305               Return w/o error

* Copy string until high bit set ($FF marker), and change end in destination to NUL $00
L0332               pshs      y                   Save Y
L0334               lda       ,x+                 Copy string from X to Y until hi bit set on a byte ($FF marker)
                    sta       ,y+
                    bpl       L0334
* 6809/6309 - wouldn't clr -1,y be 1 cyc faster (since Y is being pulled immediately after?)
                    clr       ,-y                 Flag end of string with NUL in destination
                    puls      pc,y

* Menu
L033E               ldy       ,u                  Get ptr to Parm 1 (Ptr to Window descriptor array)
                    leay      <WN.SIZ,y           Point to start of array of menu descriptors
                    ldd       [<$04,u]            Get menu ID #
                    decb                          Base 0, only 8 bits
                    lda       #MN.SIZ             Calc offset to menu descriptor for menu ID #
                    mul
                    leay      d,y                 Point to the specific menu descriptor we are creating
                    ldx       8,u                 Get ptr to Menu title
* 6809/6309 - shouldn't we make sure Parm length <=15?
                    bsr       L0332               Copy it over (to MN.TTL)
                    ldd       [<$0C,u]            Get menu id # (1-255)
                    stb       MN.ID,y             Save it in menu descriptor
                    ldd       [<$10,u]            Get X size of pull down menu (in columns)
                    stb       <MN.XSIZ,y          Save it in menu descriptor
                    ldd       [<$14,u]            Get # of items in menu pull down
                    stb       <MN.NITS,y          Save it in menu descriptor
                    ldd       <$18,u              Get ptr to Menu item descriptor array
                    std       <MN.ITEMS,y         Save it in menu descriptor
                    ldd       [<$1C,u]            Get menu enabled/disabled flag
                    stb       <MN.ENBL,y          Save it in menu descriptor
                    bra       L0305

* Item
L0371               ldy       ,u                  Get ptr to Parm 1 (Ptr to Menu bar descriptor array)
                    ldd       [<$04,u]            Get menu ID #
                    decb                          Base 0
                    lda       #MI.SIZ             Multiply by 21 (size of menu item descriptor)
                    mul                           Calc offset to menu item we are creating
                    leay      d,y                 Point Y to menu item we are creating
                    ldx       8,u                 Get ptr to menu item text
* 6809/6309 - shouldn't we make sure Parm length <=15?
                    bsr       L0332               Copy it over (to MI.TTL)
                    ldd       [<$0C,u]            Get item enable/disable flag (0=disabled, 1=enabled)
                    stb       MI.ENBL,y           Save it in Menu item descriptor
                    lbra      L0305

* WNSET
L038A               ldy       [,u]                Get window type (framed, shadow, etc.)
                    ldx       4,u                 Get ptr to window descriptor array (for if framed window)
                    lda       ,s                  Get path
                    ldb       #SS.WnSet           Set up Multi-Vue style window
                    os9       I$SetStt
                    leas      <$21,s              Eat temp stack & return
                    rts

* GETSEL
L039A               lda       ,s                  Get path
                    ldb       #SS.MnSel           Call Multi-Vue menu handler
                    os9       I$GetStt
                    pshs      a                   Save menu ID # (which menu)
                    clra                          D=item number selected from menu (if valid)
                    std       [<$04,u]            Save back to caller
                    puls      b                   D=menu ID #
                    std       [,u]                Save back to caller
                    lbra      L0305

* MOUSE - 5 parameter version returns valid,fire,x,y
*         8 parameter version returns valid,fire,x,y,area,sx,xy
L03AE               cmpb      #5                  5 parameters?
                    beq       L03B8               Yes, go read mouse
                    cmpb      #8                  8 parameters?
                    lbne      L02F6               No, exit with Parameter Error
L03B8               lda       ,s                  Get path #
                    leas      <-$20,s             Make 32 byte buffer on stack for Mouse packet
                    leax      ,s                  Point to buffer to receive mouse packet
                    pshs      b                   Save # of parms
                    ldb       #SS.Mouse           Read Mouse packet call
                    ldy       #$0000              Auto selection of mouse side
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
L0402               ldx       [,u]                Get signal # caller wants to send on mouse button press
                    bne       L0409               There is one, use it in SetStt call
                    ldx       #$0001              0=sleep until button pushed, use signal code 1
L0409               lda       ,s                  Get path
                    ldb       #SS.MsSig           Set up mouse button signal
                    os9       I$SetStt
                    bcs       L041A               If error, eat stack and return (NOTE: could be bcs L043B, faster)
                    leax      -1,x                Bump signal code down by 1
                    bne       L0419               Legit code, return w/o error
                    os9       F$Sleep             X=0, Sleep indefinitely (until signal received)
L0419               clrb                          No error, eat temp stack & return
L041A               bra       L043B

* TONE command
L041C               cmpb      #4                  4 parameters?
                    lbne      L02F6               No, exit with Parameter Error
* 6809/6309 - can't we ldy [,u] to replace next two lines?
                    ldy       [,u]                Get frequency (0-4095)
*         ldd   [,u]           Get frequency (0-4095)
*         tfr   d,y            Move to Y
                    ldd       [<$04,u]            Get duration (1/60th second count) 0-255
                    pshs      b                   Save it (only 8 bit)
                    ldd       [<$08,u]            Get volume (amplitude) (0-63)
                    tfr       b,a                 Move to high byte
                    puls      b                   Get duration back
                    tfr       d,x                 X is now set up for SS.Tone
                    lda       ,s                  Get path
                    ldb       #SS.Tone            Play tone
                    os9       I$SetStt
L043B               leas      <$21,s              Eat temp stack & return
                    rts

* WINFO
L043F               cmpb      #7                  7 parameters?
                    lbne      L02F6               No, exit with Parameter Error
                    lda       ,s                  Get path
                    ldb       #SS.ScTyp           Get screen type system call
                    os9       I$GetStt
                    bcs       L0479               Error, eat temp stack & exit
                    tfr       a,b                 D=screen type
                    clra
                    std       [,u]                Save to caller
                    lda       ,s                  Get path again
                    ldb       #SS.ScSiz           Get screen size GetStat call
                    os9       I$GetStt
                    bcs       L0479               Error, eat temp stack & exit
                    stx       [<$04,u]            Save # of columns in current working area
                    sty       [<$08,u]            Save # of rows in current working area
                    ldb       #SS.FBRgs           Get foreground,background,border color GetStat call
                    os9       I$GetStt
                    bcs       L0479               Error, eat temp stack & exit
                    pshs      a                   Save foreground color on stack
                    clra                          D=background color
                    std       [<$10,u]            Save to caller
                    puls      b                   D=foreground color
                    std       [<$0C,u]            Save to caller
                    stx       [<$14,u]            Save border color to caller
L0478               clrb                          No error, eat temp stack, & return
L0479               leas      <$21,s
                    rts

* SETMOUSE
L047D               ldd       [<$04,u]            Get timeout value from caller
                    pshs      b                   Save it (only 8 bits)
                    ldd       [,u]                mouse scan rate (# of 1/60th sec ticks between reads)
                    tfr       b,a                 Move to high byte
                    puls      b                   Merge with timeout
                    tfr       d,x                 Mouse sample rate (high byte) and Mouse timeout (low byte)
                    ldy       [<$08,u]            Get auto-follow setting from caller
                    lda       ,s                  Get path
                    ldb       #SS.Mouse           Set mouse parameters
                    os9       I$SetStt
                    bcc       L0478               No error, clear B, eat stack & return
                    bra       L0479               Error, eat stack & return

* SBAR
L0499               ldx       [,u]                Get X scroll bar position from caller
                    ldy       [<$04,u]            Get Y scroll bar position from caller
                    lda       ,s                  Get path
                    ldb       #SS.SBar            Redraw scroll bars
                    os9       I$SetStt
L04A6               bra       L0479               Eat stack & return

* UMBAR
L04A8               lda       ,s                  Get path
                    ldb       #SS.UMBar           Update menu bar
                    os9       I$SetStt
                    bra       L04A6

* DWSet
L04B1               lda       #$20                DWSet code
                    pshs      x,d                 Save output string mem ptr, # of parms & display code
                    ldx       2,u                 Get size of 1st parameter (to see if optional path #)
                    cmpx      #2                  INTEGER?
                    bne       L04C0               No, skip ahead
                    ldd       [,u]                Yes, get INTEGER value
                    bra       L04C2

L04C0               lda       [,u]                Get BYTE value from parameter 1
L04C2               puls      x,d                 Restore output mem string ptr, # of parms & display code (leaves CC alone)
                    ble       L04EF
                    cmpb      #9                  9 parameters?
                    bne       L0528               No, skip ahead
                    sta       ,x+                 Save code to output stream
                    lbra      L0920               Append next 8 parameters to output stream (either byte or integer) & write it out

* Fill
L04CF               lda       #$4F                Fill code
                    cmpb      #1                  1 parameter?
                    beq       L04E0               Yes, just append Fill code & write buffer out
                    cmpb      #3                  3 parameters (x,y)?
                    bne       L0528               No, exit with Parameter Error
                    lbsr      L05F7               Yes, append SetDPtr with X,Y coords from caller
                    ldb       #$1B                ESC code
                    stb       ,x+                 Save in output buffer
L04E0               bra       L04E8               Append fill code & write it out

* Select
L04E2               lda       #$21                Select code
L04E4               cmpb      #1                  1 parameter?
                    bne       L0528               No, exit with Parameter Error
L04E8               sta       ,x+                 Append command code, and write output buffer out
                    lbra      L0901

* OWSet
L04ED               lda       #$22                Overlay Window Set code
L04EF               cmpb      #8                  8 parameters?
                    bne       L0528               No, exit with Parameter Error
                    sta       ,x+                 Append OWSet code to output buffer
                    lbra      L0922               Append the next 7 parameters (BYTE or INTEGER) to the output buffer & write it out

* OWEnd
L04F8               lda       #$23                Overlay Window End code
                    bra       L04E4               Write it out or parameter error

* DWEnd
L04FC               lda       #$24                Device Window End code
                    bra       L04E4               Write it out or parameter error

* CWArea
L0500               lda       #$25                Change Working Area code
                    cmpb      #5                  5 parameters
                    bne       L0528               No, exit with Parameter Error
                    sta       ,x+                 Append CWArea code to output buffer
                    lbra      L0928               Append the next 4 parameters (BYTE or INTEGER) to the output buffer & write it out

* DefBuff
L050B               lda       #$29                Define Buffer code
                    cmpb      #4                  4 parameters?
                    bne       L0528               No, exit with Parameter Error
                    sta       ,x+                 Yes, append Define Buffer code to output buffer
                    lbsr      L0932               Append next parameter to output buffer (BYTE or INTEGER) - group #
                    lbsr      L0932               Append next parameter to output buffer (BYTE or INTEGER) - buffer #
                    lbra      L08FF               Append 16 bit length to output stream & write it out

* GCSet
L051C               lda       #$39                Graphic Cursor Set code
                    bra       L0526               Process

* Font
L0520               lda       #$3A                Font code
                    bra       L0526               Process

* KillBuff
L0524               lda       #$2A                Kill Buffer code
L0526               cmpb      #3                  3 parameters?
L0528               lbne      L02F6               No, exit with Parameter Error
                    sta       ,x+                 Yes, append code
                    lbra      L092C               Append 2 BYTE/INTEGER parameters

* GPLoad
L0531               lda       #$2B                Get/Put Buffer Load code
                    cmpb      #7                  7 parameters?
                    bne       L0528               No, exit with Parameter Error
                    sta       ,x+                 Yes, append code
                    lbsr      L0932               Append BYTE/INTEGER parameter to output buffer - Group #
                    lbsr      L0932               Append BYTE/INTEGER parameter to output buffer - Buffer #
                    lbsr      L0932               Append BYTE/INTEGER parameter to output buffer - Type
                    lbra      L08FB               Append 3 16 bit parameters (X dimension, Y dimension, size in bytes)

* Get
L0545               lda       #$2C                GetBlk code
                    cmpb      #7                  7 parameters?
                    bne       L0528               No, exit with Parameter Error
                    sta       ,x+                 Yes, append code
                    lbsr      L0932               Append BYTE/INTEGER parameter to output buffer - Group #
                    lbsr      L0932               Append BYTE/INTEGER parameter to output buffer - Buffer #
                    lbra      L08F9               Append 4 16 bit parameters (startx, starty,sizex,sizey)

* Put
L0556               lda       #$2D                PutBlk code
                    cmpb      #5                  5 parameters?
                    bne       L0528               No, exit with Parameter Error
                    sta       ,x+                 Yes, append code
                    lbsr      L0932               Append BYTE/INTEGER parameter to output buffer - Group #
                    lbsr      L0932               Append BYTE/INTEGER parameter to output buffer - Buffer #
                    lbra      L08FD               Append 2 16 bit parameters (startx,starty)

* Pattern
L0567               lda       #$2E                PSet code
                    bra       L0526               append 3 parameters or exit with Parameter error

* Logic
L056B               lda       #$2F                LSet code
                    cmpb      #2                  2 parameters?
                    bne       L0528               No, exit with parameter error
                    sta       ,x+                 Append code
                    pshs      y,x                 Save regs
                    leay      >L0268,pcr          Point to OFF,AND,OR,XOR table
L0579               ldx       ,u                  Get parameter ptr for string caller sent
                    lbsr      L0892               Go find match, and get code to send for that string
                    puls      y,x                 Restore regs
                    bcs       L0528               No match found in table, exit with Parameter Error
                    lbra      L04E8               Append code & write out

* Palette
L0585               lda       #$31                Palette code
                    bra       L0526               append 3 parameters or exit with Parameter error

* Color
L0589               cmpb      #2                  2 parameters? (foreground only, no path)
                    beq       L0597               Yes, do that
                    cmpb      #3                  3 parameters? (foreground/background only)?
                    beq       L059B               Yes, do that
                    cmpb      #4                  4 parameters? (foreground/background/border)?
                    bne       L0528               No, exit with Parameter Error
                    bra       L05A5               Yes, send all 3 color setting sequences out

* Build FColor sequence & write it out
L0597               bsr       L05B6               Build Foreground color sequence
                    bra       L05B3               Write it out

*  Build FColor and BColor command sequences & write them out
L059B               bsr       L05B6               Build Foreground color sequence first
                    ldb       #$1B                Add ESC code
                    stb       ,x+
                    bsr       L05BA               Build Background color sequence
                    bra       L05B3               Write it out

* Build FColor, BColor, Border
L05A5               bsr       L05B6               Append Foreground color sequence
                    ldb       #$1B                Add ESC to output buffer
                    stb       ,x+
                    bsr       L05BA               Append Background color sequence
                    ldb       #$1B                Add ESC to output buffer
                    stb       ,x+
                    bsr       L05CA               Append Border color sequence
L05B3               lbra      L0901               Write output buffer

L05B6               lda       #$32                Append FColor code
                    bra       L05BC               and BYTE/INTEGER parameter from caller

* Build BColor
L05BA               lda       #$33                Append Background Color code
L05BC               sta       ,x+
                    lbra      L0932               Append background color (BYTE/INTEGER) from caller

* Border
L05C1               cmpb      #2                  2 parameters?
                    bne       L062E               No, exit with Parameter Error
                    bsr       L05CA               Add Border color sequence
                    lbra      L0901               Write output buffer

L05CA               lda       #$34                Append Border color
                    bra       L05BC

* ScaleSw
L05CE               lda       #$35                ScaleSw code
L05D0               cmpb      #2                  2 parameters?
                    bne       L062E               No, exit with Parameter error
                    sta       ,x+                 Append code to output buffer
                    pshs      y,x                 Save regs
                    leay      >L027C,pcr          Point to OFF/ON table
                    bra       L0579               Append proper code depending on caller's ON/OFF parameter, or error

* DWProtSw
L05DE               lda       #$36                Device Window Protect Switch code
                    bra       L05D0               Get switch value & write out, or return with error

* TCharSw
L05E2               lda       #$3C                Transparent Character Switch code
                    bra       L05D0               Get switch value & write out, or return with error

* BoldSw
L05E6               lda       #$3D                Bold Switch code
                    bra       L05D0               Get switch value & write out, or return with error

* PropSw
L05EA               lda       #$3F                Proportional character Switch code
                    bra       L05D0               Get switch value & write out, or return with error

* SetDPtr
L05EE               cmpb      #3                  3 parameters?
                    bne       L062E               No, exit with Parameter Error
                    bsr       L05F7               Yes, do SetDPTr with x,y coords
                    lbra      L0901               Write sequence out

* Entry: U=ptr to current parameter ptr
*        X=ptr to current position in output buffer
* Do SetDPtr (Set Draw Pointer) to x,y coord specified by next two parameters
L05F7               pshs      a                   Save A (original display code)
                    lda       #$40                Append display code for SetDPPtr
                    sta       ,x+
                    lbsr      L08CE               Append X coord
                    lbsr      L08CE               Append Y coord
                    puls      pc,a                Restore original display code & return

* Point
L0605               lda       #$42                Point code
                    cmpb      #3                  3 parameters?
                    bne       L062E               No, exit with Parameter Error
                    bra       L061D               Append code, and two 16 bit parameters for X,Y


* LineM (Line and Move)
L060D               lda       #$46                LineM code
L060F               cmpb      #3                  3 parameters?
                    beq       L061D               Yes, process (just end point)
                    cmpb      #5                  5 parameters?
                    bne       L062E               No, exit with Parameter Error
                    bsr       L05F7               Yes, do SetDPtr (Set Draw Pointer) first and then draw line
                    ldb       #$1B                ESC code
                    stb       ,x+                 Append to output buffer
L061D               sta       ,x+                 Save code in output buffer
                    lbra      L08FD               Append two 16 bit parameters from caller (X endpoint, Y endpoint)

* Box
L0622               lda       #$48                Box code
                    bra       L060F               Process

* Bar
L0626               lda       #$4A                Bar code (filled box)
                    bra       L060F               Process

* PutGC
L062A               lda       #$4E                Put Graphics Cursor code
                    cmpb      #3                  3 parameters?
L062E               lbne      L02F6               No, exit with Parameter error
                    bra       L061D               Yes, add X,Y coords from caller & write out


* FCircle
FCircle             lda       #$53                FCircle code
                    fcb       $8c                 skip 2 bytes (CMPX)
* Circle
L0634               lda       #$50                Circle code
                    cmpb      #2                  2 parameters? (Just radius)
                    beq       L0644               Yes, skip ahead
                    cmpb      #4                  4 parameters (X,Y center coords)?
                    bne       L062E               No, exit with Parameter Error
                    bsr       L05F7               Yes, do SetDPtr first
                    ldb       #$1B                ESC
                    stb       ,x+                 Append to output buffer
L0644               sta       ,x+                 Add code to output buffer
                    lbra      L08FF               Append one 16 bit value (radius) from caller to output buffer & write out

* Draw - This adds new start x,y coords not mentioned in the manual
* So now RUN Gfx2([#path][,start X,start Y],draw string)
* Also - I think the commas between commands (not coords) are optional. Test.
L0649               cmpb      #2                  2 parameters?
                    beq       L0663               Yes, get draw string from caller and build output buffer based on it
                    cmpb      #4                  4 parameters (start x,y coord added)?
                    bne       L062E               No, exit with Parameter Error
                    pshs      u,x,d               Save regs
                    ldd       #$1B40              Add esc sequence for SetDPPtr
                    std       ,x++
                    lbsr      L08DA               Append 16 bit X start coord from caller
                    lbsr      L08DA               Append 16 bit Y start coord from caller
                    lbsr      L07CD               Send SetDPPtr sequence, and reset output buffer ptr to beginning
                    bra       L0665               Now process draw string

* 6809/6309 - may be able to move some draw routine stuff around to make more short branches?
L0663               pshs      u,x,d               Save regs (D is just to reserve 2 bytes on the stack-contents not preserved)
L0665               ldu       ,u                  Get ptr to string data from caller
                    clr       1,s                 Clear 2 bytes on stack (allocated by D in the PSHS above)
                    clr       ,s                  (Angle # 0-3 from 'A'xis command. Defaults to 0)
L066B               lda       ,u+                 Get byte from draw string
                    cmpa      #',                 comma?
                    beq       L066B               Yes, skip to next character
                    cmpa      #$FF                End of string?
                    beq       L069B               Yes, exit
                    anda      #$DF                Force to uppercase
                    cmpa      #'A                 Axis rotate?
                    beq       L06A3               Yes, process
                    cmpa      #'B                 Blank line (move gfx draw ptr w/o drawing)?
                    beq       L06AA               Yes, process
                    cmpa      #'U                 Relative vector draw?
                    beq       L06BF               Yes, process
                    cmpa      #'N                 North (up) draw?
                    beq       L06C6               Yes, process
                    cmpa      #'S                 South (down) draw?
                    beq       L06FE               Yes, process
                    cmpa      #'E                 East (right) draw?
                    lbeq      L072C               Yes, process
                    cmpa      #'W                 West (left) draw?
                    lbeq      L0735               Yes, process
L0697               leas      6,s                 Eat 2ndary temp stack
                    bra       L062E               Exit with Parameter Error

L069B               leas      2,s                 Eat temp 16 bit var
                    puls      u,x                 Restore regs
                    leas      <$21,s              Eat temp stack & return
                    rts

* 'A'xis rotate
L06A3               lbsr      L0745               Get signed parameter value into D
                    std       ,s                  Save value as angle 0-3
                    bra       L066B               Continue processing draw string

* 'B'lank line move (moves cursor, doesn't draw). Offsets draw ptr by values specified
L06AA               ldd       #$1B41              RSetDPtr (Relative Set Draw Ptr)
                    std       ,x++                Append to temp buffer
L06AF               lbsr      L0745               Get signed parameter value into D
                    std       ,x++                Save signed X offset in output buffer
                    lda       ,u+                 Get next byte from DRAW string
                    cmpa      #',                 Comma?
                    bne       L0697               No, since no Y coord offset, exit with Parameter Error
                    lbsr      L0745               Get signed Y offset into D
                    bra       L06E8               Append to output buffer

* 'U' draw relative vector w/o updating draw ptr position
L06BF               ldd       #$1B45              RLine (Relative Draw Line)
                    std       ,x++                Append to output buffer
                    bra       L06AF               Process/append X,Y offsets

* 'N' North (up) draw
L06C6               ldd       #$1B47              RLineM (Relative Draw Line and Move)
                    std       ,x++                Append to output buffer
                    lda       ,u                  Get next byte from draw string
                    anda      #$DF                Force case
                    cmpa      #'E                 East (right)?
                    beq       L06DF               Yes, NE so skip ahead (up and to right)
                    cmpa      #'W                 West (left)?
                    beq       L06F3               Yes, NW so skip ahead (up and to left)
                    clra                          Straight up, so X offset=0
                    clrb
                    std       ,x++                Append to output buffer
                    bsr       L0745               Get signed Y offset caller specified
                    bra       L06E5               Use negative value of that as Y offset

* 'NE' (northeast, up and right)
L06DF               leau      1,u                 Bump up source string ptr
                    bsr       L0745               Get signed X offset caller specified
                    std       ,x++                Append X offset to output buffer
L06E5               lbsr      L07C8               NEGD
L06E8               std       ,x++                Append Y offset to output buffer
L06EA               lbsr      L078E               Adjust X,Y coords based on current ANGLE setting (if <>0)
                    lbsr      L07CD               Write output buffer
                    lbra      L066B               Process next DRAW command sequence

* 'NW' (northwest, up and left)
L06F3               leau      1,u                 Bump up source string ptr
                    bsr       L0745               Get signed X offset caller specified
                    lbsr      L07C8               NEGD
L06FA               std       ,x++                Append X offset to output buffer
                    bra       L06E8               Append same value as Y offset to output buffer, write it out & continue

* S (south, down)
L06FE               ldd       #$1B47              RLineM (Relative Draw Line and Move)
                    std       ,x++                Append to output buffer
                    lda       ,u                  Get next char from draw string
                    anda      #$DF                Force case
                    cmpa      #'E                 East (Right?)
                    beq       L0717               Yes, SE so skip ahead (down and right)
                    cmpa      #'W                 West (Left?)
                    beq       L071D               Yes, SW so skip ahead (down and left)
                    clra                          X offset=0
                    clrb
                    std       ,x++                Append to output buffer
                    bsr       L0745               Get signed Y offset caller specified
                    bra       L06E8               Append to output buffer, adjust for ANGLE (if needed), write it out

L0717               leau      1,u                 Bump up source string ptr
                    bsr       L0745               Get signed offset from caller
                    bra       L06FA               Append as both X & Y offsets

* SW (southwest, down and left)
L071D               leau      1,u                 Bump up source string ptr
                    bsr       L0745               Get signed offset caller specified
                    std       2,x                 Save as Y offset
                    lbsr      L07C8               NEGD
* 6809/6309 - change next two lines to std ,x/leax 4,x (same size, saves 2 or 1 cycles)
*         std   ,x++           Save as X offset
*         leax  2,x            Bump up output buffer ptr
                    std       ,x                  Save as X offset
                    leax      4,x                 Bump up output buffer ptr
                    bra       L06EA

* E (East, right)
L072C               ldd       #$1B47              RLineM (Relative Draw Line and Move)
                    std       ,x++                Append to output buffer
                    bsr       L0745
                    bra       L073F

* W (West, left)
L0735               ldd       #$1B47              RLineM (Relative Draw Line and Move)
                    std       ,x++                Append to output buffer
                    bsr       L0745               Get signed offset caller specified
                    lbsr      L07C8               NEGD
L073F               std       ,x++                Append X offset to output buffer
                    clra                          Y offset=0
                    clrb
                    bra       L06E8               Append to output buffer and write it out

* Process parameter for a specific DRAW command. Gets numeric string, converts to signed
*   16 bit #. Stops on first non-numeric character encountered (decimal only)
* Entry: U=Ptr to start of parameter section of current DRAW string command
* Exit:  D=signed binary version of parameter
L0745               clra                          D=0 (used for which ASCII digit we are processing -1's, 10's, 100's)
                    clrb
                    pshs      u,d                 Save that & U
                    ldb       ,u                  Get 1st byte of DRAW command parameter
                    cmpb      #'-                 Negative sign?
                    bne       L0751               No, use current byte as numeric data byte
                    leau      1,u                 Yes, bump source ptr up by 1
L0751               clra                          A=0
                    ldb       ,u                  Get parameter byte (String)
                    subb      #'0                 Subtract ASCII to make binary value
                    bcs       L0776               If wrapped negative, skip ahead
                    cmpb      #9                  Outside of 0-9
                    bhi       L0776               Yes, skip ahead
                    pshs      d                   D=numeric value of single char parameter
                    ldd       2,s                 Get original D (inited to 0)
                    lslb                          Multiply by 8
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    pshs      d                   Save *8 result on stack
                    ldd       4,s                 Get original D (inited to 0)
                    lslb                          Multiply by 2
                    rola
                    addd      ,s++                Add *8 value
                    addd      ,s++                Add original numeric value
                    std       ,s                  Save over scratch var
                    leau      1,u                 Bump up source string ptr
                    bra       L0751               Check next char

* parm char from draw string is not '0'-'9'
L0776               cmpu      2,s                 Are we at beginning of current draw string command's parameters?
                    beq       L0789               Yes, no parameters, so eat temp stack & exit with Parameter Error
                    lda       [<$02,s]            Get first char from current draw string command's parameters again
                    cmpa      #'-                 Was it a dash (negative)?
                    puls      d                   Get current binary version of number string we processed
                    bne       L0786               Not negative, skip ahead
                    bsr       L07C8               Yes, make binary version negative
L0786               leas      2,s                 Eat start string ptr & return
                    rts

L0789               leas      $C,s                Eat temp stack, return with Parameter Error
                    lbra      L02F6

* Adjust draw command based on Axis angle (0=no rotate/no changes)
* 1,2,3 make adjustments. All other values leave coords alone
L078E               ldd       2,s                 Get Axis angle
                    beq       L07AC               If 0 (normal), return
                    tsta                          If >255, exit
                    bne       L07AC
                    decb                          1 (90 degrees)?
                    beq       L07AD               Yes, skip ahead
                    decb                          2 (180 degrees)?
                    beq       L07BC               Yes, skip ahead
                    decb                          3 (270 degrees)?
                    bne       L07AC               No, return
* 270 degree rotate
                    ldd       -4,x                Get original X value from output buffer
                    bsr       L07C8               NEGate it
                    pshs      d                   Save on stack
                    ldd       -2,x                Get original Y value from output buffer
                    std       -4,x                Save overtop original X
                    puls      d                   Get negated X back
L07AA               std       -2,x                Save overtop original Y & return
L07AC               rts

* 90 degree rotate
L07AD               ldd       -2,x                Get original X value from output buffer
                    bsr       L07C8               NEGate it
                    pshs      d                   Save on stack
                    ldd       -4,x                Get original y coord
                    std       -2,x                Save over original X coord
                    puls      d                   Get negated X value back
                    std       -4,x                Save over original Y coord
                    rts

* 180 degree rotate
L07BC               ldd       -4,x                Get original X coord
                    bsr       L07C8               Negate it
                    std       -4,x                Save overtop original X coord
                    ldd       -2,x                Get original Y coord
                    bsr       L07C8               Negate it
                    bra       L07AA               Save overtop original Y & return

* NegD
L07C8               nega                          6309 - NEGD for next three lines
                    negb
                    sbca      #$00
                    rts

* Write output buffer based on current output buffer ptr
* Entry: X=current output buffer position ptr
*        2,s = output buffer start ptr
L07CD               pshs      y,x                 Preserve regs
                    tfr       x,d                 Move current position in output buffer ptr to D
                    subd      8,s                 Calc size of string to write
                    tfr       d,y                 Move for I$Write
                    ldx       8,s                 Get ptr to start of output buffer
                    lda       $C,s                Get path
                    os9       I$Write             Write it out
                    puls      y,x                 Restore regs
                    ldx       4,s                 Get start of output buffer ptr back & return
                    rts

* FEllipse
FEllipse            lda       #$54                FEllipse code
                    fcb       $8c                 Skip 2 bytes (CMPX)
* Ellipse
L07E1               lda       #$51                Ellipse code
                    lbra      L060F               Process for 3 or 5 parameters

* Arc
L07E6               lda       #$52                Arc code
                    cmpb      #7                  7 parameters?
                    beq       L07F7               Yes, skip setting center coords
                    cmpb      #9                  9 parameters?
                    bne       L0804               No, exit with Parameter Error
                    lbsr      L05F7               Yes, append SetDPtr with callers center X,Y coord to output buffer
                    ldb       #$1B                Append ESC code
                    stb       ,x+
L07F7               sta       ,x+                 Append ARC code
                    lbra      L08F5               Process remaining 6 16 bit parameters (X radius, Y radius, startx, starty, endx,endy)

* CurHome
L07FC               lda       #$01                Home Cursor code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

* CurXY
L0800               lda       #$02                CurXY code
                    cmpb      #3                  3 parameters?
L0804               lbne      L02F6               No, exit with Parameter Error
                    sta       -1,x                Yes, overwrite original ESC code in output buffer
                    bsr       L0811               Append X coord from caller (with $20 offset)
                    bsr       L0811               Append Y coord from caller (with $20 offset)
                    lbra      L0901               Write output buffer

* Process text coord from caller. Handles BYTE or INTEGER, and adds +$20 offset needed for CurXY
L0811               pshs      y,d                 Save regs
                    ldd       [,u++]              Get coord from caller (INTEGER)
                    adda      #$20                Offset for CurXY
                    sta       ,x+                 Save in output buffer
                    pulu      y                   Get size of coord variable from caller
                    leay      -1,y                BYTE type?
                    beq       L0829               Yes, we are done, restore regs & exit
                    leay      -1,y                INTEGER type?
                    lbne      L091B               No, eat temp stack, return with Parameter error
                    addb      #$20                Replace coord in output buffer with LSB of INTEGER parameter
                    stb       -1,x
L0829               puls      pc,y,d

* ErLine
L082B               lda       #$03                Erase Line code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

* ErEOLine
L082F               lda       #$04                Erase to End of Line code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

* CurOff
L0833               lda       #5                  Cursor on/off code
                    sta       -1,x                Save over original ESC
                    lda       #$20                Off value
                    bra       L087B               Append to output buffer, write it out

* CurOn
L083B               lda       #5                  Cursor on/off code
                    sta       -1,x                Save over original ESC
                    lda       #$21                On value
                    bra       L087B               Append to output buffer, write it out

* CurRgt
L0843               lda       #6                  Cursor Right code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

* Bell
L0847               lda       #7                  Bell code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

* CurLft
L084B               lda       #8                  Cursor Left code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

* CurUp
L084F               lda       #9                  Cursor Right code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

* CurDwn
L0853               lda       #$A                 Cursor Down code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

* ErEOWndw
L0857               lda       #$B                 Erase to end of Window code
L0859               leax      -1,x                Bump back output buffer ptr
                    bra       L087B               Overwrite default ESC code in output buffer with new code, write it out

* Clear
L085D               lda       #$C                 Clear window code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

* CrRtn
L0861               lda       #$D                 Carriage return code
                    bra       L0859               Overwrite default ESC code in output buffer with new code, write it out

* ReVOn
L0865               lda       #$20                Reverse video ON sub-code for $1F code
                    bra       L0873               Append both to output buffer & write out

* ReVOff
L0869               lda       #$21                Reverse video OFF sub-code for $1F code
                    bra       L0873               Append both to output buffer & write out

* UndlnOn
L086D               lda       #$22                Underline ON sub-code for $1F code
                    bra       L0873               Append both to output buffer & write out

* UndlnOff
L0871               lda       #$23                Underline OFF sub-code for $1F code
L0873               pshs      a                   Save sub-code
                    lda       #$1F                Put $1F code overtop original ESC first
                    sta       -1,x
                    puls      a                   Get sub-code back
L087B               lbra      L04E4               Append to output buffer & write out

* BlnkOn
L087E               lda       #$24                Blink ON sub-code for $1F code
                    bra       L0873               Append both to output buffer & write out

* BlnkOff
L0882               lda       #$25                Blink OFF sub-code for $1F code
                    bra       L0873               Append both to output buffer & write out

* InsLin
L0886               lda       #$30                Insert Line sub-code for $1F code
                    bra       L0873               Append both to output buffer & write out

* DelLin
L088A               lda       #$31                Delete Line sub-code for $1FG code
                    bra       L0873               Append both to output buffer & write out

* DefCol
L088E               lda       #$30                Default color code
                    bra       L087B               Append to output buffer & write out

* Compare string from caller to string in table (used for ON, OFF, etc) case insensitive
* Entry: X=ptr to string from caller
*        Y=ptr in table for strings we are checking against
* Exit: Carry clear, A=code to send that corresponds to table string entry
*       or carry set if no match in table
L0892               pshs      x                   Save ptr to start of string from caller
L0894               lda       ,y+                 Get char from table
                    beq       L08BF               NUL (end of table), exit with error
L0898               eora      ,x+                 Force case
                    anda      #$DF
                    bne       L08AE               Different, skip to next entry
                    tst       ,y                  Hi bit ($FF cheat) set on matching character from table (ie end of name?)
                    bmi       L08AA               Yes, check if end of caller's string
                    tst       ,x                  No, was hi bit ($FF cheat) set on char from caller?
                    bmi       L08AE               Yes, skip to next entry
                    lda       ,y+                 No, matches so far, check next character
                    bra       L0898

L08AA               tst       ,x                  End of table string, is it end of caller string too?
                    bmi       L08BA               Yes, found match, skip ahead
L08AE               leay      -1,y                No, bump tbl ptr back 1
L08B0               tst       ,y+                 Skip to end of table string
                    bpl       L08B0
                    ldx       ,s                  Get ptr to start of string from caller again
                    leay      1,y                 Bump tbl ptr to next entry
                    bra       L0894

L08BA               clra                          clear carry
                    lda       1,y                 Get table byte entry
                    bra       L08C0

L08BF               coma                          No match found, exit with carry set
L08C0               puls      pc,x

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer
L08C2               pshs      y,d                 Save regs
                    bsr       L08E8               Append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6               If 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y                2 byte value (INTEGER) from caller?
                    bne       L091B               Not BYTE or INTEGER, exit with Parameter Error
                    bra       L08E4               If INTEGER, append to output buffer and return

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer (and eat 9 byte temp stack)
L08CE               pshs      y,d                 Save regs
                    bsr       L08E8               Append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6               If 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y                2 byte value (INTEGER) from caller?
                    bne       L0919               Not BYTE or INTEGER, exit with Parameter Error (& eat 9 byte temp stack)
                    bra       L08E4               If INTEGER, append to output buffer & return

* Append BYTE or INTEGER value from caller as 16 bit value to output buffer (and eat 15 byte temp stack)
L08DA               pshs      y,d                 Save regs
                    bsr       L08E8               Append value from caller (unsigned, 16 bit value from callers 8 or 16 bit)
                    beq       L08E6               If 8 bit value was expanded to 16 bit, we are done, return
                    leay      -1,y                2 byte value (INTEGER) from caller?
                    bne       L0917               Not BYTE or INTEGER, exit with Parameter Error (& eat 15 byte temp stack)
L08E4               std       ,x++                Append value to output buffer
L08E6               puls      pc,y,d

* Append 16 bit value from caller to output buffer. Original from caller is unsigned, can be BYTE or INTEGER
L08E8               ldd       [,u++]              Get 16 bit value from caller (INTEGER)
                    pulu      y                   Get size of variable form caller
                    leay      -1,y                INTEGER?
                    bne       L08F4               Yes, return
                    sta       1,x                 No, BYTE, save BYTE as 16 bit value (note: NOT SIGNED)
                    clr       ,x++
L08F4               rts

L08F5               bsr       L08C2               Append 16 bit value to output buffer (6 16 bit parameters)
                    bsr       L08C2               Append 16 bit value to output buffer
L08F9               bsr       L08C2               Append 16 bit value to output buffer (4 16 bit parameters)
L08FB               bsr       L08C2               Append 16 bit value to output buffer (3 16 bit parameters)
L08FD               bsr       L08C2               Append 16 bit value to output buffer (2 16 bit parameters)
L08FF               bsr       L08C2               Append 16 bit value to output buffer (1 16 bit parameter)
L0901               bsr       L0907               Write output buffer out
                    leas      <$21,s              Eat main temp stack & return
                    rts

* Write output buffer out
L0907               tfr       x,d
                    leax      3,s                 Point to buffer to write out
                    pshs      x                   Save start of buffer
                    subd      ,s++                Subtract end of buffer to get length
                    tfr       d,y                 Move length to Y for Write
                    lda       2,s                 Get path, write out buffer
                    os9       I$Write
                    rts

L0917               leas      6,s                 Eat extra temp stack (15 bytes)
L0919               leas      3,s                 Eat extra temp stack (9 bytes)
L091B               leas      6,s                 Eat extra temp stack  (6 bytes)
                    lbra      L02F6               Exit with Parameter Error

L0920               bsr       L0932               Append BYTE or INTEGER parameter to output stream (append 8 parameters)
L0922               bsr       L0932               Append BYTE or INTEGER parameter to output stream (append 7 parameters)
                    bsr       L0932               Append BYTE or INTEGER parameter to output stream (append 6 parameters)
                    bsr       L0932               Append BYTE or INTEGER parameter to output stream (append 5 parameters)
L0928               bsr       L0932               Append BYTE or INTEGER parameter to output stream (append 4 parameters)
                    bsr       L0932               Append BYTE or INTEGER parameter to output stream (append 3 parameters)
L092C               bsr       L0932               Append BYTE or INTEGER parameter to output stream (append 2 parameters)
                    bsr       L0932               Append BYTE or INTEGER parameter to output stream (append 1 parameter)
                    bra       L0901               Write the output buffer out

* Append next parameter value to output stream (either INTEGER or BYTE)
* Entry: U=ptr to current parameter ptr and size
*        X=Ptr to current position in output buffer
L0932               pshs      y,d                 Save regs
                    ldd       [,u++]              Get next parameter value (BYTE)
                    sta       ,x+                 Append to output stream
                    pulu      y                   Y=parm size & bump U to next parameter
                    leay      -1,y
                    beq       L0944               If it was a BYTE, we are done
                    leay      -1,y
                    bne       L091B               Not an INTEGER either, return with Parameter Error
                    stb       -1,x                Save LSB overtop original one (which would have been 0 to get here)
L0944               puls      pc,y,d

                    emod
eom                 equ       *
                    end
