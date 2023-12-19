********************************************************************
* VTIO - Video Terminal I/O Driver for CoCo 3
*
* $Id$
* Need to add SS.GIP2 as well (see notes in code below). May also want to add
* a new SetStat call to allow changing a device descriptor between CoVDG and CoWin
*   types (without needing XMODE)
* NOTE:  CODE ISSUES FOUND!!
* "Animate Palette?  This obviously isn't implemented yet"
* Look at this code.  Why is this calling an entry point in
* SNDDRV??? LCB note: Sound is usually driven by the same IRQ
*   (60hz) as the keyboard/joystick scan, and they have to link
*   together, so that may be why.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  16      1986/??/??
* Original OS-9 L2 Tandy distribution.
*
*  26r3    1998/10/12
* Added support for obtaining monitor type from the init module.
*
*  26r4    1998/10/23
* Added support for obtaining key repeat info from the init module.
*
*  26r5    2002/07/24
* Added support for obtaining mouse info from the init module.
*
*  27      2003/08/18  Boisy G. Pitre
* Forward ported to NitrOS-9.
*
*          2003/11/16  Robert Gault
* Corrected several lines for keyboard mouse.
* Corrected several lines in SSMOUSE where MS.Side used incorrectly.
*
*          2003/12/02  Boisy G. Pitre
* Keyboard mouse is now either global or local to window, depending
* on whether GLOBALKEYMOUSE is defined.
*
*          2004/08/14  Boisy G. Pitre
* Fixed a bug where the last deiniz of the last window device caused
* an infinite loop.  The problem was that IOMan clears the static
* storage of a device whose use count has reached zero (in the
* case of a hard detach).  See Note below.
*
* Renamed to VTIO and reset edition to 1.
*
*   1      2006/03/04  Boisy G. Pitre
* Added detection of CTRL-ALT-BREAK to invoke system debugger.
* Renamed to VTIO and reset edition to 1.
*
*   2      2007/08/22  Boisy G. Pitre
* Fixed bug where an error other than E$MNF when linking to CoWin would be ignored.
* Now, if the error returned from linking CoWin is not E$MNF, we don't bother to look
* for CoGrf... we just return immediately.
*
*   3      2020/04/26 (EOU Beta 5)  L. Curtis Boyle
* Changed SS.GIP call (should be backwards compatible) to allow individual $FF settings
*   (leave current setting alone) to work for all 4 parameters independently.
* Also moved start branch table to allow short branches to Write and Getstat-they get called
*   a lot more often than Terminate
*   4      2020/06/20 (EOU Beta 6)  L. Curtis Boyle
* - Minor size/speed optimizations as mentioned in my earlier comments from Beta 5
* - Also fixed SS.ComSt SetStat - goes straight to CoVDG module, and now works.
* - Minor SS.Joy optimization
* - To facilitate other planned changes, Global Keyboard mouse is removed, with local
*     keyboard mouse only (also greatly helps beginners who don't understand why simple
*     things like backspace don't work anymore on other windows).
*   2020/07/15 LCB - started adding SS.GIP2 call.
*   2020/07/20 LCB - removed KeyMem 8 byte static mem buffer and references to it; it was
*     never used and just taking up space (and time to set it up)
*   2020/07/22 LCB - merged KeyDrv back into VTIO (only had 2 functions, and no static RAM
*     usage). Will save some module space, and saves 10 bytes of global mem total.
*   2020/07/22 LCB - Keyclick (local to each window) toggle working in SS.GIP2 call
*   2020/09/16 LCB - Enable/disable 2nd mouse button on active mouse port to be CLEAR
*     equivalent working (needs updated JoyDrv_Joy) option enabled in SS.GIP2 call.
*     Both Keyclick & CLEAR are 2 bits per setting:
*     0x = leave current setting
*     10 = disable feature
*     11 = enable feature
*   2020/12/18 LCB - still had text 'KeyDrv' in code, now removed (saves 6 bytes)

** PROPOSED in SS.GIP2 call - Use low byte of X for default font # (boot default is 1). $00
**  means leave alone


                    nam       VTIO
                    ttl       Video Terminal I/O Driver for CoCo 3
* Need to fix up ISR routine to handle Animate Palette. NOTE: the "screen hardware settings"
*   flag forces a call to SelNewWindow in the Co-driver, which should actually update:
*   1) screen mode
*   2) screen address
*   3) palettes
* Disassembled 98/09/09 08:29:24 by Disasm v1.6 (C) 1988 by RML

                    ifp1
* EOU build
*         use   /dd/defs/deffile
* Repo build
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       0
edition             set       4

* LCB NOTE: Need to change this so that code always uses V.ULCASE static mem keyboard mouse flag,
* but code will copy current state to all terminals if Global settings is on (and this could
* use existing global G.KyMse for current "system state". SS.GIP2 call can add setting this to
* allow changing after booting (might want to add/modify a byte in the new INIT module so that
* the default setting comes from there). Or, have the code check if global enabled and use G.KyMse if
* it is, or V.ULCASE if not. (if latter, reserve 2 bits in G.KyMse; hi bit is global enabled, low bit
* is keyboard mouse turned on if global enabled.). NOTE: We can use the 3rd lowest bit in Feature1
* byte of INIT for the default Global keyboard mouse on/off flag.
* NOTE: Want to implement bit flags for local keyboard mouse & caps lock (like we did in TC-9), so
* that we can use 3 colors of LED on the Boomerang E2 2 MB board (add BOOMERANG equ) to signify
* Caps Lock on, Keyboard mouse on, and Caps Lock AND keyboard mouse on, for each window.
* currently proposing Red for keyboard mouse, green for capslock, and either Blue or White for Both.
* Maybe half intensity? (so AAx10000 where AA: 00="all", 01=Red, 10=Grn, 11=Blue)

                    mod       eom,name,tylg,atrv,start,CC3DSiz

                    fcb       EXEC.+UPDAT.

name                fcs       /VTIO/
                    fcb       edition


* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term                ldx       <D.CCMem            get ptr to CC memory
                    cmpu      G.CurDev,x          device to be terminated is current?
                    bne       noterm              no, execute terminate routine in co-module
                    lbsr      SHFTCLR             get ptr to previous window in window list
                    cmpu      G.CurDev,x          Still us? (IE we are only window active?)
                    bne       noterm              no, execute terminate routine in co-module
* We are last device that VTIO has active; terminate ourself
* 6809/6309 - I don't think we need to pshs/puls CC - it's not using any of the flags after.
* Just orcc and then replace puls cc with andcc. Would need testing
                    pshs      cc                  Save flags
                    orcc      #IRQMask            Shut IRQ's off
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       G.CurDev,x          Zero out ptr to current device's static mem ptr
                    ldx       G.OrgAlt,x          get original D.AltIRQ address
                    stx       <D.AltIRQ           Save as current D.AltIRQ
* for above change
*         andcc #^IRQMask    Turn IRQ's back on
                    puls      cc                  restore IRQs
                    pshs      u,x                 Save regs
                    ldx       #(WGlobal+G.JoyEnt) Point to start of JoyDrv entry/static mem block
                    bsr       TermSub             Terminate JoyDrv
                    ldx       #(WGlobal+G.SndEnt) Point to start of SndDrv entry/static mem block
                    bsr       TermSub             Terminate SndDrv
*         ldx   #(WGlobal+G.KeyEnt)  Point to start of KeyDrv entry/static mem block
*         bsr   TermSub      Terminate KeyDrv
                    puls      u,x                 Restore regs
noterm              ldb       #CoTerm             ($0C) branch table offset for terminate
                    lbra      CallCo              go to terminate in co-module

* Call terminate routine in subroutine module (KeyDrv/JoyDrv/SndDrv)
* X  = Ptr to start of 10 byte sub-module block (0-1 is entry point, 2-10 is static mem)
TermSub             leau      2,x                 point U to static area for sub module
                    ldx       ,x                  get entry pointer at ,X
                    jmp       J$Term,x            call term routine in sub module

* Init
* Entry: Y = address of device descriptor
*        U = address of device static memory area
* Exit:  CC = carry set on error
*        B  = error code
* NOTE: Uses some settings from the INIT module from OS9Boot as well, for setting defaults
Init                ldx       <D.CCMem            get ptr to CC mem
                    ldd       <G.CurDev,x         has VTIO itself been initialized?
                    lbne      PerWinInit          yes, don't bother doing it again, just do new window (or VDG) init
                    leax      >SHFTCLR,pcr        point to SHIFT-CLEAR subroutine
                    pshs      x                   save it on stack
                    leax      >setmouse,pcr       get address of setmouse routine
                    tfr       x,d                 Move to D
                    ldx       <D.CCMem            get ptr to CC mem again
                    std       >G.MsInit,x         Save setmouse routine vector (used by CoWin)
                    puls      d                   get address of SHIFT-CLEAR subroutine back
                    std       >G.WindBk,x         save its vector
                    stu       <G.CurDev,x         Save current device's static mem ptr
                    lbsr      setmouse            initialize mouse
                    lda       #2                  2 ticks default (1/30th of a second)
                    sta       G.CurTik,x          save default # of clock ticks between cursor(s) updates
                    inc       <G.Mouse+Pt.Valid,x set mouse packet to invalid (isn't this actually setting to valid?-LCB)
                    ldd       #$0178              default to right mouse/button time out value (120)
                    std       <G.Mouse+Pt.Actv,x  Save both values
                    ldd       #$FFFF              initialize last keyboard code to $FF, and key repeat counter to -1
                    std       <G.LKeyCd,x         last keyboard code & key repeat counter inactive
                    std       <G.2Key2,x          Init first two keys in secondary key table to none
                    ldd       <D.Proc             Get ptr to current process descriptor
                    pshs      u,y,x,d             save regs
* Added to allow patching for RGB/CMP/Mono and Key info - BGP
* Uses new init module format to get monitor type and key info
                    ldy       <D.Init             get ptr to INIT module
                    lda       MonType,y           get monitor type byte 0,1,2
                    sta       <G.MonTyp,x         save in global memory
                    ldd       MouseInf,y          get INIT module defaults for mouse hi/low res & left/right side
                    sta       <G.Mouse+Pt.Res,x   save hi-res/lo-res flag
                    stb       <G.Mouse+Pt.Actv,x  save off/left/right mouse flag
                    ldd       KeyRptS,y           get key repeat start/delay constants
                    sta       <G.KyRept,x         set first delay
                    std       <G.KyDly,x          set initial and 2ndary constants
                    ldd       <D.SysPrc           get system process desc ptr
                    std       <D.Proc             make current process

* KeyDrv merged back into VTIO; next lines not needed anymore
*         leax  <KeyDrv,pcr  point to keyboard driver sub module name
*         bsr   LinkSys      link to it (restores U to D.CCMem)
*         sty   >G.KeyEnt,u  save the entry point
* removed; was never used in Keydrv anyways
*         leau  >G.KeyMem,u  point U to keydrv statics
*         jsr   ,y           call init routine of sub module (K$Init)

                    leax      <JoyDrv,pcr         point to joystick driver sub module name
                    bsr       LinkSys             link to it (restores U to D.CCMem)
                    sty       >G.JoyEnt,u         and save the entry point
                    leau      >G.JoyMem,u         point U to joydrv statics
                    jsr       ,y                  call init routine of sub module (J$Init)
                    leax      <SndDrv,pcr         point to sound driver sub module name
                    bsr       LinkSys             link to it (restores U to D.CCMem)
                    sty       >G.SndEnt,u         and save the entry point
                    leau      >G.SndMem,u         point U to sound statics
                    jsr       ,y                  call init routine of sub module (S$Init)
                    puls      u,y,x,d             restore saved regs
                    std       <D.Proc             and restore current process
                    ldx       <D.AltIRQ           get original D.AltIRQ address
                    stx       >WGlobal+G.OrgAlt   save in window globals for later
                    leax      >ISR,pcr            vector to update tone counter, mice, cursor updates (called from Clock)
                    stx       <D.AltIRQ           Save as AltIRQ vector
* This code is executed on init of every window
* U = device memory area
PerWinInit          ldd       #$0078              Default mouse sample rate (0) & mouse button timeout ($78 / 120)
                    std       <V.MSmpl,u          (Mouse sample rate & fire button timeout value)
                    ldd       <IT.PAR,y           get parity/baud bytes from dev desc
                    std       <V.DevPar,u         save it off in our static (hi bit=window device)
                    lbra      FindCoMod           go find and init co-module

*KeyDrv   fcs   /KeyDrv/     Name of keyboard driver subroutine module
JoyDrv              fcs       /JoyDrv/     Name of joystick driver subroutine module
SndDrv              fcs       /SndDrv/     Name of sound driver subroutine module

* Link to subroutine module
* Entry: X=ptr to module name
LinkSys             lda       #Systm+Objct        system module
                    os9       F$Link              link to it
                    ldu       <D.CCMem            Get ptr to CC mem back
                    rts

* 6809/6309 - moved here since READ called much more often than SS.Ready, and we can bne vs lbne
NotReady            comb                          Return with Not Ready error
                    ldb       #E$NotRdy
                    rts
* Read
*
* NOTE:
* This just reads keys from the buffer. The physical reading
* of keys is done by the IRQ routine (now in KEYDRV)
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
Read                lda       V.PAUS,u            device paused?
                    bpl       read1               no, do normal read
* Here, device is paused; check for mouse button down
* If it is down, we simply return without error.
                    lda       >(WGlobal+G.Mouse+Pt.CBSA) test current button state A
                    beq       read1               button isn't pressed, do normal read
                    clra                          Button pressed, return w/o error
                    rts

* Check to see if there is a signal-on-data-ready set for this path.
* If so, we return a Not Ready error.
read1               lda       <V.SSigID,u         data ready signal trap set up?
                    bne       NotReady            yes, exit with not ready error
                    leax      >ReadBuf,u          point to keyboard buffer (up to 128 chars)
                    ldb       <V.InpPtr,u         get current position in keyboard buffer
                    orcc      #IRQMask            disable IRQs
                    cmpb      <V.EndPtr,u         same as end of buffer ptr (no keys in buffer)?
                    beq       ReadSlp             yes, no new chars waiting, sleep/scan for them
* Character(s) waiting in buffer
                    abx                           move ptr to character
                    lda       ,x                  get character from buffer
                    incb                          inc keyboard buffer ptr
                    bpl       bumpdon             if it hasn't wrapped 128 bytes, go save it
                    clrb                          Wrapped, force to 0
bumpdon             stb       <V.InpPtr,u         save updated keyboard buffer ptr
                    andcc     #^(IRQMask!Carry)   re-enable IRQ's and clear carry
                    rts                           return with A containing char read (and B=updated offset into keyboard buffer)

* Nothing is in input buffer so wait for it
ReadSlp             lda       V.BUSY,u            get active process id #
                    sta       V.WAKE,u            save as process id # to wake up when data read
                    andcc     #^IRQMask           re-enable IRQ's
                    ldx       #$0000              sleep until signal received
                    os9       F$Sleep
                    clr       V.WAKE,u            signal gotten, disable process # to wake up
                    ldx       <D.Proc             get current proc desc ptr
                    ldb       <P$Signal,x         signal pending?
                    beq       Read                no, go read char
* Signal was pending already, check it out
                    IFNE      H6309
                    tim       #Condem,P$State,x   are we condemned?
                    ELSE
                    lda       P$State,x           Are we condemned?
                    bita      #Condem
                    ENDC
                    bne       ReadErr             yes, exit with error flag set back to SCF
                    cmpb      #S$Window           window change or higher (user defined) signal?
                    bhs       Read                yes, read the char since it won't change
ReadErr             coma                          major signal, return with error (Keyboard abort/interrupt)
                    rts

* Keyboard mouse coordinate deltas - note it maxes Y correctly
L0160               fcb       8,1                 right arrow X=X+8, shifted right arrow X=X+1
                    fdb       MaxRows-1           ctrl right arrow - X=maximum X allowed
                    fcb       -8,-1               left arrow X=X-8, shifted left arrow Y=Y-1
                    fdb       0                   ctrl left arrow X=0
                    fcb       8,1                 down arrow Y=Y+8, shifted down arrow Y=Y+1
                    fdb       MaxLine             ctrl down arrow Y=maximum Y allowed
                    fcb       -8,-1               up arrow Y=Y-8, shifted up arrow Y=Y-1
                    fdb       0                   ctrl up arrow, Y=0

* Check mouse coordinate
* Entry: D=Maximum allowed coordinate for current axis being checked
*        Y=Ptr to current coordinate in mouse packet being checked
L0170               cmpd      ,y                  past maximum allowed coordinate?
                    blt       L017B               No, save as is
                    ldd       ,y                  below zero?
                    bpl       L017D               no, return
                    IFNE      H6309
                    clrd                          Yes, force to 0
                    ELSE
                    clra                          Yes, force to 0
                    clrb
                    ENDC
L017B               std       ,y                  set it to maximum coordinate & return
L017D               rts


* Main keyboard scan (after PIA has been read)
* 1) Updates keyboard mouse (if enabled), flags that mouse moved
* 2) Checks for CLEAR/SHIFT CLEAR as well (and CTRL-CLEAR keyboard mouse toggle)
* Entry: U=Global mem ptr
*        A=Key that was pressed
* Exit:  B: Flag that special update is needed:
*          B=1: No special update is needed
*          B=0: Special update needed; flagged as such if one or more of the following:
*             - Keyboard mouse on & a mouse move key or mouse button key pressed (regular/SHIFT/CTRL arrow,F1,F2)
*             - CTRL-CLEAR capslock toggled
*             - CLEAR or SHIFT-CLEAR (select next or previous window)
*        CC: Zero bit set if special update needed; cleared if not
*        X,Y,U are preserved
* Updated for localized keyboard mouse similar to TC9IO
* CHECK IF Y IS STILL DATA MEM PTR, SO WE CAN CHECK CURRENT WINDOWS KEYBOARD MOUSE FLAG
* ONLY CALLED FROM L03ED
L017E               ldb       #$01                flag that no mouse movement happened as default
                    pshs      u,y,x,d             save registers used & flag (and A=key pressed)
