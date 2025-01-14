********************************************************************
* keydrv - Keyboard subroutine module for F256 VTIO
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2024/02/17  Boisy G. Pitre
* Started.
*
*  2        2024/06/17  Boisy G. Pitre (Waco, TX)
* Fixed the SS.KySns routine to properly set/clear D.KySns bits for supported keys,
* and added support for V.PAU.
*
*  3        2024/06/26  Boisy G. Pitre
* Added an optimization check to prevent needing to do a full scan every SOF interrupt
* thanks to a suggestion by @gadget.


                    use       defsfile
                    use       f256vtio.d

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last

                    fcb       UPDAT.+EXEC.

name                fcs       /keydrv/
                    fcb       edition

                    org       V.KeyDrvStat
V.META              rmb       1                 the state of the Foenix "META" key
DownRightStates     rmb       1                 the state of the down and right arrow keys during polling

* keydrv has three 3-byte entry points:
*   - Init
*   - Term
*   - AltISR (called by VTIO at the 60Hz interval)
start               lbra      Init
                    lbra      Term
*                    lbra      AltISR

* Alternate IRQ routine - Called from vtio at 60Hz to scan the keyboard.
AltISR              ldx       #VIA1.Base get the VIA1 base address
**** Optimization: see if there's ANY key down (thanks for the idea, @gadget!)
**** Requires a new global to keep track of how many keys are down.
                tst       D.F256KKyDn       one or more keys currently down?
                bne       scan@             scan if so
                clr       VIA_ORA_IRA,x		set all outputs to 0
				lda       #$FF				check for all bits set...
				cmpa      VIA_ORB_IRB,x		...on port B
				bne       scan@			if not equal, scan needs done
				tst       VIA0.Base+VIA_ORB_IRB test for bit 7 (down/right key)
				bmi       ex@                 if bit set, no key down -- exit
scan@
****				
                    ldy       #D.RowState point to the row state global area
                    lda       #%01111111 initialize the accumulator with the row scan value
                    bsr       loop@
* Handle down and right arrow
                    sta       VIA_ORA_IRA,x store A in VIA #1's port A
                    lda       DownRightStates,u  get the down/right state byte
                    tfr       a,b save into B
                    eora      ,y XOR A with the row state at Y
                    bne       HandleRow if non-zero, either down/right changed positions -- go handle it
                    rts       else return from the ISR
loop@               sta       VIA_ORA_IRA,x save the row scan value to the VIA1 output
                    pshs      a         save it on the stack for now
* handle extra column here
                    lda       VIA0.Base+VIA_ORB_IRB load A with VIA #0's port B
                    rola                            rotate A to the left (hi bit goes in carry)
                    rol       DownRightStates,u          rotate the carry into bit 0 of down/right state byte
                    lda       VIA_ORB_IRB,x get the column value for this row
                    tfr       a,b       save a copy to B
                    eora      ,y        XOR with the last row state value
                    beq       next@     branch if there's no change
                    bsr       HandleRow else one or more keys for this row have changed direction - handle it
next@               leay      1,y       advance to the next row state value
                    puls      a         restore the row scan value we read from VIA1
                    orcc      #Carry    set the carry flag so it will rotate in the upper 8 bits
                    rora                rotate A to the right
                    bcs       loop@     branch if the carry is set to continue
ex@                 rts                 return to the caller

* Entry:
*    A = The keys in the row that have changed since the last scan.
*    B = The up/down state of keys in the row.
*    Y = The row state that we keep to know which keys are up or down.
HandleRow           pshs      d,x,y
                    stb       ,y        save off new state to current row
                    ldb       #8        load counter
kl@                 lsla                shift leftmost bit into the carry
                    bcs       kchg@     branch if carry set (key state changed)
                    lsl       1,s       shift B on stack (up/down state)
handleloop          decb                decrement the counter
                    bne       kl@       continue if more
                    puls      d,x,y,pc  restore and return
kchg@
                    pshs      d          save D on the stack
* Get character from table
                    tfr       y,d        bring the row pointer into D
                    subd      #D.RowState B now holds the row we're interested in
                    lda       #8         load A with 8
                    mul                  B = offset into the key table for the row we want
                    leax      F256KKeys,pcr point to the non-SHIFT key table
                    lda       D.KySns    get the key sense values
                    bita      #SHIFTBIT  check for SHIFT down
                    beq       noshift@   branch of SHIFT is UP
                    leax      F256KShiftKeys,pcr else point to the SHIFT key table
noshift@            abx                  X = pointer to desired row in key table
                    lda       2,s        get the byte that holds the changed keys
r@                  rola                 roll bit 7 of A into the carry
                    bcs       g@         branch if set
                    leax      1,x        else advance X
                    bra       r@         and continue
g@                  lda       ,x         load A with the key character at X -- this is the key we want!
* A = Key character
* is it key up or key down?
                    lsl       3,s       shift B on stack (up/down state)
                    bcc       keydown@  if carry set, key is going up -- ignore it
* Key is going UP
keyup@
                    dec      D.F256KKyDn    decrement the key down count
                    cmpa      #META			is this the META key
                    bne       snsup@			branch if not
				clr       V.META,u			else clear the META flag
				lbra      nextrow			and continue processing
