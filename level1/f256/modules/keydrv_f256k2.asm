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
*
*  4       2025/09/12   John A. Federico
* Modified driver for F256K2 Optical Keyboard


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
                    lbra      AltISR
		    lbra      KeyRepeat
* Alternate IRQ routine - Called from vtio at 60Hz to scan the keyboard.
AltISR              ldx       #OKB.Base          point to optical keyboard base
                    tst       OKB.Stat,x         check FIFO status
                    beq       ReadFIFOData
ex@                 rts                          return to the caller



********************************************************************
* The key repeat timer (V.KRTimer) is decremented in vtio AltISR
* If V.LastCh!=0 and V.KRTimer=0 then AltISR jumps to lbra KeyRepeat
* in Start, above, which calls this routine.  This routine:
* (1) Checks to make sure the keyboard buffer is empty, if not empty, then
*     another key has been pressed
* (2) Checks that LastCh > 0, if >0 then repeat the key and call
*     BufferChar to put in buffer, and HandleSignals to send the signal to
*     vtio to process the repeated character.
*  The timer/LastCh are set in BufferChar and reset on a keyup event in
*  ProcessRow.  In BufferChar, the timer is set to KEYDELAY1 OR KEYDELAY
*  based on whether this is the first keypress or a repeated keypress.
*  puparrows also has some extra code to make sure the proper character is
*  passed to ProcessRow to reset the key repeat for the arrows.
*  The constants KEYDELAY (=30) and KEYDELAY1(=5) are defined in f256vtio.d
*  This is the number of ticks for the initial delay and repeat key delay.
*  V.LastCh and V.KRTimer are also in f256vtio.d.
KeyRepeat           ldx       #OKB.Base          point to optical keyboard base
                    tst       OKB.Stat,x         check FIFO status
                    beq       exitkr@
		    lda	      V.LastCh,u
		    beq	      exitkr@
		    lbsr      BufferChar
		    lbsr      HandleSignals
exitkr@             rts


********************************************************************
* Read all 8 pairs of bytes from FIFO and process
* 8 pairs represent 9 row keyboard matrix (Rows 0-8)
* This reads the columns for rows 0-7. (8 pairs of bytes)
* Row 8 is contained in the first bit of the row byte.
* Build Row 8 a bit at a time from the first bit of row byte for Rows 0-7, 
* then run it through the loop at the end to process Row #8
*
* OKB.Base = base address of Optical Keyboard $FE10
* D.RowState = historical value (last value) for the column bits
* for a particular row - used to detect changed keys
* F256KKyDn = raw column bits and is used to determine
* KeyUp/Down state.
*
* Get the column bits for Row X, eora with historical bits to
* find the changed bits only.  Then act on those changed bits.
* KeyDown will buffer key.  Ignore keyup for non-modifier keys.
* Process keyup for modifier keys.
*
* Optical keyboard fills FIFO with matrix on keyup or keydown
* in 2 byte pais:
*  |4bits|4bits|  |          8 bits         |
*  |Row# |Row8 |  |Row Maxtrix Bits Cols 0-7| 
********************************************************************
ReadFIFOData        lda	      V.LastCh,u
		    sta	      V.CurLastCh,u
		    clr	      V.LastCh,u
                    ldx       #OKB.Base          point to optical keyboard
                    ldb       #0                 8 pairs to read
                    ldy       #D.RowState        historical column bits
                    leas      -1,s               store Row8 columns on stack
                    clr       ,s                 clear Row8 columns
read_loop@          lda       OKB.Data,x         read row byte
                    rora                         build Row8 by rotating bit
                    ror       ,s                 onto the stack
loadcol@            lda       OKB.Data,x         read column byte  
doRow8@             sta       D.F256KKyDn        store in current column keys down
                    eora      b,y
                    beq       skipprocess@       if the column is 0, skip processing
                    lbsr      ProcessRow         column is not zero, process keydown
skipprocess@        lda       D.F256KKyDn        load raw column value
cont@               sta       b,y                store as historical value
                    incb                         increment to last row
                    cmpb      #8                 
                    bhi       row9end@           if 9, then end
                    bne       read_loop@         if not 8, then keep looping
                    puls      a                  if 8, pull Row8 from stack and process 
                    bra       doRow8@
row9end@	    lda	      V.CurLastCh,u
 		    sta	      V.LastCh,u
           	    rts

********************************************************************
* ProcessRow - process changes in keyboard row
* b=row a=eora changed bits
* Process 1 bit at a time, if keydown, then buffer
* If modifer key, handle keyup and keydown

