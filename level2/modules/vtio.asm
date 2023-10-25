********************************************************************
* VTIO - Video Terminal I/O Driver for CoCo 3
*
* $Id$
*
* NOTE:  CODE ISSUES FOUND!!
* "Animate Palette?  This obviously isn't implemented yet"
* Look at this code.  Why is this calling an entry point in
* SNDDRV???
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

                    nam       VTIO
                    ttl       Video Terminal I/O Driver for CoCo 3

* Disassembled 98/09/09 08:29:24 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    use       cocovtio.d
                    endc

tylg                set       Drivr+Objct
atrv                set       ReEnt+rev
rev                 set       0
edition             set       2

* Comment out next line for global keyboard mouse; otherwise, it's on/off
* on a per-window basis.
GLOBALKEYMOUSE      equ       1

                    mod       eom,name,tylg,atrv,start,CC3DSiz

                    fcb       EXEC.+UPDAT.

name                fcs       /VTIO/
                    fcb       edition

start               lbra      Init
                    lbra      Read
                    lbra      Write
                    lbra      GetStat
                    lbra      SetStat

* Term
*
* Entry:
*    U  = address of device memory area
*
* Exit:
*    CC = carry set on error
*    B  = error code
*
Term                equ       *
                    ldx       <D.CCMem            get ptr to CC memory
                    cmpu      G.CurDev,x          device to be terminated is current?
*         cmpu  >WGlobal+G.CurDev	device to be terminated is current?
                    bne       noterm              no, execute terminate routine in co-module
                    lbsr      SHFTCLR             get last window memory pointer
                    cmpu      G.CurDev,x          device to be terminated is current?
*         cmpu  >WGlobal+G.CurDev	we the only window left?
                    bne       noterm              no, execute terminate routine in co-module
* We are last device that VTIO has active; terminate ourself
                    pshs      cc
                    orcc      #IRQMask
                    ifne      H6309
                    clrd
                    else
                    clra
                    clrb
                    endc
                    std       G.CurDev,x
*         std   >WGlobal+G.CurDev
*         ldx   <D.Clock		change altirq routine to go to clock
                    ldx       G.OrgAlt,x          get original D.AltIRQ address
                    stx       <D.AltIRQ
                    puls      cc                  restore IRQs

                    pshs      u,x
                    ldx       #(WGlobal+G.JoyEnt)
                    bsr       TermSub
                    ldx       #(WGlobal+G.SndEnt)
                    bsr       TermSub
                    ldx       #(WGlobal+G.KeyEnt)
                    bsr       TermSub
                    puls      u,x
noterm              ldb       #$0C                branch table offset for terminate
                    lbra      CallCo              go to terminate in co-module

* Call terminate routine in subroutine module (KeyDrv/JoyDrv/SndDrv)
* X  = addr in statics of entry
TermSub             leau      2,x                 point U to static area for sub module
                    ldx       ,x                  get entry pointer at ,X
                    jmp       $03,x               call term routine in sub module

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
Init                ldx       <D.CCMem            get ptr to CC mem
                    ldd       <G.CurDev,x         has VTIO itself been initialized?
                    lbne      PerWinInit          yes, don't bother doing it again
* VTIO initialization code - done on the first init of ANY VTIO device
*         leax  >ISR,pcr	set up AltIRQ vector in DP
*         stx   <D.AltIRQ
                    leax      >SHFTCLR,pcr        point to SHIFT-CLEAR subroutine
                    pshs      x                   save it on stack
                    leax      >setmouse,pcr       get address of setmouse routine
                    tfr       x,d
                    ldx       <D.CCMem            get ptr to CC mem
                    std       >G.MsInit,x
                    puls      b,a                 get address of SHIFT-CLEAR subroutine
                    std       >G.WindBk,x         save its vector
                    stu       <G.CurDev,x
                    lbsr      setmouse            initialize mouse

                    lda       #$02
                    sta       G.CurTik,x          save # ticks between cursor(s)updates
                    inc       <G.Mouse+Pt.Valid,x set mouse packet to invalid
                    ldd       #$0178              default to right mouse/time out value
                    std       <G.Mouse+Pt.Actv,x

                    ldd       #$FFFF              initialize keyboard values
                    std       <G.LKeyCd,x         last keyboard code & key repeat counter inactive
                    std       <G.2Key2,x
                    ldd       <D.Proc             get cur proc desc ptr in D
                    pshs      u,y,x,b,a           save regs

