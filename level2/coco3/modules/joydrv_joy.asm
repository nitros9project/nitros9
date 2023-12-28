* Left to do for Beta 6:
* 1) Try using 1st button held down while 2nd button released to control window
*    switching direction (this will work across graphics and hardware text screens,
*    unlike current mouse X position method)  CURRENTLY IN TESTING BY USERS
* 2) Software based high res mouse routine from Sock, Robert, Nick to replace
*    existing high res interface; eliminating the need for high res interface
*    at all, and also meaning that running a program using the same joystick side
*    as the mouse is set up is possible
********************************************************************
* JoyDrv - Joystick Driver for CoCo 3 Hi-Res Mouse
*
* $Id$
* Some notes:
*   - the J$JyBtn co-module call returns JUST the 4 button states. It does NOT
*     invoke the hard coded CLEAR key equivalent for switching windows.
*   - the J$MsBtn co-module call, however, does return the high bit flag that the
*     the right mouse button "clear" key has been hit (to go forward or backward one
*     window/screen in the active screen/window list. Forward or backward is based on the
*     mouse X axis position (which is ONLY updated on a graphics window, so you can't
*     change the direction on a hardware text window; you can on a graphics window).
*   - We will change SS.GIP2 from original documentation somewhat. You will not set the mouse
*     port (that is done the main SS.GIP SetStat)
*     (SS.GIP2) to turn right mouse click window switching on/off. We may add holding down left
*     button while click right button is reverse direction, so you can change directions even
*     on hardware text screens (currently, it keeps going last used direction; you can only change
*     windows selection direction on a graphics window, by moving the mouse left or right).
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      1998/10/09  Robert Gault
* Added annotations to the L2 Upgrade distribution version
*
*   7      2003/08/28  Robert Gault
* Contains routine for H6309 from VTIO
*   8      2018/07/10  L. Curtis Boyle
* Fixed scaling Y coord bug for joystick for Mouse calls (original scaling
*  from NitrOS9 2.01 for some reason was removed completely, and it was
*  hardcoded for 192 Y resolution maximum). This affects both low-res &
*  high resolution joystick/mice. Keyboard mouse is unaffected.
*  Change code to use MaxLine from cocovtio.d to determine coordinates.
*  CoWin may be changed to scale based on actual screen (not window) height
*  between 192 and 200 vertical res)- basically truncate at 191/192 if needed
* Still need to support SS.GIP2 call (once added) to support toggle of 2nd mouse button
*   as CLEAR equivalent or not
*   9      2020/09/16  L. Curtis Boyle
* - Special 2nd button click to switch windows fixed to work from active mouse side (Pt.Actv),
*     not hardcoded to right port (LCB 2020/09/16)
* - Added 10 cycle time delays in 6 bit joystick read between writing to and reading from PIA for
*   GIME-X, so joysticks/mice read correctly (LCB 2020/09/24)
                    nam       JoyDrv
                    ttl       Joystick Driver for CoCo 3 Hi-Res Mouse

* Disassembled 98/09/09 09:07:45 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       9

                    mod       eom,name,tylg,atrv,start,size
size                equ       .

* G.JoyMem static memory (pointed to by U on entry) - 8 bytes reserved
* +0 = Joystick is left/right of center flag. $80=right, $C0=left
* +1 = Previous button states (lower 4 bits, only 2 are kept for active mouse side)
* +2 to +7 = reserved for serial based mouse drivers (6551 & 6552, Microsoft & Logitech)
* NOTE:
* J$JyBtn does not change any of static mem, while J$MsBtn can change the first 2

name                fcs       /JoyDrv/
                    fcb       edition

* 6 entry branch table
* Entry: U=ptr to static memory for JoyDrv (currently 8 bytes)
start               lbra      Init                J$Init setup for special button state & clear buttons
                    lbra      Term                J$Term clear button but don't change special flag
                    lbra      SSMsBtn             J$MsBtn read and process button values
                    lbra      SSMsXY              J$MsXY read joystick values (and scale to mouse coords if Y=0 on entry)
                    lbra      SSJoyBtn            J$JyBtn clear keyboard input and return raw button info
