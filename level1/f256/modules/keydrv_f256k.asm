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

                    use       defsfile
                    use       f256vtio.d

tylg                set       Systm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

size                equ       V.Last

                    fcb       UPDAT.+EXEC.

name                fcs       /keydrv/
                    fcb       edition

                    org       V.KeyDrvStat
V.META              rmb       1

* keydrv has three 3-byte entry points:
*   - Init
*   - Term
*   - AltISR (called by VTIO at the 60Hz interval)
start               lbra      Init
                    lbra      Term
*                    lbra      AltISR

* Alternate IRQ routine - Called from vtio at 60Hz to scan the keyboard.
AltISR              ldx       #VIA1.Base get the VIA1 base address
                    ldy       #D.RowState point to the row state global area
                    lda       #%01111111 initialize the accumulator with the row scan value
                    bsr       loop@
* Handle down and right arrow
                    ldx       #VIA0.Base
                    lda       #%11111110
loop@               sta       VIA_ORB_IRB,x save the row scan value to the VIA1 output
                    pshs      a         save it on the stack for now
                    lda       VIA_ORA_IRA,x get the column value for this row
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
                    pshs      d
* Get character from table
                    tfr       y,d
                    subd      #D.RowState
                    lda       #8
                    mul
                    leax      F256KKeys,pcr
                    lda       D.KySns
                    bita      #SHIFTBIT
                    beq       noshift@  branch of so
                    leax      F256KShiftKeys,pcr
noshift@            abx
                    lda       2,s
r@                  rola
                    bcs       g@
                    leax      1,x
                    bra       r@
g@
                    lda       ,x
* A = Key character
* is it key up or key down?
                    lsl       3,s       shift B on stack (up/down state)
                    bcc       keydown@  if carry set, key is going up -- ignore it
* Key is going UP
keyup@              cmpa      #META			is this the META key
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
keydown@            cmpa      #META			is this the META key?
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
Init                ldx       #VIA1.Base
                    clr       VIA_IER,x
                    lda       #%11111111
                    sta       VIA_DDRB,x
                    sta       VIA_ORB_IRB,x
                    clr       VIA_DDRA,x
                    ldx       #VIA0.Base
                    clr       VIA_IER,x
                    lda       #%00000011
                    sta       VIA_DDRB,x
                    sta       VIA_ORB_IRB,x
                    clr       VIA_DDRA,x
                    ldx       #D.RowState
                    ldd       #$FF*256+9
l@                  sta       ,x+
                    decb
                    bne       l@
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
                    fcb       BREAK,'/,',,'n,'v,'x,LSHIFT,UP
                    fcb       'q,TAB,'[,'o,'u,'t,'e,F5
                    fcb       META,RALT,';,'k,'h,'f,'s,F3
                    fcb       C$SPAC,RSHIFT,'.,'m,'b,'c,'z,F1
                    fcb       '2,HOME,CAPS,'0,'8,'6,'4,F7
                    fcb       LCTRL,'','l,'j,'g,'d,'a,LEFT
                    fcb       BKSP,'],'p,'i,'y,'r,'w,ENTER
                    fcb       '1,'=,'-,'9,'7,'5,'3,BKSP

F256KShiftKeys 
                    fcb       BREAK,'?,'<,'n,'v,'x,LSHIFT,UP
                    fcb       'Q,TAB,'{,'O,'U,'T,'E,F6
                    fcb       META,RALT,':,'K,'H,'F,'S,F4
                    fcb       C$SPAC,RSHIFT,'>,'M,'B,'C,'Z,F2
                    fcb       '@,HOME,CAPS,'),'*,'^,'$,F8
                    fcb       LCTRL,'",'L,'J,'G,'D,'A,$18
                    fcb       $18,'},'P,'I,'Y,'R,'W,ENTER
                    fcb       '!,'+,'_,'(,'&,'%,'#,DEL

                    emod
eom                 equ       *
                    end