ProcessRow          pshs      d,x,y
                    lda       D.KySns           check SHIFT to set correct key table
                    bita      #SHIFTBIT
                    beq       noshift@
                    leax      F256KShiftKeys,pcr
                    bra       rowcomp@
noshift@            leax      F256KKeys,pcr     get the current key index
rowcomp@            lda       ,s                get the eora changed bits
                    lslb                        multiply row x8 to get the offset
                    lslb
                    lslb        
                    abx                         x now contains row offset for key table
                    ldb       #0                loop through and process bits
loop@               lsla
                    bcc       nextbit@          if bit is clear, move to next bit
                    pshs      a
                    lda       b,x               Get the key from the table
                    cmpa      #$EF              Modifier keys defined as $F0 and greater
                    bhi       processmodifier   if modifier,process modifier key
                    cmpa      #$DF
                    bhi       processarrows
                    lbsr      KeyDownTest       check if key is down or up
                    bcc       rstkeyrpt@        keyup - ignore
bufferit@           lbsr      BufferChar        keydown - buffer the character
                    lbsr      HandleSignals     signal key in buffer
		    bra	      skipbuffer@
rstkeyrpt@	    cmpa      V.CurLastCh,u	on key up cmp key to last char
		    bne	      skipbuffer@       if not the same, skip 
		    clr	      V.CurLastCh,u        if same, clear for key up
		    lda	      #KEYDELAY1	reset timer to initial key delay
		    sta	      V.KRTimer,u
skipbuffer@         puls      a
nextbit@            incb
                    cmpb      #8
                    bne       loop@
                    puls      d,x,y,pc
********************************************************************
* Process Modifier - handle modifier keys and KeySns
processmodifier     lbsr      KeyDownTest       check if modifier is KeyUp/Down
                    bcc       pupmodifier       KeyUp - clear modifier bits
                    pshs      d,x
                    ldb       D.KySns           set KySns keydown modifier bits
                    cmpa      #META             check for META key
                    blo       stdkey@           if less than, then process std mod keys
                    beq       doMeta@           if equal, then process meta key
                    bhi       doCapslock@       if higher, then process caps lock
doMeta@             bra       moddone@          process meta key
doCapslock@         lda       V.CAPSLck,u       load caps lock bit
                    eora      #SHIFTBIT         invert caps lock state bit
                    sta       V.CAPSLck,u       save it back
                    bne       doled@            if >1, then turn on led
                    andb      #^SHIFTBIT        if not, then turn off shift bit
doled@              lda       SYS0              get led bits
                    eora      #SYS_CAP_EN       toggle caps lock led
                    sta       SYS0              save led bits
                    bra       moddone@          done
stdkey@             suba      #$F0              std keys, subtract to get index
                    leax      ModTbl,pcr        load table
                    orb       a,x               or the bits from the table
moddone@            stb       D.KySns           store the KySNS
                    puls      d,x
                    bra       skipbuffer@
********************************************************************
* Process Modifier Up - handle modifier keys and KeySns
pupmodifier         pshs      d,x
                    ldb       D.KySns           set KySns keyup modifier bits
                    cmpa      #META             check for meta key
                    blo       stdupkey@         if lower, then process std modifityh
                    beq       doMetaUp@         if equal process meta-up
                    bra       modupdone@        
doMetaUp@           bra       modupdone@                    
stdupkey@           suba      #$F0              subtract to get index       
                    leax      ModUpTbl,pcr      load table
                    andb      a,x               get value from table
modupdone@          stb       D.KySns           save new KySns
                    puls      d,x
                    bra       skipbuffer@
********************************************************************
* Process Arrows - handle arrow keys and KeySns
* Set KySns flags for arrows and translate arrow to appropriate key value
processarrows       bsr       KeyDownTest       check if modifier is KeyUp/Down
                    bcc       puparrows         KeyUp - clear modifier bits
                    pshs      d,x
                    ldb       D.KySns           set KySns keydown modifier bits
                    leax      ModChrTbl,pcr     get ModChr table
                    suba      #$E0              subtract to get index
                    orb       a,x               set KySns value
                    stb       D.KySns           store KySns
                    leax      ChrTbl,pcr        change to char table
                    lda       a,x               get arrow character
                    sta       ,s                replace stack value
arrowdone@          puls      d,x               
                    lbra      bufferit@         buffer arrow character
********************************************************************
* Process Arrows Up - handle arrow    keys and KeySns
puparrows           pshs      d,x
                    ldb       D.KySns           set KySns keyup modifier bits
                    leax      ModChrUpTbl,pcr   get ModChrUp table
                    suba      #$E0              subtract to get index
                    andb      a,x               and KySns with up value to erase
                    stb       D.KySns           store KySns
		    leax      ChrTbl,pcr        change to char table    (need this to reset key repeat)
                    lda       a,x               get arrow character
                    sta       ,s                replace stack value