* Added to allow patching for RGB/CMP/Mono and Key info - BGP
* Uses new init module format to get monitor type and key info

                    ldy       <D.Init             get init module ptr
                    lda       MonType,y           get monitor type byte 0,1,2
                    sta       <G.MonTyp,x         save off
                    ldd       MouseInf,y          get mouse information
                    sta       <G.Mouse+Pt.Res,x   save off hi-res/lo-res flag
                    stb       <G.Mouse+Pt.Actv,x  save off left/right
                    ldd       KeyRptS,y           get key repeat start/delay constant
                    sta       <G.KyRept,x         set first delay
                    std       <G.KyDly,x          set initial and 2ndary constants

                    ldd       <D.SysPrc           get system process desc ptr
                    std       <D.Proc             and make current proc
                    leax      >KeyDrv,pcr         point to keyboard driver sub module name
                    bsr       LinkSys             link to it
* U = ptr to CC mem
                    sty       >G.KeyEnt,u         and save the entry point
                    leau      >G.KeyMem,u         point U to keydrv statics
                    jsr       ,y                  call init routine of sub module
                    leax      >JoyDrv,pcr         point to joystick driver sub module name
                    bsr       LinkSys             link to it
* U = ptr to CC mem
                    sty       >G.JoyEnt,u         and save the entry point
                    leau      >G.JoyMem,u         point U to joydrv statics
                    jsr       ,y                  call init routine of sub module
                    leax      >SndDrv,pcr         point to sound driver sub module name
                    bsr       LinkSys             link to it
* U = ptr to CC mem
                    sty       >G.SndEnt,u         and save the entry point
                    leau      >G.SndMem,u         point U to sound statics
                    jsr       ,y                  call init routine of sub module
                    puls      u,y,x,b,a           restore saved regs
                    std       <D.Proc             and restore current process

                    ldx       <D.AltIRQ           get original D.AltIRQ address
                    stx       >WGlobal+G.OrgAlt   save in window globals for later
                    leax      >ISR,pcr            set up AltIRQ vector in DP
                    stx       <D.AltIRQ

* This code is executed on init of every window
* U = device memory area
PerWinInit
                    ldd       #$0078              set default SS.Mouse parameters
                    std       <V.MSmpl,u          (Mouse sample rate & fire button timeout value)
                    ldd       <IT.PAR,y           get parity/baud bytes from dev desc
                    std       <V.DevPar,u         save it off in our static
*** Find CC3GfxInt
*         pshs  u,y,a		..else VDG
*         lda   #$02		get code for VDG type window
*         sta   <V.WinType,u	save it
*         leax  <CC3GfxInt,pcr	point to CC3GfxInt name
*         lbsr  L08D4		link to it if it exists
*         puls  u,y,a		restore regs & return
***
                    lbra      FindCoMod           go find and init co-module

KeyDrv              fcs       /KeyDrv/
JoyDrv              fcs       /JoyDrv/
SndDrv              fcs       /SndDrv/

LinkSys             lda       #Systm+Objct        system module
                    os9       F$Link              link to it
                    ldu       <D.CCMem            get ptr to CC mem
                    rts


* Read
*
* NOTE:
* This just reads keys from the buffer. The physical reading
* of keys is done by the IRQ routine.
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
Read                tst       V.PAUS,u            device paused?
                    bpl       read1               no, do normal read
* Here, device is paused; check for mouse button down
* If it is down, we simply return without error.
                    tst       >(WGlobal+G.Mouse+Pt.CBSA) test current button state A
                    beq       read1               button isn't pressed, do normal read
                    clra                          clear carry (no error)
                    rts                           return

* Check to see if there is a signal-on-data-ready set for this path.
* If so, we return a Not Ready error.
read1               lda       <V.SSigID,u         data ready signal trap set up?
                    lbne      NotReady            yes, exit with not ready error
                    leax      >ReadBuf,u          point to keyboard buffer
                    ldb       <V.InpPtr,u         get current position in keyboard buffer
                    orcc      #IRQMask            disable IRQs
                    cmpb      <V.EndPtr,u         same as end of buffer ptr (no keys in buffer)?
                    beq       ReadSlp             yes, no new chars waiting, sleep/scan for them
* Character(s) waiting in buffer
                    abx                           move ptr to character
                    lda       ,x                  get character from buffer
                    incb                          inc keyboard buffer ptr
                    bpl       bumpdon             if it hasn't wrapped 128 bytes, go save it
*         bsr   ChkWrap		check for wrap
                    clrb
bumpdon             stb       <V.InpPtr,u         save updated keyboard buffer ptr
                    andcc     #^(IRQMask!Carry)   restore IRQ and clear carry
                    rts                           return with A containing char read

* Nothing is in input buffer so wait for it
ReadSlp             lda       V.BUSY,u            get active process id #
                    sta       V.WAKE,u            save as process id # to wake up when data read
                    andcc     #^IRQMask           restore IRQ
                    ldx       #$0000              sleep till data ready
                    os9       F$Sleep
                    clr       V.WAKE,u            signal gotten, disable process # to wake up
                    ldx       <D.Proc             get current proc desc ptr
                    ldb       <P$Signal,x         signal pending?
                    beq       Read                no, go read char