* last table entry falls through here:
* J$JyXY (Read 6 bit joystick values)
* Not sure on these yet:
* Entry: A=joystick side to read (1=RIGHT, 2=LEFT)
*        Y=low byte 0=normal joystick read, <>0=high resolution interface read
*        U=Ptr to G.JoyMem (static mem for joydrv) (8 bytes)
*        others are not defined (X is G.JoyEnt ptr from call to here)
* Exit: X=X coord 0-63 (normal) or 0-639 (hi-res interface)
*       Y=Y coord 0-63 (normal) or 0-191/0-198 (hi-res interface)
*       B=$80 %10000000   if right joystick/mouse selected and X axis is right of center
*         $C0 %11000000   if right joystick/mouse selected and X axis is left of center
* G.JoyMem,u = Copy of B (left/right X axis flag for right joystick)
SSJoyXY             pshs      y,x,d               save regs (or make 6 byte temp stack)
                    pshs      x,d                 Reserve room for X,Y coords we are returning
                    ldx       #PIA0Base           point to PIA#1
                    lda       <$23,x              read sound enable state?
                    ldb       <$20,x              read 6-bit DAC
                    pshs      d                   save current states
                    anda      #%11110111          clear sound enable
                    sta       <$23,x              set switch
                    lda       $01,x               read MUX SEL#1
                    ldb       $03,x               read MUX SEL#2
                    pshs      d                   save current state