* CHANGE G.KYMSE,X TO USE V.ULCase in static mem instead
*         ldb   <G.KyMse,u   get global keyboard mouse enabled flag
                    ldx       <G.CurDev,u         get current device's static mem pointer
                    ldb       V.ULCase,x          Get local window keyboard flags
                    andb      #KeyMse             Keyboard mouse on?
                    beq       L01E6               Not on, skip keyboard mouse processing
* Keyboard mouse is on - check for keyboard mouse movement keys
                    lda       <G.KySns,u          Keyboard mouse on, get Key Sense byte
                    bita      #%01111000          any arrow key pressed?
                    beq       L01DF               No, skip arrow key processing
                    clr       1,s                 clear flag to indicate update
                    lda       #1                  Flag that mouse has moved
                    sta       <G.MseMv,u
                    ldd       #%00001000*256+3    start at up arrow flag bit, 4 to check for (0-3)
                    pshs      d                   Save check bit & ctr
                    leax      <L0160,pcr          point to keyboard mouse deltas
                    leay      <G.Mouse+Pt.AcY,u   Point to actual mouse Y coord in mouse packet
* Update keyboard mouse co-ordinates according to arrow key pressed
L01A2               bita      <G.KySns,u          desired arrow key down?
                    beq       L01C5               no, move to next key
                    lslb                          Yes, multiply ctr/arrow # * 4 (size of each delta set)
                    lslb                          to point to start of table entry
                    tst       <G.ShftDn,u         SHIFT key pressed too?
                    beq       L01B1               No, check for CTRL
                    incb                          Yes, move table offset to SHIFTed version
                    bra       L01BC               Go get how far we are moving from table

L01B1               tst       <G.CntlDn,u         CTRL key pressed too?
                    beq       L01BC               no, go update mouse cursor position
* <CTRL>-arrow
                    addb      #2                  move ptr to <CTRL> offset (which is actual 16 bit actual mouse coord to use)
                    ldd       b,x                 get control coordinate
                    bra       L01C1               save in mouse packet

* <arrow> (B=0) or <SHIFT>-<arrow> (B=1)
L01BC               ldb       b,x                 Get how many pixels to change mouse coordinate by
                    sex                           Make 16 bit offset, signed
                    addd      ,y                  add it to current coordinate
L01C1               std       ,y                  save updated coordinate
                    ldd       ,s                  get KeySns arrow key bit flag position, and key check counter
L01C5               lsla                          move to next arrow key bit
                    decb                          Dec key check ctr
                    cmpb      #1                  We at left arrow (switching to X coords) yet?
                    bne       L01CD               no, continue
                    leay      -2,y                Yes, point Y to Pt.AcX (Y mouse coordinate)
L01CD               std       ,s                  Save arrow key bit (keysense) & # of arrow keys left to check
                    bpl       L01A2               keep trying until all keys checked (hi bit set once we are done all arrows)
                    puls      d                   purge stack of key bit & key tbl counter
                    ldd       #MaxRows-1          get maximum X coordinate
                    bsr       L0170               If we went past, set to maximum
                    leay      2,y                 move to Y coordinate
                    ldd       #MaxLine            get maximum Y coordinate
                    bsr       L0170               If we went past, set to maximum
* Keyboard mouse on - Non-arrow key comes here (to check F1/F2 fire buttons)
L01DF               lda       <G.KyButt,u         Either F1 or F2 (keyboard mouse fire buttons) down?
                    bne       L0223               yes, clear flag byte on stack & return
                    lda       ,s                  no, get back key pressed (not arrow or F1/F2)
* If keyboard mouse disabled, it comes here
* 6809/6309 note - finish tracking each possible branch from this, but may be able to use LDB instead of TST
L01E6               tst       <G.Clear,u          CLEAR key down? (apparently also flags CTRL-0)
                    beq       L0225               No, exit with current status
                    clr       <G.Clear,u          Yes; clear out clear key flag (since we processing it)
* Check CTRL-0 (CAPS-Lock)
* 6809/6309 note: Should be able to SUBA #$81 here, then DECA's at L01FF, L0208, L0211 (smaller both CPU's+
*   faster on 6309)
                    cmpa      #$81                CTRL-0? (capslock toggle)
                    bne       L01FF               no, keep checking
                    ldb       <G.KySame,u         Yes, same key press we had last run through?
                    bne       L0223               Yes, leave flag alone & return
                    ldx       <G.CurDev,u         get current device's static mem pointer
                    IFNE      H6309
                    eim       #CapsLck,<V.ULCase,x Toggle Capslock enabled/disabled bit
                    ELSE
                    ldb       <V.ULCase,x         Get current keyboard flgas
                    eorb      #CapsLck            Toggle current CapsLock status
                    stb       <V.ULCase,x         Save it back
                    ENDC
                    bra       L0223               Flag special update (mouse/cursor change) & return

* Check CLEAR key (select next window in linked list)
L01FF               cmpa      #$82                was key pressed CLEAR key?
                    bne       L0208               no, check next
                    lbsr      CLEAR               find next window
                    bra       L0223               Flag special update change & return

* Check SHIFT-CLEAR (select previous window in linked list)
L0208               cmpa      #$83                was it SHIFT-CLEAR?
                    bne       L0211               no, check next
                    lbsr      SHFTCLR             yes, find previous window & return with no change flag
                    bra       L0223               Flag special update change & return

* Check CTRL-CLEAR (keyboard mouse on/off toggle)
L0211               cmpa      #$84                keyboard mouse toggle key (CTRL-CLEAR>?
                    bne       L0225               no, return leaving change flag as is
                    ldb       <G.KySame,u         Yes, get same key as last pressed flag
                    bne       L0223               It is the same, flag special update change & return
* EOU is going to have local to window keyboard mouse only - far too much confusion why
*   backspace, etc. no longer work for beginning users. Pro's don't seem to use GUI's and
*   mice at all anyways, and won't miss it either way.
                    ldx       <G.CurDev,u         Get current device's static mem ptr
                    clra                          default keyboard mouse disabled
                    IFNE      H6309
                    eim       #KeyMse,<V.ULCase,x Toggle local keyboard mouse status bit
                    ELSE
                    ldb       <V.ULCase,x         Get current keyboard special flags
                    eorb      #KeyMse             toggle current local Keyboard Mouse status bit
                    stb       <V.ULCase,x         Save new setting
                    ENDC
L0223               clr       1,s                 Flag that a special update (mouse moved or window changed) has happened
L0225               ldb       1,s                 Get current state of move flag (Zero flag set or cleared), restore regs & return
                    puls      pc,u,y,x,d