* Signal was pending already, check it out
                    ifne      H6309
                    tim       #Condem,P$State,x   are we condemend?
                    else
                    lda       P$State,x
                    bita      #Condem
                    endc
                    bne       ReadErr             yes, exit with error flag set back to SCF
                    cmpb      #S$Window           window change or higher signal?
                    bcc       Read                yes, read the char since it won't change
ReadErr             coma                          major signal, return with error flag
                    rts                           (Keyboard abort/interrupt)

* Check wraparound of keyboard buffer (could be inlined)
*ChkWrap  incb  		inc keyboard buffer pointer
*         cmpb  #$7F	wrapped around?
*         bls   L015F	branch if not
*         clrb  		else reset pointer to 0
*L015F    rts   		return

* Keyboard mouse coordinate deltas
L0160               fcb       8,1                 right arrow (normal, shifted)
                    fdb       MaxRows-1           right arrow (control)
                    fcb       -8,-1               left arrow (normal, shifted)
                    fdb       0                   left arrow (control)
                    fcb       8,1                 down arrow (normal, shifted)
                    fdb       MaxLine             down arrow (control)
                    fcb       -8,-1               up arrow (normal, shifted)
                    fdb       0                   up arrow (control)

* Check mouse coordinate
* Entry: D=Maximum allowed coordinate for current axis being checked
*        Y=Ptr to current coordinate in mouse packet being checked
L0170               cmpd      ,y                  past maximum allowed coordinate?
                    blt       L017B
                    ldd       ,y                  below zero?
                    bpl       L017D               no, return
                    ifne      H6309
                    clrd                          set it to minimum coordinate (zero)
                    else
                    clra
                    clrb
                    endc
L017B               std       ,y                  set it to maximum coordinate
L017D               rts                           return


* Main keyboard scan (after PIA has been read)
* Check keyboard mouse arrows
* Entry: U=Global mem ptr
*        X=???
*        A=Key that was pressed
* Exit:  E=0 if key was pressed, 1 if none pressed
* Updated for localized keyboard mouse similiar to TC9IO
*
L017E               ldb       #$01                flag
                    pshs      u,y,x,b,a           save registers used & flag
                    ldb       <G.KyMse,u          get keyboard mouse flag
                    beq       L01E6               branch if off
* Keyboard mouse is on
                    lda       <G.KySns,u
                    bita      #%01111000          any arrow key pressed?
                    beq       L01DF
                    clr       $01,s               clear flag to indicate update
                    lda       #$01
                    sta       <G.MseMv,u          flag a mouse coord change
                    ldd       #$0803              start at up arrow and up arrow table
                    pshs      b,a                 entries & save them
                    leax      >L0160,pcr          point to keyboard mouse deltas
                    leay      <G.Mouse+Pt.AcY,u   point to mouse coords

* Update keyboard mouse co-ordinates according to arrow key pressed
L01A2               bita      <G.KySns,u          desired arrow key down?
                    beq       L01C5               no, move to next key
                    lslb                          multiply * 4 (size of each set)
                    lslb                          to point to start of proper arrow entry
                    tst       <G.ShftDn,u         shift key down?
                    beq       L01B1               no, go on
                    incb                          move ptr to <shifted> offset
                    bra       L01BC               get delta
L01B1               tst       <G.CntlDn,u         control key down?
                    beq       L01BC               no, go on
* <CTRL>-arrow
                    addb      #$02                move ptr to <CTRL> offset
                    ldd       b,x                 get control coordinate
                    bra       L01C1               go store it in mouse packet
* <arrow> or <SHIFT>-<arrow>
L01BC               ldb       b,x                 get offset to present mouse coordinate
                    sex                           make into 16 bit offset (keep sign)
                    addd      ,y                  add it to current coordinate
L01C1               std       ,y                  save updated coordinate
                    ldd       ,s                  get key count
L01C5               lsla                          move to next key bit
                    decb                          decrement key count
                    cmpb      #$01                down to X coordinates?
                    bne       L01CD               no, continue
                    leay      -$02,y              move to mouse X coordinate
L01CD               std       ,s                  save key count & key
                    bpl       L01A2               keep trying until all keys checked
                    puls      b,a                 purge stack of key and delta offset
                    ldd       #MaxRows-1          get maximum X coordinate
                    bsr       L0170               check X coordinate
                    leay      $02,y               move to Y coordinate
                    ldd       #MaxLine            get maximum Y coordinate
                    lbsr      L0170               check it
L01DF               lda       <G.KyButt,u         key button down?
                    bne       L0223               yes, return
                    lda       ,s                  get back character read
L01E6               tst       <G.Clear,u          clear key down?
                    beq       L0225               yes, return
                    clr       <G.Clear,u          clear out clear key flag