* stack at this point (I think):
* 0,s = MUX SEL#1 (to restore to)
* 1,s = MUX SEL#2 (to restore to)
* 2,s = Sound enable state (to restore to)
* 3,s = 6 bit DAC (to restore to)
* 4-5,s = reserved space for final X coord
* 6-7,s = reserved space for final Y coord
* 8,s = Original A joystick side (1=right, 2=left)
* 9,s = Original B (I don't think this is actually every used - may be able to remove?)
* $A-$B,s = original X (JoyEnt ptr)
* $C-$D,s = original Y (resolution (0=6 bit low res, <>0 is high res interface) - only uses
*    low byte
                    orb       #%00001000          set SEL#2 (left joystick by default)
                    lda       8,s                 read joystick side (original A on entry)
                    anda      #%00000010          keep only left joystick bit (if not set, it was right)
                    bne       L0047               if left then left SEL#2 alone
                    andb      #%11110111          clear SEL#2 (right joystick)
L0047               stb       3,x                 enable SEL#2 value
                    leay      <L0097,pcr          point to high res routine
                    ldb       $D,s                flag for high/low res (low byte of original Y from caller)
                    bne       L0054               Hi res, keep jump vector
* Could make this L010F-L0097,pcr (if it fits in signed 8 bits) - smaller/faster.
* But if we replace with software high res routine, probably won't fit. Unless we reverse
* to default to lowres, and offset to start of high res.
                    leay      >L010F,pcr          point to low res routine instead
L0054               lda       ,s                  Get back original MUX SEL#1 state
                    ora       #%00001000          set MUX SEL#1
                    jsr       ,y                  read Y pot
                    tst       $D,s                Was hi or low res requested?
                    beq       L0060               Low res, leave Y coord alone
                    bsr       L00DB               Hi res, convert Y to allowable height range (MaxLines from coco3vtio it should be)
L0060               std       6,s                 Save Y coord
                    lda       ,s                  now read the other axis
                    anda      #%11110111          flip the MUX SEL#1 bit
                    jsr       ,y                  read the X pot
                    std       4,s                 save X coord
                    puls      d                   Get original MUX SEL#1/#2 states
                    sta       1,x                 Restore them
                    stb       3,x
                    puls      d                   Get original 6 bit DAC and sound enable states back
                    stb       <$20,x              restore the DAC and sound enable states
                    sta       <$23,x
                    puls      y,x                 Get X & Y coords we made
* LCB change: Since we are allowing both sides, this check is no longer needed
*         lda   ,s         Get original A from caller (joystick side select)
*         cmpa  #$01       Was Right joystick selected?
*         bne   L0094      If Left Joystick, don't update X Axis left/right flag
*         ldb   #%10000000 Default B to joystick to right flag
*         lda   5,s        Get hi/low res flag
*         bne   L008B      High res, skip ahead
*         cmpx  #32        Compare X coord with center of low res joystick
*         bhs   L0092      If X right of center, leave B as %10000000
*L008B    cmpx  #320       Compare X coord with center of high res joystick
*         bhs   L0092      If X right of center, leave B as %10000000
*         ldb   #%11000000 If X left of center, B=%11000000
*L0092    stb   ,u         Save left/right joystick flag bits
L0094               leas      6,s                 Eat temp stack
                    rts

* High res joystick interface read routine - reads 1 axis with 0-639 resolution
* Entry: A=MUX SEL#1 for which axis (X or Y) we are reading
* Exit:  D=coord (0-639) on current axis
* stack at this point (I think):
* 0,s = MUX SEL#1
* 1,s = MUX SEL#2
* 2,s = Sound enable state
* 3,s = 6 bit DAC
* 4-5,s = Reserved space for final X coord
* 6-7,s = Reserved space for final Y coord
* 8-9,s = Original D
* $A-$B,s = original X
* $C-$D,s = original Y
* EOU NOTE: WILL WANT TO REPLACE THIS ROUTINE WITH "NATIVE" HIGH RES. ROUTINE FROM JOHN KOWALSKI
*   AND NICK MARENTES.
L0097               pshs      cc                  Save CC
                    sta       1,x                 select x/y pot
                    lda       #$FF                full DAC value
                    sta       <$20,x              store in DAC to charge capacitor
* 6309 version of code (I organized & duplicated the few instructions
*   in common to make each version easier to read/follow)
                    IFNE      H6309
                    lda       #128                timing loop delay count for 6309 native mode; wait for voltage to settle
L00A2               deca
                    bne       L00A2               wait
                    ldd       #$2F0
                    lde       #2
                    orcc      #IntMasks           kill interrupts
                    ste       <$20,x              clear DAC; mask RS-232; start cap. discharge
L00B1               lde       ,x                  test comparator
                    bmi       L00C0
                    decd
                    bne       L00B1               loop until state change
                    ldd       #MaxRows-1          Too big, force to highest possible coord (639)
                    puls      cc,pc               Restore CC & return

L00C0               decb
                    ldw       #MaxRows            Max coord (640)
                    subr      d,w                 Subtract the timing ramp value we got
                    bhs       L0A11               If didn't wrap, we're fine
                    clrd                          If went negative, force to 0 coord
                    puls      cc,pc               Turn interrupts back on & return

L0A11               tfr       w,d                 Move to proper exit register for now
                    cmpd      #MaxRows-1          Past maximum X coordinate? (639)
                    blo       L0A1A               No, leave it alone
                    ldd       #MaxRows-1          Don't let it get past end of screen (force to 639)
L0A1A               puls      pc,cc

                    ELSE

* 6809 version of code
                    lda       #90                 timing loop delay count for 6809; wait for voltage to settle
L00A2               deca
                    bne       L00A2               wait
                    ldd       #$329
                    pshs      a
                    lda       #$02
                    orcc      #IntMasks           kill interrupts
                    sta       <$20,x              clear DAC; mask RS-232; start cap. discharge
L00B1               lda       ,x                  test comparator
                    bmi       L00C0
                    decb                          counter
                    bne       L00B1               loop until state change
                    dec       ,s                  3 -> 0
                    bpl       L00B1               loop again
                    puls      a
                    bra       L00D6               branch to maximum value

L00C0               puls      a
                    decb
                    pshs      D
                    ldd       #MaxRows            Max coord (640)
                    subd      ,s++                convert from 640 -> 0 to 0 -> 640
                    bcc       L00D0               Didn't wrap negative, use result
                    clra                          minimum value is $00
                    clrb
                    puls      pc,cc

L00D0               cmpd      #MaxRows-1          Is it within maximum allowed?
                    blo       L00D9               Yes, return
L00D6               ldd       #MaxRows-1          No, force maximum value
L00D9               puls      pc,cc

                    ENDC

* LCB NOTE: I think I have grfdrv now handling x24 and x25 screens; if I do, then this
*   should not be IFEQ, but based on the screen table size and adjust between the two.
* I have this wrong - it should be converting 0-639 ($0-$27F) to 0-191/0-198 ($0-$BF/$C6)
* Convert 10 bit Y (0-639) to 0-198 or 0-191 (depending on MaxLines)
* This routine converts a pot value from max of(63/$3F) to max height (191)
*  ie. value multiplied by 3. Change to 3.171875 (44/256 of value * 3 tims value)
*  for x200.
* Self contained subroutine, only call from 1 location.
* Entry: D=current Y coord (0-639) we need to scale
* Exit:  B=scaled Y coord 0-191 or 0-198 (Dependent on value of MaxLines at assembly time)
L00DB               pshs      a                   Save high byte of 0-639 coord (0-2 only)
                    IFEQ      MaxLines-25
                    lda       #$50                First, multiply LSB by multiplier
                    ELSE
                    lda       #$4d                First, multiply LSB by multiplier
                    ENDC
                    mul
                    pshs      a                   Save high byte of result
                    lda       1,s                 Get original MSB back
                    IFEQ      MaxLines-25
                    ldb       #$50                Multiply MSB by multiplier
                    ELSE
                    ldb       #$4d                Multiply MSB by multiplier
                    ENDC
                    mul
                    addb      ,s++                Add to original result, eat temp
                    clra                          Force to 8 bit result
                    IFEQ      MaxLines-25
                    cmpb      #198                Are we at limit of viewable Y?
                    bls       DoneYFix            Yes, exit with B scaled coord
                    ldb       #198                Force to maximum
                    ELSE
                    cmpb      #191                Are we at limit of viewable Y?
                    bls       DoneYFix            Yes, exit with B scaled coord
                    ldb       #191                Force to maximum
                    ENDC
DoneYFix            rts                           Return

* Low resolution joystick read of one axis
*  binary tree search for joystick value
* Entry: A=which axis (set up for MUX SEL#1 already)
* Exit:  D=6 bit value (16 bit since shared code with high resolution mouse interface)
* While this code could technically be optimized, there is a delay settle time needed for
*   the PIA's, so do NOT change this code (I tried... LCB)
L010F               sta       1,x                 set MUX SEL#1
                    lda       #%01111111          DAC value
                    ldb       #%01000000          start coord scale at 64
                    bra       L0122

L0117               lsrb                          reset DAC offset value
                    cmpb      #1                  Keep doing all 6 bits
                    bhi       L0122
                    lsra                          Done all 6, shift result to lower 6 bits
                    lsra
                    tfr       a,b                 D=6 bit joystick value
                    clra
                    rts                           return with voltage

L0122               pshs      b
                    sta       <$20,x              set DAC
                    ifne      GIMEX
                    ifeq      H6309
                    exg       x,x                 8 cycle delay \10 cycles needed for GIMEX-
                    nop       2                   cycle delay /  6809
                    else
                    exg       x,x                 5 cycle delay \10 cycles needed for GIMEX-
                    exg       x,x                 5 cycle delay /  6309
                    endc
                    endc
                    tst       ,x                  test comparator
                    bpl       L012F
                    adda      ,s+                 adjust binary tree search
                    bra       L0117

L012F               suba      ,s+                 adjust binary tree search
                    bra       L0117

* Read joystick values as mice values (ie scale 0-63,0-63 to 0-634(?),0-189
* Entry: Y=Mouse resolution (0=low res (need to scale), 1=high res (leave alone)
*        A=Mouse side (0=left, 1=right)
*        U=Joydrv static mem ptr (8 bytes) (G.JoyMem)
* Exit: X=X coordinate scaled to mouse resolution
*       Y=Y coordinate scaled to mouse resolution
SSMsXY              leay      ,y                  Lo res mouse?
                    lbne      SSJoyXY             High res, just read raw joystick coords and return from there (already has full range)
                    lbsr      SSJoyXY             Low res, go get raw joystick values (0-63 on each access)
                    tfr       x,d                 Scale X by * 10
                    lda       #10
                    mul
                    tfr       d,x                 Save scaled X over original X
                    cmpx      #630                Anything>630 force to 634 (so mouse fairly visible and in last column of 80 column)
                    blo       L014B
                    ldx       #634                maximum limit on regX (I think to allow far right scroll bars to be reached)
L014B               tfr       y,d                 Multiply Y coord by 3 (192 resolution ONLY)
                    lda       #3
                    mul
                    IFEQ      MaxLine-198
                    pshs      b                   Save *3 value
                    tfr       y,d                 Get Y coord back into B
                    lda       #$28                Multiply by fraction $28/$100 to scale Y coord
                    mul
                    adda      ,s+                 Add to original *3 value
                    tfr       a,b                 Move to lower byte
                    clra                          D=scaled Y coord 0-198
                    ENDC
                    tfr       d,y                 Save scaled Y overtop original Y
                    rts

* Entry: X=Ptr to entry into Joydrv (the branch table)
*        U=Ptr to joydrv static mem
Init                ldb       #%10000000          Default X axis left/right flag to Right
                    stb       ,u                  Save in J.LftRgt
* Entry: X=Ptr to entry into Joydrv (the branch table)
*        U=Ptr to joydrv static mem
Term                clr       1,u                 Clear right mouse special button states & return
                    rts

* J$JoyBtn
* Entry: U=JoyMem ptr (static mem ptr for joydrv)
* Exit:  B=lower 4 bits are flags for each of the 4 joystick buttons
*          xxxx0001 = Right button 1
*          xxxx0010 = Left button 1
*          xxxx0100 = Right button 2
*          xxxx1000 = Left button 2
*        X=ptr to PIA0Base ($FF00)
SSJoyBtn            ldx       #PIA0Base           PIA#0 base address
                    ldb       #$FF
                    stb       2,x                 clear PIA#1 key strobe lines
                    ldb       ,x                  read data lines
                    comb                          invert bits
                    andb      #%00001111          only buttons; 0=off 1=on
                    rts

* J$MsBtn
* Entry: U=JoyMem ptr (static mem ptr for joydrv)
* Exit:  B=Button state (Button pressed then released, or button down)
*          %10xxxxxx Window Forward flag (button 2 clicked & released, joystick X on right side)
*          %11xxxxxx Window Backward flag (button 2 clicked & released, joystick X on left side)
*          %00xxbbbb BBBB is the four buttons states from PIA (buttons currently held down)
*        1,u in static mem has previous button states for active mouse side (originally right port only)
*        X&A IS MODIFIED!
* LCB NOTE: IF WE ADD GIP2 CALL, SET FLAG WITH HIGH BIT SET TO INDICATE CLEAR MOUSE ENABLED. AND
*   THIS VALUE WITH THE TABLE READ - IF HIGH BIT STILL SET, IT IS ENABLED, ELSE NOT.
* WE NEED TO CHANGE SO THAT THIS CAN WORK WITH EITHER LEFT OR RIGHT MOUSE ENABLED, BASED ON SYSTEM
*   MOUSE SIDE (Pt.Actv)
* Also, documentation for original Level 2/Version 3 upgrade had SS.GIP2 had you able to select which
*  button, but you need at least the first mouse button for all menuing, so it should just be a toggle
*  for the second button. If I do start using right mouse button in GShell, will need to add alternate
*  version (CTRL-CLICK for example). And it should use current mouse side, not hardcoded to Right only
* If the mouse is inactive (mouse side=0), then default to right port as per Init in VTIO
SSMsBtn             bsr       SSJoyBtn            Get button states from PIA into B (only returns lower 4 bits)
                    ldx       <D.CCMem            Get CC3 Global mem ptr
                    lda       G.Bt2Clr,x          Get global VTIO flags
                    bmi       MsClrAct            Use Mouse button 2 as CLEAR, go do that
                    rts                           Otherwise, just exit with the 4 button states in B

MsClrAct            tfr       b,a                 Duplicate so we can mask for each side separately
* Left mouse active - keep right button copy on stack, adjust left for table lookup
                    IFNE      H6309
                    andd      #$0A05              Left buttons in A, Right buttons in B
                    ELSE
                    anda      #%00001010          Keep left buttons only in A
                    andb      #%00000101          Keep only right buttons in B
                    ENDC
                    pshs      d                   Save both sides individual button states
                    lda       G.Mouse+Pt.Actv,x   Get current mouse side (0=off)
                    deca                          -1=off, 0=right, 1=left (so bgt means left, otherwise right)
                    pshs      a                   Save it so we can pre/post adjust by side
                    ble       UpdtSt              If right side, bits already in proper position in B
                    ldb       1,s                 Get left buttons into B
                    lsrb                          Move to right button positions for table
* At this point:
*   B=active side button states (shifted for table if needed (mimics right side))
* Stack is: 0,s = 1 if left is active side, <1 if right is active side (signed!)
*           1,s = Left buttons (bits 1 and 3)
*           2,s = Right buttons (bits 0 and 2)

* NEW CODE: 1st set up CLEAR direction flags, so they are ready if needed
UpdtSt              lda       #%10000000          Default to forward CLEAR direction
                    bitb      #%00000001          Button 1 down?
                    beq       NoDirFlg            No, save forward CLEAR direction flag
                    lda       #%11000000          Backward CLEAR direction
NoDirFlg            sta       ,u                  Save CLEAR/Direction flags
* 2nd: check if button 2 is up, *and* it's previous state was down (1,U <>0)
                    bitb      #%00000100          Is 2nd button pressed on active mouse side?
                    bne       FlgBt2Dn            Yes, flag it & return with the 4 current button states
                    lda       1,u                 No, get previous button 2 state
                    beq       NoClear             Never was pressed, so just return with 4 buttons from PIA
                    clr       1,u                 It was just released, clear previous state
                    ldb       ,u                  Get CLEAR/direction flags
                    lda       ,s                  Get active mouse side (0=right, 1=left)
                    nega                          (0=right, -1=left)
                    adda      #2                  Offset to proper button state on stack
                    clr       a,s                 Clear buttons for active mouse side (THIS MIGHT HAVE TO BE ONLY BUTTON 1?)
                    orb       1,s                 Merge left buttons from PIA
* LCB NOTE: We may need to clear the active side button 1 state here first!
                    bra       MrgRtBut            Merge right as well & return

FlgBt2Dn            stb       1,u                 Save previous state of button 2 being down (non-zero)
NoClear             ldb       1,s                 Get left buttons from PIA
MrgRtBut            orb       2,s                 Merge right buttons from PIA
                    leas      3,s                 Eat temp stack
                    rts                           Exit with high bits clear, and all 4 button states


*UpdtSt   orb   1,u            merge current mouse button states with previous (table based) mouse button states
*UpdtSt   lda   #%10000000     Default to forward CLEAR direction
*         bitb  #%00000001     Button 1 down?
*         beq   NoDirFlg       No, save forward CLEAR direction flag
*         lda   #%11000000     Backward CLEAR direction
*NoDirFlg sta   ,u             Save CLEAR/Direction flags
*         orb   1,u            merge current mouse button states with previous (table based) mouse button states

*         stb   2,u            DEBUG - SAVE TABLE ENTRY #

*         leax  <L0187,pcr     point to table of mouse state updates
*         lda   b,x            Get updated state based on previous state
*         anda  #%00001010     Keep updated previous states only
*         sta   1,u            save previous states back
* Done updating "previous states"; now get B set up for return to caller. For now, B is the pointer
*  into the table so that we re-access it when needed
*         ldb   b,x            Get state updates again
*         andb  #%10000101     Keep window change & current button states only
*         bpl   NoClear        No window change needed, merge in opposite port buttons
* Window change (hi bit set) needed
*         orb   ,u             Add current window flags byte (window change, and forward/backwards bit)
* now merge opposite port's buttons with window flags
*         lda   ,s             Get side
*         ble   AddLftBt       If right, merge left buttons & return
*         bra   AddRtBt        Left, merge right buttons & return

* No right click window change comes here; just merge 4 button states together for user
*NoClear  lda   ,s             Check side; do we need to shift?
*         ble   AddLftBt       right side, button bits already in right position
*         lslb                 Left side, shift to left buttons
*AddRtBt  orb   2,s            Merge in right buttons
*         fcb   $8C            Skip next 2 bytes (cmpx immediate)
*AddLftBt orb   1,s            Right side, merge left buttons
*DoneMsBt leas  3,s            Eat temps & return with value in B
*         rts

* Translation table for lower 4 bits (previous & current button states for active mouse side).
*   High bit set on exit is "CLEAR" key equivalent flag.
* Table entry # (0-15) is previous and current raw 4 button state (originally right mouse only).
* Former G.KyMse in CC3 Global ($1000-$10FF) is now G.Bt2Clr bit flags. Hi bit flag is set/cleared
* by the new SS.GIP2 call, and affects system wide. This enables/disables using the 2nd button as
* a CLEAR key equivalent, as some programs did use both buttons and those break under the 3.3.0
* hard coded set up.
* Entry:
* xxxx1xxx - Button 2 previous state
* xxxxx1xx - Button 2 current state
* xxxxxx1x - Button 1 previous state
* xxxxxxx1 - Button 1 current state
* Exit: hi bit set if CLEAR equivalent, and both previous and current button states
*       (previous state bits are saved to 1,u; current states are returned along with buttons from other
*        port)
* Returns: What to save in previous buttons state for next round (or high bit set for CLEAR equivalent)
* NOTE: The right mouse button as CLEAR *only* works if that is the only button clicked - if you hold down
*   button 1, and then right click, or right click & then left click while still holding down the right, then
*   no CLEAR key mapping is done.
*              Returned value    previous/current button states is entry # in table (0-15)
*L0187    fcb   %00000000      0 (xxxx0000) No buttons pressed prev or cur; return no buttons
*         fcb   %00000010      1 (xxxx0001) cur btn1 down; return prev btn1 down
*         fcb   %00000000      2 (xxxx0010) prev btn1 down; return no buttons
*         fcb   %00000010      3 (xxxx0011) prev & cur btn1 down; return prev btn1 down again
*         fcb   %00001000      4 (xxxx0100) cur btn2 down; return prev btn2 down (move but2 state from cur to prev)
*         fcb   %00001010      5 (xxxx0101) cur both buttons down; return both prev buttons down
*         fcb   %00000010      6 (xxxx0110) cur btn2 & prev btn1 down, return prev btn2 down
*         fcb   %00001010      7 (xxxx0111) cur btn2, prev & cur btn1 down, return prev btn2 & prev btn1 down
* Following are button 2 just released
*         fcb   %10000000      8 (xxxx1000) prev btn2 down, no cur buttons, return no buttons down, CLEAR flag set
*         fcb   %00000010      9 (xxxx1001) prev btn2 down, cur btn1 down, return prev btn1 down
*         fcb   %00000000      10 (xxxx1010) prev buttons 1 & 2 down, return no buttons
*         fcb   %10000010      11 (xxxx1011) prev btn2 down, cur & prev btn1 down, return prev btn1 down & CLEAR flag
*         fcb   %00001000      12 (xxxx1100) prev & cur btn2 down, return prev btn2 down
*         fcb   %00001010      13 (xxxx1101) cur & prev btn2 down, cur btn1 down, return prev btn2 down, prev btn1 down
*         fcb   %00001000      14 (xxxx1110) cur & prev btn2 down, prev btn1 down, return prev btn2 down
*         fcb   %00001010      15 (xxxx1111) cur & prev both buttons down,, return prev btn2 down, prev btn1 down

* originals
*L0187    fcb   %00000000      0 (xxxx0000) No buttons pressed prev or cur; return no buttons
*         fcb   %00000011      1 (xxxx0001) cur btn1 down; return prev & cur btn1 down
*         fcb   %00000000      2 (xxxx0010) cur btn1 up, prev btn1 down; return no buttons
*         fcb   %00000011      3 (xxxx0011) prev & cur btn1 down; return prev & cur btn1 down again
*         fcb   %00001000      4 (xxxx0100) cur btn2 down; return prev btn2 down (move but2 state from cur to prev)
*         fcb   %00000110      5 (xxxx0101) cur both buttons down; return cur btn2 down, prev btn1 down
*         fcb   %00000010      6 (xxxx0110) cur btn2 & prev btn1 down, return prev btn2 down
*         fcb   %00000110      7 (xxxx0111) cur btn2, prev & cur btn1 down, return cur btn2 & prev btn1 down
* Following are button 2 just released
*         fcb   %10000000      8 (xxxx1000) prev btn2 down, no cur buttons, return no buttons down, CLEAR flag set
*         fcb   %00000010      9 (xxxx1001) prev btn2 down, cur btn1 down, return prev btn1 down
*         fcb   %00000000      10 (xxxx1010) prev buttons 1 & 2 down, return no buttons
*         fcb   %00000010      11 (xxxx1011) prev btn2 down, cur & prev btn1 down, return prev btn1 down
*         fcb   %00001000      12 (xxxx1100) prev & cur btn2 down,, return prev btn2 down
*         fcb   %00000110      13 (xxxx1101) cur & prev btn2 down, cur btn1 down, return cur btn2 down, prev btn1 down
*         fcb   %00001010      14 (xxxx1110) cur & prev btn2 down, prev btn1 down, return prev btn2 & prev btn1 down
*         fcb   %00000110      15 (xxxx1111) cur & prev both buttons down,, return cur btn2 down, prev btn1 down


                    emod
eom                 equ       *
                    end

