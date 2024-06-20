********************************************************************
* keydrv - Keyboard subroutine module for F256 VTIO
*
* https://wiki.osdev.org/PS2_Keyboard
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2024/02/17  Boisy G. Pitre
* Started.
*
*  2       2024/03/16  Boisy G. Pitre
* Added F256 reset when Sys Rq key pressed.
*
*  3        2024/06/17  Boisy G. Pitre (Waco, TX)
* Added support for V.PAU.

                    use       defsfile
                    use       f256vtio.d

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3


* We can use a different MMU slot if we want.
MAPSLOT             equ       MMU_SLOT_1
MAPADDR             equ       (MAPSLOT-MMU_SLOT_0)*$2000

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last

                    fcb       UPDAT.+EXEC.

name                fcs       /keydrv/
                    fcb       edition

                    org       V.KeyDrvStat
V.KCVect            rmb       2
                   
* keydrv has three 3-byte entry points:
* - Init                  
* - Term
* - AltISR (called by VTIO at the 60Hz interval)  
start               lbra      Init
                    lbra      Term
                    lbra      AltISR

AltISR              rts

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
Init                
* F256 Jr. PS/2 keyboard initialization                    
*
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
                    
                    leax      KCHandler,pcr       get the PS/2 key code handler routine
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
* F256K keyboard termination
*                    

* F256 Jr. PS/2 keyboard termination
*                     
                    ldx       #$0000              we want to remove the IRQ table entry
                    leay      IRQSvc,pcr          point to the interrupt service routine
                    os9       F$IRQ               call to remove it

                    ldx       >D.OrgAlt   get the original alternate IRQ vector
                    stx       <D.AltIRQ           save it back to the D.AltIRQ address
                    
                    clrb                          clear the carry
                    rts                           return to the caller

***
* IRQ routine for the F256 Jr. PS/2 keyboard
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
                    lbsr      BufferChar          buffer it
                    puls      a                   get the character
                    lbsr      BufferChar          buffer it
                    bra       CheckSig            wake up any sleeping process waiting on input
                    endc

* A = key code
* point Y to appropriate key table (SHIFT vs Non-SHIFT)
                    ldb       D.KySns             B = Key Sense byte
                    bitb      #SHIFTBIT           is the SHIFT key down?
                    bne       shift@              branch of so
                    leay      ScanMap,pcr         else point to the non-SHIFT scan map
                    bra       pastshift@          and branch
shift@              leay      SHIFTScanMap,pcr    point to the SHIFT scan map
pastshift@          ldx       V.KCVect,u          get the current key code handler
                    jsr       ,x                  branch into it
                    bcs       IRQExit             if the carry is set, don't wake process
                    cmpa      V.PCHR,u  pause character?
                    bne       int@      branch if not
                    ldx       V.DEV2,u  else get dev2 statics
                    beq       WakeIt     branch if none
                    sta       V.PAUS,x  else set pause request
                    bra       WakeIt
int@
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

* Check if we need to wrap around tail pointer to zero.
IncNCheck           incb                          increment the next character pointer
                    cmpb      #KBufSz-1           are we pointing to the end of the buffer?
                    bls       ex@                 branch if not
                    clrb                          else clear the pointer (wraps to head)
ex@                 rts                           return

* Entry:  A = PS/2 key code
*
* Exit:  CC = carry clear: wake up a sleeping process waiting on input
*             carry set: don't wake up a sleeping process waiting on input
KCHandler
                    cmpa      #$E0                is it the $E0 preface byte?
                    beq       ProcE0              branch if so
                    cmpa      #$F0                is it the $F0 preface byte?
                    beq       ProcF0              branch if so
                    cmpa      #$58                is this the Caps Lock byte?
                    beq       DoCapsLockDown      branch if so                    
                    cmpa      #$11                is this the Left Alt byte?
                    beq       DoLeftAltDown       branch if so                    
                    cmpa      #$12                is this the Left Shift byte?
                    beq       DoLeftShiftDown     branch if so                    
                    cmpa      #$59                is this the Right Shift byte?
                    beq       DoRightShiftDown    branch if so                    
                    cmpa      #$14                is this the Left Ctrl byte?
                    beq       DoLeftCtrlDown      branch if so                    
                    lda       a,y                 else pull the key character from the scan code table
                    cmpa      #C$SPAC             is this space key?
                    bne       ctrlck@
                    orb       #SPACEBIT
                    stb       D.KySns