* Check CTRL-0 (CAPS-Lock)
                    cmpa      #%10000001          CTRL-0?
                    bne       L01FF               no, keep checking
                    ldb       <G.KySame,u         same key pressed?
                    bne       L0223
                    ldx       <G.CurDev,u         get dev mem pointer
                    ifne      H6309
                    eim       #CapsLck,<V.ULCase,x
                    else
                    ldb       <V.ULCase,x
                    eorb      #CapsLck            reverse current CapsLock status
                    stb       <V.ULCase,x
                    endc
                    bra       L0223               return
* Check CLEAR key
L01FF               cmpa      #%10000010          was it CLEAR key?
                    bne       L0208               no, keep going
                    lbsr      CLEAR               find next window
                    bra       L0223               return
* Check SHIFT-CLEAR
L0208               cmpa      #%10000011          was it SHIFT-CLEAR?
                    bne       L0211               no, keep checking
                    lbsr      SHFTCLR             yes, find back window
                    bra       L0223               return
* Check CTRL-CLEAR
L0211               cmpa      #%10000100          keyboard mouse toggle key?
                    bne       L0225               no, return
                    ldb       <G.KySame,u         same key pressed?
                    bne       L0223               yes, return
                    ifne      GLOBALKEYMOUSE
                    com       <G.KyMse,u
                    else
                    ldx       <G.CurDev,u
                    clra                          assume no keyboard mouse
                    ifne      H6309
                    eim       #KeyMse,<V.ULCase,x
                    else
                    ldb       <V.ULCase,x
                    eorb      #KeyMse             reverse current Keyboard Mouse status
                    stb       <V.ULCase,x
                    endc
                    beq       KeyMOff             branch if off
                    deca                          else A = $FF
KeyMOff             sta       <G.KyMse,u          save window's keyboard mouse flag in global
                    endc
L0223               clr       $01,s
L0225               ldb       $01,s
                    puls      pc,u,y,x,b,a        restore regs

L0229               pshs      x,b                 save external mouse button status & PIA addr
                    leax      <G.Mouse,u          mouse point to mouse packet
                    tst       Pt.ToTm,x           timed value zero?
                    lbeq      L02C8               branch if so
                    leas      -$05,s              make a buffer for locals
                    tfr       a,b                 move keyboard button flags to B
                    tst       <G.KyMse,u          keyboard mouse activated?
                    bne       L024E               yes, go on
                    ldb       #%00000101          mask for button 1 & 2 on right mouse/joystick
                    lda       Pt.Actv,x           get active mouse side
                    anda      #%00000010          clear all but left side select
                    sta       ,s                  save result
                    beq       L0248               if 0 (off or right side), skip ahead
                    lslb                          otherwise, change button 1 & 2 mask for left moue
L0248               andb      $05,s               check with external mouse button status type
                    tsta                          right side?
                    beq       L024E               yes, skip ahead
                    lsrb                          left side, shift over so we can use same routine
* Bits 0 & 2 of B contain external mouse buttons that are pressed (doesn't
* matter which side)
L024E               clra                          clear out A
                    lsrb                          shift out LSBit of B
                    rola                          put into LSBit of A
                    lsrb                          shift out another bit of B
                    std       $01,s               store fire button info
                    bne       L0276               fire button(s) pressed, go on
                    lda       Pt.TTTo,x           timeout occur?
                    beq       L02C6               yes, exit
                    bsr       L02CA               fire buttons change?
                    beq       L0262               no, decrement timeout count
                    bsr       L02D3               go update fire button click & timeout info
                    beq       L02AB               if neither button state changed, skip ahead
L0262               dec       Pt.TTTo,x           decrement timeout count
                    bne       L02AB               not timed out, go update last state counts
                    ifne      H6309
                    clrd
                    clrw
                    else
                    clra
                    clrb
                    endc
                    sta       >G.MsSig,u          clear read flag
                    std       Pt.TSSt,x           clear time since counter start
                    ifne      H6309
                    stq       Pt.CCtA,x           clear button click count & time this state
                    else
                    std       Pt.CCtA,x           clear button click count & time this state
                    std       Pt.TTSA,x
                    endc
                    std       Pt.TLSA,x           clear button time last state
                    bra       L02C6               exit

L0276               lda       Pt.ToTm,x           get timeout initial value
                    sta       Pt.TTTo,x           reset count
                    bsr       L02CA               fire buttons change?
                    beq       L02AB               no, update last state counts
                    bsr       L02D3               update fire button info
                    inc       >WGlobal+G.MsSig    flag mouse signal
                    ifne      H6309
                    ldq       <Pt.AcX,x           get actual X & Y coordinates
                    stq       <Pt.BDX,x           copy it to button down X & Y coordinates
                    else
                    ldd       <Pt.AcX,x           get actual X coordinate
                    std       <Pt.BDX,x           copy it to button down X coordinate
                    ldd       <Pt.AcY,x           get actual Y coordinate
                    std       <Pt.BDY,x           copy it to button down Y coordinate
                    endc
                    pshs      u                   save ptr to CC mem
                    ldu       <G.CurDev,u         get dev mem ptr
                    lda       <V.MSigID,u         get process ID requesting mouse signal
                    beq       L02A9               branch if none
                    ldb       <V.MSigSg,u         else get signal code to send
                    os9       F$Send              and send it
                    bcs       L02A5               branch if error
                    clr       <V.MSigID,u         clear signal ID (one shot)