snsup@				
                    leax      KySnsTbl,pcr		point to the key sense UP table
l@                  tst       ,x+				are we at the end of the table?
				lbeq      nextrow			branch if so
				cmpa      -1,x				else compare key character against first byte in table entry
				bne       l@	 			branch if not the same (go to the top and process the next table entry)
* Process the key character in A relative to the key sense table byte at X
				ldb       ,x				get the key sense bit in the table entry
				comb						complement it
                    andb      D.KySns			AND it with the key sense flag
				stb       D.KySns			and save it back
				lbra      nextrow			continue processing
* Key is going DOWN
keydown@
                inc       D.F256KKyDn   increment the key down count
                cmpa      #META			is this the META key?
                bne       snsdn@			branch if not
				sta       V.META,u			else set the META flag
				lbra      nextrow			and continue processing
snsdn@				

                    leax      KySnsTbl,pcr		point to the key sense DOWN table
l@                  tst       ,x++				are we at the end of the table?
				beq      isitcaps@			branch if so
				cmpa      -2,x				else compare key character against first byte of previous table entry
				bne       l@				branch if not the same (go to the top and process the next table entry)
                ldb       D.KySns			get the key sense flag
                    orb       -1,x				OR it with the table byte at -1,X
				stb       D.KySns			and save it back
				cmpa      #$F0				is this key character >= $F0 (modifier key)
				lbhs      nextrow			if so, continue processing
* Up/Down/Left/Right keys are marked with special values between $E0 and $EF
                    cmpa      #$E0				is the key code < $E0
				blo       isitcaps@			yes, keep processing it
				suba      #$E0				else subtract $E0 from it to get true value
isitcaps@           cmpa      #CAPS			is the key code the CAPS Lock key?
                    bne       z@				branch if not
                    com       V.CAPSLck,u		else complement the state
* Set/Clear CAPS Lock LED
                    ldx       #SYS0			point to the hardware for changing the LED
                    ldb       ,x				get the value
                    tst       V.CAPSLck,u		did CAPS Lock get turned off?
                    beq       ledoff@			branch if so to turn off LED
ledon@              orb       #SYS_CAP_EN		else set the hardware CAPS Lock enable bit
                    bra       ledsave@			and save it
ledoff@             andb      #^SYS_CAP_EN		clear the hardware CAPS Lock enable bit
ledsave@            stb       ,x				and save it
                    lbra      nextrow			continue processing
* Handle CAPS LOCK engaged
z@                  tst       V.CAPSLck,u		is CAPS Lock engaged?
                    beq       z1@				branch if not
                    cmpa      #'a				else compare key character to 'a'
                    blo       z1@				branch if it's lower (not eligible for CAPS modification)
                    cmpa      #'z				compare key character to 'z'
                    bhi       z1@				branch if it's higher (not eligible for CAPS modification)
                    suba      #$20				convert the lowercase character to uppercase
* Handle CTRL down
z1@                 ldb       D.KySns			get the key sense flags
                    bitb      #CTRLBIT			is CTRL down?
                    beq       z2@				branch if not
                    anda      #$5F				else make the character an uppercase one
                    suba      #$40				and subtract to get the key's CTRL value
* Handle ALT down
z2@                 bitb      #ALTBIT			is ALT down?
                    beq       z3@				branch if not
                    anda      #$5F				else make the character an uppercase one
                    adda      #$40				and add to get the key's ALT value
* Handle META down
z3@                 tst       V.META,u			is META down?
                    beq       BufferChar		branch if not
                    leax      MetaTab,pcr		else point to the META table
zl@                 tst       ,x				is the character at X zero?
                    beq       BufferChar		branch if so
                    cmpa      ,x++				else compare the key character to the entry
                    bne       zl@				branch if not the same
                    lda       -1,x				load A with corresponding entry

* Advance the circular buffer one character.
BufferChar          ldb       V.IBufH,u get buffer head pointer in B
                    leax      V.InBuf,u point X to the input buffer
                    abx                 X now holds address of the head pointer
* Check if we need to wrap around tail pointer to zero.
IncNCheck           incb                increment the next character pointer
                    cmpb      #KBufSz-1 are we pointing to the end of the buffer?
                    bls       next@     branch if not
                    clrb                else clear the pointer (wraps to head)
next@               cmpb      V.IBufT,u is B at the tail? (if so, the input buffer is full)
                    beq       bye@      branch if the input buffer is full (drop the character)
                    stb       V.IBufH,u update the buffer head pointer
                    sta       ,x        place the character in the buffer
bye@
                    cmpa      V.PCHR,u  pause character?
                    bne       int@      branch if not
                    ldx       V.DEV2,u  else get dev2 statics
                    beq       wake@     branch if none
                    sta       V.PAUS,x  else set pause request
* Wake up any process if it's sleeping waiting for input.
wake@               ldb       #S$Wake   get the wake signal
                    lda       V.WAKE,u  is there a process asleep waiting for input?
noproc@             beq       nextrow     branch if not
                    clr       V.WAKE,u  else clear the wake flag
