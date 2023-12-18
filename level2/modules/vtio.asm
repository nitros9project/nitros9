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
*   3      2020/04/26  L. Curtis Boyle
* Changed SS.GIP call (should be backwards compatible) to allow individual $FF settings
*   (leave current setting alone) to work for all 4 parameters independently.

                    nam       VTIO
                    ttl       Video Terminal I/O Driver for CoCo 3

* Disassembled 98/09/09 08:29:24 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       /dd/defs/deffile
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       0
edition             set       3

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
* Maybe half intensity? (so AAx10000 where AA: 00="all", 01=Red, 10=Grn, 11=Blue
* Also, I am not sure local window keyboard mouse is fully working - it looks the keysense check
*  routine is checking the global setting only? Not tested yet, though.
* Comment out next line for global keyboard mouse; otherwise, it's on/off
* on a per-window basis.
GLOBALKEYMOUSE      equ       0                   0=Local to window keyboard mouse, 1=Global keyboard mouse

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
                    lbsr      SHFTCLR             get last window memory pointer
                    cmpu      G.CurDev,x          device to be terminated is current?
                    bne       noterm              no, execute terminate routine in co-module
* We are last device that VTIO has active; terminate ourself
* 6809/6309 - I don't think we need to pshs/puls CC - it's not using any of the flags after.
* Just orcc and then replace puls cc with andcc
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
*         andcc #^IRQMask      Turn IRQ's back on
                    puls      cc                  restore IRQs
                    pshs      u,x                 Save regs
                    ldx       #(WGlobal+G.JoyEnt) Point to start of JoyDrv entry/static mem block
                    bsr       TermSub             Terminate JoyDrv
                    ldx       #(WGlobal+G.SndEnt) Point to start of SndDrv entry/static mem block
                    bsr       TermSub             Terminate SndDrv
                    ldx       #(WGlobal+G.KeyEnt) Point to start of KeyDrv entry/static mem block
                    bsr       TermSub             Terminate KeyDrv
                    puls      u,x                 Restore regs
noterm              ldb       #$0C                branch table offset for terminate
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

Init                ldx       <D.CCMem            get ptr to CC mem
                    ldd       <G.CurDev,x         has VTIO itself been initialized?
* 6809/6309 - change to BNE
                    lbne      PerWinInit          yes, don't bother doing it again, just do new window (or VDG) init
                    leax      >SHFTCLR,pcr        point to SHIFT-CLEAR subroutine
                    pshs      x                   save it on stack
                    leax      >setmouse,pcr       get address of setmouse routine
                    tfr       x,d                 Move to D
                    ldx       <D.CCMem            get ptr to CC mem again
                    std       >G.MsInit,x         Save setmouse routine vector
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
* LCB 6809/6309 - Define another bit in Feature Byte 1 or 2 for global vs. local window keyboard
*  mouse, and set that up here.
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
* 6809/6309 use < addressing
                    leax      >KeyDrv,pcr         point to keyboard driver sub module name
                    bsr       LinkSys             link to it (restores U to D.CCMem)
                    sty       >G.KeyEnt,u         save the entry point
                    leau      >G.KeyMem,u         point U to keydrv statics
                    jsr       ,y                  call init routine of sub module (K$Init)
* 6809/6309 use < addressing
                    leax      >JoyDrv,pcr         point to joystick driver sub module name
                    bsr       LinkSys             link to it (restores U to D.CCMem)
                    sty       >G.JoyEnt,u         and save the entry point
                    leau      >G.JoyMem,u         point U to joydrv statics
                    jsr       ,y                  call init routine of sub module (J$Init)
* 6809/6309 use < addressing
                    leax      >SndDrv,pcr         point to sound driver sub module name
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

KeyDrv              fcs       /KeyDrv/       Name of keyboard driver subroutine module
JoyDrv              fcs       /JoyDrv/       Name of joystick driver subroutine module
SndDrv              fcs       /SndDrv/       Name of sound driver subroutine module

* Link to subroutine module
* Entry: X=ptr to module name
LinkSys             lda       #Systm+Objct        system module
                    os9       F$Link              link to it
                    ldu       <D.CCMem            Get ptr to CC mem back
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
* 6809/6309 - use lda instead of tst (same size/faster)
Read                tst       V.PAUS,u            device paused?
                    bpl       read1               no, do normal read
* Here, device is paused; check for mouse button down
* If it is down, we simply return without error.
* 6809/6309 - use lda instead of tst (same size/faster)
                    tst       >(WGlobal+G.Mouse+Pt.CBSA) test current button state A
                    beq       read1               button isn't pressed, do normal read
                    clra                          Button pressed, return w/o error
                    rts

* Check to see if there is a signal-on-data-ready set for this path.
* If so, we return a Not Ready error.
read1               lda       <V.SSigID,u         data ready signal trap set up?
                    lbne      NotReady            yes, exit with not ready error
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
* Check keyboard mouse arrows
* Entry: U=Global mem ptr
*        X=???
*        A=Key that was pressed
* Exit:  E=0 if key was pressed, 1 if none pressed
* Updated for localized keyboard mouse similar to TC9IO
*
L017E               ldb       #$01                flag that no mouse movement happened as default
                    pshs      u,y,x,d             save registers used & flag (and A=key pressed)
                    ldb       <G.KyMse,u          get global keyboard mouse enabled flag
                    beq       L01E6               Not on, skip keyboard mouse processing
* Keyboard mouse is on
                    lda       <G.KySns,u          Keyboard mouse on, get Key Sense byte
                    bita      #%01111000          any arrow key pressed?
                    beq       L01DF               No, skip arrow key processing
                    clr       1,s                 clear flag to indicate update
                    lda       #1                  Flag that mouse has moved
                    sta       <G.MseMv,u
                    ldd       #%00001000*256+3    start at up arrow flag bit, 4 to check for (0-3)
                    pshs      d                   Save check bit & ctr
                    leax      >L0160,pcr          point to keyboard mouse deltas
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
* Non-arrow key comes here
L01DF               lda       <G.KyButt,u         Either F1 or F2 (keyboard mouse fire buttons) down?
                    bne       L0223               yes, clear flag byte on stack & return
                    lda       ,s                  no, get back key pressed
L01E6               tst       <G.Clear,u          CLEAR key down?
                    beq       L0225               yes, get mouse moved flag into B & return
                    clr       <G.Clear,u          no, clear out clear key flag
* Check CTRL-0 (CAPS-Lock)
                    cmpa      #%10000001          CTRL-0? (capslock toggle)
                    bne       L01FF               no, keep checking
                    ldb       <G.KySame,u         Yes, same key press we had last run through?
                    bne       L0223               Yes,flag no update & return
                    ldx       <G.CurDev,u         get current device's static mem pointer
                    IFNE      H6309
                    eim       #CapsLck,<V.ULCase,x Toggle Capslock enabled/disabled bit
                    ELSE
                    ldb       <V.ULCase,x         Get current keyboard flgas
                    eorb      #CapsLck            Toggle current CapsLock status
                    stb       <V.ULCase,x         Save it back
                    ENDC
                    bra       L0223               Flag no mouse/cursor change & return

* Check CLEAR key
L01FF               cmpa      #%10000010          was key pressed CLEAR key?
                    bne       L0208               no, check next
                    lbsr      CLEAR               find next window & return with no change flag
                    bra       L0223

* Check SHIFT-CLEAR
L0208               cmpa      #%10000011          was it SHIFT-CLEAR?
                    bne       L0211               no, check next
                    lbsr      SHFTCLR             yes, find previous window & return with no change flag
                    bra       L0223

* Check CTRL-CLEAR
L0211               cmpa      #%10000100          keyboard mouse toggle key (CTRL-CLEAR>?
                    bne       L0225               no, return leaving change flag as is
                    ldb       <G.KySame,u         Yes, same key as last pressed?
                    bne       L0223               yes, clear change flag & return
* 6809/6309 - see notes in cocovtio.d for using a new SS.GIP2 call to allow setting global
* vs. local keyboard mouse while NitrOS9 is running, vs. having to assemble each version separately
* LCB (not implemented yet)
                    IFNE      GLOBALKEYMOUSE
                    com       <G.KyMse,u          Toggle global keyboard mouse setting
                    ELSE
                    ldx       <G.CurDev,u         Get current device's static mem ptr
                    clra                          default keyboard mouse disabled
                    IFNE      H6309
                    eim       #KeyMse,<V.ULCase,x Toggle local keyboard mouse status bit
                    ELSE
                    ldb       <V.ULCase,x         Get current keyboard special flags
                    eorb      #KeyMse             toggle current local Keyboard Mouse status bit
                    stb       <V.ULCase,x         Save new setting
                    ENDC
                    beq       KeyMOff             Leave A=0 if keyboards mouse OFF
                    deca                          else A=$FF (for ON)
KeyMOff             sta       <G.KyMse,u          Copy window's local keyboard mouse flag into global version
                    ENDC
L0223               clr       1,s                 Clear move flag
L0225               ldb       1,s                 Get current state of move flag, restore regs & return
                    puls      pc,u,y,x,d

* Update a bounch of mouse packet stuff
* Entry: X=PIA address
*        A=keyboard mouse button flags
*        B=mouse button status
*        U=global mem ptr
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
                    tst       <G.KyMse,u          Global keyboard mouse activated?
                    bne       L024E               yes, go on
                    ldb       #%00000101          Default mask for button 1 & 2 on right mouse/joystick
                    lda       Pt.Actv,x           get active mouse side
                    anda      #%00000010          clear all but left side select
                    sta       ,s                  Save side flag
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
                    inc       >WGlobal+G.MsSig    flag mouse signal
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
                    lda       <V.MSigID,u         get process ID requesting mouse signal
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
                    rts                           return

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
                    clra                          special function: select new active window
                    lbsr      L05DA               go execute co-module
                    clr       <V.ScrChg,y         clear screen change flag in device mem
* CHECK IF GFX/TEXT CURSORS NEED TO BE UPDATED
* G.GfBusy = 1 Grfdrv is busy processing something else
* G.WIBusy = 1 CoWin is busy processing something else
* g0000 = # of clock ticks/cursor update constant (2) for 3 ticks: 2,1,0
* G.CntTik = current clock tick for cursor update
L0337               tst       G.CntTik,u          get current clock tick count for cursor updates
                    beq       L034F               if 0, no update required
                    dec       G.CntTik,u          decrement the tick count
                    bne       L034F               if still not 0, don't do update
                    lda       G.GfBusy,u          get GrfDrv busy flag
                    ora       G.WIBusy,u          merge with CoWin busy flag
                    beq       L034A               if both not busy, go update cursors
                    inc       G.CntTik,u          otherwise bump tick count up again
                    bra       L034F               and don't update

L034A               lda       #$02                update cursors sub-function code
                    lbsr      L05DA               go update cursors through co-module
* Check for mouse update
L034F               equ       *
* Major error here. Used regU which points to D.CCMem not G.CurDev. RG
                    IFNE      GLOBALKEYMOUSE
                    tst       <G.KyMse,u          keyboard mouse?
                    ELSE
                    IFNE      H6309
                    tim       #KeyMse,<V.ULCase,y keyboard mouse?
                    ELSE
                    lda       <V.ULCase,y         keyboard mouse?
                    bita      #KeyMse
                    ENDC
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
                    clra
                    clrb
                    ENDC
                    std       <G.KySns,u          initialize keysense & same key flag
* Major error here. Was regU; see above. RG
                    IFNE      GLOBALKEYMOUSE
                    tst       <G.KyMse,u
                    ELSE
                    IFNE      H6309
                    tim       #KeyMse,>V.ULCase,y
                    ELSE
                    pshs      a
                    lda       >V.ULCase,y         is the keyboard mouse enabled?
                    bita      #KeyMse
                    puls      a
                    ENDC
                    ENDC
                    beq       L0381               no, try joystick
                    ldx       >WGlobal+G.KeyEnt   else get ptr to keydrv
                    leau      >G.KeyMem,u         and ptr to its statics
                    jsr       K$FnKey,x           call into it
                    ldu       <D.CCMem            get ptr to CC mem
                    sta       <G.KyButt,u         save keyboard/button state
L0381               ldx       >WGlobal+G.JoyEnt   get ptr to joydrv
* 6809/6309 - since other references know that G.JoyMem is G.JoyEnt+2, we could do leau 2,x
* (smaller/faster)
                    leau      >G.JoyMem,u         and ptr to its statics
                    jsr       J$MsBtn,x           get mouse button info
* Here, B now holds the value from the MsBtn routine in JoyDrv. Which is a table lookup.
                    ldu       <D.CCMem            get ptr to CC mem
                    lda       #%10000010          A = $82
                    cmpb      #%10000000          If joystick/mouse left of center & right button 1, flag forward CLEAR key
                    beq       L0397
                    inca                          A now = $83
                    cmpb      #%11000000          If joystick/mouse right of center & right button 1, flag forward CLEAR key
                    bne       L039C               nope, skip ahead
L0397               inc       <G.Clear,u          Flag that CLEAR key is pressed (go to next window)
                    bra       L03C8

L039C               tst       V.PAUS,y            pause screen on?
                    bpl       L03A8               branch if not
                    bitb      #%00000011          any mouse buttons down?
                    beq       L03A8               branch if not
                    lda       #C$CR               load A with carriage return
* 6809/6309 - since we just loaded A with $0D, skip jumping to L03C8 and go straight to
*  n@ (slightly faster)
                    bra       L03C8

L03A8               lda       <G.KyButt,u         Get keyboard mouse fire buttons (F1/F2)
                    lbsr      L0229
                    tstb
                    lbne      L044E
                    pshs      u,y,x
                    ldx       >WGlobal+G.KeyEnt
                    leau      >G.KeyMem,u
                    jsr       K$RdKey,x           call Read Key routine
                    puls      u,y,x
                    bpl       L03C8               branch if valid char received
                    clr       <G.LastCh,u         else clear last character var
* 6809/6309 - would a BRA work?
                    lbra      L044E

*** Inserted detection of debugger invocation key sequence here...
L03C8               cmpa      #$9B                CTRL+ALT+BREAK?
                    bne       n@                  no, move on
                    jsr       [>WGlobal+G.BelVec] Yes, Beep
                    os9       F$Debug             And call debugger routine
* 6809/6309 - would a BRA work?
                    lbra      L044E               go update cursors, clean up & return
n@
***
                    cmpa      <G.LastCh,u         is current ASCII code same as last one pressed?
                    bne       L03DF               no, no keyboard repeat, skip ahead
                    ldb       <G.KyRept,u         get repeat delay constant
                    beq       L044E               if keyboard repeat shut off, skip repeat code
                    decb                          repeat delay up?
                    beq       L03DA               branch if so and reset
L03D5               stb       <G.KyRept,u         update delay
                    bra       L044E               go update cursors, clean up & return

L03DA               ldb       <G.KySpd,u          get reset value for repeat delay
                    bra       L03ED               go update it

L03DF               sta       <G.LastCh,u         store last keyboard character
                    ldb       <G.KyDly,u          get keyboard delay speed
                    tst       <G.KySame,u         same key as last time?
                    bne       L03D5               no, go reset repeat delay
                    ldb       <G.KyDly,u          get time remaining
L03ED               stb       <G.KyRept,u         save updated repeat delay
                    lbsr      L017E
                    beq       L044E
                    ldb       #$01                This may be wrong because regB was created in sub RG
                    stb       >g00BF,u            menu keypress flag
                    ldu       <G.CurDev,u         get ptr to statics in U
                    ldb       <V.EndPtr,u
                    leax      >ReadBuf,u          point to keyboard buffer
                    abx                           move to proper offset
                    incb                          inc keyboard buffer ptr
                    bpl       bumpdon2            hasn't wrapped, skip ahead
                    clrb                          reset pointer
bumpdon2            cmpb      <V.InpPtr,u         same as start?
                    beq       L0411               yep, go on
                    stb       <V.EndPtr,u         save updated pointer
L0411               sta       ,x                  save key in buffer
                    beq       L0431               go on if it was 0
* Check for special characters
                    cmpa      V.PCHR,u            pause character?
                    bne       L0421               no, keep checking
                    ldx       V.DEV2,u            is there an output path?
                    beq       L0443               no, wake up the process
                    sta       V.PAUS,x            set immediate pause request on device
                    bra       L0443               wake up the process

L0421               ldb       #S$Intrpt           get signal code for key interrupt
                    cmpa      V.INTR,u            is key an interrupt?
                    beq       L042D               branch if so (go send signal)
                    ldb       #S$Abort            get signal code for key abort
                    cmpa      V.QUIT,u            is it a key abort?
                    bne       L0431               no, check data ready signal
L042D               lda       V.LPRC,u            get last process ID
                    bra       L0447               go send the signal

L0431               lda       <V.SSigID,u         send signal on data ready?
                    beq       L0443               no, just go wake up process
                    ldb       <V.SSigSg,u         else get signal code
                    os9       F$Send
                    bcs       L044E
                    clr       <V.SSigID,u         clear signal ID
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
                    lda       #$03
                    lbsr      L05DA
                    clr       <G.MseMv,u          clear mouse move flag
L046B               orcc      #IntMasks           mask interrupts
                    leax      >ISR,pcr            get IRQ vector
                    stx       <D.AltIRQ           and store in AltIRQ
                    rts                           return


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
*
* The search takes place just before or after the current window's
* device table entry.
*
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
                    clr       g000A,x             flag that we are not on active device anymore
                    clr       >g00BF,x            clear CoWin's key was pressed flag (new window)
* If there is only one window, it comes here to allow the text/mouse cursors
* to blink so you know you hit CLEAR or SHIFT-CLEAR
L0541               inc       <V.ScrChg,u         flag device for a screen change
                    bsr       setmouse            check mouse
L0546               leas      <f.end,s            purge stack buffer
                    clrb                          clear carry
                    puls      pc,u,y,x,d          restore regs and return

* Initialize mouse
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
                    IFEQ      GLOBALKEYMOUSE
* Added: get window's keyboard mouse flag and update global keyboard mouse
                    IFNE      H6309
                    tim       #KeyMse,<V.ULCase,u keyboard mouse?
                    ELSE
                    lda       <V.ULCase,u         keyboard mouse?
                    bita      #KeyMse
                    ENDC
                    bne       setmous2
                    clra
                    fcb       $8c                 CMPX opcode (skip 2 bytes)
setmous2            lda       #$FF
                    sta       <G.KyMse,x
                    ENDC
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
                    bhs       CoWrite             yes, normal write
                    cmpa      #$1E                1E or $1F escape code?
                    bhs       L05EF               yes, go process
                    cmpa      #$1B                $1B escape code?
                    beq       L05F3               yes, go handle it
                    cmpa      #$05                $05 escape code? (cursor on/off)
                    beq       L05F3               yep, go handle it
                    cmpa      #C$BELL             Bell?
                    bne       CoWrite             no, control char, process in co-driver
                    jmp       [>WGlobal+G.BelVec] Yes, call bell vector routine

CoWrite             ldb       #$03                write entry point in co-module
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
L05DF               ldb       #$0F                Window special processing table offset in CoGrf/CoWin
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
L05F3               leax      <CoWrite,pcr        point to parameter vector entry point
                    ldb       #$01                get parameter count (need 1 to determine code)
                    stx       <V.ParmVct,u        save vector
                    stb       <V.ParmCnt,u        save # param bytes needed before exec'ing vect.
Do1E                clrb                          no error & return
                    rts                           return

* Processing parameters
* A=parameter byte from SCF
* B=# parameter bytes left (not including one in A)
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
                    bsr       L05C0
                    stu       G.CurDvM,x
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
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
GetStat             cmpa      #SS.EOF
                    beq       SSEOF
                    ldx       PD.RGS,y
                    cmpa      #SS.ComSt
                    beq       GSComSt
                    cmpa      #SS.Joy
                    beq       GSJoy
                    cmpa      #SS.Mouse
                    lbeq      GSMouse
                    cmpa      #SS.Ready
                    beq       GSReady
                    cmpa      #SS.KySns
                    beq       GSKySns
                    cmpa      #SS.Montr
                    beq       GSMontr
                    ldb       #$06                carry over to co-module
                    lbra      L0593

* SS.ComSt - get baud/parity info
GSComSt             lda       V.TYPE,u            get device type
                    clrb                          clear parity, etc.
                    std       R$Y,x               save in caller's register Y & return
                    rts

GSReady             ldb       <V.EndPtr,u         get input buffer end pointer
                    cmpb      <V.InpPtr,u         anything there?
                    beq       NotReady            nope, exit with error
                    bhi       L0660               higher?
                    addb      #$80                nope, add 128 to count
L0660               subb      <V.InpPtr,u         calculate number of characters there
                    stb       R$B,x               save it in register stack
SSEOF               clrb                          clear errors & return
                    rts

NotReady            comb                          Return with Not Ready error
                    ldb       #E$NotRdy
                    rts

* Return special key status
*        X = pointer to caller's register stack
GSKySns             ldy       <D.CCMem            get ptr to CC mem
                    clrb                          clear key code
                    cmpu      <G.CurDev,y         are we the active device?
                    bne       L0678               branch if not
                    ldb       <G.KySns,y          get key codes
L0678               stb       R$A,x               save to caller reg
                    clrb                          return w/o error
                    rts

* GetStat: SS.Montr (get Monitor type)
*        X = pointer to caller's register stack
GSMontr             ldb       >WGlobal+G.MonTyp   get monitor type into D
                    clra
                    std       R$X,x               save in caller's X & return
                    rts

* GetStat: SS.JOY (get joystick X/Y/button values)
*        X = pointer to caller's register stack
GSJoy               clrb                          default to no errors
                    leay      ,x                  transfer caller's register ptr to Y (6809/6309 faster than tfr x,y)
                    ldx       <D.CCMem            get ptr to CC mem
                    cmpu      <G.CurDev,x         are we the current active device?
                    beq       GetJoy              if so, go read joysticks
                    clra                          else D = 0
                    std       R$X,y               X pos = 0
                    std       R$Y,y               Y pos = 0
                    sta       R$A,y               no buttons held down
                    rts

* Get button status first
GetJoy              ldx       >WGlobal+G.JoyEnt
                    pshs      u                   save driver static
                    ldu       <D.CCMem            get ptr to CC mem
                    leau      >G.JoyMem,u         point to subroutine module's static mem
                    jsr       J$JyBtn,x           call entry point to get button
* Joysticks button states returned in B
                    puls      u                   restore driver static
                    lda       R$X+1,y             left or right?
                    beq       L06AB               branch if right joystick
                    lsrb                          shift over so same range as if right joystick
L06AB               andb      #$05                preserve button bits
                    lsrb                          button 1 down? (shifts button 2 to bit 2 too)
                    bcc       L06B2               no, go on
                    orb       #$01                turn on button 1
L06B2               stb       R$A,y               save button status to caller
* Now get actual joystick values (note: IRQs still off)
                    pshs      y                   save ptr to caller's regs
                    lda       R$X+1,y             get switch to indicate left or right joystick
                    inca                          now 1 or 2
                    ldy       #$0000              force low res??
                    pshs      u                   save driver static mem
                    ldu       <D.CCMem            get ptr to CC mem
                    ldx       >WGlobal+G.JoyEnt   get address of joystick sub module
                    leau      >G.JoyMem,u         get ptr to sub module's static mem
                    jsr       J$JyXY,x            call routine in sub module to get joy X/Y
* X = joystick X pos, Y = joystick Y pos
                    puls      u                   restore driver static mem
* 6309 - don't pshs y, do ldw #63 / subr y,w and stw R$Y,y instead
                    pshs      y                   save joystick Y
                    ldy       2,s                 get ptr to caller's regs
                    stx       R$X,y               save joystick X in caller's X
                    ldd       #63
                    subd      ,s++
                    std       R$Y,y               save joystick Y in caller's Y
                    clrb                          No error & return
                    puls      pc,y

* GetStat: SS.Mouse (get mouse info)
*        X = pointer to caller's register stack
GSMouse             pshs      u,y,x               Save U, Y and ptr to caller's register stack
                    ldx       <D.CCMem            get ptr to CC mem
                    cmpu      <G.CurDev,x         is caller in current window?
                    beq       L06FA               branch if so
                    ldy       ,s                  get ptr to caller's regs
                    ldb       #Pt.Siz             size of packet
L06EC               clr       ,-s                 make room on stack
                    decb
                    bne       L06EC
                    leax      ,s                  point X to temp mouse buffer on stack
                    bsr       MovMsPkt
                    leas      <Pt.Siz,s           clean up stack
                    puls      pc,u,y,x            and return

* here the caller is in the current window
L06FA               tst       <G.KyMse,x          Keyboard mouse active?
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
                    jmp       S$SetStt,x          go  execute routine in sub module

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
                    cmpa      #SS.ComSt
                    lbeq      SSComSt
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
                    ldb       R$X+1,x             get user signal code
                    rts                           return

L07F3               clr       >G.MsSig,x          clear mouse button down flag
L07F7               puls      cc                  restore interrupts
                    os9       F$Send              send the signal
                    rts                           return

* SS.Relea - release a path from SS.SSig
SSRelea             lda       PD.CPR,y            get curr proc #
                    cmpa      <V.SSigID,u         same as keyboard?
                    bne       L0807               branch if not
                    clr       <V.SSigID,u         clear process ID
L0807               cmpa      <V.MSigID,u         same as mouse?
                    bne       L0871               no, return
                    clr       <V.MSigID,u         else clear process ID
                    rts                           return

* SS.Mouse - set mouse sample rate and button timeout
*
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
                    cmpa      #$FF                sample rate 256?
                    beq       L0819               yes, can't have it so go on
                    sta       <V.MSmpl,u          save new timeout
L0819               cmpb      #$FF                timeout 256?
                    beq       L0820               yes, can't have it so go on
                    stb       <V.MTime,u          save new timeout
L0820               ldb       R$Y+1,x             get auto-follow flag
                    stb       <V.MAutoF,u         save it was MS.Side wrong RG
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
SSGIP               ldy       <D.CCMem            get ptr to CC mem
                    cmpu      <G.CurDev,y         current window?
                    bne       L0866               branch if not
                    ldd       R$Y,x               get caller's Y (key repeat info)
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
L0866               clrb                          clear errors
                    rts                           and return

* SS.KySns - setstat???
SSKySns             ldd       R$X,x               get monitor type requested
                    beq       L086E               below legal value?
                    ldb       #$FF                no, exit with error
L086E               stb       <V.KySnsFlg,u       save new sense mode
L0871               clrb                          clear errors & return
                    rts

* SS.Montr - change monitor type
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
L088F               comb                          set carry for error
                    ldb       #E$IllArg           get illegal argument error code
                    rts                           return with it

* SS.ComSt - set baud/parity params
SSComSt             ldd       R$Y,x               get requested window type
                    eora      V.TYPE,u            same type as now?
                    anda      #$80                trying to flip from window to VDG?
                    bne       L088F               yes, error
                    lda       R$Y,x               no, get requested window type again
                    bsr       FindCoMod           go make sure co-module for new type exists
                    lbcc      L07B5               carry it over to co-module
                    rts                           return

CoVDG               fcs       /CoVDG/

*
* Link to proper co-module
* Try CoVDG first
*
* Entry: A = window type (If bit 7 is set, it's a window, else VDG screen)
*
FindCoMod
                    sta       V.TYPE,u            save new type
                    bmi       FindWind            if hi-bit if A is set, we're a window
                    pshs      u,y,a               ..else VDG
                    lda       #$02                get code for VDG type window
                    sta       <V.WinType,u        save it
                    leax      <CoVDG,pcr          point to CoVDG name
                    bsr       L08D4               link to it if it exists
                    puls      pc,u,y,a            restore regs & return

CoWin               fcs       /CoWin/
CoGrf               fcs       /CoGrf/ ++
*CC3GfxInt fcs   /CC3GfxInt/ ++

*
* Try CoWin
*
FindWind            pshs      u,y                 preserve regs
                    clra                          set window type
                    sta       <V.WinType,u
                    leax      <CoWin,pcr          point to CoWin name
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

                    leax      <CoGrf,pcr          point to CoGrf name
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
L0900               clrb
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

                    emod
eom                 equ       *
                    end