L02A5               clr       >WGlobal+G.MsSig    clear read flag
L02A9               puls      u                   recover pointer to CC mem
L02AB               ldd       Pt.TTSA,x           get button A&B time last state
                    cmpa      #$FF                limit?
                    beq       L02B2               yes, go on
                    inca                          increment state
L02B2               cmpb      #$FF                limit?
                    beq       L02B7               yes, store them
                    incb                          increment B state
L02B7               std       Pt.TTSA,x           save updated states
                    ldd       Pt.TSST,x           get time since start
                    ifne      H6309
                    incd                          increment
                    beq       L02C6               branch if zero
                    else
*         cmpd  #$FFFF		check upper bound
*         beq   L02C4		branch if so
*         addd  #$0001		else increment
                    addd      #1
                    beq       L02C6
                    endc
L02C4               std       Pt.TSST,x           save updated state count
L02C6               leas      $05,s               purge locals
L02C8               puls      pc,x,b              restore & return

L02CA               ldd       Pt.CBSA,x           get button states
                    ifne      H6309
                    eord      $03,s               flip fire 1 & 2
                    else
                    eora      $03,s
                    eorb      $04,s
                    endc
                    std       $05,s               save 'em
                    rts                           return

* Update mouse button clock counts & timeouts
L02D3               ldd       Pt.TTSA,x           get button time this state
                    tst       $05,s               button A change?
                    beq       L02E9               no, go check B
                    sta       Pt.TLSA,x           save button A time last state
                    lda       $03,s               button A pressed?
                    bne       L02E8               yes, skip increment
                    lda       Pt.CCtA,x           get click count for A
                    inca                          bump up click count
                    beq       L02E9               branch if wrapped
                    sta       Pt.CCtA,x           save button A click count
L02E8               clra                          clear button A time this state
L02E9               tst       6,s                 button B change?
                    beq       L02FD               no, go save time this state
                    stb       Pt.TLSB,x           save button B time last state count
                    ldb       $04,s               button B pressed?
                    bne       L02FC               yes, skip increment
                    ldb       Pt.CCtB,x           get b click count
                    incb                          bump up click count
                    beq       L02FD               brach if wrapped to zero
                    stb       Pt.CCtB,x           save B click count
L02FC               clrb                          clear button B time this state
L02FD               std       Pt.TTSA,x           save button time this state counts
                    ldd       $03,s               get new fire buttons
                    std       Pt.CBSA,x           save 'em
                    ldd       $05,s               get button A & B change flags
NullIRQ             rts                           return


*
* VTIO IRQ routine - Entered from Clock every 1/60th of a second
*
* The interrupt service routine is responsible for:
*   - Decrementing the tone counter
*   - Select the new active window if needed
*   - Updating graphics cursors if needed
*   - Checking for mouse update
*
ISR                 ldu       <D.CCMem            get ptr to CC mem
                    ldy       <G.CurDev,u         get current device's static
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
*
* CHECK IF GFX/TEXT CURSORS NEED TO BE UPDATED
* G.GfBusy = 1 Grfdrv is busy processing something else
* G.WIBusy = 1 CoWin is busy processing something else
* g0000 = # of clock ticks/cursor update constant (2) for 3 ticks: 2,1,0
* G.CntTik = current clock tick for cursor update
*
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
                    ifne      GLOBALKEYMOUSE
                    tst       <G.KyMse,u          keyboard mouse?
                    else
                    ifne      H6309
                    tim       #KeyMse,<V.ULCase,y keyboard mouse?
                    else
                    lda       <V.ULCase,y         keyboard mouse?
                    bita      #KeyMse
                    endc
                    endc
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
                    ifne      H6309
                    clrd                          initialize keysense & same key flag
                    else
                    clra
                    clrb
                    endc
                    std       <G.KySns,u          initialize keysense & same key flag
* Major error here. Was regU; see above. RG
                    ifne      GLOBALKEYMOUSE
                    tst       <G.KyMse,u
                    else
                    ifne      H6309
                    tim       #KeyMse,>V.ULCase,y
                    else
                    pshs      a
                    lda       >V.ULCase,y         is the keyboard mouse enabled?
                    bita      #KeyMse
                    puls      a
                    endc
                    endc
                    beq       L0381               no, try joystick
                    ldx       >WGlobal+G.KeyEnt   else get ptr to keydrv
                    leau      >G.KeyMem,u         and ptr to its statics
                    jsr       K$FnKey,x           call into it
                    ldu       <D.CCMem            get ptr to CC mem
                    sta       <G.KyButt,u         save keyboard/button state