* Update a bunch of mouse packet stuff (timers, signals)
* Entry: X=PIA address
*        A=keyboard mouse button flags
*        B=mouse button status
*        U=global mem ptr
*        Y=static mem ptr
* Exit:  X,B preserved
*        U=global mem ptr
*        Y=static mem ptr
*        A=modified
L0229               pshs      x,b                 save external mouse button status & PIA addr
                    leax      <G.Mouse,u          Point to mouse packet in Global mem
                    tst       Pt.ToTm,x           Is timeout INIT value 0 (ie off)?
                    lbeq      L02C8               Yes, restore regs & return
                    leas      -5,s                make a buffer for locals
* local stack vars are:
* 0,s = left / right side select (1=left side, 0=none or right side)
* 1,s = High bit is button 1 state
* 2,s = low bit is button 2 state
* 3,s = toggled version Pt.CBSA (the previous button 1 state)
* 4,s = toggled version Pt.CBSB (the previous button 2 state)
                    tfr       a,b                 move keyboard button flags to B
                    lda       V.ULCase,y          Get local keyboard flags
                    bita      #KeyMse             Keyboard mouse active?
                    bne       L024E               yes, go on
                    ldb       #%00000101          Default mask for button 1 & 2 on right mouse/joystick
                    lda       Pt.Actv,x           get active mouse side
                    anda      #%00000010          clear all but left side select
                    sta       ,s                  Save side flag (0=right, 2=left)
                    beq       L0248               If right, bit mask is already correct
                    lslb                          Left, change button 1 & 2 mask for left mouse
L0248               andb      5,s                 check with external mouse button status type
                    tsta                          right side?
                    beq       L024E               yes, skip ahead
                    lsrb                          left side, shift over so we can use same routine
* Bits 0 & 2 of B contain external mouse buttons that are pressed (doesn't
* matter which side)
L024E               clra                          Next 4 lines: High bit of A is fire button 1, low bit of B is fire button 2
                    lsrb
                    rola
                    lsrb
                    std       1,s                 Save both fire button flags
                    bne       L0276               If either/both fire buttons are pressed, skip ahead
                    lda       Pt.TTTo,x           Timeout counter done?
                    beq       L02C6               yes, eat temp stack & exit
                    bsr       L02CA               No, check if either/both fire button state has changed from last time
                    beq       L0262               no, decrement timeout count
                    bsr       L02D3               Yes, update fire button click & timeout info
                    beq       L02AB               if neither button changed state, skip ahead
L0262               dec       Pt.TTTo,x           decrement timeout counter
                    bne       L02AB               not timed out, update last state counts
                    IFNE      H6309
                    clrd
                    clrw
                    ELSE
                    clra
                    clrb
                    ENDC
                    sta       >G.MsSig,u          clear Mouse signal flag
                    std       Pt.TSSt,x           clear time since start counter
                    IFNE      H6309
                    stq       Pt.CCtA,x           clear both buttons click count & time this state
                    ELSE
                    std       Pt.CCtA,x           clear both buttons click count & time this state
                    std       Pt.TTSA,x
                    ENDC
                    std       Pt.TLSA,x           clear both buttons time last state
                    bra       L02C6               Eat temp stack & return

* At least one firebutton is pressed
L0276               lda       Pt.ToTm,x           Re-initialize time till timeout from initial counter
                    sta       Pt.TTTo,x
                    bsr       L02CA               Either fire button change state?
                    beq       L02AB               No, update last state counts
                    bsr       L02D3               Yes, update fire button states, timeouts & counters
                    inc       >WGlobal+G.MsSig    flag mouse button signal
                    IFNE      H6309
                    ldq       <Pt.AcX,x           get actual X & Y coordinates
                    stq       <Pt.BDX,x           copy it to button down X & Y coordinates
                    ELSE
                    ldd       <Pt.AcX,x           get actual X coordinate
                    std       <Pt.BDX,x           copy it to button down X coordinate
                    ldd       <Pt.AcY,x           get actual Y coordinate
                    std       <Pt.BDY,x           copy it to button down Y coordinate
                    ENDC
                    pshs      u                   save ptr to CC mem
                    ldu       <G.CurDev,u         get current device static mem ptr
                    lda       <V.MSigID,u         get process ID requesting mouse button signal
                    beq       L02A9               None, don't set up a signal
                    ldb       <V.MSigSg,u         Get signal code we need to send
                    os9       F$Send              and send it to process
                    bcs       L02A5               If error on Send, leave Mouse signal flag (so we can try again later)
                    clr       <V.MSigID,u         Successful send, erase process # to send signal to
L02A5               clr       >WGlobal+G.MsSig    clear Mouse signal pending flag
L02A9               puls      u                   Get CC mem ptr back
L02AB               ldd       Pt.TTSA,x           Get time this state for both buttons
                    cmpa      #$FF                Button A already at 255?
                    beq       L02B2               Yes, don't change it
                    inca                          No, bump time ctr up
L02B2               cmpb      #$FF                Button B time this state already at 255?
                    beq       L02B7               Yes, don't change it
                    incb                          No, bump time ctr up
L02B7               std       Pt.TTSA,x           Save both buttons updated time this state
                    ldd       Pt.TSSt,x           get current time since start counter
                    IFNE      H6309
                    incd                          Bump it up
                    ELSE
                    addd      #1                  Bump it up
                    ENDC
                    beq       L02C6               If it would have wrapped, leave at 65535
L02C4               std       Pt.TSSt,x           save updated state counter
L02C6               leas      5,s                 purge locals
L02C8               puls      pc,x,b              restore & return

* NOTE: stack offsets +2 here from my note above due to RTS address
* Exit: A=fire button 1 changed state (if <>0)
*       B=fire button 2 changed state (if <>0)
L02CA               ldd       Pt.CBSA,x           get previous button states
                    IFNE      H6309
                    eord      3,s                 Set bits for button state(s) that changed since last time
                    ELSE
                    eora      3,s                 toggle both fire button bits
                    eorb      4,s
                    ENDC
                    std       5,s                 Save them back & return
                    rts

* Update mouse button clock counts & timeouts (happens if either button state has changed)
* Stack is +2 from my note above, due to RTS address being 0-1,s
L02D3               ldd       Pt.TTSA,x           get time of this state for both buttons
                    tst       5,s                 Has button A state changed?
                    beq       L02E9               No, check button B
                    sta       Pt.TLSA,x           Copy time of this state for button A to time last state
                    lda       3,s                 Is button A pressed right now?
                    bne       L02E8               Yes, set time this state to 0
                    lda       Pt.CCtA,x           No, increase counter for button A (leave @ 255 if it goes over)
                    inca
                    beq       L02E9
                    sta       Pt.CCtA,x           Save new button A click ctr
L02E8               clra                          Set button A time this state to 0
L02E9               tst       6,s                 Has button B state changed?
                    beq       L02FD               No, update time this state for both buttons
                    stb       Pt.TLSB,x           Copy time of this state for button B to time last state
                    ldb       4,s                 Is button B pressed right now?
                    bne       L02FC               Yes, set time this state to 0
                    ldb       Pt.CCtB,x           No, increase counter for button B (leave @ 255 if it goes over)
                    incb
                    beq       L02FD
                    stb       Pt.CCtB,x           Save new button B click ctr
L02FC               clrb                          Set button B time this state to 0
L02FD               std       Pt.TTSA,x           Save time this state for both buttons
                    ldd       3,s                 Get current fire button states
                    std       Pt.CBSA,x           Save as "current" fire button state
                    ldd       5,s                 Get button A & B change flags & return
NullIRQ             rts