send@               os9       F$Send    and send the signal in B
nextrow             puls      d
                    lbra      handleloop
int@
                    ldb       #S$Intrpt get the interrupt signal
                    cmpa      V.INTR,u  is our character same as the interrupt signal?
                    beq       getlproc@ branch if it's the same
                    ldb       #S$Abort  get the abort signal
                    cmpa      V.QUIT,u  is our character same as the abort signal?
                    bne       CheckSig  branch if it isn't
getlproc@           lda       V.LPRC,u  else get the ID of the last process to use this device
                    bra       noproc@   branch
* Check signal
CheckSig
                    lda       <V.SSigID,u send signal on data ready?
                    beq       wake@     no, just go wake up the process
                    ldb       <V.SSigSg,u else get the signal code
                    clr       <V.SSigID,u clear signal ID
                    bra       send@

* This small table handles the META characters on the F256K keyboard.
MetaTab             fcb       '7,'~
                    fcb       '8,'`
                    fcb       '9,'|
                    fcb       '0,'\
                    fcb       0

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
Init                ldx       #VIA1.Base        point X to the VIA1
                    clr       VIA_IER,x         clear interrupts
                    lda       #%11111111        load A with $FF
                    sta       VIA_DDRA,x        set all bits of port A (outputs)
                    sta       VIA_ORA_IRA,x     and set the corresponding values to 1
                    clr       VIA_DDRB,x        clear all bits of port B (inputs)
                    ldx       #VIA0.Base        point X to the VIA0
                    clr       VIA_IER,x         clear interrupts
                    lda       #%0111111         load A with $7F
                    sta       VIA_DDRA,x        set bits 6-0 of port A (outputs)
                    sta       VIA_ORA_IRA,x     and set the corresponding values to 1
                    clr       VIA_DDRB,x        clear all bits of port B (inputs)
                    clr       VIA_ORB_IRB,x     and set the corresonding values to 0
                    ldx       #D.RowState       point to the row state globals
                    ldd       #$FF*256+9        A = $FF, B = 9 (bytes to set)
l@                  sta       ,x+               set byte at X with $FF and increment X
                    decb                        decrement B
                    bne       l@                keep doing until B is 0
Term                rts                 return to the caller

* F256K key table
HOME                set       'A-64
END                 set       'E-64
DEL                 set       'D-64
ESC                 set       'C-64
TAB                 set       'I-64
ENTER               set       'M-64
BKSP                set       'H-64
BREAK               set       'E-64
XLINE               set       'X-64


* Arrow keys reside in $E0-$EF and are treated special by the code.
UP                  set       $EC
DOWN                set       $EA
LEFT                set       $E8
RIGHT               set       $E9

* Function keys just return some ASCII value
F1                  set       $A1
F2                  set       $A2
F3                  set       $A3
F4                  set       $A4
F5                  set       $A5
F6                  set       $A6
F7                  set       $A7
F8                  set       $A8

* Any key code above $EF is considered a modifier key
META                set       $F0
LCTRL               set       $F1
CAPS                set       $F2
LSHIFT              set       $F3
RALT                set       $F4
RSHIFT              set       LSHIFT
INS                 set       15

KySnsTbl            fcb       LSHIFT,SHIFTBIT
			     fcb       RALT,ALTBIT
				fcb       LCTRL,CTRLBIT
				fcb       C$SPAC,SPACEBIT
				fcb       UP,UPBIT
				fcb       DOWN,DOWNBIT
				fcb       LEFT,LEFTBIT
				fcb       RIGHT,RIGHTBIT
				fcb       0
				
F256KKeys
                    fcb       BREAK,'q,META,C$SPAC,'2,LCTRL,BKSP,'1
                    fcb       '/,TAB,RALT,RSHIFT,$01,'','],'=
                    fcb       ',,'[,';,'.,CAPS,'l,'p,'-
                    fcb       'n,'o,'k,'m,'0,'j,'i,'9
                    fcb       'v,'u,'h,'b,'8,'g,'y,'7
                    fcb       'x,'t,'f,'c,'6,'d,'r,'5
                    fcb       LSHIFT,'e,'s,'z,'4,'a,'w,'3
                    fcb       UP,F5,F3,F1,F7,LEFT,ENTER,BKSP
                    fcb       0,RIGHT,0,0,0,0,0,DOWN

F256KShiftKeys 
                    fcb       BREAK,'Q,META,C$SPAC,'@,LCTRL,$18,'!
                    fcb       '?,TAB,RALT,RSHIFT,$01,'",'},'+
                    fcb       '<,'{,':,'>,CAPS,'L,'P,'_
                    fcb       'N,'O,'K,'M,'),'J,'I,'(
                    fcb       'V,'U,'H,'B,'*,'G,'Y,'&
                    fcb       'X,'T,'F,'C,'^,'D,'R,'%
                    fcb       LSHIFT,'E,'S,'Z,'$,'A,'W,'#
                    fcb       UP,F6,F4,F2,F8,LEFT,ENTER,$18
                    fcb       0,RIGHT,0,0,0,0,0,DOWN

                    emod
eom                 equ       *
                    end