L0381               ldx       >WGlobal+G.JoyEnt   get ptr to joydrv
                    leau      >G.JoyMem,u         and ptr to its statics
                    jsr       J$MsBtn,x           get mouse button info
* Here, B now holds the value from the MsBtn routine in JoyDrv.
                    ldu       <D.CCMem            get ptr to CC mem
                    lda       #%10000010          A = $82
                    cmpb      #%10000000          clear flag set?
                    beq       L0397               branch if so
                    inca                          A now = $83
                    cmpb      #%11000000          shift clear flag set?
                    bne       L039C               branch if not
L0397               inc       <G.Clear,u
                    bra       L03C8
L039C               tst       V.PAUS,y            pause screen on?
                    bpl       L03A8               branch if not
                    bitb      #%00000011          any mouse buttons down?
                    beq       L03A8               branch if not
                    lda       #C$CR               load A with carriage return
                    bra       L03C8
L03A8               lda       <G.KyButt,u
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
                    lbra      L044E
L03C8
*** Inserted detection of debugger invocation key sequence here...
                    cmpa      #$9B                CTRL+ALT+BREAK?
                    bne       n@                  no, move on
                    jsr       [>WGlobal+G.BelVec] for whom the bell tolls...
                    os9       F$Debug
                    lbra      L044E
n@
***
                    cmpa      <G.LastCh,u         is current ASCII code same as last one pressed?
                    bne       L03DF               no, no keyboard repeat, skip ahead
                    ldb       <G.KyRept,u         get repeat delay constant
                    beq       L044E               if keyboard repeat shut off, skip repeat code
                    decb                          repeat delay up?
                    beq       L03DA               branch if so and reset
L03D5               stb       <G.KyRept,u         update delay
                    bra       L044E               return

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
*         lbsr  ChkWrap		check for wrap-around
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
CheckAutoMouse
                    lda       <G.AutoMs,u         auto mouse flag set?
                    beq       L046B               branch if not
                    lda       <G.MseMv,u          get mouse moved flag
                    ora       <G.Mouse+Pt.CBSA,u
                    beq       L046B
                    lda       G.GfBusy,u          check for GrfDrv busy
                    ora       G.WIBusy,u          OR with CoWin busy
                    bne       L046B               branch if they are busy
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
*f.ptrcur rmb   2	ptr to current device's device table entry
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
CLEAR               pshs      u,y,x,b,a           preserve registers
                    leas      <-f.end,s           make a buffer on stack
                    ldb       #DEVSIZ             get # of bytes to move to next entry (forward)
                    bsr       WinSearchInit       get pointer to devtable
                    stx       f.ptrend,s          save end of devtable
                    sty       f.ptrstr,s          save beginning of devtable
                    bra       FindWin

* Shift-CLEAR processor
SHFTCLR             pshs      u,y,x,b,a           preserve registers
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
*         stx   f.ptrcur,s	save it on stack
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
* NOTE: The next two lines are moved down two lines, past the check
* for our own device table pointer.  This fixes a bug where the last
* deiniz of the last window device caused an infinite loop.  The problem
* was that IOMan clears the static storage of a device whose use count
* has reached zero (in the case of a hard detach), and we were testing for
* a V$STAT of zero BEFORE seeing if we reached our own device table entry.

* Next two lines moved...
*         ldu   V$STAT,x	get ptr to static storage for tbl entry
*         beq   L04BC		there is none, try next one
*         cmpx  f.ptrcur,s	is this our own (have we come full circle)?
*         beq   L0541		yes, obviously nowhere else to switch to
* ...to here.
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
L0522               cmpa      ,x                  path we are checking same as path already open
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
                    puls      pc,u,y,x,b,a        restore regs and return

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
                    ifeq      GLOBALKEYMOUSE
* Added: get window's keyboard mouse flag and update global keyboard mouse
                    ifne      H6309
                    tim       #KeyMse,<V.ULCase,u keyboard mouse?
                    else
                    lda       <V.ULCase,u         keyboard mouse?
                    bita      #KeyMse
                    endc
                    bne       setmous2
                    clra
                    fcb       $8c