*
* VTIO IRQ routine - Entered from Clock every 1/60th of a second
*
* The interrupt service routine is responsible for:
*   - Decrementing the tone counter
*   - Select the new active window if needed (LCB NOTE: This should do palette updates as well, with
* HSYNC timing on 6809, to prevent sparklies. Hopefully for both GRFDRV and CoVDG.
*   - Updating graphics cursors if needed
*   - Checking for mouse update
* 6809/6309 - Need to add support for Animate Palette system call as well - LCB
* Also screen hardware changes (new mode, new screen RAM location, palette updates) should all be here as well
*   (or use a VRN based VIRQ?)
ISR                 ldu       <D.CCMem            get ptr to CC mem
                    ldy       <G.CurDev,u         get current device's static mem ptr
                    lbeq      CheckAutoMouse      branch if none (meaning no window is currently created)
                    tst       <G.TnCnt,u          get tone counter
                    beq       CheckScrChange      branch if zero
                    dec       <G.TnCnt,u          else decrement
* Check for any change on screen
* U=Unused now (sitting as NullIRQ ptr) - MAY WANT TO CHANGE TO CUR DEV PTR
* Y=Current Device mem ptr
CheckScrChange
                    leax      <NullIRQ,pcr        set AltIRQ to do nothing routine so other IRQs
                    stx       <D.AltIRQ           can fall through to IOMan polling routine
                    andcc     #^(IntMasks)        re-enable interrupts
                    ldb       <V.ScrChg,y         check screen update request flag (cur screen)
                    beq       L0337               no update needed, skip ahead
                    lda       V.TYPE,y            device a window?
                    bpl       SelNewWindow        no, must be CoVDG, so go on
                    lda       G.GfBusy,u          0 = GrfDrv free, 1 = GrfDrv busy
                    ora       G.WIBusy,u          0 = CoWin free, 1 = CoWin busy
                    bne       L034F               one of the two is busy, can't update, skip
SelNewWindow
                    clra                          WnSpSlct - Select new active window
                    lbsr      L05DA               go execute co-module
                    clr       <V.ScrChg,y         clear screen change flag in device mem
* CHECK IF GFX/TEXT CURSORS NEED TO BE UPDATED
* G.GfBusy = 1 Grfdrv is busy processing something else
* G.WIBusy = 1 CoWin is busy processing something else
* g0000 = # of clock ticks/cursor update constant (2) for 3 ticks: 2,1,0
* G.CntTik = current clock tick for cursor update
L0337               lda       G.CntTik,u          get current clock tick count for cursor updates
                    beq       L034F               if 0, no update required
                    dec       G.CntTik,u          decrement the tick count
                    bne       L034F               if still not 0, don't do update
                    lda       G.GfBusy,u          get GrfDrv busy flag
                    ora       G.WIBusy,u          merge with CoWin busy flag
                    beq       L034A               if both not busy, go update cursors
                    inc       G.CntTik,u          otherwise bump tick count up again
                    bra       L034F               and don't update

L034A               lda       #WnSpUpCr           ($02) update text & mouse cursors
                    lbsr      L05DA               go update cursors through co-module
* Check for mouse update
L034F               equ       *
                    IFNE      H6309
                    tim       #KeyMse,<V.ULCase,y keyboard mouse?
                    ELSE
                    lda       <V.ULCase,y         keyboard mouse?
                    bita      #KeyMse
                    ENDC
                    bne       L0369               branch if so
                    lda       <G.MSmpRt,u         get # ticks until next mouse read
                    beq       L0369               0 means shut off, don't bother
                    deca                          decrement # ticks
                    bne       L0366               still not yet, save tick counter & skip mouse
                    pshs      u,y,x               save dev mem ptr and others
                    lbsr      L0739               go update mouse packet
                    puls      u,y,x               restore regs
                    lda       <G.MSmpRV,u         get # ticks/mouse read reset value
L0366               sta       <G.MSmpRt,u         save updated tick count

* Check keyboard
L0369               equ       *
                    IFNE      H6309
                    clrd                          initialize keysense & same key flag
                    ELSE
                    clra                          initialize keysense & same key flag
                    clrb
                    ENDC
                    std       <G.KySns,u          zero out both G.KySns (key sense bits) & same key flag (G.KySame)
                    IFNE      H6309
                    tim       #KeyMse,<V.ULCase,y Is the keyboard mouse enabled?
                    ELSE
                    pshs      a
                    lda       <V.ULCase,y         is the keyboard mouse enabled?
                    bita      #KeyMse
                    puls      a
                    ENDC
                    beq       L0381               no, try joystick
                    lbsr      FuncKeys            Get status of F1/F2 keys into A
                    sta       <G.KyButt,u         save keyboard/button state
L0381               ldx       >WGlobal+G.JoyEnt   get ptr to joydrv Entry point
                    leau      >G.JoyMem,u         and ptr to its statics
                    jsr       J$MsBtn,x           get mouse button (extended) info
* Here, B now holds the button state of the active mouse side (originally right port only):
*   %10xxxxxx Window Forward flag (button 2 clicked & released, joystick X on right side)
*   %11xxxxxx Window Backward flag (button 2 clicked & released, joystick X on left side) EXPERIMENTAL
*   %00xxbbbb BBBB is the four buttons states from PIA (buttons currently held down)
* High bit set=CLEAR key equivalent, otherwise max of 2 bits set in least sig 4 bits
                    ldu       <D.CCMem            get ptr to CC mem back
                    lda       #$82                Default A to be CLEAR key code (see KL00F6)
                    bitb      #%10000000          Has a window change been requested (either CLEAR or SHIFT-CLEAR equivalent)?
                    beq       L039C               No, check for other things
                    bitb      #%01000000          Backwards?
                    beq       L0397               No, leave A as CLEAR
                    inca                          A=$83 (SHIFT-CLEAR)
L0397               inc       <G.Clear,u          Flag that a CLEAR key is pressed (go to next window or previous window)
                    clr       <G.LastCh,u         Clear repeated key ASCII value
                    bra       n@                  Process as key press
* 6809/6309 - LDA should work (saves a 1 cycle or 2)
L039C               tst       V.PAUS,y            pause screen on?
                    bpl       L03A8               branch if not
                    bitb      #%00000011          any mouse button 1's down? (we can only get here with active mouse side)
                    beq       L03A8               No, check keyboard mouse buttons
                    lda       #C$CR               Yes, load A with carriage return (to unpause)
                    bra       n@                  Treat mouse button 1 press like hitting a key to unpause
* Entry: B=mouse buttons for active mouse side
* ADDED LCB 09/23/2020 - if 2nd button down AND high bit of G.Bt2Clr is set, go to CheckAutoMouse
L03A8               lda       <G.Bt2Clr,u         Is 2nd button to function as CLEAR?
                    bpl       Normal              No, process buttons normally
                    bitb      #%00001100          Yes, Is 2nd button down?
                    lbne      CheckAutoMouse      Yes, skip updating mouse packet, go update mouse cursor
Normal              lda       <G.KyButt,u         Get keyboard mouse fire buttons (F1/F2)
                    lbsr      L0229               Update mouse packet timers, etc. (and signals if needed)
                    tstb                          Any mouse buttons clicked?
                    lbne      CheckAutoMouse      Yes, skip ahead
                    pshs      y,x                 No, save regs
                    lbsr      ReadKys             Get keypress into A (or high bit set in B if button pressed)
                    puls      y,x                 Restore regs
                    bpl       L03C8               branch if normal char received
                    clr       <G.LastCh,u         else clear last character var
                    lbra      CheckAutoMouse      and skip ahead
*** Inserted detection of debugger invocation key sequence here...
L03C8               cmpa      #$9B                CTRL+ALT+BREAK?
                    bne       n@                  no, move on
                    jsr       [>WGlobal+G.BelVec] Yes, Beep
                    os9       F$Debug             And call debugger routine
                    lbra      L044E               go update cursors, clean up & return
n@                  cmpa      <G.LastCh,u         is current ASCII code same as last one pressed?
                    bne       L03DF               no, no keyboard repeat, skip ahead
                    ldb       <G.KyRept,u         get repeat delay constant
                    lbeq      CheckAutoMouse      if keyboard repeat shut off, skip repeat code
                    decb                          repeat delay up?
                    beq       L03DA               branch if so and reset
L03D5               stb       <G.KyRept,u         update delay
                    lbra      CheckAutoMouse      go update cursors, clean up & return

L03DA               ldb       <G.KySpd,u          get reset value for repeat delay
                    bra       L03ED               go update it

L03DF               sta       <G.LastCh,u         store last keyboard character
                    ldb       <G.KyDly,u          get keyboard delay speed
                    tst       <G.KySame,u         same key as last time?
                    bne       L03D5               no, go reset repeat delay
                    ldb       <G.KyDly,u          get time remaining
L03ED               stb       <G.KyRept,u         save updated repeat delay
                    lbsr      L017E               Check for special key updates (keyboard mouse keys, capslock toggle, CLEAR/SHIFT-CLEAR)
                    beq       CheckAutoMouse      Yes, do special update
                    stb       >g00BF,u            No special update, set menu keypress flag
                    ldu       <G.CurDev,u         get ptr to statics in U
                    ldb       <V.EndPtr,u         Get offset to last character read in keyboard buffer
                    leax      >ReadBuf,u          point to start keyboard buffer (128 byte buffer currently)
                    abx                           point to last character in keyboard buffer
                    incb                          And bump that offset by 1 for new key
                    bpl       bumpdon2            hasn't wrapped, skip ahead
                    clrb                          wrapped, reset pointer to start of 128 byte keyboard buffer
bumpdon2            cmpb      <V.InpPtr,u         same as start offset?
                    beq       L0411               yes, don't save updated end pointer (keyboard buffer full)
                    stb       <V.EndPtr,u         no, save updated end pointer
* see if key click set through SS.GIP2 call. We can use B now, as it gets reloaded with something
* else below
ClickChk            ldb       <V.ULCase,u         Get current devices keyboard flags
                    bitb      #KeyClick           Key Click on?
                    beq       L0411               No, go write the character
* Do JSR [>WGlobal+G.BelVec] to do key click, but set up an entry parameter to make it
*   the shortest length, and different pitch than the regular bell. Note that the Bell vector
*   destroys D & Y
                    pshs      a                   Save key
                    jsr       [>WGlobal+G.BelVec] Yes, do special Bell (entry: B=#KeyClick (%00001000)) first
                    puls      a                   restore key
L0411               sta       ,x                  save key in keyboard buffer
                    beq       L0431               skip ahead if keypress is 0 (?Maybe some special keys clear value out?)
* Check for special characters
* LCB NOTE: Since buffered Grfdrv (and hopefully soon CoVDG) is based on "special characters"
*   being ASCII $1F or lower ONLY, we could do that compare here and bypass the special checks
                    cmpa      V.PCHR,u            pause character?
                    bne       L0421               no, keep checking
                    ldx       V.DEV2,u            is there an output path?
                    beq       L0443               no, wake up the process
                    sta       V.PAUS,x            set immediate pause request on device
                    bra       L0443               wake up the process

L0421               ldb       #S$Intrpt           get signal code (3) for key interrupt
                    cmpa      V.INTR,u            is key an interrupt?
                    beq       L042D               yes, send signal
                    decb                          (2) S$Abort signal code for key abort
                    cmpa      V.QUIT,u            is it a key abort?
                    bne       L0431               no, check data ready signal
L042D               lda       V.LPRC,u            get last process ID
                    bra       L0447               send the signal to that process

L0431               lda       <V.SSigID,u         send signal on data ready?
                    beq       L0443               no, just go wake up process
                    ldb       <V.SSigSg,u         else get signal code
                    os9       F$Send              Send to process expecting it
                    bcs       L044E               Error; skip ahead
                    clr       <V.SSigID,u         Success, clear signal ID & return
                    bra       L044E               return

L0443               ldb       #S$Wake             get signal code for wakeup
                    lda       V.WAKE,u            get process ID to wake up
L0447               beq       L044E               no process to wake, return
                    clr       V.WAKE,u            clear it
                    os9       F$Send              send the signal
L044E               ldu       <D.CCMem            get ptr to CC mem
CheckAutoMouse      lda       <G.AutoMs,u         Are we auto-following the mouse with the mouse cursor?
                    beq       L046B               No, skip updating mouse cursor
                    lda       <G.MseMv,u          Yes, get mouse moved flag
                    ora       <G.Mouse+Pt.CBSA,u  Merge with current state of Button A
                    beq       L046B               If neither is set, skip updating mouse cursor, etc.
                    lda       G.GfBusy,u          Check if GrfDrv is busy
                    ora       G.WIBusy,u          and CoWin too
                    bne       L046B               If either is busy, skip updating mouse cursor, etc.
                    lda       #WnSpAMse           ($03) update auto-follow mouse cursor
                    lbsr      L05DA
                    clr       <G.MseMv,u          clear mouse move flag
L046B               orcc      #IntMasks           mask interrupts
                    leax      >ISR,pcr            get IRQ vector
                    stx       <D.AltIRQ           store in AltIRQ & return
                    rts

* Stack offsets used by window search routine
* Eventually want to have "click to activate window"; probably will be in here
                    org       4
f.nbyte             rmb       1                   # of bytes to next entry in table (signed #)
f.tblend            rmb       2                   ptr to end of device table + 1
f.ptrstr            rmb       2                   start of search ptr (if backwards, -1 entry)
f.ptrend            rmb       2                   end of search ptr (if backwards, -1 entry)
*f.ptrcur rmb   2 ptr to current device's device table entry
f.ptrdrv            rmb       2                   ptr to current device's driver
f.ptrchk            rmb       2                   ptr to the device table entry we are currently checking
f.numdve            rmb       1                   number of device table entries in device table
f.end               equ       .

* Prepare for Window search in Device Table
* Point to end of device table
WinSearchInit
                    stb       f.nbyte+2,s         save # bytes to next (neg or pos)
                    ldx       <D.Init             get pointer to init module
                    lda       DevCnt,x            get max # of devices allowed
                    sta       f.numdve+2,s
                    ldb       #DEVSIZ             get size of each device table entry
                    mul                           calculate total size of device table
                    ldy       <D.DevTbl           get device table ptr
                    leax      d,y                 point X to end of devtable + 1
                    stx       f.tblend+2,s        save the ptr & return
                    rts

* CLEAR processor
CLEAR               pshs      u,y,x,d             preserve registers
                    leas      <-f.end,s           make a buffer on stack
                    ldb       #DEVSIZ             get # of bytes to move to next entry (forward)
                    bsr       WinSearchInit       get pointer to devtable
                    stx       f.ptrend,s          save end of devtable
                    sty       f.ptrstr,s          save beginning of devtable
                    bra       FindWin

* Shift-CLEAR processor
SHFTCLR             pshs      u,y,x,d             preserve registers
                    leas      <-f.end,s           make a buffer on the stack
                    ldb       #-DEVSIZ            # of bytes to move next entry (backwards)
                    bsr       WinSearchInit       make ptrs to devtable
* Here, Y points to first entry of device table
* and X points to last entry of device table + 1
                    leay      -DEVSIZ,y           bump Y back by 1 entry (for start of loop)
                    sty       f.ptrend,s          save it
                    leax      -DEVSIZ,x           bump X back for start of loop
                    stx       f.ptrstr,s          save it
* FindWin - Find the next (or previous) window in the device table
* The search takes place just before or after the current window's
* device table entry.
* NOTE: SS.OPEN for current window has changed V.PORT to be the ptr to the
*   current window's entry in the device table
FindWin             ldx       <D.CCMem            get ptr to CC mem
                    ldu       <G.CurDev,x         get active device's static mem ptr
                    lbeq      L0546               if none (no screens), exit without error
                    ldx       V.PORT,u            get device table ptr for current device
                    stx       f.ptrchk,s          save as default we are checking
                    ldd       V$DRIV,x            get ptr to current device driver's module
                    std       f.ptrdrv,s          save it on stack
* Main search loop
L04BA               ldx       f.ptrchk,s          get ptr to device tbl entry we are checking
L04BC               ldb       f.nbyte,s           get # of bytes to next entry (signed)
                    dec       f.numdve,s          + have we exhausted all entries?
                    bmi       L0541               + yes, end
                    leax      b,x                 point to next entry (signed add)
                    cmpx      f.ptrend,s          did we hit end of search table?
                    bne       L04C6               no, go check if it is a screen device
                    ldx       f.ptrstr,s          otherwise wrap around to start of search ptr
* Check device table entry (any entry we can switch to has to have VTIO as
*  the driver)
L04C6               stx       f.ptrchk,s          save new device table ptr we are checking
                    ldd       V$DRIV,x            get ptr to driver
                    cmpd      f.ptrdrv,s          same driver as us? (VTIO)
                    bne       L04BC               no, try next one
                    ldu       V$STAT,x            get ptr to static storage for tbl entry
                    beq       L04BC               there is none, try next one
* Found an initialized device controlled by VTIO that is not current device
                    lda       <V.InfVld,u         is the extra window data in static mem valid?
                    beq       L04BA               no, not good enough, try next one
                    ldx       <V.PDLHd,u          get ptr to list of open paths on device
                    beq       L0536               no open paths, so switch to that device
                    lda       V.LPRC,u            get last active process ID # that used device
                    beq       L0536
* Path's open to device & there is a last process # for that path
                    ldy       <D.PrcDBT           get process descriptor table ptr
                    lda       a,y                 get MSB of ptr to process descriptor last on it
                    beq       L0536               process now gone, so switch to device
                    clrb                          move process desc ptr to Y
                    tfr       d,y
                    lda       >P$SelP,y           get the path # that outputs to the window
                    leay      <P$Path,y           move to the path table local to the process
                    sta       ,s
                    pshs      x
L04FA               ldb       #NumPaths           for every possible path...
                    lda       ,x                  get system path into A
L04FE               decb                          decrement
                    cmpa      b,y                 same?
                    beq       L050F               branch if so
                    tstb                          are we at start of paths?
                    bne       L04FE               branch if not
                    ldx       <PD.PLP,x           get ptr to next path dsc. list (linked list)
                    bne       L04FA               branch if valid
                    puls      x                   else restore X
                    bra       L0536

L050F               puls      x
                    lda       ,s
L0513               sta       ,s
                    cmpa      #$02                is selected path one of the 3 std paths?
                    bhi       L051F               not one of the std 3 paths, skip ahead
                    ldb       #$02                standard error path
                    lda       b,y                 get system path # for local error path
                    bra       L0522

L051F               lda       a,y                 get system path # for local path
                    clrb                          standard in
* X=Ptr to linked list of open paths on device
* A=System path #
* B=Local (to process) path #
* Check if any paths to device are open, if they are we can switch to it
L0522               cmpa      ,x                  path we are checking same as path already open?
                    beq       L0536               on device? yes, go switch to it
                    decb                          bump local path # down
                    bmi       L052D               if no more paths to check, skip ahead
                    lda       b,y                 get system path # for new local path to check
                    bra       L0522               check if it is already open on device

L052D               lda       ,s                  get local path # we started on
                    ldx       <PD.PLP,x           get ptr to path dsc. list (linked list)
                    bne       L0513               there is no path desc list, try next path
                    bra       L04BA               can't switch to it, go to next device tbl entry

L0536               ldx       <D.CCMem            get ptr to CC mem
                    stu       <G.CurDev,x         save new active device
                    clr       G.CrDvFl,x          flag that we are not on active device anymore
                    clr       >g00BF,x            clear CoWin's key was pressed flag (new window)
* If there is only one window, it comes here to allow the text/mouse cursors
* to blink so you know you hit CLEAR or SHIFT-CLEAR
L0541               inc       <V.ScrChg,u         flag device for a screen change
                    bsr       setmouse            Set some mouse defaults (sampling rates, autofollow, device type)
L0546               leas      <f.end,s            purge stack buffer
                    clrb                          clear carry
                    puls      pc,u,y,x,d          restore regs and return

* Initialize mouse (sets global settings for mouse sampling rate, auto follow & device type,
*  based on newly selected window)
* Also called when CLEARing to a new window.
setmouse            pshs      x                   save register used
                    ldd       <V.MSmpl,u          get sample and timeout from win devmem
                    ldx       <D.CCMem            get ptr to CC mem
                    sta       <G.MSmpRt,x         set sample tick count in global mem
                    sta       <G.MSmpRV,x         set sample rate in global mem
                    stb       <G.Mouse+Pt.ToTm,x  set timeout constant in mouse packet
                    ldb       <V.MAutoF,u         get auto follow flag from win devmem
                    stb       <G.AutoMs,x         and set auto follow flag in global mem
                    lda       V.TYPE,u            get device type
                    sta       <G.WinType,x        set it
                    clra
                    puls      pc,x                restore and return

* LCB - moved table here for short branch to Write and Getstat - used much more often than Term
start               lbra      Init
                    lbra      Read
                    bra       Write
                    nop
                    lbra      GetStat
                    lbra      SetStat
                    lbra      Term

* Write
* Entry:
*    A  = character to write
*    Y  = address of path descriptor
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
Write               ldb       <V.ParmCnt,u        are we in the process of getting parameters?
                    lbne      L0600               yes, get next param byte
                    sta       <V.DevPar,u         save off character
                    cmpa      #C$SPAC             space or higher?
                    bhs       CoWrit              yes, normal write
                    cmpa      #$1E                1E or $1F escape code?
                    bhs       L05EF               yes, go process
                    cmpa      #$1B                $1B escape code?
                    beq       L05F3               yes, go handle it
                    cmpa      #$05                $05 escape code? (cursor on/off)
                    beq       L05F3               yep, go handle it
                    cmpa      #C$BELL             Bell?
                    bne       CoWrit              no, control char, process in co-driver
                    jmp       [>WGlobal+G.BelVec] Yes, call bell vector routine

CoWrit              ldb       #CoWrite            ($03) write entry point in co-module
CallCo              lda       <V.DevPar,u         get character stored earlier
L0593               ldx       <D.CCMem            get ptr to CC mem
                    stu       G.CurDvM,x          save dev mem ptr for current device
* Call CoXXX module
* Entry: X=CC global Mem ptr
*        B=vector table offset (0=Init, 3=Write, 6=GetStat,9=SetStat,$C=Term,$F=window Special processing)
*        A=parameter for vector routine (ie sub-function for Special processing, char to write
*          for write, etc.
L0597               pshs      a                   Save parameter for vector we are about to call
                    leax      <G.CoTble,x         point to co-module entry vectors
                    lda       <V.WinType,u        get window type from device mem
                    ldx       a,x                 get vector to proper co-module (CoGrf/Win, CoVDG, etc)
                    puls      a                   Get parameter back
                    beq       L05EB               vector was empty, exit with module not found error
                    leax      b,x                 Point to appropriate branch table entry
                    bsr       L05C0               Flag CoWin busy (if appropriate) and flag we are current device
                    ldb       <V.WinType,u        Get device type
                    beq       L05B4               CoGrf or CoWin; will need to set flags so skip ahead
                    jsr       ,x                  CoVDG,etc. call function in Co Module
L05B0               pshs      cc                  Save error status
                    bra       L05BB               Flag we are not on our device & return with error status from comodule

L05B4               jsr       ,x                  CoGrf/CoWin - call function in Co Module
L05B6               pshs      cc                  Save error status
                    clr       >WGlobal+G.WIBusy   Flag WindInt no longer busy
L05BB               clr       >WGlobal+G.CrDvFl   Flag we are not our on device
                    puls      pc,cc               Restore error status & return

* Flag CoWin busy if appropriate, and flag whether we are current device
*  (so CoXXX knows to actually update viewable screen, or just the screen in memory)
L05C0               pshs      x,b                 Save regs
                    ldx       <D.CCMem            Get CC global mem ptr
                    clr       G.WIBusy,x          Flag CoWin NOT busy as default
                    ldb       <V.WinType,u        get window type (0 = CoWin, 2=CoVDG)
                    bne       L05CE               CoVDG, leave that CoWin is NOT busy
                    incb                          CoWin or CoGrf, flag it as busy
                    stb       G.WIBusy,x
L05CE               clr       G.CrDvFl,x          Default 'we are not current device'
                    cmpu      <G.CurDev,x         Is current device static mem ptr the same as ours?
                    bne       L05D8               No, leave flag as "we are not current device"
                    inc       G.CrDvFl,x          Yes, set flag that we ARE current device
L05D8               puls      pc,x,b              Restore regs & return

* Call window Special Processing routine in CoGrf/CoWin
* U = ptr to CC memory
* A=sub-function to call from Window Special Processing branch table in CoGrf/CoWin
L05DA               pshs      u,y,x               Save regs
                    ldu       <G.CurDev,u         get current device mem ptr
L05DF               ldb       #CoWinSpc           ($0F) Window special processing table offset in CoGrf/CoWin
                    ldx       <D.CCMem            get ptr to CC memory in X
                    bsr       L0597
                    puls      pc,u,y,x            restore regs and return

* Call special window vector in CoWin, without changing U
* Entry: A=sub-function (0=screen has changed,1=update mouse packet,
*   2=update text/gfx cursors,3=update auto follow mouse)
L05E7               pshs      u,y,x               save regs
                    bra       L05DF

L05EB               comb                          Module not found error
                    ldb       #E$MNF
                    rts

* $1E & $1F codes go here
L05EF               cmpa      #$1E                $1E code?
                    beq       Do1E                branch if so
* $1F codes fall through to here
* Escape code handler : Initial code handled by VTIO, any parameters past
* $1B xx are handled by co-module later
* NOTE: Notice that is does NOT update <DevPar,u to contain the param byte,
*  but leaves the initial <ESC> ($1b) code there. The co-module checks it
*  to see it as an ESC, and then checks for the first parameter byte for the
*  required action.
L05F3               leax      <CoWrit,pcr         point to parameter vector entry point
                    ldb       #$01                get parameter count (need 1 to determine code)
                    stx       <V.ParmVct,u        save vector
                    stb       <V.ParmCnt,u        save # param bytes needed before exec'ing vect.
Do1E                clrb                          no error & return
                    rts                           return

* Processing parameters
* A=parameter byte from SCF
* B=# parameter bytes left (not including one in A) (can be large with things like GPLoad)
* U=device mem ptr
L0600               ldx       <V.NxtPrm,u         get ptr of where to put next param byte
                    sta       ,x+                 put it there
                    stx       <V.NxtPrm,u         update pointer
                    decb                          decrement parameter count
                    stb       <V.ParmCnt,u        update it
                    bne       Do1E                if still more to get, exit without error
* B=0, flag to say we are not current device
* We have all parameter bytes we need at this point.
                    ldx       <D.CCMem            get ptr to CC mem
                    bsr       L05C0               Flag CoWin busy (if appropriate) & flag we are current device
                    stu       G.CurDvM,x          Save current device mem ptr
                    ldx       <V.PrmStrt,u        reset next param ptr to start
                    stx       <V.NxtPrm,u
                    ldb       <V.WinType,u        is this device using CoWin?
                    beq       L0624               yes, special processing for CoWin
                    jsr       [<V.ParmVct,u]      go execute parameter handler
                    bra       L05B0

L0624               jsr       [<V.ParmVct,u]
                    bra       L05B6

* GetStat
*
* Entry:
*    A  = function code
*    Y  = address of path descriptor
*    U  = address of device memory area
*    X  = Ptr to callers register stack
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStat             cmpa      #SS.EOF             ($06) EOF check always exits without error
                    beq       SSEOF
                    ldx       PD.RGS,y            All other GetStat's we need caller's registers
                    cmpa      #SS.ComSt           ($28) Get device configuration?
                    beq       GSComSt
                    cmpa      #SS.Joy             ($13) Read joystick? (values/buttons only)
                    beq       GSJoy
                    cmpa      #SS.Mouse           ($89) Read mouse (entire mouse packet)
                    lbeq      GSMouse
                    cmpa      #SS.Ready           ($01) Device ready? (means any keys in keyboard buffer in this case)
                    beq       GSReady
                    cmpa      #SS.KySns           ($27) Special keys downs stauts?
                    beq       GSKySns
                    cmpa      #SS.Montr           ($92) Get current monitor type?
                    beq       GSMontr
                    ldb       #CoGetStt           GetStat offset ($06) to carry over to co-module
                    lbra      L0593

* SS.ComSt GetStat- get baud/parity info. For VTIO devices, the baud byte is always 0 (unused), but the parity
* byte uses the most significant bit: %0xxxxxxx = CoVDG device, %1xxxxxxx = CoWin/CoGrf device
GSComSt             lda       V.TYPE,u            get device type (VTIO device type bit flag)
                    clrb                          clear parity, etc.
                    std       R$Y,x               save in caller's register Y & return
                    rts

* SS.Ready - Return Not Ready error if no keys in keyboard buffer, or B=# of chars in buffer.
GSReady             ldb       <V.EndPtr,u         get input buffer end pointer
                    cmpb      <V.InpPtr,u         anything there?
                    lbeq      NotReady            nope, exit with error
                    bhi       L0660               higher?
                    addb      #$80                nope, add 128 to count
L0660               subb      <V.InpPtr,u         calculate number of characters there
                    stb       R$B,x               save it in register stack
SSEOF               clrb                          clear errors & return
                    rts

* Return special key status
GSKySns             ldy       <D.CCMem            get ptr to CC mem
                    clrb                          clear key code
                    cmpu      <G.CurDev,y         are we the active device?
                    bne       L0678               branch if not
                    ldb       <G.KySns,y          get key codes
L0678               stb       R$A,x               save to caller reg
                    clrb                          return w/o error
                    rts

* GetStat: SS.Montr (get Monitor type)
GSMontr             ldb       >WGlobal+G.MonTyp   get monitor type into D
                    clra
                    std       R$X,x               save in caller's X & return
                    rts

* GetStat: SS.Joy (get joystick X/Y/button values)
* NOTE: While the J$xxx calls may update the first two bytes of special 8 byte device memory,
*  SS.Joy
GSJoy               clrb                          default to no errors
                    leay      ,x                  transfer caller's register ptr to Y (6809/6309 faster than tfr x,y)
                    ldx       <D.CCMem            get ptr to CC mem
                    cmpu      <G.CurDev,x         are we the current active device?
                    beq       GetJoy              if so, go read joysticks
                    clra                          else not buttons down, set X&Y to 0 & return
                    std       R$X,y
                    std       R$Y,y
                    sta       R$A,y
                    rts

* Get button status first
GetJoy              ldx       >WGlobal+G.JoyEnt   Get entry point to JoyDrv co-module
                    pshs      u                   save driver static
                    ldu       <D.CCMem            get ptr to CC mem
                    leau      >G.JoyMem,u         point to JoyDrv's special 8 byte static mem
                    jsr       J$JyBtn,x           call entry point to get button (NOTE: This gets all 4 buttons (both sides))
* Joysticks button states returned in B (least sig 4 bits)
                    puls      u                   restore co-driver static
                    lda       R$X+1,y             Did caller ask for left or right joystick?
                    beq       L06AB               branch if right joystick
                    lsrb                          shift over so same range as if right joystick
L06AB               andb      #%00000101          preserve button bits for current joystick
                    lsrb                          button 1 down? (shifts button 2 to bit 2 too)
                    bcc       L06B2               no, go on
                    orb       #$01                turn on button 1 (if button 2 pressed, both least sig bits now set)
L06B2               stb       R$A,y               save button status to caller (now in lowest two bits)
* Now get actual joystick values (note: IRQs still off)
                    pshs      y                   save ptr to caller's regs
                    lda       R$X+1,y             get switch to indicate right or left joystick (base 0)
                    inca                          now 1 (right) or 2 (left)
                    IFNE      H6309
                    tfr       0,y                 force low res (6 bit read) (same speed, 2 bytes smaller)
                    ELSE
                    ldy       #$0000              force low res (6 bit read)
                    ENDC
                    pshs      u                   save driver static mem
                    ldu       <D.CCMem            get ptr to CC mem
                    ldx       >WGlobal+G.JoyEnt   get address of joystick sub module again
                    leau      >G.JoyMem,u         get ptr to sub module's static mem
                    jsr       J$JyXY,x            call routine in sub module to get 6 bit joystick X/Y
* Now, X = joystick X pos, Y = joystick Y pos
                    puls      u                   restore driver static mem
                    IFNE      H6309
                    ldw       #63                 Y is 63-Y
                    subr      y,w                 W is new Y coord
                    puls      y                   Get ptr to callers regs back
                    stx       R$X,y               Save joystick X in caller's X
                    stw       R$Y,y               Save joystick Y in caller's Y
                    clrb                          No error & return
                    rts
                    ELSE
                    pshs      y                   save joystick Y
                    ldy       2,s                 get ptr to caller's regs
                    stx       R$X,y               save joystick X in caller's X
                    ldd       #63
                    subd      ,s++
                    std       R$Y,y               save joystick Y in caller's Y
                    clrb                          No error & return
                    puls      pc,y
                    ENDC

* GetStat: SS.Mouse (get mouse info)
* Entry:  Y  = address of path descriptor
*         U  = address of device memory area
*         X = pointer to caller's register stack
GSMouse             pshs      u,y,x               Save pointers
                    ldx       <D.CCMem            get ptr to CC mem
                    cmpu      <G.CurDev,x         Are we current active window?
                    beq       L06FA               Yes, skip ahead
* LCB: 6809/6309 - mini stack blast or tfm to clear 32 byte dummy mouse packet instead
* (Or use clear block vector once that is set up)
                    ldy       ,s                  No, get ptr to caller's regs
                    ldb       #Pt.Siz             Init dummy mouse packet on stack to 0's
L06EC               clr       ,-s
                    decb
                    bne       L06EC
                    leax      ,s                  point X to temp zeroed mouse buffer on stack
                    bsr       MovMsPkt
                    leas      <Pt.Siz,s           clean up stack
                    puls      pc,u,y,x            and return

* here the caller is in the current window
* CHANGE G.KYMSE,X TO USE V.ULCase in static mem instead
L06FA               lda       <V.ULCase,u         Get current window bit flags
                    bita      #KeyMse             Keyboard mouse active?
                    bne       L071A               Yes, skip ahead
                    lda       <G.MSmpRV,x         ready to sample?
                    bne       L071A               no, return packet
                    pshs      u,y,x               Save regs
                    bsr       L073B               read mouse
                    puls      u,y,x               Restore regs
                    lda       <G.AutoMs,x         get automouse flag
                    anda      <G.MseMv,x          has mouse moved?
                    beq       L071A               no, return packet
                    lda       #$03                update auto-follow mouse sub-function call
                    lbsr      L05E7               call co-module to update mouse
                    clr       <G.MseMv,x          flag that the mouse hasn't moved
L071A               lda       #$01                'special' co-mod function code: update mouse packet region
                    lbsr      L05E7
                    leax      <G.Mouse,x          move X to point to mouse packet
                    ldy       ,s                  get register stack pointer
                    bsr       MovMsPkt            move packet to caller
                    puls      pc,u,y,x

* Move mouse packet to process
* Entry: Y = ptr to caller's register stack
*        X = ptr to 32 byte mouse packet to send to caller
* Exit: Pt.AcX/Pt.AcY updated, and
MovMsPkt            ldu       R$X,y               get destination pointer
                    ldy       <D.Proc             get process descriptor pointer
                    ldb       P$Task,y            get destination task number
                    clra                          source task number=system task
                    ldy       #Pt.Siz             get length of packet
                    os9       F$Move              move it to the process & return
                    rts

L0739               ldx       <D.CCMem            Get ptr to VTIO global mem
L073B               leax      <G.Mouse,x          Point to mouse packet
                    clra                          clear MSB of mouse resolution
                    ldb       <Pt.Res,x           get resolution (0 = lores, 1 = hires)
                    tfr       d,y                 move mouse res to Y
                    lda       Pt.Actv,x           get mouse side
                    pshs      u,y,x,d             preserve regs
                    ldx       >WGlobal+G.JoyEnt   get ptr to mouse sub module
                    ldu       <D.CCMem            get mem pointer
                    leau      >G.JoyMem,u         and point to mouse sub module statics
                    jsr       J$MsXY,x            Call JoyDrv to get mouse coords
                    pshs      y,x                 Save X,Y coords
                    ldx       6,s                 get ptr to mouse packet back
                    puls      d                   get X value into D
                    leay      <Pt.AcX,x           point X to "current" mouse X,Y coords in mouse packet
                    bsr       L0764               Check/update X  (also sets mouse moved flag)
                    puls      d                   get Y value into D
                    bsr       L0764               Check/update Y (also sets mouse moved flag)
                    puls      pc,u,y,x,d          Restore regs & return

* Entry:
* X=Address of G.Mouse in D.CCMem
* Y=ptr to actual mouse position for axis we are working on
L0764               cmpd      ,y++                compare mouse's current X to Pt.AcX (last position)
                    beq       L0770               Hasn't moved, return
                    std       -2,y                save new value as new Pt.AcX
                    lda       #1                  Flag that mouse has moved
                    sta       <(G.MseMv-G.Mouse),x update mouse moved flag
L0770               rts

SSTone              ldx       >WGlobal+G.SndEnt   get address of sound sub module
                    jmp       S$SetStt,x          go  execute sound Setstat routine in sub module

* Animate Palette?  This obviously isn't implemented yet
SSAnPal             ldx       >WGlobal+G.SndEnt
                    jmp       S$Term,x

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
SetStat             ldx       PD.RGS,y
                    cmpa      #SS.Montr
                    lbeq      SSMontr
                    cmpa      #SS.KySns
                    lbeq      SSKySns
                    cmpa      #SS.Tone
                    beq       SSTone
                    cmpa      #SS.AnPal
                    beq       SSAnPal
                    cmpa      #SS.SSig
                    beq       SSSig
                    cmpa      #SS.MsSig
                    beq       SSMsSig
                    cmpa      #SS.Relea
                    beq       SSRelea
                    cmpa      #SS.Mouse
                    beq       SSMouse
                    cmpa      #SS.GIP
                    lbeq      SSGIP
                    cmpa      #SS.GIP2
                    lbeq      SSGIP               Will branch off once current device test finished
                    cmpa      #SS.Open
                    bne       L07B5
SSOpen              ldx       PD.DEV,y            get device table entry
                    stx       V.PORT,u            save it as port address
L07B5               ldb       #$09                call setstt entry point in co-module
                    lbra      L0593               go do it

* SS.SSig - send signal on data ready
SSSig               pshs      cc                  save interrupt status
* The next line doesn't exist in the NitrOS version
*         clr   <V.SSigID,u
                    lda       <V.InpPtr,u         get input buffer pointer
                    suba      <V.EndPtr,u         get how many chars are there
                    pshs      a                   save it temporarily
                    bsr       L07EC               get current process ID
                    tst       ,s+                 anything in buffer?
                    bne       L07F7               yes, go send the signal
                    std       <V.SSigID,u         save process ID & signal
                    puls      pc,cc               restore interrupts & return

* SS.MsSig - send signal on mouse button
SSMsSig             pshs      cc                  save interrupt status
* The next line doesn't exist in the NitrOS version
*         clr   <V.MSigID,u
                    bsr       L07EC               get process ID
                    ldx       <D.CCMem            get ptr to CC mem
                    cmpu      <G.CurDev,x         are we active device?
                    bne       L07E7               no, save ID & signal
                    tst       >G.MsSig,x          has button been down?
                    bne       L07F3               yes, go send the signal
L07E7               std       <V.MSigID,u         save ID & signal code
                    puls      pc,cc               restore interrupts & return

L07EC               orcc      #IntMasks           disable interrupts
                    lda       PD.CPR,y            get curr proc #
                    ldb       R$X+1,x             get user signal code & return
                    rts

L07F3               clr       >G.MsSig,x          clear mouse button down flag
L07F7               puls      cc                  restore interrupts
                    os9       F$Send              send the signal & return
                    rts

* SS.Relea - release a path from SS.SSig
SSRelea             lda       PD.CPR,y            get curr proc #
                    cmpa      <V.SSigID,u         same as keyboard?
                    bne       L0807               branch if not
                    clr       <V.SSigID,u         clear process ID
L0807               cmpa      <V.MSigID,u         same as mouse?
                    bne       L083D               no, return
                    clr       <V.MSigID,u         else clear process ID & return
                    rts

* SS.Mouse - set mouse sample rate and button timeout
* Entry:
*    R$X = mouse sample rate and timeout
*          MSB = mouse sample rate
*          LSB = mouse button timeout
*    R$Y = mouse auto-follow feature
*          MSB = don't care
*          LSB = auto-follow ($00 = OFF, else = ON)
*
* NOTE: Default mouse params @ $28,u are $0078
*       It modifies the static mem variables (for caller's window) first, and
*       then modifies global memory only if we are the current active device.
SSMouse             ldd       R$X,x               get sample rate & timeout from caller
                    cmpa      #$FF                Leave sample rate as is?
                    beq       L0819               yes, skip ahead
                    sta       <V.MSmpl,u          save new sample rate timeout
L0819               cmpb      #$FF                Leave button timeout as is?
                    beq       L0820               yes, skip ahead
                    stb       <V.MTime,u          save new button timeout
L0820               ldb       R$Y+1,x             get auto-follow flag
                    stb       <V.MAutoF,u         save it
                    ldy       <D.CCMem            get ptr to CC mem
                    cmpu      <G.CurDev,y         are we current device?
                    bne       L083D               no, exit without error
                    stb       <G.AutoMs,y         save auto-follow flag for this dev
                    ldd       <V.MSmpl,u          get sample rate/timeout
                    sta       <G.MSmpRV,y         save it (reset value)
                    sta       <G.MSmpRt,y         save it (current value)
                    stb       <G.Mouse+Pt.ToTm,y  save timeout too
L083D               clrb                          exit without error
                    rts

* SS.GIP
* Added individual settings checking for $FF to leave current setting alone. This way,
* one change change mouse resolution w/o changing the port (or vice versa), change the
* keyboard settings while leaving the mouse alone, etc.
* NOTE: If this system call is called while not on active window, it is ignored & returns
*   without error.
SSGIP               ldy       <D.CCMem            get ptr to CC mem
                    cmpu      <G.CurDev,y         current window?
                    bne       L0866               No, exit w/o error, and w/o changing anything
                    cmpa      #SS.GIP2            Are we doing SS.GIP2 call?
                    beq       SSGIP2              Yes, go do that
                    ldd       R$Y,x               plain SS.GIP; get caller's Y (key repeat info)
                    cmpa      #$FF                Start constant "don't change"?
                    beq       ChkKSpd             Yes, skip to check keyboard delay
                    sta       <G.KyDly,y          Save new keyboard delay setting
ChkKSpd             cmpb      #$FF                Don't change key repeat delay?
                    beq       L0853               Yes, skip to mouse settings
                    stb       <G.KySpd,y          Save new repeat delay
L0853               ldd       R$X,x               get mouse info
                    cmpa      #$FF                Leave mouse resolution alone?
                    beq       ChkMPrt             Yes, check mouse port
                    cmpa      #$01                set for hi res adapter?
                    bgt       L088F               branch to error if greater
                    sta       <G.Mouse+Pt.Res,y   save new resolution value
* B  = mouse port (1 = right, 2 = left, $FF=leave alone)
ChkMPrt             cmpb      #$FF                Leave mouse port alone?
                    beq       L0866               Yes, we are done
                    tstb                          side below legal value?
                    ble       L088F               no, exit with error
                    cmpb      #2                  side below legal value?
                    bgt       L088F               no, exit with error
                    stb       <G.Mouse+Pt.Actv,y  save new side
L0866               clrb                          clear errors & return
                    rts

* SS.GIP2 - additional global parameters. NOTE: As of now, not all proposed features are enabled
* each option is a 2 bit packet, to allow "leave setting alone" option
* X MSB: 0xxxxxxx = Leave current 2nd button function alone
*        10xxxxxx = disable Mouse 2nd button as CLEAR key
*        11xxxxxx = enable Mouse 2nd button as CLEAR key
*        xx0xxxxx = Leave current key click setting alone
*        xx10xxxx = Disable key click on current window
*        xx11xxxx = Enable key click on current window
*   All other bits in X are reserved, and should be set to 0 on entry for now
* Y=$0000 (for now - reserved for screensaver timer in ticks, with $0000 being disabled)
* U=$0000 for now (Ptr to process desc. or suspended process # (maybe?) for screensaver (which uses Y for timer)
*     U=0 means just monitor dimout. This would only be active if Y above is <>0)
* Entry: X=callers register stack ptr
*        Y=VTIO Global mem ptr
*        U=static mem ptr for current window
SSGIP2              lda       R$X,x               Get MSB of X (2nd mouse button feature & keyclick)
                    bita      #%00100000          Leave Key click alone?
                    beq       ChkMsClr            Yes, skip ahead to check for 2nd button as CLEAR
                    bita      #%00010000          Turn it off?
                    beq       NoKyClk             Yes, go turn it off
                    IFNE      H6309
                    oim       #KeyClick,<V.ULCase,u Turn Key click flag on
                    ELSE
                    ldb       <V.ULCase,u         Turn Key click flag on
                    orb       #KeyClick
                    stb       <V.ULCase,u
                    ENDC
                    bra       ChkMsClr            Now check for right Mouse button as CLEAR equivalent

NoKyClk
                    IFNE      H6309
                    aim       #^KeyClick,<V.ULCase,u Turn Key click flag off
                    ELSE
                    ldb       <V.ULCase,u         Turn Key click flag off
                    andb      #^KeyClick
                    stb       <V.ULCase,u
                    ENDC
ChkMsClr            bita      #%10000000          Leave 2nd mouse button function alone?
                    beq       NxGP2Opt            Yes, exit without error
                    bita      #%01000000          Caller want 2nd mouse button function as window change?
                    beq       NoBt2Clr            No, force it off
                    IFNE      H6309
                    oim       #MseCLEAR,<G.Bt2Clr,y Yes, set button 2 as CLEAR flag
                    ELSE
                    ldb       <G.Bt2Clr,y         Yes, set button 2 as CLEAR flag
                    orb       #MseCLEAR
                    stb       <G.Bt2Clr,y
                    ENDC
                    bra       NxGP2Opt            Check next option

NoBt2Clr
                    IFNE      H6309
                    aim       #^MseCLEAR,<G.Bt2Clr,y No, clear right mouse button as CLEAR Key flag
                    ELSE
                    ldb       <G.Bt2Clr,y         No, clear right mouse button as CLEAR Key flag
                    andb      #^MseCLEAR
                    stb       <G.Bt2Clr,y
                    ENDC
* Later, options for screensave autodim, etc. will go here using Y and U registers. Call should
*  set both to 0 for now.
NxGP2Opt            clrb                          Since we are just checking specific bit flags, no possible error
                    rts



* SS.KySns (SetStat)
*   X=0 = normal key operation
*   X=1 = key sense operation. This suspends any keys being transmitted through SCF, and they
*         can only be read through the equivalent GetStat SS.KySns call. Usually used to speed
*         up response in games, it only checks for: SHIFT,CTRL/CLEAR, ALT/@, the four arrow
*         keys and the spacebar
SSKySns             ldd       R$X,x               get Keysense mode user requested
                    beq       L086E               0=normal key operation, save that flag
                    ldb       #$FF                anything else is Key Sense operation
L086E               stb       <V.KySnsFlg,u       save new sense mode
L0871               clrb                          clear errors & return
                    rts

* SS.Montr (SetStat) change monitor type
SSMontr             ldd       R$X,x               get monitor type requested
                    cmpd      #$0002              below legal value?
                    bhi       L088F               no, exit with error
                    lda       <D.VIDMD            get current GIME video mode register
                    anda      #$EF                get rid of monochrome bit
                    bitb      #$02                mono requested?
                    beq       L0885               no, keep checking
                    ora       #$10                switch to monochrome
L0885               sta       <D.VIDMD            update video mode register
                    stb       >WGlobal+G.MonTyp   save new monitor type
                    inc       <V.ScrChg,u         flag a screen change
                    clrb                          clear errors & return
                    rts

* Illegal argument error handler
L088F               comb                          Exit with Illegal Argument error
                    ldb       #E$IllArg
                    rts

CoVDGNm             fcs       /CoVDG/

* Link to proper co-module
* Entry: A = window type (If bit 7 is set, it's a window, else VDG screen)
* Exit: Carry clear if co-module found, carry set if not
FindCoMod
                    sta       V.TYPE,u            save new type
                    bmi       FindWind            if hi-bit if A is set, we're a window
                    pshs      u,y,a               ..else VDG
                    lda       #$02                get code for VDG type window
                    sta       <V.WinType,u        save it
                    leax      <CoVDGNm,pcr        point to CoVDG name
                    bsr       L08D4               link to it if it exists
                    puls      pc,u,y,a            restore regs & return

CoWinNm             fcs       /CoWin/
CoGrfNm             fcs       /CoGrf/      ++
*CC3GfxInt fcs   /CC3GfxInt/ ++

*
* Try CoWin
*
FindWind            pshs      u,y                 preserve regs
                    clra                          set window type
                    sta       <V.WinType,u
                    leax      <CoWinNm,pcr        point to CoWin name
                    lda       #$80                get driver type code
                    bsr       L08D4               try and link it
*++
                    bcc       ok

* Bug fix by Boisy on 08/22/2007 - The three lines below were inserted to check to see
* the nature of the error that occurred fromfailing to link to CoWin/CoGrf.  Since CoWin/CoGrf
* also load GrfDrv, an error other than E$MNF might arise.  We expect an E$MNF if CoGrf is in
* place instead of CoWin, but any other error just gets blown away without the three lines below.
* Now, if any error other than E$MNF is returned from trying to link to CoWin, we don't bother trying
* to link to CoGrf... we just return the error as is.
                    cmpb      #E$MNF              compare the error to what we expect
                    orcc      #Carry              set the carry again (cmpb above clears it)
                    bne       ok                  if the error in B is not E$MNF, just leave this routine
                    leax      <CoGrfNm,pcr        point to CoGrf name
                    lda       #$80
                    bsr       L08D4
*++
ok                  puls      pc,u,y              restore regs and return

L08D2               clrb
                    rts
*
* Check if co-module is in memory
*
L08D4               ldb       <V.PrmStrt,u        any parameter vector?
                    bne       L08D2               no, return
                    pshs      u                   save statics
                    ldu       <D.CCMem            get ptr to CC mem
                    bita      <G.BCFFlg,u         BCFFlg already linked?
                    puls      u                   restore statics
                    bne       L0900               yes, initialize co-module
                    tsta                          Window type device?
                    bpl       L08E8               no, go on
                    clra                          set co-module vector offset for window
L08E8               pshs      y,a                 preserve registers
                    bsr       L0905               try and link module
                    bcc       L08F0               we linked it, go on
                    puls      pc,y,a              restore registers & return error

L08F0               puls      a                   restore vector offset
                    ldx       <D.CCMem            get ptr to CC mem
                    leax      <G.CoTble,x         point to vector offsets
                    sty       a,x                 store co-module entry vector
                    puls      y                   restore path descriptor pointer
                    cmpa      #$02                was it CoWin?
                    bgt       L08D2               no, return
L0900               clrb                          CoInit ($0)
                    lbra      CallCo              send it to co-module

*
* Link or load a co-module
*
L0905               ldd       <D.Proc             get current process descriptor pointer
                    pshs      u,x,d               preserve it along with registers
                    ldd       <D.SysPrc           get system process descriptor pointer
                    std       <D.Proc             save it as current process
                    lda       #Systm+Objct        get codes for link
                    os9       F$Link              link to it
                    ldx       $02,s               get name pointer
                    bcc       L091B               does module exist?
                    ldu       <D.SysPrc           no, get system process descriptor pointer
                    os9       F$Load              load it
L091B               puls      u,x,d               restore regs
                    std       <D.Proc             restore current process descriptor
                    lbcs      L05EB               exit if error from load or link, else return
                    rts

* Keydrv merged into here (2 functions)
* K$FnKey
* This entry point tests for the F1/F2 function keys on a CoCo 3
* keyboard.
* Entry: U=Global mem ptr
* Exit: A = Function keys pressed (Bit 0 = F1, Bit 2 = F2)
*       X = PIA0Base address
*       U = CC Global mem ptr ($1000)
* NOTE: This function does NOT use the KeyDrv 8 byte data area at all.
FuncKeys            ldx       #PIA0Base           get address of PIA #0
                    ldd       #%11011111          A=0 (no F keys default) and strobe column 6 of PIA #0
                    stb       2,x
                    IFNE      H6309
                    tim       #%01000000,0,x      F1 down?
                    ELSE
                    ldb       ,x                  read PIA #0
                    bitb      #%01000000          test for F1 function key
                    ENDC
                    bne       CheckF2             branch if set (key not down)
                    inca                          flag F1 as down
CheckF2             ldb       #%10111111          strobe column #7 PIA #0
                    stb       $02,x
                    IFNE      H6309
                    tim       #%01000000,0,x      F2 down?
                    ELSE
                    ldb       ,x                  read PIA #0
                    bitb      #%01000000          test for F2 function key
                    ENDC
                    bne       L024C
                    ora       #$04                flag F2 as down
L024C               rts


* K$RdKey - read keys if pressed
* Entry: U=Global mem ptr
* Exit: A = key pressed
*       B = $FF (hi bit set actually) is error (like any joystick button pressed instead of a key)
*       U is preserved (Global mem ptr)
*       Y may be modified
*       X is modified
ReadKys             ldx       #PIA0Base           base address of PIA #0
                    ldb       #$FF
                    stb       $02,x               clear all row strobes
                    ldb       ,x                  read Joystick buttons
                    comb                          invert bits so 1=pressed
                    andb      #%00001111          keep only buttons
                    bne       KL0059              branch if button pushed; error routine
                    clr       $02,x               enable all strobe lines
                    lda       ,x                  read PIA #0
                    coma
* Check to see if ANY key is down
                    anda      #%01111111          mask only the joystick comparator
                    beq       NoKey               branch if no keys pressed
* Here, a key is down on the keyboard
                    pshs      dp                  save our DP
                    tfr       u,d                 move global mem ptr to D
                    tfr       a,dp                set DP to the address in regU
                    bsr       EvalMatrix          evaluate the found key matrix
                    puls      dp                  return to system DP
                    bpl       KL005B              normal key, return
NoKey               clra                          Clear out keypress to return to caller
                    ldb       <G.CapLok,u         Get CapsLock key down flag
                    bne       KL0056              branch if down
                    clr       <G.KTblLC,u         Key table entry# last checked (1-3)
                    IFNE      H6309
                    comd
                    ELSE
                    coma
                    comb
                    ENDC
                    sta       <G.LKeyCd,u         last keyboard code
                    sta       <G.2Key1,u          2nd key table storage; $FF=none
                    std       <G.2Key2,u          format (Row/Column)
KL0056              clr       <G.CapLok,u         see above
KL0059              ldb       #$FF
KL005B              rts


* Evaluates the keyboard matrix for a key
* Entry: DP = ptr to CC3 global memory
*        U  = ptr to CC3 global memory (used for index mode references)
* Exit:  X is modified
*        key variables in global mem updated
*        A - key hit
*        CC Negative bit set if key is an ALT key (high bit set in A)
EvalMatrix
                    ldx       #PIA0Base           base value of PIA #0
                    IFNE      H6309
                    clrd
                    ELSE
                    clra
                    clrb
                    ENDC
                    std       <G.ShftDn           shift/CTRL flag; 0=NO $FF=YES
                    std       <G.KeyFlg           PIA bits/ALT flag
* %00000111-Column # (Output, 0-7)
* %00111000-Row # (Input, 0-6)
                    IFNE      H6309
                    comd                          set D to $FFFF
                    ELSE
                    coma
                    comb                          set primary key table
                    ENDC
                    std       <G.Key1             key 1&2 flags $FF=none
                    sta       <G.Key3             key 3     "
                    deca                          ie. lda #%11111110
                    sta       $02,x               strobe one column
KL006E              lda       ,x                  read PIA #0 row states
                    coma                          invert bits so 1=key pressed
                    anda      #$7F                keep only keys, bit 0=off 1=on
                    beq       KL0082              no keys pressed, try next column
                    ldb       #-1                 preset counter to -1
KL0077              incb
                    lsra                          bit test regA
                    bcc       KL007E              no key so branch
                    lbsr      KL010E              convert column/row to matrix value and store it
KL007E              cmpb      #$06                max counter
                    blo       KL0077              loop if more bits to test
KL0082              inc       <G.KeyFlg           counter; used here for column
                    orcc      #Carry              bit marker; disable strobe
                    rol       $02,x               shift to next column
                    bcs       KL006E              not finished with columns so loop
                    lbsr      KL0166              simultaneous check; recover key matrix value
                    bmi       KL00F5              invalid so go
                    cmpa      <G.LKeyCd           last keyboard code
                    bne       KL0095
                    inc       <G.KySame           set same key flag
KL0095              sta       <G.LKeyCd           setup for last key pressed
                    beq       KL00B5              if @ key, use lookup table
                    suba      #$1A                the key value (matrix) of Z
                    bhi       KL00B5              not a letter so go
                    adda      #$1A                restore regA
                    ldb       <G.CntlDn           CTRL flag
                    bne       KL00E0              CTRL is down so go
                    adda      #$40                convert to ASCII value; all caps
                    ldb       <G.ShftDn           shift key flag
                    ldy       <G.CurDev           get current device static memory pointer
                    eorb      <V.ULCase,y         caps lock and keyboard mouse flags
                    andb      #CapsLck            test caps flag
                    bne       KL00E0              not shifted so go
                    adda      #$20                convert to ASCII lower case
                    bra       KL00E0

* not a letter key, use the special keycode lookup table at KL01DC.
* Entry: regA = table index (matrix scancode-26)
KL00B5              ldb       #$03                three entries per key (normal,shift,ctrl)
                    mul                           convert index to table offset
                    lda       <G.ShftDn           shift key flag
                    beq       KL00BF              not shifted so go
                    incb                          adjust offset for SHIFTed entry
                    bra       KL00C5

KL00BF              lda       <G.CntlDn           CTRL flag
                    beq       KL00C5              adjust offset for CONTROL entry
                    addb      #$02
KL00C5              ldx       <G.CurDev           point X to device's static memory
                    lda       <V.KySnsFlg,x       key sense flag
                    beq       KL00D0              not set so go
                    cmpb      #$11                spacebar
                    ble       KL00F3              must be an arrow so go
KL00D0              cmpb      #$4B                ALT key? (was cmpb #$4C)
                    blt       KL00D8              not ALT, CTRL, F1, F2, or SHIFT so go
                    inc       <G.AltDwn           flag special keys (ALT,CTRL)
                    subb      #$06                and adjust offset to skip them
KL00D8              leax      >KL01DC,pcr         decode table
                    lda       b,x
                    bmi       KL00F6              if regA = $81 - $84, special key
* several entries to this routine from any key press; regA is already ASCII
KL00E0              ldb       <G.AltDwn           was ALT flagged?
                    beq       KL00F0              no so go
                    cmpa      #$3F                '?'
                    bls       KL00EE              # or code
                    cmpa      #$5B                '['
                    bhs       KL00EE              capital letter so go
                    ora       #$20                convert to lower case
KL00EE              ora       #$80                set for ALT characters
KL00F0              andcc     #^Negative          not negative
                    rts

KL00F3              orcc      #Negative           set negative
KL00F5              rts

* Flag that a special key was hit (CLEAR, SHIFT-CLEAR, CTRL-CLEAR, CTRL-0)
KL00F6              inc       <G.Clear            Flag special key hit
                    bra       KL00F0

* Calculate arrow keys for key sense byte
KL00FC              pshs      d                   convert column into power of 2
                    clrb
                    orcc      #Carry
                    inca
KL0102              rolb
                    deca
                    bne       KL0102
KL0108              orb       <G.KySns            Merge key to previous value of column
                    stb       <G.KySns
                    puls      pc,d

* Check special keys (Shift, Cntrl, Alt)
KL010E              pshs      d
                    cmpb      #$03                is it row 3?
                    bne       KL011C
                    lda       <G.KeyFlg           get column #
                    cmpa      #$03                is it column 3?; ie up arrow
                    blt       KL011C              if lt must be a letter
                    bsr       KL00FC              its a non letter so bsr
KL011C              lslb                          B*8  8 keys per row
                    lslb
                    lslb
                    addb      <G.KeyFlg           add in the column #
                    cmpb      #$33                ALT?
                    bne       KL012B
                    inc       <G.AltDwn           ALT down flag
                    ldb       #$04
                    bra       KL0108

KL012B              cmpb      #$34                CTRL?
                    bne       KL0135
                    inc       <G.CntlDn           CTRL down flag
                    ldb       #$02
                    bra       KL0108

KL0135              cmpb      #$37                SHIFT?
                    bne       KL013F
                    com       <G.ShftDn           SHIFT down flag
                    ldb       #$01
                    bra       KL0108

* check how many key (1-3) are currently being pressed
KL013F              pshs      x
                    leax      <G.Key1,u           $2D 1st key table
                    bsr       KL014A
                    puls      x
                    puls      pc,d

KL014A              pshs      a
                    lda       ,x
                    bpl       KL0156
                    stb       ,x
                    ldb       #1
                    puls      pc,a

KL0156              lda       1,x
                    bpl       KL0160
                    stb       1,x
                    ldb       #2
                    puls      pc,a

KL0160              stb       2,x
                    ldb       #3
                    puls      pc,a

* simultaneous key test.
* 6309: Might be able to use E/F as 0 and $FF for some flags? (like clr ,y/com ,y)
* Entry: U=CC3 Global Mem ptr
*        X=PIA0Base ($FF00)
*       DP=CC3 Global Mem
KL0166              pshs      y,x,b
                    ldb       <G.KTblLC           key table entry #
                    beq       KL019D
                    leax      <G.2Key1,u          ($2A) point to 2nd key table
                    pshs      b
KL0171              leay      <G.Key1,u           ($2D) point to 1st key table
                    ldb       #$03
                    lda       ,x                  get key #1
                    bmi       KL018F              go if invalid? (no key)
KL017A              cmpa      ,y                  is it a match?
                    bne       KL0184              go if not a matched key
                    clr       ,y
                    com       ,y                  set value to $FF
                    bra       KL018F

KL0184              leay      1,y
                    decb
                    bne       KL017A
                    lda       #$FF
                    sta       ,x
                    dec       <G.KTblLC           key table entry#
KL018F              leax      1,x
                    dec       ,s                  column counter
                    bne       KL0171
                    leas      1,s
                    ldb       <G.KTblLC           key table entry (can test for 3 simul keys)
                    beq       KL019D
                    bsr       KL01C4
KL019D              leax      <G.Key1,u           $2D 1st key table
                    lda       #$03
KL01A2              ldb       ,x+
                    bpl       KL01B5
                    deca
                    bne       KL01A2
                    ldb       <G.KTblLC           key table entry (can test for 3 simul keys)
                    beq       KL01C0
                    decb
                    leax      <G.2Key1,u          $2A 2nd key table
                    lda       b,x
                    bra       KL01BE

KL01B5              tfr       b,a
                    leax      <G.2Key1,u          $2A 2nd key table
                    bsr       KL014A
                    stb       <G.KTblLC
KL01BE              puls      pc,y,x,b

KL01C0              orcc      #Negative           flag negative
                    puls      pc,y,x,b

* Sort 3 byte packet @ G.2Key1 according to sign of each byte
* so that positive #'s are at beginning & negative #'s at end
KL01C4              leax      <G.2Key1,u          $2A 2nd key table
                    bsr       KL01CF              sort bytes 1 & 2
                    leax      1,x
                    bsr       KL01CF              sort bytes 2 & 3
                    leax      -1,x                sort 1 & 2 again (fall thru for third pass)
KL01CF              ldb       ,x                  get current byte
                    bpl       KL01DB              positive - no swap
                    lda       1,x                 get next byte
                    bmi       KL01DB              negative - no swap
                    std       ,x                  swap the bytes
KL01DB              rts

* Special Key Codes Table : 3 entries per key - Normal, Shift, Control
* They are in COCO keyboard scan matrix order; the alphabetic and meta
* control keys are handled elsewhere.  See INSIDE OS9 LEVEL II p.4-1-7
KL01DC              fcb       $40,$60,$00         '@,'`,null
                    fcb       $0c,$1c,$13         UP ARROW:    FF, FS,DC3
                    fcb       $0a,$1a,$12         DOWN ARROW:  LF,SUB,DC2
                    fcb       $08,$18,$10         LEFT ARROW:  BS,CAN,DLE
                    fcb       $09,$19,$11         RIGHT ARROW: HT, EM,DC1
                    fcb       $20,$20,$20         SPACEBAR
                    fcb       $30,$30,$81         '0,'0,$81 (caps lock toggle)
                    fcb       $31,$21,$7c         '1,'!,'|
                    fcb       $32,$22,$00         '2,'",null
                    fcb       $33,$23,$7e         '3,'#,'~
                    fcb       $34,$24,$1d         '4,'$,GS (was null)
                    fcb       $35,$25,$1e         '5,'%,RS (was null)
                    fcb       $36,$26,$1f         '6,'&,US (was null)
                    fcb       $37,$27,$5e         '7,'','^
                    fcb       $38,$28,$5b         '8,'(,'[
                    fcb       $39,$29,$5d         '9,'),']
                    fcb       $3a,$2a,$00         ':,'*,null
                    fcb       $3b,$2b,$7f         ';,'+,DEL
                    fcb       $2c,$3c,$7b         ',,'<,'{
                    fcb       $2d,$3d,$5f         '-,'=,'_
                    fcb       $2e,$3e,$7d         '.,'>,'}
                    fcb       $2f,$3f,$5c         '/,'?,'\
                    fcb       $0d,$0d,$0d         ENTER key
                    fcb       $82,$83,$84         CLEAR key (NextWin, PrevWin, KbdMouse toggle)
                    fcb       $05,$03,$1b         BREAK key (ENQ,ETX,ESC)
                    fcb       $31,$33,$35         F1 key (converts to $B1,$B3,$B5)
                    fcb       $32,$34,$36         F2 key (converts to $B2,$B4,$B6)

                    emod
eom                 equ       *
                    end
