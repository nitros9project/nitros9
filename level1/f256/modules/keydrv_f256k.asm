********************************************************************
* keydrv - Keyboard subroutine module for F256 VTIO
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  1       2024/02/17  Boisy G. Pitre
* Started.

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
                    lda       #%10000000
loop@               sta       VIA_ORA_IRA,x save the row scan value to the VIA1 output
                    pshs      a save it on the stack for now
                    lda       VIA_ORB_IRB,x get the column value for this row
                    tfr       a,b save a copy to B
                    eora      ,y XOR with the last row state value
                    beq       next@ branch if there's no change
                    bsr       HandleRow else one or more keys for this row have changed direction - handle it
next@               leay      1,y advance to the next row state value
                    puls      a restore the row scan value we read from VIA1
                    orcc      #Carry set the carry flag so it will rotate in the upper 8 bits
                    rora rotate A to the right
                    bcs       loop@ branch if the carry is set to continue
ex@                 rts return to the caller

* Entry:
*    A = The keys in the row that have changed since the last scan.
*    B = The up/down state of keys in the row.
HandleRow           pshs      d,x,y
                    stb       ,y       save off new state to current row
                    ldb       #8       load counter
kl@                 lsla               shift leftmost bit into the carry
                    bcs       kchg@    branch if carry set (key state changed)
                    lsl       1,s      shift B on stack (up/down state)
nextbit             decb               decrement the counter
                    bne       kl@      continue if more
                    puls      d,x,y,pc restore and return
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
                    beq       noshift@              branch of so
                    leax      F256KShiftKeys,pcr
noshift@            abx
                    lda       2,s
r@                  rola
                    bcs       g@
                    leax      1,x
                    bra       r@
g@
                    lda       ,x
* A = ASCII character
* is it key up or key down?
                    lsl       3,s     shift B on stack (up/down state)
                    bcc       keydown@ if carry set, key is going up -- ignore it
* key is up -- process character
keyup@              cmpa      #LSHIFT
                    bne       isitmeta@
                    ldb       D.KySns
                    andb      #^SHIFTBIT
                    stb       D.KySns
                    lbra      repex
isitmeta@           cmpa      #META
                    bne       isitctrl@
                    clr       V.META,u
                    lbra      repex
isitctrl@           cmpa      #LCTRL
                    bne       isitalt@
                    ldb       D.KySns
                    andb      #^CTRLBIT
                    stb       D.KySns
                    lbra      repex
isitalt@            cmpa      #RALT                                    
                    lbne      repex
                    ldb       D.KySns
                    andb      #^ALTBIT
                    stb       D.KySns
                    lbra      repex
* key is down -- process character
keydown@            tsta
                    lbeq       CheckSig
                    cmpa      #LSHIFT
                    
                    bne       isitmeta@
                    ldb       D.KySns
                    orb       #SHIFTBIT
                    stb       D.KySns
                    lbra      repex
isitmeta@           cmpa      #META
                    bne       isitctrl@
                    sta       V.META,u
                    lbra      repex
isitctrl@           cmpa      #LCTRL
                    bne       isitalt@
                    ldb       D.KySns
                    orb       #CTRLBIT
                    stb       D.KySns
                    lbra      repex
isitalt@            cmpa      #RALT                                    
                    bne       isitcaps@
                    ldb       D.KySns
                    orb       #ALTBIT
                    stb       D.KySns
                    lbra      repex
isitcaps@           cmpa      #CAPS
                    bne       z@
                    com       V.CAPSLck,u
* Set/Clear CAPS Lock LED
                    ldx       #SYS0          
                    ldb       ,x
                    tst       V.CAPSLck,u
                    beq       ledoff@
ledon@              orb       #SYS_CAP_EN
                    bra       ledsave@
ledoff@             andb      #^SYS_CAP_EN
ledsave@            stb       ,x
                    lbra      repex     
* Handle CAPS LOCK engaged
z@                  tst       V.CAPSLck,u
                    beq       z1@
                    cmpa      #'a
                    blo       z1@
                    cmpa      #'z
                    bhi       z1@
                    suba      #$20
* Handle CTRL down                    
z1@                 ldb       D.KySns
                    bitb      #CTRLBIT
                    beq       z2@
                    anda      #$5F
                    suba      #$40
* Handle ALT down
z2@                 ldb       D.KySns
                    bitb      #ALTBIT
                    beq       z3@
                    anda      #$5F
                    adda      #$40
* Handle META down
z3@                 tst       V.META,u
                    beq       BufferChar
                    leax      MetaTab,pcr
zl@                 tst       ,x
                    beq       BufferChar
                    cmpa      ,x++
                    bne       zl@
                    lda       -1,x