setmous2            lda       #$FF
                    sta       <G.KyMse,x
                    endc
                    clra
                    puls      pc,x                restore and return


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
Write               ldb       <V.ParmCnt,u        are we in the process of getting parameters?
                    lbne      L0600               yes, go process
                    sta       <V.DevPar,u         save off character
                    cmpa      #C$SPAC             space or higher?
                    bcc       CoWrite             yes, normal write
                    cmpa      #$1E                1E escape code?
                    bcc       L05EF               yes, go process
                    cmpa      #$1B                $1B escape code?
                    beq       L05F3               yes, go handle it
                    cmpa      #$05                $05 escape code? (cursor on/off)
                    beq       L05F3               yep, go handle it
                    cmpa      #C$BELL             Bell?
                    bne       CoWrite             no, control char
                    jmp       [>WGlobal+G.BelVec] for whom the bell tolls...

CoWrite             ldb       #$03                write entry point in co-module
CallCo              lda       <V.DevPar,u         get character stored earlier
L0593               ldx       <D.CCMem            get ptr to CC mem
                    stu       G.CurDvM,x          save dev mem ptr for current device
L0597               pshs      a
                    leax      <G.CoTble,x         point to co-module entry vectors
                    lda       <V.WinType,u        get window type from device mem
                    ldx       a,x                 get vector to proper co-module
                    puls      a
                    beq       L05EB               vector empty, exit with module not found
                    leax      b,x
                    bsr       L05C0
                    ldb       <V.WinType,u
                    beq       L05B4
                    jsr       ,x                  go execute co-module
L05B0               pshs      cc
                    bra       L05BB
L05B4               jsr       ,x
L05B6               pshs      cc
                    clr       >WGlobal+G.WIBusy
L05BB               clr       >WGlobal+G.CrDvFl
                    puls      pc,cc

L05C0               pshs      x,b
                    ldx       <D.CCMem            get ptr to CC mem
                    clr       G.WIBusy,x          clear CoWin busy flag
                    ldb       <V.WinType,u        get window type (0 = CoWin)
                    bne       L05CE               branch if CoVDG
                    incb                          else make B = 1
                    stb       G.WIBusy,x          and make CoWin busy
L05CE               clr       G.CrDvFl,x          clear 'we are current device'
                    cmpu      <G.CurDev,x
                    bne       L05D8
                    inc       g000A,x
L05D8               puls      pc,x,b

* U = ptr to CC memory
L05DA               pshs      u,y,x
                    ldu       <G.CurDev,u         get ptr to curr dev mem
L05DF               ldb       #$0F
                    ldx       <D.CCMem            get ptr to CC memory in X
                    bsr       L0597
                    puls      pc,u,y,x            restore regs and return

L05E7               pshs      u,y,x               save regs
                    bra       L05DF

L05EB               comb
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
Do1E                clrb                          no error
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
                    std       R$Y,x               save it in register stack
                    rts                           return

GSReady             ldb       <V.EndPtr,u         get input buffer end pointer
                    cmpb      <V.InpPtr,u         anything there?
                    beq       NotReady            nope, exit with error
                    bhi       L0660               higher?
                    addb      #$80                nope, add 128 to count
L0660               subb      <V.InpPtr,u         calculate number of characters there
                    stb       R$B,x               save it in register stack
SSEOF               clrb                          clear errors
                    rts                           return
NotReady            comb                          set carry
                    ldb       #E$NotRdy           get error code
                    rts                           return

* Return special key status
*        X = pointer to caller's register stack
GSKySns             ldy       <D.CCMem            get ptr to CC mem
                    clrb                          clear key code
                    cmpu      <G.CurDev,y         are we the active device?
                    bne       L0678               branch if not
                    ldb       <G.KySns,y          get key codes
L0678               stb       R$A,x               save to caller reg
                    clrb                          clear errors
                    rts                           return

* GetStat: SS.Montr (get Monitor type)
*        X = pointer to caller's register stack
GSMontr             ldb       >WGlobal+G.MonTyp   get monitor type
*         tfr   b,a		put in A
                    clra
                    std       R$X,x               save in caller's X
                    rts                           return

* GetStat: SS.JOY (get joystick X/Y/button values)
*        X = pointer to caller's register stack
GSJoy               clrb                          default to no errors
                    tfr       x,y                 transfer caller's registers to Y
                    ldx       <D.CCMem            get ptr to CC mem
                    cmpu      <G.CurDev,x         are we the current active device?
                    beq       GetJoy              if so, go read joysticks
                    clra                          else D = 0
                    std       R$X,y               X pos = 0
                    std       R$Y,y               Y pos = 0
                    sta       R$A,y               no buttons held down
                    rts                           return

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
*
* Now get actual joystick values (note: IRQs still off)
*
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
                    pshs      y                   save joystick Y
                    ldy       $02,s               get ptr to caller's regs
                    stx       R$X,y               save joystick X in caller's X
                    ldd       #63
                    subd      ,s++
                    std       R$Y,y               save joystick Y in caller's Y
                    clrb                          cleary carry
                    puls      pc,y                return