arrowupdone@        puls      d,x               
                    lbra      rstkeyrpt@       skip buffering on keyup
********************************************************************
* KeyDown Test - check bit in original keypress
* on entry b = bit to test, raw row value is stored in D.F256KKyDn
* Carry  1=keydown 0=keyup
KeyDownTest         pshs      d,x
                    leax      keybits,pcr
                    lda       D.F256KKyDn
                    andcc     #$FE
                    bita      b,x
                    beq       end@
                    orcc      #$01
end@                puls      d,x,pc                  
                 
keybits             fcb       $80,$40,$20,$10,$08,$04,$02,$01

********************************************************************
* BufferChar - take the char in a and place in buffer
* Advance the circular buffer one character.

BufferChar          pshs      d,x,y
		    cmpa      V.CurLastCh,u
		    beq	      shortdelay@
		    ldb	      #KEYDELAY1
		    bra	      keyrepeat@
shortdelay@	    ldb	      #KEYDELAY		    
keyrepeat@	    sta	      V.CurLastCh,u	 store character in last char for key repeat
		    stb	      V.KRTimer,u	 reset keyrepeat timer
                    ldb       V.IBufH,u          get buffer head pointer in B
                    leay      V.KSBuf,u
                    leay      b,y
                    leax      V.InBuf,u          point X to the input buffer
                    abx                          X now holds address of the head pointer
                    lbsr      IncNCheck          increment the pointer and check for tail wrap
                    cmpb      V.IBufT,u          is B at the tail? (if so, the input buffer is full)
                    beq       bye@               branch if the input buffer is full (drop the character)
                    stb       V.IBufH,u          update the buffer head pointer
                    tst       V.CAPSLck,u        test if caps lock is on
                    beq       checkctrl@         if not, then go to CTRL check
                    bsr       CapAlpha           if on, then capitalize character if alpha char
checkctrl@          ldb       D.KySns            check for CTRLBIT
                    bitb      #CTRLBIT
                    beq       checkalt@
                    bsr       CapAlpha
                    bcc       checkalt@
                    suba      #$40               subtract #$40 if CTRL down and a-z pressed
                    sta       ,s
		    bra	      bufferit@
checkalt@	    bitb      #ALTBIT
		    beq	      bufferit@
		    bsr	      CapAlpha
		    bcc	      checknum@
		    adda      #$40
		    bra	      bufferit@
checknum@	    bsr	      AltNum
bufferit@           sta       ,x                 place the character in the buffer
* Store the KySns in the KSBuf
BufferKSns          lda       D.KySns
                    sta       ,y                 place the D.KySns in the KS buffer
bye@                puls      d,x,y
                    rts                          return

* Check if we need to wrap around tail pointer to zero.
IncNCheck           incb                         increment the next character pointer
                    cmpb      #KBufSz-1          are we pointing to the end of the buffer?
                    bls       ex@                branch if not
                    clrb                         else clear the pointer (wraps to head)
ex@                 rts

********************************************************************
* cap alpha - if this is an alpha character, capitalize it
* if alpha char then also set cc to 1, otherwise 0
CapAlpha            pshs      a
                    anda      #$5F               make character uppercase
                    cmpa      #$41               compare to 'A'
                    blo       notalpha@
                    cmpa      #$5A               compare to 'Z'
                    bhi       notalpha@
                    sta       ,s                 if alpha, change stored stack value
                    orcc      #$01               set cc to 1
                    puls      a,pc
notalpha@           andcc     #$FE               if not alpha, set cc to 0
                    puls      a,pc

********************************************************************
* cap alpha - if this is an alpha character, capitalize it
* if alpha char then also set cc to 1, otherwise 0
AltNum              pshs      x
                    cmpa      #$30               compare to '0'
                    blo       notnum@
                    cmpa      #$39               compare to '9'
                    bhi       notnum@
		    suba      #$30
		    leax      AltNumTbl,pcr
		    lda	      a,x
notnum@             puls      x,pc

AltNumTbl	    fcb	      $5C,0,0,0,$A3,$A4,0,$7E,$60,$7C
********************************************************************
* HandleSignals - Once something is in the buffer, wake a process
* to receive the input and handle pause, interrupt and abort keys

* Check for pause character, and create pause request               
HandleSignals       pshs      d,x
                    cmpa      V.PCHR,u           pause character?
                    bne       int@               branch for interrrupt/abort char
                    ldx       V.DEV2,u           else get dev2 statics
                    beq       wake@              branch if none
                    sta       V.PAUS,x           else set pause request