* Check for the CTRL key.
ctrlck@             bitb      #CTRLBIT            is the CTRL key down?
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

DoCapsLockDown
                    lda       #$ED                get the PS/2 keyboard LED command
                    lbsr      SendToPS2           send it to the PS/2
                    lda       V.LEDStates,u       get the PS/2 LED flags in static memory
                    com       V.CAPSLck,u         complement the CAPS lock flag in our static memory
                    beq       ledoff@             branch if the result is 0 (LED should be turned off)
                    ora       #$04                set the CAPS Lock LED bit
                    bra       send@               and send it to the keyboard
ledoff@             anda      #^$04               clear the CAPS Lock LED bit
send@               lbsr      SendToPS2           send the byte to the keyboard
                    comb                          clear the carry so that the read routine just returns
                    rts                           return

DoLeftAltDown
DoRightAltDown
                    orb       #ALTBIT
                    lbra      StoreKySns
DoLeftCtrlDown
DoRightCtrlDown
                    orb       #CTRLBIT
                    lbra      StoreKySns
DoLeftShiftDown
DoRightShiftDown    orb       #SHIFTBIT
                    lbra      StoreKySns

ProcE0              leax      E0Handler,pcr       get the $E0 handler routine
                    bra       StoreNEx

ProcE0F0            leax      E0F0Handler,pcr     get the $E0F0 handler routine
                    bra       StoreNEx

ProcF0              leax      F0Handler,pcr       get the $F0 handler routine
StoreNEx            stx       V.KCVect,u          store it in the vector
                    comb                          clear the carry so that the read routine handles other work
                    rts                           return

DoPrtScr            leax      PrtScrCode3,pcr
                    bra       StoreNEx                    
                    
PrtScrCode3         cmpa      #$F0                is this an $F0?
                    beq       ProcF0              handle weird case where $E012F012 comes up when hitting LEFT SHIFT DOWN, RIGHT ARROW DOWN, RIGHT ARROW UP, LEFT SHIFT UP
                    cmpa      #$E0                is this the second $E0?
                    lbne      SetDefaultHandler
                    leax      PrtScrCode4,pcr
                    bra       StoreNEx                    

PrtScrCode4         cmpa      #$7C                is this the full Prt Scr?
                    lbne      SetDefaultHandler      
* This performs a proper reset of the F256.
ResetGo             ldd       #$DEAD              get the sentinel values
                    sta       RST0                store the first value
                    stb       RST1                and the second value
                    lda       #$80                set the high bit
                    sta       SYS0                store the high bit in the register
                    clr       SYS0                then clear the high bit in the register
l@                  bra       l@                  wait for the reset condition

* A = key code
* Y = scan table
E0Handler
                    cmpa      #$F0                is this the $F0 key code?
                    beq       ProcE0F0            branch if so
                    cmpa      #$11                is this the right Alt key?
                    beq       DoRightAltDown      if so, handle the Alt key
                    cmpa      #$14                is this the right Ctrl key?
                    beq       DoRightCtrlDown     if so, handle the Ctrl key
                    cmpa      #$75                is this the up arrow key?
                    beq       DoUpArrowDown       if so, handle it
                    cmpa      #$6B                is this the left arrow key?
                    beq       DoLeftArrowDown     if so, handle it
                    cmpa      #$72                is this the down arrow key?
                    beq       DoDownArrowDown     if so, handle it
                    cmpa      #$74                is this the right arrow key?
                    beq       DoRightArrowDown    if so, handle it
                    cmpa      #$12                is this the Prt Scr key?
                    beq       DoPrtScr
                    lbra      SetDefaultHandler
DoUpArrowDown       lda       #$0C                load up arrow character
                    orb       #UPBIT
                    bra       StoreKySnsAndReport
DoDownArrowDown     lda       #$0A                load down arrow character
                    orb       #DOWNBIT
                    bra       StoreKySnsAndReport
DoLeftArrowDown     lda       #$08                load left arrow character
                    orb       #LEFTBIT
                    bra       StoreKySnsAndReport
DoRightArrowDown    lda       #$09                load right arrow character
                    orb       #RIGHTBIT
StoreKySnsAndReport
                    stb       D.KySns
                    bsr       SetDefaultHandler
                    lbra      BufferChar          add it to the input buffer