* GetStat: SS.Mouse (get mouse info)
*        X = pointer to caller's register stack
GSMouse             pshs      u,y,x
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
L06FA               tst       <G.KyMse,x          mouse keyboard active?
                    bne       L071A               branch if so
                    lda       <G.MSmpRV,x         ready to sample?
                    bne       L071A               no, return packet
                    pshs      u,y,x
                    bsr       L073B               read external mouse
                    puls      u,y,x
                    lda       <G.AutoMs,x         get automouse flag
                    anda      <G.MseMv,x          has mouse moved?
                    beq       L071A               no, return packet
                    lda       #$03                update auto-follow mouse sub-function call
                    lbsr      L05E7               call co-module to update mouse
                    clr       <G.MseMv,x          flag that the mouse hasn't moved
L071A               lda       #$01                'special' co-mod function code: move mouse packet?
                    lbsr      L05E7
                    leax      <G.Mouse,x          move X to point to mouse packet
                    ldy       ,s                  get register stack pointer
                    bsr       MovMsPkt            move packet to caller
                    puls      pc,u,y,x

* Move mouse packet to process
* Y = ptr to caller's register stack
MovMsPkt            ldu       R$X,y               get destination pointer
                    ldy       <D.Proc             get process descriptor pointer
                    ldb       P$Task,y            get destination task number
                    clra                          get source task number
                    ldy       #Pt.Siz             get length of packet
                    os9       F$Move              move it to the process
                    rts                           return

L0739               ldx       <D.CCMem
L073B               leax      <G.Mouse,x          move X to mouse packet
                    clra                          clear MSB of mouse resolution
                    ldb       <Pt.Res,x           get resolution (0 = lores, 1 = hires)
                    tfr       d,y                 move mouse res to Y
                    lda       Pt.Actv,x           get mouse side
                    pshs      u,y,x,b,a           preserve regs
                    ldx       >WGlobal+G.JoyEnt   get ptr to mouse sub module
                    ldu       <D.CCMem            get mem pointer
                    leau      >G.JoyMem,u         and point to mouse sub module statics
                    jsr       J$MsXY,x            get data
                    pshs      y,x
                    ldx       $06,s               get ptr to mouse packet in CC mem
                    puls      b,a                 get X value into D
                    leay      <Pt.AcX,x           point X to mouse X/Y in mouse packet
                    bsr       L0764
                    puls      b,a                 get Y value into D
                    bsr       L0764
                    puls      pc,u,y,x,b,a
* X = Address of G.Mouse in D.CCMem
L0764               cmpd      ,y++                compare mouse's current X to Pt.AcX
                    beq       L0770               branch if same
                    std       -$02,y              else store new X into Pt.AcX
                    lda       #$01
                    sta       <(G.MseMv-G.Mouse),x update mouse moved flag
L0770               rts

SSTone              ldx       >WGlobal+G.SndEnt   get address of sound sub module
                    jmp       S$SetStt,x          go execute routine in sub module

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
SSGIP               ldy       <D.CCMem            get ptr to CC mem
                    cmpu      <G.CurDev,y         current window?
                    bne       L0866               branch if not
                    ldd       R$Y,x               get caller's Y (key repeat info)
                    cmpd      #$FFFF              unchanged?
                    beq       L0853               yes, don't change current key info
                    std       <G.KyDly,y          else save key delay and speed info
L0853               ldd       R$X,x               get mouse info
                    cmpa      #$01                set for hi res adapter?
                    bgt       L088F               branch to error if greater
                    sta       <G.Mouse+Pt.Res,y   save new resolution value
* B  = mouse port (1 = right, 2 = left)
                    tstb                          side above legal value?
                    beq       L088F               no, exit with error
                    cmpb      #$02                side below legal value?
                    bgt       L088F               no, exit with error
                    stb       <G.Mouse+Pt.Actv,y  save new side
L0866               clrb                          clear errors
                    rts                           and return

* SS.KySns - setstat???
SSKySns             ldd       R$X,x               get monitor type requested
                    beq       L086E               below legal value?
                    ldb       #$FF                no, exit with error
L086E               stb       <V.KySnsFlg,u       save new sense mode
L0871               clrb                          clear errors
                    rts                           return

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
                    clrb                          clear errors
                    rts                           return

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
CoGrf               fcs       /CoGrf/             ++
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
                    pshs      u,x,b,a             preserve it along with registers
                    ldd       <D.SysPrc           get system process descriptor pointer
                    std       <D.Proc             save it as current process
                    lda       #Systm+Objct        get codes for link
                    os9       F$Link              link to it
                    ldx       $02,s               get name pointer
                    bcc       L091B               does module exist?
                    ldu       <D.SysPrc           no, get system process descriptor pointer
                    os9       F$Load              load it
L091B               puls      u,x,b,a             restore regs
                    std       <D.Proc             restore current process descriptor
                    lbcs      L05EB               exit if error from load or link
                    rts                           return

                    emod
eom                 equ       *
                    end