* Wake up any process if it's sleeping waiting for input.
wake@               ldb       #S$Wake            get the wake signal
                    lda       V.WAKE,u           is there a process asleep waiting for input?
noproc@             beq       nextrow            branch if not
                    clr       V.WAKE,u           else clear the wake flag
send@               os9       F$Send             and send the signal in B
nextrow             puls      d,x
                    rts
* Handle Interrupt/Abort Character (like CTRL+C or Esc)
int@
                    ldb       #S$Intrpt          get the interrupt signal
                    cmpa      V.INTR,u           is our character same as the interrupt signal?
                    beq       getlproc@          branch if it's the same
                    ldb       #S$Abort           get the abort signal
                    cmpa      V.QUIT,u           is our character same as the abort signal?
                    bne       CheckSig           branch if it isn't
getlproc@           lda       V.LPRC,u           else get the ID of the last process to use this device
                    bra       noproc@            branch
* Signal on Data Ready
CheckSig            lda       <V.SSigID,u        send signal on data ready?
                    beq       wake@              no, just go wake up the process
                    ldb       <V.SSigSg,u        else get the signal code
                    clr       <V.SSigID,u        clear signal ID
                    bra       send@


********************************************************************
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
Init                clr       V.CAPSLck,u
		    clr	      V.LastCh,u
		    lda	      #KEYDELAY1
		    sta	      V.KRTimer,u
                    ldx       #D.RowState        point to the row state globals
                    ldb       #9                 B = 9 (bytes to set)
l@                  clr       ,x+                set byte at X with $FF and increment X
                    decb                         decrement B
                    bne       l@                 keep doing until B is 0
Term                rts                          return to the caller

* F256K key table
HOME                set       $01
END                 set       $03
DEL                 set       $04
ESC                 set       $1B
TAB                 set       $09
ENTER               set       $0D
BKSP                set       $08
BREAK               set       $05
INS                 set       $0F


* Arrow keys reside in $E0-$EF and are treated special by the code.
UP                  set       $0C
DOWN                set       $0A
LEFT                set       $08
RIGHT               set       $09

kUP                 set       $E0
kDOWN               set       $E1
kLEFT               set       $E2
kRIGHT              set       $E3
kSPACE              set       $E4

ModChrTbl           fcb       UPBIT,DOWNBIT,LEFTBIT,RIGHTBIT,SPACEBIT
ModChrUpTbl         fcb       ^UPBIT,^DOWNBIT,^LEFTBIT,^RIGHTBIT,^SPACEBIT
ChrTbl              fcb       UP,DOWN,LEFT,RIGHT,C$SPAC

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

LCTRL               set       $F0
LSHIFT              set       $F1
RALT                set       $F2
RSHIFT              set       LSHIFT
META                set       $F3
CAPS                set       $F4

ModTbl              fcb       CTRLBIT,SHIFTBIT,ALTBIT
ModUpTbl            fcb       ^CTRLBIT,^SHIFTBIT,^ALTBIT

F256KKeys
                    fcb       kUP,F5,F3,F1,F7,kLEFT,ENTER,BKSP
                    fcb       LSHIFT,'e,'s,'z,'4,'a,'w,'3
                    fcb       'x,'t,'f,'c,'6,'d,'r,'5
                    fcb       'v,'u,'h,'b,'8,'g,'y,'7
                    fcb       'n,'o,'k,'m,'0,'j,'i,'9
                    fcb       ',,'[,';,'.,CAPS,'l,'p,'-
                    fcb       '/,TAB,RALT,RSHIFT,$01,'','],'=
                    fcb       BREAK,'q,META,C$SPAC,'2,LCTRL,BKSP,'1
                    fcb       0,kRIGHT,0,0,0,0,0,kDOWN

F256KShiftKeys 
                    fcb       kUP,F6,F4,F2,F8,kLEFT,ENTER,$18
                    fcb       LSHIFT,'E,'S,'Z,'$,'A,'W,'#
                    fcb       'X,'T,'F,'C,'^,'D,'R,'%
                    fcb       'V,'U,'H,'B,'*,'G,'Y,'&
                    fcb       'N,'O,'K,'M,'),'J,'I,'(
                    fcb       '<,'{,':,'>,CAPS,'L,'P,'_
                    fcb       '?,TAB,RALT,RSHIFT,$01,'",'},'+               
                    fcb       BREAK,'Q,META,C$SPAC,'@,LCTRL,$18,'!
                    fcb       0,kRIGHT,0,0,0,0,0,kDOWN

                    emod
eom                 equ       *
                    end