* Advance the circular buffer one character.
BufferChar          ldb       V.IBufH,u           get buffer head pointer in B
                    leax      V.InBuf,u           point X to the input buffer
                    abx                           X now holds address of the head pointer
* Check if we need to wrap around tail pointer to zero.
IncNCheck           incb                          increment the next character pointer
                    cmpb      #KBufSz-1           are we pointing to the end of the buffer?
                    bls       next@               branch if not
                    clrb                          else clear the pointer (wraps to head)
next@               cmpb      V.IBufT,u           is B at the tail? (if so, the input buffer is full)
                    beq       bye@                branch if the input buffer is full (drop the character)
                    stb       V.IBufH,u           update the buffer head pointer
                    sta       ,x                  place the character in the buffer
bye@                

                    ldb       #S$Intrpt           get the interrupt signal
                    cmpa      V.INTR,u            is our character same as the interrupt signal?
                    beq       getlproc@           branch if it's the same
                    ldb       #S$Abort            get the abort signal
                    cmpa      V.QUIT,u            is our character same as the abort signal?
                    bne       CheckSig            branch if it isn't
getlproc@           lda       V.LPRC,u            else get the ID of the last process to use this device
                    bra       noproc@             branch
* Check signal
CheckSig
                    lda       <V.SSigID,u         send signal on data ready?
                    beq       wake@               no, just go wake up the process
                    ldb       <V.SSigSg,u         else get the signal code
                    clr       <V.SSigID,u         clear signal ID
                    bra       send@
* Wake up any process if it's sleeping waiting for input.
wake@               ldb       #S$Wake             get the wake signal
                    lda       V.WAKE,u            is there a process asleep waiting for input?
noproc@             beq       repex                 branch if not
                    clr       V.WAKE,u            else clear the wake flag
send@               os9       F$Send              and send the signal in B
repex               puls      d
                    lbra       nextbit

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
Init                ldx     #VIA1.Base
                    clr     VIA_IER,x
                    lda     #$FF    
                    sta     VIA_DDRA,x
                    sta     VIA_ORA_IRA,x                    
                    clr     VIA_DDRB,x
                    ldx     #VIA0.Base
                    clr     VIA_IER,x
                    lda     #$80    
                    sta     VIA_DDRA,x
                    sta     VIA_ORA_IRA,x                    
                    clr     VIA_DDRB,x                 
                    ldx     #D.RowState
                    ldd     #$FF*256+9
l@                  sta     ,x+
                    decb
                    bne     l@
Term                rts                           return to the caller

* F256K key table
HOME set   'A'-64
END set    'E'-64
UP set     'P'-64
DOWN set   'N'-64
LEFT set   'B'-64
RIGHT set  'F'-64
DEL set    'D'-64
ESC set    'C'-64
TAB set    'I'-64
ENTER set  'M'-64
BKSP set   'H'-64
BREAK set  'E'-64
XLINE  set    'X'-64

F1 set $F1
F2 set $F2
F3 set $F3
F4 set $F4
F5 set $F5
F6 set $F6
F7 set $F7
F8 set $F8        
RSHIFT set LSHIFT
META set $FB
LCTRL set $FC
CAPS set $FD
LSHIFT set $FE
RALT set $FF
INS set 15

F256KKeys fcb  BREAK,'q,META,$20,'2,LCTRL,BKSP,'1
        fcb  '/,TAB,RALT,RSHIFT,HOME,'','],'=
        fcb  ',,'[,';,'.,CAPS,'l,'p,'-
        fcc  "nokm0ji9"
        fcc  "vuhb8gy7"
        fcc  "xtfc6dr5"
        fcb  LSHIFT,'e,'s,'z,'4,'a,'w,'3
        fcb  UP,F5,F3,F1,F7,LEFT,ENTER,BKSP
        fcb  DOWN,RIGHT,0,0,0,0,RIGHT,DOWN

F256KShiftKeys  fcb  ESC,'Q,META,32,'@,LCTRL,XLINE,'!
        fcb  '?,RALT,LEFT,RSHIFT,END,34,'},'+
        fcb  '<,'{,':,'>,CAPS,'L,'P,'_
        fcc  "NOKM)JI("
        fcc  "VUHB*GY&"
        fcc  "XTFC^DR%"
        fcb  LSHIFT,'E,'S,'Z,'$,'A,'W,'#
        fcb   UP,F6,F4,F2,F8,LEFT,ENTER,INS
        fcb  DOWN,RIGHT,0,0,0,0,RIGHT,DOWN

                    emod
eom                 equ       *
                    end