F0Handler
                    cmpa      #$14                is this the left Ctrl key going up?
                    beq       DoLeftCtrlUp        if so, handle that case
                    cmpa      #$59                is this the right Shift key going up?
                    beq       DoRightShiftUp      if so, handle that case
                    cmpa      #$12                is this the left Shift key going up?                    
                    beq       DoLeftShiftUp
                    cmpa      #$11                is this the left Alt key going up?                    
                    beq       DoLeftAltUp
                    cmpa      #$29                is this space key?
                    beq       DoSpaceUp           if so, handle it
                    bra       SetDefaultHandler
                    
DoLeftCtrlUp
DoRightCtrlUp
                    andb      #^CTRLBIT
                    bra       StoreKySns
DoLeftShiftUp
DoRightShiftUp
                    andb      #^SHIFTBIT
                    bra       StoreKySns
DoLeftAltUp                    
DoRightAltUp
                    andb      #^ALTBIT
StoreKySns          stb       D.KySns
                    bra       SetDefaultHandler   and branch to set the default handler
DoSpaceUp
                    andb      #^SPACEBIT
                    bra       StoreKySns
DoUpArrowUp         andb      #^UPBIT
                    bra       StoreKySns
DoDownArrowUp       andb      #^DOWNBIT
                    bra       StoreKySns
DoLeftArrowUp       andb      #^LEFTBIT
                    bra       StoreKySns
DoRightArrowUp      andb      #^RIGHTBIT
                    bra       StoreKySns
                    
E0F0Handler
                    cmpa      #$14                is this the right Ctrl key going up?
                    beq       DoRightCtrlUp       if so, handle that case
                    cmpa      #$11                is this the right Alt key going up?
                    beq       DoRightAltUp        if so, handle that case
                    cmpa      #$75                is this the up arrow key?
                    beq       DoUpArrowUp         if so, handle it
                    cmpa      #$6B                is this the left arrow key?
                    beq       DoLeftArrowUp       if so, handle it
                    cmpa      #$72                is this the down arrow key?
                    beq       DoDownArrowUp       if so, handle it
                    cmpa      #$74                is this the right arrow key?
                    beq       DoRightArrowUp      if so, handle it
SetDefaultHandler
                    leax      KCHandler,pcr       point to default key code processor
                    stx       V.KCVect,u          save it in the key code vector
                    comb
                    rts

* These tables map PS/2 key codes to characters in both non-SHIFT and SHIFT cases.
* If the high bit of a character is set, it is a special flag and therefore
* is handled differently.
ScanMap             fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,'`,0
                    fcb       0,0,0,0,0,'q,'1,0,0,0,'z,'s,'a,'w,'2,0
                    fcb       0,'c,'x,'d,'e,'4,'3,0,0,C$SPAC,'v,'f,'t,'r,'5,0
                    fcb       0,'n,'b,'h,'g,'y,'6,0,0,0,'m,'j,'u,'7,'8,0
                    fcb       0,C$COMA,'k,'i,'o,'0,'9,0,0,'.,'/,'l,';,'p,'-,0
                    fcb       0,0,'',0,'[,'=,0,0,0,0,C$CR,'],0,'\,0,0
                    fcb       0,0,0,0,0,0,$8,0,0,'1,0,'4,'7,0,0,0
                    fcb       '0,'.,'2,'5,'6,'8,$05,0,0,'+,'3,'-,'*,'9,$17,0

SHIFTScanMap        fcb       0,0,0,0,0,0,0,0,0,0,0,0,0,0,'~,0
                    fcb       0,0,0,0,0,'Q,'!,0,0,0,'Z,'S,'A,'W,'@,0
                    fcb       0,'C,'X,'D,'E,'$,'#,0,0,C$SPAC,'V,'F,'T,'R,'%,0
                    fcb       0,'N,'B,'H,'G,'Y,'^,0,0,0,'M,'J,'U,'&,'*,0
                    fcb       0,'<,'K,'I,'O,'),'(,0,0,'>,'?,'L,':,'P,'_,0
                    fcb       0,0,'",0,'{,'+,0,0,0,0,C$CR,'},0,'|,0,0
                    fcb       0,0,0,0,0,0,$18,0,0,'1,0,'4,'7,0,0,0
                    fcb       '0,'.,'2,'5,'6,'8,$05,0,0,'+,'3,'-,'*,'9,$17,0

                    emod
eom                 equ       *
                    end
